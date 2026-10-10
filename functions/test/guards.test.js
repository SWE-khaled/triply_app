/**
 * Unit tests for `../lib/guards.js` — the exact decision logic imported by
 * `../index.js`. Run WITHOUT any emulator: `node --test test/guards.test.js`
 * (from `functions/`). Covers P0 items 4–7 at the logic layer; Firestore
 * Rules behavior itself is proven separately by `test/rules.test.js`
 * against the Firestore emulator (see test evidence in the audit doc).
 */
const {describe, it} = require('node:test');
const assert = require('node:assert/strict');
const g = require('../lib/guards');

describe('canClientCancel (mirrors rules bookings update)', () => {
  it('allows unpaid active bookings', () => {
    assert.deepEqual(g.canClientCancel({status: 'pending', paymentStatus: 'pending'}), {ok: true});
    assert.deepEqual(g.canClientCancel({status: 'confirmed', paymentStatus: 'failed'}), {ok: true});
    assert.deepEqual(g.canClientCancel({status: 'pending'}), {ok: true}); // legacy default
  });
  it('rejects paid bookings (must use cancelBooking callable)', () => {
    assert.deepEqual(
      g.canClientCancel({status: 'confirmed', paymentStatus: 'succeeded'}),
      {ok: false, reason: 'paid-use-callable'},
    );
  });
  it('rejects non-active bookings', () => {
    for (const s of ['cancelled', 'completed', 'whatever']) {
      assert.equal(g.canClientCancel({status: s, paymentStatus: 'pending'}).ok, false);
    }
  });
});

describe('canConfirmAfterVerify (no resurrection, replay-safe)', () => {
  it('confirms pending+pending', () => {
    assert.deepEqual(
      g.canConfirmAfterVerify({bookingStatus: 'pending', paymentStatus: 'pending'}),
      {ok: true},
    );
  });
  it('dedupes already-succeeded without side effects', () => {
    assert.deepEqual(
      g.canConfirmAfterVerify({bookingStatus: 'confirmed', paymentStatus: 'succeeded'}),
      {ok: true, deduped: true},
    );
  });
  it('blocks cancelled/completed/confirmed-unpaid transitions', () => {
    assert.deepEqual(
      g.canConfirmAfterVerify({bookingStatus: 'cancelled', paymentStatus: 'pending'}),
      {ok: false, reason: 'invalid-transition'},
    );
    assert.deepEqual(
      g.canConfirmAfterVerify({bookingStatus: 'completed', paymentStatus: 'pending'}),
      {ok: false, reason: 'invalid-transition'},
    );
    assert.deepEqual(
      g.canConfirmAfterVerify({bookingStatus: 'confirmed', paymentStatus: 'pending'}),
      {ok: false, reason: 'invalid-transition'},
    );
  });
});

describe('paymobOrderCoversBooking (amount + currency, never client trust)', () => {
  const base = {amount_cents: 1260000, paid_amount_cents: 1260000, currency: 'EGP'};
  it('accepts a fully-paid matching order', () => {
    assert.deepEqual(
      g.paymobOrderCoversBooking({order: base, expectedCents: 1260000, currency: 'EGP'}),
      {ok: true},
    );
  });
  it('accepts captured / provider-marked-paid orders', () => {
    assert.deepEqual(
      g.paymobOrderCoversBooking({
        order: {...base, paid_amount_cents: 0, is_captured: true},
        expectedCents: 1260000, currency: 'EGP',
      }),
      {ok: true},
    );
    assert.deepEqual(
      g.paymobOrderCoversBooking({
        order: {...base, paid_amount_cents: 0, payment_status: 'paid'},
        expectedCents: 1260000, currency: 'EGP',
      }),
      {ok: true},
    );
  });
  it('rejects a smaller order (underpayment attack)', () => {
    assert.deepEqual(
      g.paymobOrderCoversBooking({
        order: {...base, amount_cents: 42050, paid_amount_cents: 42050},
        expectedCents: 1260000, currency: 'EGP',
      }),
      {ok: false, reason: 'amount-mismatch'},
    );
  });
  it('rejects foreign-currency orders', () => {
    assert.deepEqual(
      g.paymobOrderCoversBooking({order: {...base, currency: 'USD'}, expectedCents: 1260000, currency: 'EGP'}),
      {ok: false, reason: 'currency-mismatch'},
    );
  });
  it('rejects unpaid orders and missing orders', () => {
    assert.deepEqual(
      g.paymobOrderCoversBooking({
        order: {...base, paid_amount_cents: 0}, expectedCents: 1260000, currency: 'EGP',
      }),
      {ok: false, reason: 'not-paid'},
    );
    assert.deepEqual(
      g.paymobOrderCoversBooking({order: null, expectedCents: 1, currency: 'EGP'}),
      {ok: false, reason: 'no-order'},
    );
  });
  it('matches Dart minor-unit math', () => {
    assert.equal(g.toMinorUnits(12600), 1260000);
    assert.equal(g.toMinorUnits(420.5), 42050);
  });
});

describe('validIdempotencyKey', () => {
  it('requires a reasonably long opaque string without slashes', () => {
    assert.equal(g.validIdempotencyKey('u1_t1_2026-11-02_2'), true);
    assert.equal(g.validIdempotencyKey('short'), false);
    assert.equal(g.validIdempotencyKey(''), false);
    assert.equal(g.validIdempotencyKey('a/bcdefgh'), false);
    assert.equal(g.validIdempotencyKey(null), false);
    assert.equal(g.validIdempotencyKey('x'.repeat(161)), false);
  });
});

describe('classifyKeyConflict (no cross-user disclosure)', () => {
  it('proceeds when the key is new', () => {
    assert.deepEqual(g.classifyKeyConflict({keyExists: false}), {action: 'proceed'});
  });
  it('dedupes for the owning caller with the booking id', () => {
    assert.deepEqual(
      g.classifyKeyConflict({keyExists: true, keyTouristId: 'u1', callerUid: 'u1', bookingId: 'b9'}),
      {action: 'dedupe', bookingId: 'b9'},
    );
  });
  it('denies a different caller WITHOUT revealing the booking', () => {
    const r = g.classifyKeyConflict({keyExists: true, keyTouristId: 'u1', callerUid: 'u2', bookingId: 'b9'});
    assert.equal(r.action, 'deny');
    assert.ok(!('bookingId' in r));
  });
});

describe('parseDateOrNull', () => {
  it('passes through null/empty, parses valid, flags garbage', () => {
    assert.deepEqual(g.parseDateOrNull(null), {date: null});
    assert.deepEqual(g.parseDateOrNull(''), {date: null});
    assert.equal(g.parseDateOrNull('2026-11-02T10:00:00Z').date instanceof Date, true);
    assert.deepEqual(g.parseDateOrNull('not-a-date'), {invalid: true});
  });
});

describe('shouldRependTrip (approved commercial edits return to pending)', () => {
  const approved = {approvalStatus: 'approved', priceEgp: 6000, capacity: 12, dateLabel: 'Nov 2', title: 'Nile Day'};
  it('re-pends on price/capacity/date change', () => {
    assert.equal(g.shouldRependTrip(approved, {...approved, priceEgp: 6500}), true);
    assert.equal(g.shouldRependTrip(approved, {...approved, capacity: 10}), true);
    assert.equal(g.shouldRependTrip(approved, {...approved, dateLabel: 'Nov 3'}), true);
  });
  it('ignores editorial fixes and non-approved states', () => {
    assert.equal(g.shouldRependTrip(approved, {...approved, title: 'Nile Day!'}), false);
    assert.equal(g.shouldRependTrip(approved, {...approved}), false);
    assert.equal(
      g.shouldRependTrip({...approved, approvalStatus: 'pending'}, {...approved, approvalStatus: 'pending', priceEgp: 1}),
      false,
    );
    assert.equal(
      g.shouldRependTrip(approved, {...approved, approvalStatus: 'pending', priceEgp: 1}),
      false,
    );
    assert.equal(g.shouldRependTrip(null, approved), false);
  });
});

describe('mergeLegacyVerification (preserve submitted docs)', () => {
  it('keeps URLs/submittedAt while overwriting decision fields', () => {
    const legacy = {idDocumentUrl: 'http://id', licenseDocumentUrl: 'http://lic', submittedAt: 't', reviewStatus: 'pending'};
    assert.deepEqual(
      g.mergeLegacyVerification(legacy, {status: 'approved', canPublish: true, rejectionReason: ''}),
      {idDocumentUrl: 'http://id', licenseDocumentUrl: 'http://lic', submittedAt: 't', reviewStatus: 'approved', canPublishTrips: true, rejectionReason: ''},
    );
  });
  it('tolerates missing legacy maps', () => {
    assert.deepEqual(
      g.mergeLegacyVerification(null, {status: 'rejected', canPublish: false, rejectionReason: 'blurry'}),
      {idDocumentUrl: '', licenseDocumentUrl: '', submittedAt: null, reviewStatus: 'rejected', canPublishTrips: false, rejectionReason: 'blurry'},
    );
  });
});
