# Triply Foundations — Phase S1 Report

**Status:** complete. Automated verification passes; no new failures vs baseline.  
**Project:** `triply-f9b82` — Firebase SPARK (free) plan.  
**Baseline:** `flutter analyze` = 0 errors / 22 info lints; `flutter test` = 50 pass / 1 known failing template test (`test/widget_test.dart`).

> **Scope note:** The manual Paymob verification checklist (card / wallet / private booking / cancel / expiry) requires Khaled with real Paymob test keys and test accounts. I cannot perform Paymob calls or create test documents against Firestore. Everything below that is automatable has been done and verified; the manual items are listed as **pending Khaled**.

---

## 1. Platform & guard compliance

| Check | Result |
|-------|--------|
| Active Firebase project id | `triply-f9b82` (confirmed via `firebase use`; printed before the rules deploy) |
| Plan | Spark (free); billing not touched |
| `functions/` folder | None; no Cloud Functions needed |
| Deploy performed | `firebase deploy --only firestore:rules` to `triply-f9b82` (no force flag) |
| Rules backup | `firestore.rules.before-S1` saved before deploy |

Rollback for the rules deploy: restore `firestore.rules.before-S1` over `firestore.rules` and run `firebase deploy --only firestore:rules` (no force flag).

---

## 2. Task 0 — Rules patch (deployed)

`firestore.rules` compiled and was **released** to project `triply-f9b82` (`cloud.firestore`).

**(a) `trips` seat-counter rule** — `bookedSeats` may now grow OR shrink, bounded to `[0, capacity]`. The old grow-only check (`bookedSeats > resource.data.bookedSeats`) was replaced with `bookedSeats >= 0 && bookedSeats <= capacity`, same `affectedKeys().hasOnly(['bookedSeats', 'updatedAt'])`. This lets cancel/expiry release seats.

**(b) `bookings` update rule** — the owning tourist may now update to `status: 'cancelled'` (with the cancel fields) even when `paymentStatus == 'paid'`, in addition to the existing `paymentStatus == 'pending'` withdraw path. The cancel path is scoped to `affectedKeys().hasOnly(['status', 'cancelledAt', 'cancelledBy', 'refundStatus', 'updatedAt'])`. Nothing else changed; S3 tightens the rest.

**Guide/admin booking-`status` reads inventory** (so the new `confirmed` meaning does not break them):
- `lib/features/admin_dashboard/d_bookings/view/d_bookings_view.dart:173,249` — reads `booking.status`, but `booking` is `MockBooking` from the **mock session store** (`d_mock_notifications.dart`), not live Firestore bookings. Unaffected.
- `lib/features/tour_guide/home_and_notification_tg/cubit/booking_details_cubit.dart` — reads a live booking via `fetchBookingDetails`, but the `BookingDetails` model does **not** read `status`/`paymentStatus`. Unaffected.
- `lib/features/tourist/my_trips/cubit/my_trips_cubit.dart:85` — reads `TouristBooking.status` (live Firestore); this is the tourist screen, and S1 now maps `confirmed`+`endAt` past → `Completed` (display only) and expired `pending` → `cancelled`.

No live guide/admin screen reads or writes booking `status` that would break.

---

## 3. Files changed

| File | What changed |
|------|-------------|
| `firestore.rules` | Task 0 rules patch (deployed) — seats may decrease; tourist may cancel paid bookings |
| `lib/core/data/repositories/booking_repository.dart` | `createPublicBooking`/`createPrivateBooking` now write `status: 'pending'`, `paymentStatus: 'pending'` + `startAt`, `endAt`, `expiresAt` (now+30m), `paymentMethod`, `refundStatus: 'none'`, `createdAt`; added `confirmPayment(...)` and `cancelBooking(...)` (cancels + releases public-trip seats in one transaction) |
| `lib/core/data/models/tourist_booking.dart` | Reads `paymentStatus`, `expiresAt`, `endAt` (tolerant of missing fields) |
| `lib/features/tourist/booking_public/cubit/booking_public_cubit.dart` | `createBooking(tripId, unitPrice)` creates pending/pending + reserves seats; `confirmPayment(bookingId, paymentId)` → confirmed/paid; `changePaymentMethod(card\|wallet)` |
| `lib/features/tourist/booking_public/cubit/booking_public_state.dart` | Added `paymentMethod` field |
| `lib/features/tourist/booking_public/view/booking_public_screen.dart` | Flow reworked: create pending booking → Paymob WebView → on success `confirmPayment`; on failure/close stays pending. Added Card/Wallet selector |
| `lib/features/tourist/booking/cubit/booking_cubit.dart` | Added `startAt` (date+time) and `endAt` (start + duration hours) getters |
| `lib/features/tourist/booking/view/booking_screen.dart` | Private booking: create pending/pending with `startAt`/`endAt`/`paymentMethod` before PaymentView; on success `confirmPayment`; false refund claim removed |
| `lib/features/tourist/my_trips/cubit/my_trips_cubit.dart` | Lazy expiry: pending bookings past `expiresAt` are cancelled and seats released on load; confirmed booking whose `endAt` passed shows as `Completed` (display only) |
| `lib/features/tourist/my_trips/view/my_trips_screen.dart` | Cancel/delete message changed to "booking cancelled; the team will handle the refund (test payment)" (false refund claim removed) |

Additive only — nothing renamed or deleted.

---

## 4. Price formulas (unchanged meaning, new fields added)

- **Public trip:** `total = (unitPrice × seats) + (unitPrice × seats × 0.05)` = `unitPrice × seats × 1.05` (`booking_repository.dart`, `booking_public_cubit.dart`).
- **Private trip:** `total = totalPrice` passed in by the caller; no service-fee computation in `createPrivateBooking`.

---

## 5. Tests added

| Test file | What it covers |
|-----------|----------------|
| `test/core/data/models/tourist_booking_test.dart` | `TouristBooking.fromDocument` reads `paymentStatus`/`expiresAt`/`endAt`/`status`/`seats`/`totalPrice`, tolerates missing fields, `traveler_count` fallback |
| `test/features/tourist/booking_public/cubit/booking_public_cubit_test.dart` | `subtotal`/`fee`/`total` (5% fee), `changePaymentMethod(card\|wallet)` with invalid-method rejection, seat clamping |
| `test/features/tourist/booking/cubit/booking_cubit_test.dart` | `startAt` from date+time (12h, Arabic meridiem, midnight/noon), `endAt` = start + duration hours (4h / Full Day 8h) |

No UI redesign; tests avoid Firestore (no Firebase app needed in plain unit tests).

---

## 6. Numbers vs baseline

| Check | Baseline | After S1 | Result |
|-------|----------|----------|--------|
| `flutter analyze` errors | 0 | 0 | PASS |
| `flutter analyze` info lints | 22 | 22 | PASS (no new lints) |
| `flutter test` passing | 50 | 69 | PASS (+19 new, all pass) |
| `flutter test` failing | 1 (`widget_test.dart` template) | 1 (same) | PASS (no new failures) |

No new failures compared with baseline; did not continue past any failure (none occurred).

---

## 7. Manual checklist (pending Khaled — Paymob test mode required)

I cannot run these (no Paymob calls, no test documents created by me). To be executed by Khaled with Paymob sandbox/test keys (stated by Khaled, not verified by code) and `isTest: true` test accounts:

| # | Manual check | Status |
|---|--------------|--------|
| (a) Public booking paid by card | pending Khaled |
| (b) Public booking paid by wallet (test number) | pending Khaled |
| (c) Private booking with date, time, hours | pending Khaled |
| (d) Cancel a paid booking | pending Khaled |
| (e) Close Paymob WebView without paying → expires after 30 min when My Trips opens | pending Khaled |

After Khaled's run: read the results (read-only), check fields and seat counts, then delete **all** test data created and confirm deletion. Every test account/document must be flagged `isTest: true`.

---

## 8. Test data

No test accounts or documents were created in this phase (no app execution against Firestore; only local `flutter analyze`/`flutter test`). **Nothing to delete; confirmed none exists.**

---

## Verdict

**Phase S2 may start: YES** (S1 automated checks all PASS; manual Paymob checklist pending Khaled).

Files changed/deployed as listed above. Rollback for the rules deploy: restore `firestore.rules.before-S1` and redeploy `--only firestore:rules`.