/**
 * Callable integration tests — run against the LOCAL emulators ONLY.
 *
 * Required emulators: auth + firestore + functions, demo-triply project:
 *   firebase emulators:exec --only auth,firestore,functions --project demo-triply \
 *     "npm --prefix functions run test:callables"
 * (add a `test:callables` script before first use; env overrides below.)
 *
 * Env (all have safe defaults; emulator host vars are set automatically by
 * `emulators:exec`):
 *   FIRESTORE_EMULATOR_HOST, FIREBASE_AUTH_EMULATOR_HOST (required — the file
 *     refuses to run without them so it can NEVER touch production),
 *   FIRESTORE_TEST_PROJECT (default 'demo-triply'),
 *   FUNCTIONS_TEST_PORT (default 5001), FUNCTIONS_TEST_REGION (default
 *   'us-central1', the v2 platform default).
 *
 * Hard safety rails (fail fast, never silent):
 * - refuses to run if PAYMOB_API_KEY is set (no live payment APIs, ever);
 * - refuses to run against a non-demo, non-emulator target;
 * - amount-mismatch / duplicate-order / live-verify paths are NOT exercised
 *   here (they need the Paymob sandbox); the matcher logic is unit-covered
 *   in test/guards.test.js. The no-config rejection path IS exercised.
 *
 * Covers: server-side pricing, idempotent retries, cross-user key denial,
 * capacity limits, unknown-guide rejection, unpaid/paid cancel behavior,
 * verify rejection cases that need no provider, concurrent same-key bursts,
 * retry-safe capacity release.
 */
const {describe, it, before} = require('node:test');
const assert = require('node:assert/strict');
const admin = require('firebase-admin');

const PROJECT = process.env.FIRESTORE_TEST_PROJECT || 'demo-triply';
if (!process.env.FIRESTORE_EMULATOR_HOST || !process.env.FIREBASE_AUTH_EMULATOR_HOST) {
  throw new Error(
    'callables.test.js requires emulators: set FIRESTORE_EMULATOR_HOST and ' +
    'FIREBASE_AUTH_EMULATOR_HOST (run via `firebase emulators:exec ' +
    '--only auth,firestore,functions --project demo-triply "npm --prefix ' +
    'functions run test:callables"`). Refusing to run elsewhere.',
  );
}
if (!PROJECT.startsWith('demo-')) {
  throw new Error(`Refusing: test project must be demo-*, got ${PROJECT}.`);
}
if (process.env.PAYMOB_API_KEY) {
  throw new Error('Refusing: PAYMOB_API_KEY must be unset (no live payment APIs in tests).');
}

admin.initializeApp({projectId: PROJECT});
const db = admin.firestore();

const AUTH_HOST = process.env.FIREBASE_AUTH_EMULATOR_HOST;
const FN_PORT = Number(process.env.FUNCTIONS_TEST_PORT || 5001);
const FN_REGION = process.env.FUNCTIONS_TEST_REGION || 'us-central1';
const FN_BASE = `http://127.0.0.1:${FN_PORT}/${PROJECT}/${FN_REGION}`;

const tokens = {};

async function signIn(email, password) {
  const res = await fetch(
    `http://${AUTH_HOST}/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=fake-api-key`,
    {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({email, password, returnSecureToken: true}),
    },
  );
  if (!res.ok) throw new Error(`sign-in failed for ${email}: ${res.status}`);
  const body = await res.json();
  return body.idToken;
}

/** Invoke a callable; returns {ok, status, payload}. Never throws on app errors. */
async function call(fn, token, data) {
  const headers = {'Content-Type': 'application/json'};
  if (token) headers.Authorization = `Bearer ${token}`;
  const res = await fetch(`${FN_BASE}/${fn}`, {
    method: 'POST',
    headers,
    body: JSON.stringify({data}),
  });
  const body = await res.json().catch(() => ({}));
  if (res.ok) return {ok: true, status: res.status, payload: body.result};
  return {ok: false, status: (body.error && body.error.status) || `HTTP_${res.status}`, message: (body.error && body.error.message) || ''};
}

async function waitFor(fn, {timeoutMs = 20000, intervalMs = 500, label = 'condition'} = {}) {
  const start = Date.now();
  for (;;) {
    if (await fn()) return;
    if (Date.now() - start > timeoutMs) throw new Error(`timed out waiting for: ${label}`);
    await new Promise((r) => setTimeout(r, intervalMs));
  }
}

const doc = (col, id) => db.collection(col).doc(id).get().then((s) => ({...s.data(), _id: s.id}));

before(async () => {
  // Users (Auth emulator) + Firestore fixtures (admin SDK bypasses rules).
  for (const [uid, email] of [['touristA', 'a@test.dev'], ['touristB', 'b@test.dev'], ['guide1', 'g@test.dev'], ['admin1', 'admin@test.dev']]) {
    try {
      await admin.auth().createUser({uid, email, password: 'pass1234'});
    } catch (e) {
      if (e.code !== 'auth/uid-already-exists' && e.code !== 'auth/email-already-exists') throw e;
    }
    tokens[uid] = await signIn(email, 'pass1234');
  }
  await db.collection('users').doc('touristA').set({role: 'tourist'});
  await db.collection('users').doc('touristB').set({role: 'tourist'});
  await db.collection('users').doc('guide1').set({role: 'guide'});
  await db.collection('admins').doc('admin1').set({provisionedBy: 'test'});
  await db.collection('guideProfiles').doc('guide1').set({userId: 'guide1', pricePerHour: 100, isVerified: true});
  await db.collection('trips').doc('tripA').set({
    guideId: 'guide1', approvalStatus: 'approved', title: 'Nile Day',
    capacity: 5, bookedSeats: 0, priceEgp: 1000, currency: 'EGP',
  });
  await db.collection('trips').doc('tripFull').set({
    guideId: 'guide1', approvalStatus: 'approved', title: 'Full Boat',
    capacity: 1, bookedSeats: 1, priceEgp: 500, currency: 'EGP',
  });
  await db.collection('trips').doc('tripConc').set({
    guideId: 'guide1', approvalStatus: 'approved', title: 'Race Boat',
    capacity: 10, bookedSeats: 0, priceEgp: 1000, currency: 'EGP',
  });
  await db.collection('trips').doc('tripCancel').set({
    guideId: 'guide1', approvalStatus: 'approved', title: 'Cancel Boat',
    capacity: 10, bookedSeats: 0, priceEgp: 1000, currency: 'EGP',
  });
});

describe('createBooking: server pricing + validation', () => {
  it('books with server-computed totals (2000 + 5% = 2100)', async () => {
    const r = await call('createBooking', tokens.touristA, {
      bookingType: 'public', tripId: 'tripA', tripDate: '2026-11-02T10:00:00Z',
      seats: 2, idempotencyKey: 'test-K1-00000001',
    });
    assert.equal(r.ok, true);
    assert.equal(r.payload.unitPrice, 1000);
    assert.equal(r.payload.serviceFee, 100);
    assert.equal(r.payload.totalAmount, 2100);
    assert.equal(r.payload.status, 'pending');
    assert.equal(r.payload.paymentStatus, 'pending');
    const key = await doc('bookingKeys', 'test-K1-00000001');
    assert.equal(key.bookingId, r.payload.id);
    assert.equal(key.touristId, 'touristA');
    await waitFor(async () => (await doc('trips', 'tripA')).bookedSeats === 2, {label: 'bookedSeats == 2'});
  });

  it('rejects over-capacity, unknown trip, bad input', async () => {
    const full = await call('createBooking', tokens.touristA, {
      bookingType: 'public', tripId: 'tripFull', seats: 1, idempotencyKey: 'test-Kfull-0001',
    });
    assert.equal(full.ok, false);
    assert.equal(full.status, 'FAILED_PRECONDITION');
    const missing = await call('createBooking', tokens.touristA, {
      bookingType: 'public', tripId: 'nope', seats: 1, idempotencyKey: 'test-Kmiss-0001',
    });
    assert.equal(missing.status, 'NOT_FOUND');
    const badDate = await call('createBooking', tokens.touristA, {
      bookingType: 'public', tripId: 'tripA', tripDate: 'garbage', seats: 1, idempotencyKey: 'test-Kdate-0001',
    });
    assert.equal(badDate.status, 'INVALID_ARGUMENT');
    const badKey = await call('createBooking', tokens.touristA, {
      bookingType: 'public', tripId: 'tripA', seats: 1, idempotencyKey: 'x',
    });
    assert.equal(badKey.status, 'INVALID_ARGUMENT');
    const anon = await call('createBooking', null, {
      bookingType: 'public', tripId: 'tripA', seats: 1, idempotencyKey: 'test-Kanon-0001',
    });
    assert.equal(anon.status, 'UNAUTHENTICATED');
  });

  it('private booking uses guide price (100 x 2h x 2 = 420) and rejects unknown guides', async () => {
    const r = await call('createBooking', tokens.touristA, {
      bookingType: 'private', guideId: 'guide1', travelers: 2, durationHours: 2,
      idempotencyKey: 'test-Kpriv-0001',
    });
    assert.equal(r.ok, true);
    assert.equal(r.payload.totalAmount, 420);
    const ghost = await call('createBooking', tokens.touristA, {
      bookingType: 'private', guideId: 'ghost', travelers: 1, durationHours: 1,
      idempotencyKey: 'test-Kghost-0001',
    });
    assert.equal(ghost.status, 'NOT_FOUND');
  });
});

describe('createBooking: idempotency ownership + concurrency', () => {
  let ownedBookingId = '';
  it('same-key retry returns the same booking (dedupe)', async () => {
    const first = await call('createBooking', tokens.touristA, {
      bookingType: 'public', tripId: 'tripA', seats: 1, idempotencyKey: 'test-K2-00000002',
    });
    assert.equal(first.ok, true);
    ownedBookingId = first.payload.id;
    // Identical retry resolves directly to the original booking: same id,
    // flagged deduped, original seats untouched (no second charge).
    const retry = await call('createBooking', tokens.touristA, {
      bookingType: 'public', tripId: 'tripA', seats: 1, idempotencyKey: 'test-K2-00000002',
    });
    assert.equal(retry.ok, true);
    assert.equal(retry.payload.id, ownedBookingId);
    assert.equal(retry.payload._deduped, true);
    assert.equal(retry.payload.seats, 1);
    // Same key + MATERIALLY different request is rejected, never silently
    // resolved to the unrelated original booking.
    const again = await call('createBooking', tokens.touristA, {
      bookingType: 'public', tripId: 'tripA', seats: 9, idempotencyKey: 'test-K2-00000002',
    });
    assert.equal(again.ok, false);
    assert.equal(again.status, 'FAILED_PRECONDITION');
    const orig = await doc('bookings', ownedBookingId);
    assert.equal(orig.seats, 1);
    assert.equal(orig.status, 'pending');
  });

  it('cross-user same key is denied with no disclosure', async () => {
    const r = await call('createBooking', tokens.touristB, {
      bookingType: 'public', tripId: 'tripA', seats: 1, idempotencyKey: 'test-K2-00000002',
    });
    assert.equal(r.ok, false);
    assert.equal(r.status, 'PERMISSION_DENIED');
    assert.ok(!r.message.includes(ownedBookingId), 'owner booking id must not leak');
  });

  it('concurrent same-key burst yields exactly one booking and one seat charge', async () => {
    const before = (await doc('trips', 'tripConc')).bookedSeats;
    const results = await Promise.all(
      Array.from({length: 5}, () => call('createBooking', tokens.touristA, {
        bookingType: 'public', tripId: 'tripConc', seats: 1, idempotencyKey: 'test-Kconc-00003',
      })),
    );
    // Every concurrent caller receives a booking (exactly one fresh, the
    // rest deduped), all pointing at the SAME booking id: no duplicates,
    // no double charge. Retries resolve directly, so all responses are ok.
    assert.ok(results.every((r) => r.ok));
    const ids = results.map((r) => r.payload.id);
    assert.equal(new Set(ids).size, 1);
    assert.equal(results.filter((r) => !r.payload._deduped).length, 1);
    await waitFor(async () => (await doc('trips', 'tripConc')).bookedSeats === before + 1, {label: 'single seat charge'});
  });
});

describe('cancelBooking + capacity release', () => {
  it('unpaid cancel releases capacity exactly once across retries', async () => {
    const made = await call('createBooking', tokens.touristA, {
      bookingType: 'public', tripId: 'tripCancel', seats: 2, idempotencyKey: 'test-Kcx-000004',
    });
    assert.equal(made.ok, true);
    await waitFor(async () => (await doc('trips', 'tripCancel')).bookedSeats === 2, {label: 'seats reserved'});
    const c1 = await call('cancelBooking', tokens.touristA, {bookingId: made.payload.id});
    assert.equal(c1.ok, true);
    assert.equal(c1.payload.refundStatus, 'none');
    const c2 = await call('cancelBooking', tokens.touristA, {bookingId: made.payload.id});
    assert.equal(c2.ok, true);
    assert.equal(c2.payload._deduped, true);
    await waitFor(async () => (await doc('trips', 'tripCancel')).bookedSeats === 0, {label: 'capacity released once'});
    const after = (await doc('trips', 'tripCancel')).bookedSeats;
    assert.equal(after, 0);
  });

  it('paid cancel records refund owed (no money moved)', async () => {
    const bRef = db.collection('bookings').doc('test-bPaid9');
    await bRef.set({
      touristId: 'touristA', bookingType: 'public', tripId: 'tripA', guideId: 'guide1',
      seats: 1, unitPrice: 1000, serviceFee: 50, totalAmount: 1050, currency: 'EGP',
      status: 'confirmed', paymentStatus: 'succeeded', idempotencyKey: 'test-Kpaid-0009',
    });
    const r = await call('cancelBooking', tokens.touristA, {bookingId: 'test-bPaid9', reason: 'changed plans'});
    assert.equal(r.ok, true);
    assert.equal(r.payload.refundStatus, 'owed');
    const b = await doc('bookings', 'test-bPaid9');
    assert.equal(b.refundAmount, 1050);
  });

  it('stranger cancel denied; unknown id not-found; completed immutable', async () => {
    const s = await call('cancelBooking', tokens.touristB, {bookingId: 'test-bPaid9'});
    assert.equal(s.status, 'PERMISSION_DENIED');
    const n = await call('cancelBooking', tokens.touristA, {bookingId: 'nope'});
    assert.equal(n.status, 'NOT_FOUND');
    await db.collection('bookings').doc('test-bDone9').set({
      touristId: 'touristA', bookingType: 'public', tripId: 'tripA', guideId: 'guide1',
      seats: 1, totalAmount: 1050, currency: 'EGP', status: 'completed',
      paymentStatus: 'succeeded', idempotencyKey: 'test-Kdone-0009',
    });
    const d = await call('cancelBooking', tokens.touristA, {bookingId: 'test-bDone9'});
    assert.equal(d.status, 'FAILED_PRECONDITION');
  });
});

describe('verifyPaymobTransaction without provider (no live calls)', () => {
  it('rejects unknown, foreign, and non-payable bookings before any lookup', async () => {
    const n = await call('verifyPaymobTransaction', tokens.touristA, {paymentId: 'nope'});
    assert.equal(n.status, 'NOT_FOUND');
    await db.collection('payments').doc('test-pFor9').set({
      touristId: 'touristB', bookingId: 'test-bPaid9', provider: 'paymob',
      providerReference: 'ord-9', amount: 1050, currency: 'EGP', status: 'pending',
    });
    const f = await call('verifyPaymobTransaction', tokens.touristA, {paymentId: 'test-pFor9'});
    assert.equal(f.status, 'PERMISSION_DENIED');
    await db.collection('payments').doc('test-pCx9').set({
      touristId: 'touristA', bookingId: 'test-bPaid9', provider: 'paymob',
      providerReference: 'ord-9', amount: 1050, currency: 'EGP', status: 'pending',
    });
    const c = await call('verifyPaymobTransaction', tokens.touristA, {paymentId: 'test-pCx9'});
    assert.equal(c.status, 'FAILED_PRECONDITION'); // booking cancelled, not pending
  });

  it('reports unconfigured provider without touching state', async () => {
    await db.collection('bookings').doc('test-bPen9').set({
      touristId: 'touristA', bookingType: 'public', tripId: 'tripA', guideId: 'guide1',
      seats: 1, totalAmount: 1050, currency: 'EGP', status: 'pending',
      paymentStatus: 'pending', idempotencyKey: 'test-Kpen-0009',
    });
    await db.collection('payments').doc('test-pPen9').set({
      touristId: 'touristA', bookingId: 'test-bPen9', provider: 'paymob',
      providerReference: 'ord-9', amount: 1050, currency: 'EGP', status: 'pending',
    });
    const r = await call('verifyPaymobTransaction', tokens.touristA, {paymentId: 'test-pPen9'});
    assert.equal(r.status, 'FAILED_PRECONDITION'); // verification not configured
    const p = await doc('payments', 'test-pPen9');
    assert.equal(p.status, 'pending'); // untouched
  });

  it('already-succeeded payment replays with no side effects', async () => {
    await db.collection('payments').doc('test-pOk9').set({
      touristId: 'touristA', bookingId: 'test-bPen9', provider: 'paymob',
      providerReference: 'ord-9', amount: 1050, currency: 'EGP', status: 'succeeded',
    });
    const r = await call('verifyPaymobTransaction', tokens.touristA, {paymentId: 'test-pOk9'});
    assert.equal(r.ok, true);
    assert.equal(r.payload._deduped, true);
  });
});

describe('onTripCreated: approval defaulting (F-A)', () => {
  it('preserves an explicitly approved status and backfills denormalized fields', async () => {
    await db.collection('trips').doc('test-trigApproved9').set({
      guideId: 'guide1', approvalStatus: 'approved', title: 'Seeded Approved',
      capacity: 6, priceEgp: 900, currency: 'EGP',
    });
    await waitFor(async () => {
      const t = await doc('trips', 'test-trigApproved9');
      return t.titleLower === 'seeded approved' && t.bookedSeats === 0;
    }, {label: 'trigger backfill without touching approval'});
    const t = await doc('trips', 'test-trigApproved9');
    assert.equal(t.approvalStatus, 'approved');
  });

  it('defaults a missing status to pending', async () => {
    await db.collection('trips').doc('test-trigDefault9').set({
      guideId: 'guide1', title: 'Fresh Draft', capacity: 4, priceEgp: 500, currency: 'EGP',
    });
    await waitFor(
      async () => (await doc('trips', 'test-trigDefault9')).approvalStatus === 'pending',
      {label: 'default pending applied'},
    );
  });
});

describe('verifyPaymobTransaction transition gates (F-B)', () => {
  it('rejects a pending payment on a confirmed-but-unpaid booking', async () => {
    // Pins the corrected gate: only pending+pending may confirm. A booking
    // that already moved on (confirmed/cancelled/completed) must never be
    // (re)confirmed by a fresh payment, even if money was captured before.
    await db.collection('bookings').doc('test-bConfUnpaid9').set({
      touristId: 'touristA', bookingType: 'public', tripId: 'tripA', guideId: 'guide1',
      seats: 1, totalAmount: 1050, currency: 'EGP', status: 'confirmed',
      paymentStatus: 'pending', idempotencyKey: 'test-Kconfunpaid-0009',
    });
    await db.collection('payments').doc('test-pConfUnpaid9').set({
      touristId: 'touristA', bookingId: 'test-bConfUnpaid9', provider: 'paymob',
      providerReference: 'ord-9', amount: 1050, currency: 'EGP', status: 'pending',
    });
    const r = await call('verifyPaymobTransaction', tokens.touristA, {paymentId: 'test-pConfUnpaid9'});
    assert.equal(r.ok, false);
    assert.equal(r.status, 'FAILED_PRECONDITION');
    const p = await doc('payments', 'test-pConfUnpaid9');
    assert.equal(p.status, 'pending'); // untouched, no false confirm
  });
});
