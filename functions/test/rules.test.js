/**
 * Firestore Security Rules tests — run against the LOCAL Firestore emulator.
 *
 * Requires: `firebase emulators:start --only firestore --project demo-triply`
 * (uses the repo's real `firestore.rules` via `firebase.json`).
 * Run: `node --test test/rules.test.js` with
 * `FIRESTORE_EMULATOR_HOST=127.0.0.1:8080` (set by the emulator automatically).
 *
 * Covers P0 items 1–3 + cancel/payment gates: unauthorized trip lists,
 * cross-user booking reads/writes, cross-user notification access.
 * These tests PROVE the rules at runtime; unit tests in `guards.test.js`
 * prove the Functions-side decision logic.
 */
const {describe, it, before, after, beforeEach} = require('node:test');
const assert = require('node:assert/strict');
const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require('@firebase/rules-unit-testing');
// NOTE: every Firestore instance in this file (seed + test bodies) comes
// from the CLIENT SDK via the test context (see
// withSecurityRulesDisabled/createContext in @firebase/rules-unit-testing:
// `this.getApp().firestore()`). Never pass firebase-admin value classes
// (Timestamp/FieldValue/GeoPoint) here — the client serializer rejects them
// as foreign objects. Use plain `new Date()`; the client converts it to a
// Timestamp on write.

const PROJECT_ID = process.env.FIRESTORE_TEST_PROJECT || 'demo-triply';
const HOST = '127.0.0.1';
const PORT = Number(process.env.FIRESTORE_EMULATOR_PORT || 8080);

let testEnv;

function ctx(uid, extra = {}) {
  if (!uid) return testEnv.unauthenticatedContext();
  return testEnv.authenticatedContext(uid, {email: `${uid}@test.dev`, ...extra});
}

async function seed() {
  await testEnv.withSecurityRulesDisabled(async (admin) => {
    const db = admin.firestore();
    await db.collection('admins').doc('admin1').set({provisionedBy: 'test'});
    await db.collection('users').doc('touristA').set({role: 'tourist', fullName: 'A', isActive: true});
    await db.collection('users').doc('touristB').set({role: 'tourist', fullName: 'B', isActive: true});
    await db.collection('users').doc('guide1').set({role: 'guide', fullName: 'G', isActive: true});
    await db.collection('trips').doc('t1').set({
      guideId: 'guide1', approvalStatus: 'approved', title: 'Nile Day',
      capacity: 10, bookedSeats: 2, priceEgp: 6000, currency: 'EGP',
    });
    await db.collection('trips').doc('t2').set({
      guideId: 'guide1', approvalStatus: 'pending', title: 'Draft Trip',
      capacity: 8, bookedSeats: 0, priceEgp: 1000, currency: 'EGP',
    });
    await db.collection('trips').doc('t3').set({
      guideId: 'guideX', approvalStatus: 'approved', title: 'Other Guide Trip',
      capacity: 6, bookedSeats: 0, priceEgp: 500, currency: 'EGP',
    });
    await db.collection('bookings').doc('bA').set({
      touristId: 'touristA', guideId: 'guide1', tripId: 't1',
      bookingType: 'public', seats: 2, unitPrice: 6000, serviceFee: 600,
      totalAmount: 12600, currency: 'EGP', status: 'pending',
      paymentStatus: 'pending', idempotencyKey: 'key-tA-001',
    });
    await db.collection('bookings').doc('bPaid').set({
      touristId: 'touristA', guideId: 'guide1', tripId: 't1',
      bookingType: 'public', seats: 1, unitPrice: 6000, serviceFee: 300,
      totalAmount: 6300, currency: 'EGP', status: 'confirmed',
      paymentStatus: 'succeeded', idempotencyKey: 'key-tA-002',
    });
    await db.collection('notifications').doc('nA').set({
      userId: 'touristA', title: 'Hi', message: 'hello', type: 'general',
      isRead: false, createdAt: new Date(),
    });
    await db.collection('payments').doc('pA').set({
      touristId: 'touristA', bookingId: 'bA', provider: 'paymob',
      providerReference: 'ord-1', amount: 12600, currency: 'EGP',
      status: 'pending',
    });
    await db.collection('guideProfiles').doc('guide1').set({
      userId: 'guide1', isVerified: false, canPublishTrips: false,
      ratingAvg: 0, ratingCount: 0,
    });
    await db.collection('guideVerifications').doc('rej1').set({
      guideId: 'guide1', idDocumentUrl: 'http://id', licenseDocumentUrl: 'http://lic',
      status: 'rejected', reviewerId: 'admin1', rejectionReason: 'blurry',
    });
    await db.collection('guideVerifications').doc('appr1').set({
      guideId: 'guide1', idDocumentUrl: 'http://id', licenseDocumentUrl: 'http://lic',
      status: 'approved', reviewerId: 'admin1', rejectionReason: '',
    });
  });
}

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {host: HOST, port: PORT},
  });
});

after(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
  await seed();
});

describe('trips list authorization (P0-1)', () => {
  it('anonymous users can list approved trips (public feed preserved)', async () => {
    const db = ctx(null).firestore();
    const snap = await assertSucceeds(
      db.collection('trips').where('approvalStatus', '==', 'approved').get(),
    );
    assert.deepEqual(snap.docs.map((d) => d.id).sort(), ['t1', 't3']);
  });

  it('tourist approved-query sees ONLY approved trips', async () => {
    const db = ctx('touristA').firestore();
    const snap = await assertSucceeds(
      db.collection('trips').where('approvalStatus', '==', 'approved').get(),
    );
    assert.deepEqual(snap.docs.map((d) => d.id).sort(), ['t1', 't3']);
  });

  it('tourist unfiltered list is denied (pending leak closed)', async () => {
    const db = ctx('touristA').firestore();
    await assertFails(db.collection('trips').get());
  });

  it('tourist pending-filtered list is denied', async () => {
    const db = ctx('touristA').firestore();
    await assertFails(
      db.collection('trips').where('approvalStatus', '==', 'pending').get(),
    );
  });

  it('guide lists own trips across statuses', async () => {
    const db = ctx('guide1').firestore();
    const snap = await assertSucceeds(
      db.collection('trips').where('guideId', '==', 'guide1').get(),
    );
    assert.deepEqual(snap.docs.map((d) => d.id).sort(), ['t1', 't2']);
  });

  it('tourist cannot list a guide\'s trips (mixed pending doc denies query)', async () => {
    const db = ctx('touristA').firestore();
    await assertFails(
      db.collection('trips').where('guideId', '==', 'guide1').get(),
    );
  });

  it('admin lists everything', async () => {
    const db = ctx('admin1').firestore();
    const snap = await assertSucceeds(db.collection('trips').get());
    assert.equal(snap.size, 3);
  });

  it('guide cannot smuggle approvalStatus/bookedSeats on create', async () => {
    const db = ctx('guide1').firestore();
    await assertFails(
      db.collection('trips').doc('evil').set({guideId: 'guide1', title: 'x', priceEgp: 100, capacity: 5, approvalStatus: 'approved'}),
    );
    await assertFails(
      db.collection('trips').doc('evil').set({guideId: 'guideX', title: 'x', priceEgp: 100, capacity: 5}),
    );
    await assertSucceeds(
      db.collection('trips').doc('ok1').set({guideId: 'guide1', title: 'x', priceEgp: 100, capacity: 5}),
    );
  });

  it('trip create requires guide role + valid payload', async () => {
    // Tourist (role=tourist) cannot publish, even with a clean payload.
    await assertFails(
      ctx('touristA').firestore().collection('trips').doc('nope').set({guideId: 'touristA', title: 'x', priceEgp: 100, capacity: 5}),
    );
    const db = ctx('guide1').firestore();
    await assertFails(
      db.collection('trips').doc('bad1').set({guideId: 'guide1', title: '', priceEgp: 100, capacity: 5}),
    );
    await assertFails(
      db.collection('trips').doc('bad2').set({guideId: 'guide1', title: 'x', priceEgp: -5, capacity: 5}),
    );
    await assertFails(
      db.collection('trips').doc('bad3').set({guideId: 'guide1', title: 'x', priceEgp: 100, capacity: 0}),
    );
  });

  it('owner cannot rewrite bookedSeats; may edit price', async () => {
    const db = ctx('guide1').firestore();
    await assertFails(db.collection('trips').doc('t1').update({bookedSeats: 0}));
    await assertSucceeds(db.collection('trips').doc('t1').update({priceEgp: 6500}));
  });
});

describe('bookings privacy + cancel gate (P0-2, P0-4)', () => {
  it('owner reads own booking; stranger get is denied', async () => {
    await assertSucceeds(ctx('touristA').firestore().collection('bookings').doc('bA').get());
    await assertFails(ctx('touristB').firestore().collection('bookings').doc('bA').get());
  });

  it('owner lists own bookings; unfiltered and cross-user lists denied', async () => {
    const own = await assertSucceeds(
      ctx('touristA').firestore().collection('bookings').where('touristId', '==', 'touristA').get(),
    );
    assert.equal(own.size, 2);
    await assertFails(ctx('touristA').firestore().collection('bookings').get());
    await assertFails(
      ctx('touristB').firestore().collection('bookings').where('touristId', '==', 'touristA').get(),
    );
  });

  it('guide lists bookings for their trips; direct create is disabled', async () => {
    const mine = await assertSucceeds(
      ctx('guide1').firestore().collection('bookings').where('guideId', '==', 'guide1').get(),
    );
    assert.equal(mine.size, 2);
    await assertFails(
      ctx('touristB').firestore().collection('bookings').doc('sneaky').set({touristId: 'touristB', status: 'pending'}),
    );
  });

  it('owner cancels unpaid booking; paid cancel is denied (callable only)', async () => {
    await assertSucceeds(ctx('touristA').firestore().collection('bookings').doc('bA').update({status: 'cancelled'}));
    await assertFails(ctx('touristA').firestore().collection('bookings').doc('bPaid').update({status: 'cancelled'}));
  });

  it('cancel cannot smuggle price/status fields', async () => {
    await assertFails(
      ctx('touristA').firestore().collection('bookings').doc('bA').update({status: 'cancelled', totalAmount: 1}),
    );
    await assertFails(
      ctx('touristA').firestore().collection('bookings').doc('bA').update({status: 'confirmed'}),
    );
    await assertFails(ctx('touristB').firestore().collection('bookings').doc('bA').update({status: 'cancelled'}));
  });

  it('admin reads and cancels anything', async () => {
    const db = ctx('admin1').firestore();
    await assertSucceeds(db.collection('bookings').get());
    await assertSucceeds(db.collection('bookings').doc('bPaid').update({status: 'cancelled'}));
  });
});

describe('notifications privacy (P0-3)', () => {
  it('recipient reads own; stranger get/list denied', async () => {
    await assertSucceeds(ctx('touristA').firestore().collection('notifications').doc('nA').get());
    await assertFails(ctx('touristB').firestore().collection('notifications').doc('nA').get());
    const own = await assertSucceeds(
      ctx('touristA').firestore().collection('notifications').where('userId', '==', 'touristA').get(),
    );
    assert.equal(own.size, 1);
    await assertFails(ctx('touristA').firestore().collection('notifications').get());
    await assertFails(
      ctx('touristB').firestore().collection('notifications').where('userId', '==', 'touristA').get(),
    );
  });

  it('recipient flips isRead only; direct create denied', async () => {
    const ref = ctx('touristA').firestore().collection('notifications').doc('nA');
    await assertSucceeds(ref.update({isRead: true}));
    await assertFails(ref.update({isRead: true, title: 'Hacked'}));
    await assertFails(
      ctx('touristA').firestore().collection('notifications').doc('fake').set({userId: 'touristA', title: 'x'}),
    );
  });
});

describe('payments + users + profiles + bookingKeys', () => {
  it('pending payment create allowed; success escalation and cross-user reads denied', async () => {
    const mine = ctx('touristA').firestore();
    await assertSucceeds(
      mine.collection('payments').doc('p2').set({touristId: 'touristA', bookingId: 'bA', provider: 'paymob', status: 'pending'}),
    );
    await assertFails(
      mine.collection('payments').doc('p3').set({touristId: 'touristA', bookingId: 'bA', provider: 'paymob', status: 'succeeded'}),
    );
    await assertFails(mine.collection('payments').doc('pA').update({status: 'succeeded'}));
    await assertFails(ctx('touristB').firestore().collection('payments').doc('pA').get());
    const own = await assertSucceeds(
      mine.collection('payments').where('touristId', '==', 'touristA').get(),
    );
    assert.ok(own.size >= 1);
  });

  it('users: admin role self-grant and role edits denied; profile edit allowed', async () => {
    const mine = ctx('touristA').firestore();
    await assertFails(mine.collection('users').doc('touristA').update({role: 'admin'}));
    await assertFails(mine.collection('users').doc('touristC').set({role: 'admin', fullName: 'x'}));
    await assertSucceeds(mine.collection('users').doc('touristA').update({phone: '+2010'}));
    await assertFails(ctx('touristB').firestore().collection('users').doc('touristA').get());
  });

  it('guideProfiles: public read; owner flag edits denied; bookingKeys fully closed', async () => {
    await assertSucceeds(ctx(null).firestore().collection('guideProfiles').doc('guide1').get());
    const g = ctx('guide1').firestore();
    await assertSucceeds(
      g.collection('guideProfiles').doc('guide1').set(
        {userId: 'guide1', about: 'hi', isVerified: false, canPublishTrips: false, ratingAvg: 0, ratingCount: 0},
        {merge: true},
      ),
    );
    await assertFails(g.collection('guideProfiles').doc('guide1').update({isVerified: true}));
    // First-time create may omit server-owned fields (defaults apply).
    await assertSucceeds(
      ctx('guideNew').firestore().collection('guideProfiles').doc('guideNew').set(
        {userId: 'guideNew', displayName: 'New', contactPhone: '+200'},
      ),
    );
    await assertFails(ctx('touristA').firestore().collection('bookingKeys').doc('k').get());
    await assertFails(ctx('touristA').firestore().collection('bookingKeys').doc('k').set({x: 1}));
  });

  it('guideVerifications: resubmit only rejected->pending with exact keys', async () => {
    const g = ctx('guide1').firestore();
    // Rejected doc resubmits cleanly (reviewer metadata dropped by overwrite).
    await assertSucceeds(
      g.collection('guideVerifications').doc('rej1').set({
        guideId: 'guide1', idDocumentUrl: 'http://id2', licenseDocumentUrl: 'http://lic2',
        status: 'pending', submittedAt: new Date(), rejectionReason: '',
      }),
    );
    // Approved doc cannot be touched by the owner.
    await assertFails(
      g.collection('guideVerifications').doc('appr1').set({
        guideId: 'guide1', idDocumentUrl: 'http://id2', licenseDocumentUrl: 'http://lic2',
        status: 'pending', submittedAt: new Date(), rejectionReason: '',
      }),
    );
    // Reviewer fields can never be smuggled client-side.
    await assertFails(
      g.collection('guideVerifications').doc('fresh').set({
        guideId: 'guide1', idDocumentUrl: 'http://id', licenseDocumentUrl: 'http://lic',
        status: 'pending', reviewerId: 'guide1',
      }),
    );
    // Another user's submission is invisible/unwritable.
    await assertFails(ctx('touristB').firestore().collection('guideVerifications').doc('rej1').get());
  });

  it('stories: expiresAt must be a Timestamp (string expiries rejected)', async () => {
    const mine = ctx('touristA').firestore();
    // `new Date()` is serialized to a Timestamp by the client SDK, so the
    // `is timestamp` rule still sees a Timestamp here.
    await assertSucceeds(
      mine.collection('stories').doc('s1').set({userId: 'touristA', mediaUrl: 'm', expiresAt: new Date()}),
    );
    await assertFails(
      mine.collection('stories').doc('s2').set({userId: 'touristA', mediaUrl: 'm', expiresAt: '2026-11-02T10:00:00.000Z'}),
    );
  });
});
