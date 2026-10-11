/**
 * Pure booking/payment decision helpers — NO firebase dependencies.
 *
 * Required by `../index.js` so the deployed Functions and the unit tests in
 * `../test/guards.test.js` exercise the exact same logic (`node --test`).
 * Covers P0 items 4–7: safe state transitions, idempotency ownership,
 * Paymob amount/currency verification, and replay protection.
 */

const {createHash} = require('node:crypto');

const CANCELLABLE_STATUSES = ['pending', 'confirmed'];
const UNPAID_STATUSES = ['pending', 'failed'];

/** Client direct-cancel gate (mirrors `firestore.rules` bookings update). */
function canClientCancel({status, paymentStatus}) {
  if (!CANCELLABLE_STATUSES.includes(status)) {
    return {ok: false, reason: 'not-active'};
  }
  if (!UNPAID_STATUSES.includes(paymentStatus ?? 'pending')) {
    return {ok: false, reason: 'paid-use-callable'};
  }
  return {ok: true};
}

/**
 * Paymob verify gate: ONLY a pending booking with a pending payment may move
 * to confirmed. There is deliberately NO dedupe branch here: a booking-level
 * `succeeded` never proves that a NEW, unverified payment doc was captured.
 * Legitimate replay of an already-succeeded PAYMENT is handled separately by
 * the payment-level early return in verifyPaymobTransaction.
 */
function canConfirmAfterVerify({bookingStatus, paymentStatus}) {
  if (bookingStatus !== 'pending' || paymentStatus !== 'pending') {
    return {ok: false, reason: 'invalid-transition'};
  }
  return {ok: true};
}

function toMinorUnits(amount) {
  return Math.round(Number(amount) * 100);
}

/**
 * Does a Paymob order lookup prove full payment for this booking?
 * `order` is the parsed Paymob order object; amounts compare in minor units
 * and currency must match when the provider reports one.
 */
function paymobOrderCoversBooking({order, expectedCents, currency}) {
  if (!order || typeof order !== 'object') return {ok: false, reason: 'no-order'};
  if (Number(order.amount_cents) !== expectedCents) {
    return {ok: false, reason: 'amount-mismatch'};
  }
  if (
    order.currency != null &&
    currency != null &&
    String(order.currency) !== String(currency)
  ) {
    return {ok: false, reason: 'currency-mismatch'};
  }
  const paid =
    order.paid_amount_cents === order.amount_cents ||
    order.is_captured === true ||
    order.payment_status === 'paid';
  if (!paid) return {ok: false, reason: 'not-paid'};
  return {ok: true};
}

/** Idempotency keys must be unguessable-ish opaque strings, never `/`-scoped. */
function validIdempotencyKey(key) {
  if (typeof key !== 'string') return false;
  const k = key.trim();
  return k.length >= 8 && k.length <= 160 && !k.includes('/');
}

/** Parses an optional ISO date input; invalid strings are rejected, not stored. */
function parseDateOrNull(v) {
  if (v == null || v === '') return {date: null};
  const d = new Date(v);
  if (Number.isNaN(d.getTime())) return {invalid: true};
  return {date: d};
}

/**
 * Single-transaction idempotency decision. `keyTouristId` is the owner stored
 * on the existing key doc; `callerUid` is the current caller.
 *
 * `expectedFp` is the request fingerprint stored on the key doc (absent for
 * keys written before fingerprinting existed — treated as a match so old
 * retries keep working); `actualFp` is the current request's fingerprint.
 * Same owner + same request → dedupe; same owner + DIFFERENT request →
 * mismatch (rejected: the key is bound to the original booking, never
 * silently re-resolved to an unrelated one).
 */
function classifyKeyConflict({keyExists, keyTouristId, callerUid, bookingId, expectedFp, actualFp}) {
  if (!keyExists) return {action: 'proceed'};
  if (keyTouristId !== callerUid) return {action: 'deny'};
  if (expectedFp && actualFp && expectedFp !== actualFp) return {action: 'mismatch'};
  return {action: 'dedupe', bookingId};
}

/**
 * Stable fingerprint of a booking request's material fields. Key-sorted JSON
 * hashed with SHA-256: deterministic across retries, sensitive to any
 * material change, and independent of field order or idempotency key.
 * Pure (node:crypto only) so unit tests exercise the deployed logic.
 */
function bookingFingerprint(input) {
  const norm = {};
  for (const k of Object.keys(input || {}).sort()) {
    const v = input[k];
    norm[k] = v === undefined ? null : v;
  }
  return createHash('sha256').update(JSON.stringify(norm)).digest('hex');
}

/** Commercial terms whose edit re-pends an approved trip (P1 decided rule). */
const REPEND_FIELDS = ['priceEgp', 'capacity', 'dateLabel'];

/**
 * Whether an approved→approved trip edit must return to `pending`.
 * Only fires when both snapshots are `approved` (the trigger's own
 * approved→pending write, admin decisions, and pending-trip edits never
 * match) AND a commercial term changed. Plain `===` suffices: Firestore
 * scalarizes these fields identically on read.
 */
function shouldRependTrip(before, after) {
  if (!before || !after) return false;
  if (before.approvalStatus !== 'approved' || after.approvalStatus !== 'approved') {
    return false;
  }
  return REPEND_FIELDS.some((k) => before[k] !== after[k]);
}

/**
 * Legacy `users.verification` merge for `decideVerification`: preserves the
 * guide's submitted document references while overwriting ONLY the decision
 * fields. (`reviewedAt` is stamped by the caller with a server timestamp.)
 */
function mergeLegacyVerification(legacy, {status, canPublish, rejectionReason}) {
  const src = legacy && typeof legacy === 'object' ? legacy : {};
  return {
    idDocumentUrl: src.idDocumentUrl || '',
    licenseDocumentUrl: src.licenseDocumentUrl || '',
    submittedAt: src.submittedAt || null,
    reviewStatus: status,
    canPublishTrips: canPublish,
    rejectionReason: rejectionReason || '',
  };
}

module.exports = {
  CANCELLABLE_STATUSES,
  UNPAID_STATUSES,
  canClientCancel,
  canConfirmAfterVerify,
  toMinorUnits,
  paymobOrderCoversBooking,
  validIdempotencyKey,
  parseDateOrNull,
  classifyKeyConflict,
  bookingFingerprint,
  REPEND_FIELDS,
  shouldRependTrip,
  mergeLegacyVerification,
};
