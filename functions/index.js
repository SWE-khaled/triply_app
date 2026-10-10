/**
 * Triply Cloud Functions — trusted backend operations.
 *
 * Firebase project: triply-f9b82 (DO NOT DEPLOY without explicit approval).
 * Runtime: Node 20, firebase-functions v6, firebase-admin v12.
 *
 * Secrets (Paymob + admin bootstrap) come from Functions environment config
 * ONLY — never hardcoded, never sent to clients. See docs/DEPLOYMENT_CHECKLIST.md.
 *
 * Responsibilities:
 * - createBooking: capacity transaction + server-side pricing + idempotency.
 * - onTripCreated: normalize new trips (pending) + notify the guide.
 * - onBookingStatusChanged: release capacity on cancel + notify the guide.
 * - decideTripStatus / decideVerification: admin-only approval flows.
 * - verifyPaymobTransaction: server-side payment verification (no client trust).
 * - onPostLikeWritten: likesCount aggregate (clients never write it).
 * - onReviewWritten: trip/guide rating aggregates (roadmap).
 * - cleanupExpiredStories: scheduled hard-delete of expired stories.
 * - provisionAdmin: admin-only role provisioning (custom claim + admins doc).
 */

const {onCall, HttpsError} = require('firebase-functions/v2/https');
const {onDocumentCreated, onDocumentUpdated, onDocumentWritten} = require('firebase-functions/v2/firestore');
const {onSchedule} = require('firebase-functions/v2/scheduler');
const admin = require('firebase-admin');
const guards = require('./lib/guards');

admin.initializeApp();
const db = admin.firestore();
const FieldValue = admin.firestore.FieldValue;

// ── Shared helpers ──────────────────────────────────────────────

const round2 = (v) => Math.round(v * 100) / 100;

function publicPricing({unitPrice, seats, feeRate = 0.05}) {
  const s = Math.max(1, seats | 0);
  const u = Math.max(0, Number(unitPrice) || 0);
  const subtotal = round2(u * s);
  const fee = round2(subtotal * feeRate);
  return {subtotal, fee, total: round2(subtotal + fee)};
}

function privatePricing({pricePerHour, hours, travelers, feeRate = 0.05}) {
  const h = Math.max(1, hours | 0);
  const t = Math.max(1, travelers | 0);
  const p = Math.max(0, Number(pricePerHour) || 0);
  const subtotal = round2(p * h * t);
  const fee = round2(subtotal * feeRate);
  return {subtotal, fee, total: round2(subtotal + fee)};
}

function requireAuth(request) {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Please sign in to continue.');
  }
  return request.auth.uid;
}

async function isAdminUid(uid) {
  if (!uid) return false;
  try {
    const user = await admin.auth().getUser(uid);
    const claims = user.customClaims || {};
    if (claims.admin === true) return true;
  } catch (_) {
    // Fall through to admins-doc check.
  }
  try {
    const doc = await db.collection('admins').doc(uid).get();
    return doc.exists;
  } catch (_) {
    return false;
  }
}

async function requireAdmin(request) {
  const uid = requireAuth(request);
  if (!(await isAdminUid(uid))) {
    throw new HttpsError('permission-denied', 'Admin access required.');
  }
  return uid;
}

async function notify({userId, title, message, type = 'general', relatedEntityId = null, relatedCollection = null}) {
  if (!userId) return;
  await db.collection('notifications').add({
    userId,
    title,
    message,
    type,
    relatedEntityId,
    relatedCollection,
    isRead: false,
    createdAt: FieldValue.serverTimestamp(),
  });
}

async function operationalFeeRate(key, fallback = 0.05) {
  try {
    const doc = await db.collection('appSettings').doc(key).get();
    const v = doc.exists ? Number(doc.data().value) : NaN;
    return Number.isFinite(v) && v >= 0 && v < 1 ? v : fallback;
  } catch (_) {
    return fallback;
  }
}

// ── createBooking (callable) ─────────────────────────────────────
//
// Public:  {bookingType:'public', tripId, tripDate, seats, specialRequests?, idempotencyKey}
// Private: {bookingType:'private', guideId, placeId?, appointmentAt, timeSlot?,
//           travelers, durationHours, meetingPoint?, specialRequests?, idempotencyKey}
// Server owns: touristId, prices, totals, status=pending, paymentStatus=pending,
// bookedSeats increment (public only, inside the same transaction).

exports.createBooking = onCall(async (request) => {
  const touristId = requireAuth(request);
  const d = request.data || {};
  const bookingType = d.bookingType === 'private' ? 'private' : 'public';
  const idempotencyKey = String(d.idempotencyKey || '').trim();
  if (!guards.validIdempotencyKey(idempotencyKey)) {
    throw new HttpsError('invalid-argument', 'Valid idempotencyKey is required.');
  }
  const keyRef = db.collection('bookingKeys').doc(idempotencyKey);

  // Runs the conflicting-key protocol: throws `already-exists` carrying the
  // booking id for the OWNER (dedupe), or `permission-denied` when the key
  // belongs to someone else (no cross-user disclosure).
  const fetchDeduped = async () => {
    const existing = await db.collection('bookings')
      .where('idempotencyKey', '==', idempotencyKey).limit(1).get();
    if (existing.empty) {
      throw new HttpsError('failed-precondition', 'Booking reference expired.');
    }
    const doc = existing.docs[0];
    if (doc.data().touristId !== touristId) {
      throw new HttpsError('permission-denied', 'Duplicate booking reference.');
    }
    return {id: doc.id, ...doc.data(), _deduped: true};
  };

  if (bookingType === 'public') {
    const tripId = String(d.tripId || '');
    const seats = Number(d.seats) || 0;
    if (!tripId) throw new HttpsError('invalid-argument', 'tripId is required.');
    if (!Number.isInteger(seats) || seats < 1) throw new HttpsError('invalid-argument', 'Select at least 1 seat.');
    const parsed = guards.parseDateOrNull(d.tripDate);
    if (parsed.invalid) throw new HttpsError('invalid-argument', 'Invalid tripDate.');

    const feeRate = await operationalFeeRate('serviceFeeRate', 0.05);
    const bookingRef = db.collection('bookings').doc();

    try {
      await db.runTransaction(async (tx) => {
        // Idempotency INSIDE the transaction: concurrent same-key requests
        // serialize on the key doc instead of double-booking.
        const keySnap = await tx.get(keyRef);
        if (keySnap.exists) {
          const c = guards.classifyKeyConflict({
            keyExists: true,
            keyTouristId: keySnap.data().touristId,
            callerUid: touristId,
            bookingId: keySnap.data().bookingId,
          });
          if (c.action === 'deny') {
            throw new HttpsError('permission-denied', 'Duplicate booking reference.');
          }
          throw new HttpsError('already-exists', c.bookingId);
        }
        const tripRef = db.collection('trips').doc(tripId);
        const tripSnap = await tx.get(tripRef);
        if (!tripSnap.exists) throw new HttpsError('not-found', 'Trip not found.');
        const trip = tripSnap.data();
        if (trip.approvalStatus !== 'approved') {
          throw new HttpsError('failed-precondition', 'This trip is not available for booking.');
        }
        const capacity = Number(trip.capacity) || 0;
        const booked = Number(trip.bookedSeats) || 0;
        const available = capacity - booked;
        if (seats > available) {
          throw new HttpsError('failed-precondition', `Only ${Math.max(0, available)} seats left.`);
        }
        const price = publicPricing({unitPrice: Number(trip.priceEgp) || 0, seats, feeRate});
        tx.set(bookingRef, {
          touristId,
          bookingType: 'public',
          tripId,
          guideId: String(trip.guideId || ''),
          placeId: trip.placeId || null,
          tripDate: parsed.date ? admin.firestore.Timestamp.fromDate(parsed.date) : null,
          seats,
          unitPrice: round2(Number(trip.priceEgp) || 0),
          serviceFee: price.fee,
          totalAmount: price.total,
          currency: String(trip.currency || 'EGP'),
          status: 'pending',
          paymentStatus: 'pending',
          meetingPoint: String(trip.meetingPoint || ''),
          specialRequests: String(d.specialRequests || ''),
          idempotencyKey,
          createdAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        });
        tx.update(tripRef, {
          bookedSeats: FieldValue.increment(seats),
          updatedAt: FieldValue.serverTimestamp(),
        });
        tx.set(keyRef, {
          bookingId: bookingRef.id,
          touristId,
          createdAt: FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      if (e instanceof HttpsError && e.code === 'already-exists') {
        return fetchDeduped();
      }
      throw e;
    }

    const created = await bookingRef.get();
    const booking = {id: created.id, ...created.data()};
    await notify({
      userId: booking.guideId,
      title: 'New booking request',
      message: `${seats} seat(s) requested for "${(await bookingRef.get()).data().tripId}".`,
      type: 'booking_created',
      relatedEntityId: bookingRef.id,
      relatedCollection: 'bookings',
    });
    return booking;
  }

  // Private guide booking.
  const guideId = String(d.guideId || '');
  const travelers = Number(d.travelers ?? d.seats) || 0;
  const durationHours = Number(d.durationHours) || 0;
  if (!guideId) throw new HttpsError('invalid-argument', 'guideId is required.');
  if (!Number.isInteger(travelers) || travelers < 1 || travelers > 10) {
    throw new HttpsError('invalid-argument', 'Travelers must be 1–10.');
  }
  if (!Number.isInteger(durationHours) || durationHours < 1 || durationHours > 24) {
    throw new HttpsError('invalid-argument', 'Invalid duration.');
  }
  const parsedAppt = guards.parseDateOrNull(d.appointmentAt);
  if (parsedAppt.invalid) throw new HttpsError('invalid-argument', 'Invalid appointmentAt.');
  const profileSnap = await db.collection('guideProfiles').doc(guideId).get();
  if (!profileSnap.exists) {
    throw new HttpsError('not-found', 'Guide not found.');
  }
  const pricePerHour = Number(profileSnap.data().pricePerHour) || 0;
  const feeRate = await operationalFeeRate('privateServiceFeeRate', 0.05);
  const price = privatePricing({pricePerHour, hours: durationHours, travelers, feeRate});
  const bookingRef = db.collection('bookings').doc();
  try {
    await db.runTransaction(async (tx) => {
      const keySnap = await tx.get(keyRef);
      if (keySnap.exists) {
        const c = guards.classifyKeyConflict({
          keyExists: true,
          keyTouristId: keySnap.data().touristId,
          callerUid: touristId,
          bookingId: keySnap.data().bookingId,
        });
        if (c.action === 'deny') {
          throw new HttpsError('permission-denied', 'Duplicate booking reference.');
        }
        throw new HttpsError('already-exists', c.bookingId);
      }
      tx.set(bookingRef, {
        touristId,
        bookingType: 'private',
        guideId,
        placeId: d.placeId || null,
        appointmentAt: parsedAppt.date ? admin.firestore.Timestamp.fromDate(parsedAppt.date) : null,
        timeSlot: String(d.timeSlot || ''),
        seats: travelers,
        durationHours,
        unitPrice: round2(pricePerHour),
        serviceFee: price.fee,
        totalAmount: price.total,
        currency: 'EGP',
        status: 'pending',
        paymentStatus: 'pending',
        meetingPoint: String(d.meetingPoint || ''),
        specialRequests: String(d.specialRequests || ''),
        idempotencyKey,
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });
      tx.set(keyRef, {
        bookingId: bookingRef.id,
        touristId,
        createdAt: FieldValue.serverTimestamp(),
      });
    });
  } catch (e) {
    if (e instanceof HttpsError && e.code === 'already-exists') {
      return fetchDeduped();
    }
    throw e;
  }
  const created = await bookingRef.get();
  await notify({
    userId: guideId,
    title: 'New private booking request',
    message: `${travelers} traveler(s) requested a private tour.`,
    type: 'booking_created',
    relatedEntityId: bookingRef.id,
    relatedCollection: 'bookings',
  });
  return {id: created.id, ...created.data()};
});

// ── onTripCreated: normalize + confirm submission ────────────────

exports.onTripCreated = onDocumentCreated('trips/{tripId}', async (event) => {
  const snap = event.data;
  if (!snap) return;
  const data = snap.data() || {};
  const patch = {};
  if (data.approvalStatus !== 'pending') patch.approvalStatus = 'pending';
  if (typeof data.title === 'string' && !data.titleLower) patch.titleLower = data.title.toLowerCase();
  if (data.bookedSeats == null) patch.bookedSeats = 0;
  patch.updatedAt = FieldValue.serverTimestamp();
  if (Object.keys(patch).length > 1) {
    await snap.ref.set(patch, {merge: true});
  }
  if (data.guideId) {
    await notify({
      userId: data.guideId,
      title: 'Trip submitted for review',
      message: `"${data.title || 'Your trip'}" is pending admin approval.`,
      type: 'trip_submitted',
      relatedEntityId: snap.id,
      relatedCollection: 'trips',
    });
  }
});

// ── onTripUpdated: re-pend approved trips whose commercial terms changed ──
//
// Decided product rule: edits to price/capacity/date on an APPROVED trip send
// it back to `pending` (stale bookings keep their locked-in price; future
// bookers see the new terms only after re-approval). Editorial fixes
// (title/location/about/…) stay live. Loop-safe: the trigger's own write is
// approved→pending, which the guard below ignores; admin decisions and
// pending-trip edits never match the guard.

exports.onTripUpdated = onDocumentUpdated('trips/{tripId}', async (event) => {
  const before = event.data?.before?.data() || {};
  const after = event.data?.after?.data();
  if (!after) return;
  if (!guards.shouldRependTrip(before, after)) return;
  await event.data.after.ref.set({
    approvalStatus: 'pending',
    rejectionReason: '',
    updatedAt: FieldValue.serverTimestamp(),
  }, {merge: true});
  if (after.guideId) {
    await notify({
      userId: after.guideId,
      title: 'Trip needs re-review',
      message: `"${after.title || 'Your trip'}" was edited and is pending admin approval again.`,
      type: 'trip_resubmitted',
      relatedEntityId: event.params.tripId,
      relatedCollection: 'trips',
    });
  }
});

// ── onBookingStatusChanged: capacity release + guide notice ──────

exports.onBookingStatusChanged = onDocumentUpdated('bookings/{bookingId}', async (event) => {
  const before = event.data?.before?.data();
  const after = event.data?.after?.data();
  if (!before || !after) return;
  if (before.status === after.status) return;
  // Release capacity when a public booking is cancelled. Retry-safe: a
  // `capacityReleased` marker is set in the SAME transaction as the
  // decrement, so at-least-once redelivery can never double-release.
  if (after.status === 'cancelled' && before.status !== 'cancelled' && after.bookingType === 'public' && after.tripId) {
    const bookingRef = db.collection('bookings').doc(event.params.bookingId);
    await db.runTransaction(async (tx) => {
      const bsnap = await tx.get(bookingRef);
      if (!bsnap.exists) return;
      const bdata = bsnap.data() || {};
      if (bdata.status !== 'cancelled' || bdata.capacityReleased === true) return;
      const seats = Number(bdata.seats) || 0;
      if (seats > 0 && bdata.tripId) {
        const tripRef = db.collection('trips').doc(String(bdata.tripId));
        const tripSnap = await tx.get(tripRef);
        if (tripSnap.exists) {
          tx.update(tripRef, {
            bookedSeats: FieldValue.increment(-seats),
            updatedAt: FieldValue.serverTimestamp(),
          });
        }
      }
      tx.set(bookingRef, {capacityReleased: true}, {merge: true});
    });
  }
  if (after.guideId) {
    await notify({
      userId: after.guideId,
      title: after.status === 'cancelled' ? 'Booking cancelled' : `Booking ${after.status}`,
      message: `Booking ${event.params.bookingId} is now ${after.status}.`,
      type: 'booking_updated',
      relatedEntityId: event.params.bookingId,
      relatedCollection: 'bookings',
    });
  }
});

// ── cancelBooking (callable): the ONLY path for paid cancellations ──
//
// Decides refund bookkeeping WITHOUT moving money (no refund policy exists —
// `refundStatus: 'owed'` flags manual handling). Unpaid bookings may also use
// this path; the direct client write stays available for unpaid only (rules).
// Capacity release happens in `onBookingStatusChanged` (idempotent marker).

exports.cancelBooking = onCall(async (request) => {
  const uid = requireAuth(request);
  const {bookingId, reason = ''} = request.data || {};
  if (!bookingId) throw new HttpsError('invalid-argument', 'bookingId is required.');
  const ref = db.collection('bookings').doc(String(bookingId));
  const snap = await ref.get();
  if (!snap.exists) throw new HttpsError('not-found', 'Booking not found.');
  const b = snap.data();
  const owner = b.touristId === uid;
  if (!owner && !(await isAdminUid(uid))) {
    throw new HttpsError('permission-denied', 'Not your booking.');
  }
  if (b.status === 'cancelled') {
    return {id: ref.id, status: 'cancelled', _deduped: true};
  }
  if (!['pending', 'confirmed'].includes(b.status)) {
    throw new HttpsError('failed-precondition', `Booking is ${b.status}.`);
  }
  const paid = b.paymentStatus === 'succeeded';
  await ref.set({
    status: 'cancelled',
    cancelReason: String(reason || ''),
    cancelledAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
    refundStatus: paid ? 'owed' : 'none',
    refundAmount: paid ? Number(b.totalAmount) || 0 : 0,
  }, {merge: true});
  return {id: ref.id, status: 'cancelled', refundStatus: paid ? 'owed' : 'none'};
});

// ── decideTripStatus (admin callable) ─────────────────────────────

exports.decideTripStatus = onCall(async (request) => {
  const adminUid = await requireAdmin(request);
  const {tripId, decision, rejectionReason = ''} = request.data || {};
  if (!tripId || !['approved', 'rejected', 'cancelled'].includes(decision)) {
    throw new HttpsError('invalid-argument', 'tripId and a valid decision are required.');
  }
  const ref = db.collection('trips').doc(String(tripId));
  const snap = await ref.get();
  if (!snap.exists) throw new HttpsError('not-found', 'Trip not found.');
  await ref.set({
    approvalStatus: decision,
    rejectionReason: decision === 'rejected' ? String(rejectionReason) : '',
    updatedAt: FieldValue.serverTimestamp(),
  }, {merge: true});
  const guideId = snap.data().guideId;
  if (guideId) {
    await notify({
      userId: guideId,
      title: decision === 'approved' ? 'Trip approved' : `Trip ${decision}`,
      message: `"${snap.data().title || 'Your trip'}" was ${decision} by the admin team.`,
      type: 'trip_decided',
      relatedEntityId: String(tripId),
      relatedCollection: 'trips',
    });
  }
  return {tripId: String(tripId), approvalStatus: decision, decidedBy: adminUid};
});

// ── decideVerification (admin callable) ───────────────────────────

exports.decideVerification = onCall(async (request) => {
  const adminUid = await requireAdmin(request);
  const {guideId, decision, rejectionReason = ''} = request.data || {};
  if (!guideId || !['approved', 'rejected'].includes(decision)) {
    throw new HttpsError('invalid-argument', 'guideId and a valid decision are required.');
  }
  const status = decision === 'approved' ? 'approved' : 'rejected';
  // Preserve the guide's submitted document references: the legacy
  // `users.verification` map is shallow-replaced below, so carry the URLs
  // forward instead of wiping them (canonical copies also survive in
  // `guideVerifications/`).
  const userSnap = await db.collection('users').doc(String(guideId)).get();
  const legacyVerification =
    (userSnap.exists && userSnap.data().verification) || {};
  const batch = db.batch();
  batch.set(db.collection('guideVerifications').doc(String(guideId)), {
    status,
    reviewerId: adminUid,
    reviewedAt: FieldValue.serverTimestamp(),
    rejectionReason: decision === 'rejected' ? String(rejectionReason) : '',
  }, {merge: true});
  batch.set(db.collection('guideProfiles').doc(String(guideId)), {
    isVerified: decision === 'approved',
    canPublishTrips: decision === 'approved',
    updatedAt: FieldValue.serverTimestamp(),
  }, {merge: true});
  // Legacy mirror so the existing dashboard banner flips without app update.
  // Submitted document URLs are preserved (see above); only the decision
  // fields are overwritten.
  batch.set(db.collection('users').doc(String(guideId)), {
    isApproved: decision === 'approved',
    verification: {
      ...guards.mergeLegacyVerification(legacyVerification, {
        status,
        canPublish: decision === 'approved',
        rejectionReason: decision === 'rejected' ? String(rejectionReason) : '',
      }),
      reviewedAt: FieldValue.serverTimestamp(),
    },
    updatedAt: FieldValue.serverTimestamp(),
  }, {merge: true});
  await batch.commit();
  await notify({
    userId: String(guideId),
    title: decision === 'approved' ? 'Verification approved' : 'Verification update',
    message: decision === 'approved'
      ? 'Your guide verification was approved. You can now publish trips.'
      : 'Your verification needs attention. Please check the app for details.',
    type: 'verification_decided',
    relatedEntityId: String(guideId),
    relatedCollection: 'guideVerifications',
  });
  return {guideId: String(guideId), status, decidedBy: adminUid};
});

// ── verifyPaymobTransaction (callable, trusted) ───────────────────
//
// Body: {paymentId}. Reads the pending `payments/{paymentId}` doc, queries
// Paymob with the SERVER-side API key (never exposed to Flutter), and on
// success marks payment succeeded + booking paid. Never trusts client status.

exports.verifyPaymobTransaction = onCall(async (request) => {
  const uid = requireAuth(request);
  const {paymentId} = request.data || {};
  if (!paymentId) throw new HttpsError('invalid-argument', 'paymentId is required.');
  const payRef = db.collection('payments').doc(String(paymentId));
  const paySnap = await payRef.get();
  if (!paySnap.exists) throw new HttpsError('not-found', 'Payment not found.');
  const payment = paySnap.data();
  if (payment.touristId !== uid && !(await isAdminUid(uid))) {
    throw new HttpsError('permission-denied', 'Not your payment.');
  }
  // Replay-safe: an already-succeeded payment returns its state with no
  // side effects; anything not pending is never (re)confirmed here.
  if (payment.status === 'succeeded') {
    return {paymentId: String(paymentId), status: 'succeeded', _deduped: true};
  }
  if (payment.status !== 'pending') {
    throw new HttpsError('failed-precondition', `Payment is ${payment.status}.`);
  }
  if (!payment.bookingId) {
    throw new HttpsError('failed-precondition', 'Payment has no booking.');
  }
  const bookingRef = db.collection('bookings').doc(String(payment.bookingId));
  const bookingSnap = await bookingRef.get();
  if (!bookingSnap.exists) {
    throw new HttpsError('failed-precondition', 'Booking no longer exists.');
  }
  const booking = bookingSnap.data();
  // Only a pending+unpaid booking may transition to confirmed. This closes
  // the cancel-then-verify resurrection (capacity was already released).
  const gate = guards.canConfirmAfterVerify({
    bookingStatus: booking.status,
    paymentStatus: booking.paymentStatus,
  });
  if (gate.deduped) {
    return {paymentId: String(paymentId), status: 'succeeded', _deduped: true};
  }
  if (!gate.ok) {
    throw new HttpsError(
      'failed-precondition',
      `Booking is ${booking.status} (${booking.paymentStatus}).`,
    );
  }
  const apiKey = process.env.PAYMOB_API_KEY;
  if (!apiKey) {
    throw new HttpsError('failed-precondition', 'Payment verification is not configured.');
  }
  // Server-side Paymob lookup (order `providerReference`). Any non-success
  // response keeps the payment pending — never marks paid on ambiguity.
  let order = null;
  try {
    const orderId = String(payment.providerReference || '');
    if (!orderId) throw new Error('missing providerReference');
    const authRes = await fetch('https://accept.paymob.com/api/auth/tokens', {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({api_key: apiKey}),
    });
    if (!authRes.ok) throw new Error(`paymob auth HTTP ${authRes.status}`);
    const {token} = await authRes.json();
    const orderRes = await fetch(`https://accept.paymob.com/api/ecommerce/orders/${orderId}`, {
      headers: {Authorization: `Bearer ${token}`},
    });
    if (!orderRes.ok) throw new Error(`paymob order HTTP ${orderRes.status}`);
    order = await orderRes.json();
  } catch (e) {
    throw new HttpsError('unavailable', `Verification lookup failed: ${e.message}`);
  }
  // Amount/currency match against the SERVER booking total: a smaller or
  // foreign-currency order can never confirm this booking.
  const verdict = guards.paymobOrderCoversBooking({
    order,
    expectedCents: guards.toMinorUnits(booking.totalAmount),
    currency: booking.currency,
  });
  if (!verdict.ok) {
    await payRef.set({status: 'pending', updatedAt: FieldValue.serverTimestamp()}, {merge: true});
    return {paymentId: String(paymentId), status: 'pending', reason: verdict.reason};
  }
  // Replay protection: the same provider order must not confirm twice
  // (e.g. referenced from two payment docs). The check and both writes run
  // in ONE transaction so concurrent verifies serialize instead of both
  // passing the check.
  await db.runTransaction(async (tx) => {
    const dup = await tx.get(db.collection('payments')
      .where('providerReference', '==', String(payment.providerReference))
      .where('status', '==', 'succeeded')
      .limit(1));
    if (!dup.empty) {
      throw new HttpsError('failed-precondition', 'Transaction already processed.');
    }
    tx.set(payRef, {status: 'succeeded', verifiedAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp()}, {merge: true});
    tx.set(bookingRef, {
      paymentStatus: 'succeeded',
      status: 'confirmed',
      paymentId: String(paymentId),
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
  });
  await notify({
    userId: payment.touristId,
    title: 'Payment confirmed',
    message: 'Your payment was verified and your booking is confirmed.',
    type: 'payment_succeeded',
    relatedEntityId: String(payment.bookingId || paymentId),
    relatedCollection: 'bookings',
  });
  return {paymentId: String(paymentId), status: 'succeeded'};
});

// ── onPostLikeWritten: likesCount aggregate ───────────────────────

exports.onPostLikeWritten = onDocumentWritten('posts/{postId}/likes/{uid}', async (event) => {
  const postRef = db.collection('posts').doc(event.params.postId);
  const likes = await postRef.collection('likes').count().get();
  await postRef.set({likesCount: likes.data().count, updatedAt: FieldValue.serverTimestamp()}, {merge: true});
});

// ── onReviewWritten: trip/guide rating aggregates (roadmap) ──────

exports.onReviewWritten = onDocumentWritten('reviews/{reviewId}', async (event) => {
  const after = event.data?.after?.data();
  const before = event.data?.before?.data();
  const tripId = (after || before || {}).tripId;
  if (!tripId) return;
  const snap = await db.collection('reviews').where('tripId', '==', tripId).get();
  const ratings = snap.docs.map((d) => Number(d.data().rating) || 0).filter((r) => r >= 1 && r <= 5);
  const avg = ratings.length ? round2(ratings.reduce((a, b) => a + b, 0) / ratings.length) : 0;
  const guideId = (after || before || {}).guideId;
  const batch = db.batch();
  batch.set(db.collection('trips').doc(tripId), {rating: avg, reviewsCount: ratings.length, updatedAt: FieldValue.serverTimestamp()}, {merge: true});
  if (guideId) {
    // Recompute guide average across all their reviewed trips (bounded: last 200 reviews).
    const all = await db.collection('reviews').where('guideId', '==', guideId).limit(200).get();
    const gr = all.docs.map((d) => Number(d.data().rating) || 0).filter((r) => r >= 1 && r <= 5);
    const gAvg = gr.length ? round2(gr.reduce((a, b) => a + b, 0) / gr.length) : 0;
    batch.set(db.collection('guideProfiles').doc(guideId), {ratingAvg: gAvg, ratingCount: gr.length, updatedAt: FieldValue.serverTimestamp()}, {merge: true});
  }
  await batch.commit();
});

// ── cleanupExpiredStories (scheduled, daily) ─────────────────────

exports.cleanupExpiredStories = onSchedule({schedule: 'every 24 hours', timeZone: 'Africa/Cairo'}, async () => {
  const now = admin.firestore.Timestamp.now();
  const snap = await db.collection('stories').where('expiresAt', '<', now).limit(400).get();
  if (snap.empty) return;
  const batch = db.batch();
  snap.docs.forEach((d) => batch.delete(d.ref));
  await batch.commit();
});

// ── provisionAdmin (admin-only callable) ──────────────────────────

exports.provisionAdmin = onCall(async (request) => {
  const caller = await requireAdmin(request);
  const {uid, email} = request.data || {};
  let targetUid = uid ? String(uid) : '';
  if (!targetUid && email) {
    try {
      const user = await admin.auth().getUserByEmail(String(email));
      targetUid = user.uid;
    } catch (_) {
      throw new HttpsError('not-found', 'No user with that email.');
    }
  }
  if (!targetUid) throw new HttpsError('invalid-argument', 'uid or email is required.');
  await admin.auth().setCustomUserClaims(targetUid, {admin: true});
  await db.collection('admins').doc(targetUid).set({
    provisionedBy: caller,
    provisionedAt: FieldValue.serverTimestamp(),
  }, {merge: true});
  await db.collection('users').doc(targetUid).set({
    role: 'admin',
    updatedAt: FieldValue.serverTimestamp(),
  }, {merge: true});
  return {uid: targetUid, admin: true, provisionedBy: caller};
});
