# Triply Foundations — Phase S0 Preflight Report

**Status:** complete (read-only, nothing changed or deployed).  
**Project:** `triply-f9b82` — Firebase SPARK (free) plan, no Cloud Functions.  
**Baseline preserved:** `flutter analyze` = 0 errors / 22 info lints; `flutter test` = 50 pass / 1 known failing template test (`test/widget_test.dart`).

---

## 1. Platform

| Check | Result |
|-------|--------|
| Active Firebase project id | `triply-f9b82` (from `firebase.json` → `flutter.platforms.android.default.projectId` and `dart.lib/firebase_options.dart` projectId) |
| Plan | Spark (free) — read-only check; billing not touched. Consistent with: no `functions/` folder, `firebase.json` only configures `firestore.rules` + `firestore.indexes.json`. |
| `functions/` folder | Does not exist (`Test-Path functions` → False). No Cloud Functions are needed or referenced by the app. |
| Deploy targets available | `--only firestore:rules` and `--only firestore:indexes` only (per `firebase.json`). |

The project id `triply-f9b82` matches the required value, so S1-S3 deploys (rules only) would target the correct project. No deploy was performed in S0.

---

## 2. Paymob (no calls to Paymob made)

The app reads Paymob configuration exclusively from `lib/features/tourist/checkout/paymob_settings.dart`, which pulls each value from `.env` (a git-ignored, bundled asset — `git ls-files .env` → no match). Variable **names** (values not read, not printed):

| Variable name | Where read | Purpose (per code comments / audit) |
|---------------|------------|-------------------------------------|
| `PAYMOB_API_KEY` | `paymob_settings.dart:28` (`apiKey` getter) | Paymob authentication (`/api/auth/tokens`) |
| `PAYMOB_INTEGRATION_ID` | `paymob_settings.dart:32` | Card integration id |
| `PAYMOB_IFRAME_ID` | `paymob_settings.dart:36` | Hosted iframe id |
| `PAYMOB_WALLET_INTEGRATION_ID` | `paymob_settings.dart:41` (`''` fallback) | Wallet integration id (optional) |

Test/live determination: **not inferred from key text**. Khaled has stated the keys are Paymob sandbox/test keys — recorded as "stated by Khaled, not verified by code". No Paymob API calls were made in S0.

---

## 3. Baselines (recorded before any change)

| Command | Result | Matches known baseline? |
|---------|--------|-------------------------|
| `flutter analyze` | 0 errors, 22 info lints (ran in 7.1s) | Yes |
| `flutter test` | 50 tests pass, 1 failing (`test/widget_test.dart` "Counter increments smoke test" — the known failing template test) | Yes |

Flutter 3.44.2, Dart 3.12.2.

---

## 4. Compatibility inventory

Every place the app reads or writes `bookings`, `trips`, `users` fields relevant to Foundations.

### 4a. `bookings` — fields written

**`lib/core/data/repositories/booking_repository.dart`**

`createPublicBooking` (public trip booking, lines 74-171) writes one booking document inside a transaction that also bumps `trips.bookedSeats`:

| Line | Field | Value written |
|------|-------|---------------|
| 120 | `trips.bookedSeats` | `booked + seats` (seat reservation, grows, capped by capacity) |
| 121 | `trips.updatedAt` | `FieldValue.serverTimestamp()` |
| 123-146 | `bookings.<fields>` | see field list below |

Booking document fields written (public):
- `tripId` (124), `touristId` (125), `guideId` (126), `tour_title` (127), `guest_name` (128), `country` (129), `traveler_count` (130), `seats` (131), `avatar_url` (132), `is_private: false` (133), `unitPrice` (134), `serviceFee` (135), `totalPrice` (136), `price_label` (137), `detail_label` (138), `datetime_label` (139), `location` (140), `booking_code` (141), `specialRequests` (142), `status: 'pending'` (143), `paymentStatus: 'paid'` (144), `createdAt` (145)

`fetchMyBookings` (lines 177-191) reads `bookings` where `touristId == uid` (line 183).

`createPrivateBooking` (private guide booking, lines 194-258) writes one booking document (no trip, no seat reservation):

| Line | Field | Value written |
|------|-------|---------------|
| 218 | `tripId` | `''` |
| 219 | `touristId` | `uid` |
| 220 | `guideId` | `guideId` |
| 221-235 | `tour_title, guest_name, country, traveler_count, seats, avatar_url, is_private: true, totalPrice, price_label, detail_label, datetime_label (''), location, booking_code, notes, specialRequests` | from args / guest profile |
| 236 | `status` | `'pending'` |
| 237 | `paymentStatus` | `'paid'` |
| 238 | `createdAt` | `FieldValue.serverTimestamp()` |

### 4b. `bookings` — status and paymentStatus literals

| File:line | Literal | Context |
|-----------|---------|---------|
| `booking_repository.dart:143` | `status: 'pending'` | public booking create |
| `booking_repository.dart:144` | `paymentStatus: 'paid'` | public booking create |
| `booking_repository.dart:236` | `status: 'pending'` | private booking create |
| `booking_repository.dart:237` | `paymentStatus: 'paid'` | private booking create |
| `mock_booking_details.dart:28` | `paymentStatus: 'pending'` | mock data |
| `mock_booking_details.dart:42` | `paymentStatus: 'paid'` | mock data |
| `mock_booking_details.dart:56` | `paymentStatus: 'pending'` | mock data |
| `booking.dart:31,48` | `status = 'pending'` / default | private-booking model (tourist screen) |
| `booking_public.dart:19,30` | `status = 'pending'` / default | public-booking model |
| `my_bookings_public.dart:11` | `statusPending = 'pending'` | session-only mock store |

Note: currently **both** public and private bookings are created with `paymentStatus: 'paid'`. Phase S1 changes new bookings to `paymentStatus: 'pending'` until the Paymob WebView reports success.

### 4c. Seat changes on `trips.bookedSeats`

| File:line | Operation |
|-----------|-----------|
| `booking_repository.dart:108` | read `booked = trip['bookedSeats']` |
| `booking_repository.dart:120` | write `bookedSeats: booked + seats` (reserve, grow-only, `<= capacity`) |
| `guide_trips_repository.dart:260` | write `'bookedSeats': trip.bookedSeats` (trip publish/edit) |
| `guide_trips_repository.dart:135` | read `bookedSeats` for dashboard query |
| `public_trip.dart:53,82,99,146,175` | `bookedSeats` field; `availableSeats = capacity - bookedSeats`; default `0`; read from doc |
| `guide_trip.dart:50,78,109,128,149` | `bookedSeats` field; default `0`; `availableSeats` getter; read/write |
| `admin_trips_repository.dart:23,49,62,214` | `bookedSeats` field; `travelers` getter; read from doc |
| `place_detail_cubit.dart:169` | read `trip.bookedSeats` → `peopleCount` |
| `create_trip_cubit.dart:392` | `bookedSeats: existingTrip.bookedSeats` (edit preserves) |
| `my_trips_cubit.dart:98` | `peopleCount: booking.seats > 0 ? booking.seats : trip.bookedSeats` |
| `home_cubit.dart:200` | `bookedSeats: 0` (mock seed) |
| `popular_cubit.dart:86` | read `peopleCount` as `bookedSeats` |
| `trips (tourist model).dart:37` | `peopleCount: trip.bookedSeats` |
| `mock_guide_trips.dart:27,44,61,78,95` | mock `bookedSeats` values (3, 3, 0, 0, 0) |

### 4d. Price formula

**Public trips** (`booking_repository.dart:91-92`):
```
serviceFee = unitPrice * seats * 0.05
total      = unitPrice * seats + serviceFee   // = unitPrice * seats * 1.05
```
Stored as `unitPrice`, `serviceFee`, `totalPrice`, `price_label: 'EGP ${total.toStringAsFixed(0)}'`.

**Private trips** (`booking_repository.dart:199,228`):
```
totalPrice = value passed in by the caller (no service-fee computation in createPrivateBooking)
```
Stored as `totalPrice`, `price_label: 'EGP ${totalPrice.toStringAsFixed(0)}'`.

### 4e. `trips.startAt` / `trips.endAt`

`startAt` is read and written; **`endAt` is not used anywhere in the app** (zero matches for `endAt` in `lib/`).

| File:line | Field | Operation |
|-----------|-------|-----------|
| `guide_trips_repository.dart:254-256` | `startAt` | write `'startAt': Timestamp.fromDate(trip.startAt!)` (trip publish/edit) |
| `guide_trip.dart:61,82,100,132,153` | `startAt` | `DateTime?` field; constructor param; `parseGuideDate(json['startAt'])` read; `'startAt': startAt?.toIso8601String()` write; `start` helper (100) |
| `create_trip_cubit.dart:244-272` | `startAt` | getter parsing date (`d/m/yyyy`) + time (`h:mm AM/PM`) pickers |
| `create_trip_cubit.dart:299,396` | `startAt` | `buildTrip`: `startAt: starts`; `saveEdit`: `startAt: starts ?? existingTrip.startAt` |
| `create_trip_screen.dart:55-56` | `startAt` | initial trip `startAt` parsed for pickers |
| `mock_guide_trips.dart:22,39,56,73,90` | `startAt` | mock ISO timestamps |
| `guide_seed.dart:80` | `startAt` | `startAt: trip.startAt` (seed) |
| `mock_booking_details.dart:99,112,114` | `startAt` | mock: `DateTime.parse(trip['startAt'])` → datetime label |
| `endAt` | — | **not referenced anywhere in `lib/`** |

### 4f. `users.displayName` / `users.avatarUrl`

**`displayName` reads (Firebase Auth `currentUser?.displayName`, not necessarily the Firestore `users` doc):**
- `auth_cubit.dart:80` — `name: user?.displayName`
- `guide_dashboard_screen.dart:150` — `firebaseName = authUser?.displayName?.trim() ?? ''`
- `profile_screen.dart:37-38,74` — `firebaseUser?.displayName`
- `home_screen.dart:53` — `name = user?.displayName ?? ''`
- `create_trip_cubit.dart:582` — `guideName: firebaseUser?.displayName?.trim() ?? ''`
- `trip_details_tg_cubit.dart:60` — `name = ... displayName`
- `admin_auth_cubit.dart:102` — `credential.user!.displayName`
- `profile_tg_cubit.dart:199,201,219` — `displayName` getter / `user?.displayName`

**`avatarUrl` reads/writes:**
- `public_guide.dart:11,31,49,66` — `avatarUrl` field; read `merged['avatarUrl']`; default `''`
- `guide_dashboard_repository.dart:127,242,249` — `avatarUrl: base.avatarUrl`; `'avatarUrl': ''`; `merged['avatarUrl'] = data?['avatar_url']`
- `tour_guide_auth_service.dart:129,180` — `'avatarUrl': ''` (create/update user profile)
- `booking_repository.dart:273-274` — reads `users` doc (guest profile) for `photoUrl` → written to booking `avatar_url`
- Multiple guide/traveler models read `avatar_url`/`avatarUrl` from JSON (tourist `guide.dart`, `place_details/guide.dart`, `tour_guide/profile_tg/model/guide.dart`, `home/model/guide.dart`, `travelers_tg/model/traveler.dart`, `guide_dashboard_booking_request.dart`, `guide_dashboard_stats.dart`, `booking_details.dart`).

The Firestore `users` document fields relevant here are `displayName` and `avatarUrl` (written via auth service / profile edits; read via `users/{userId}`). Phase S2 adds profile-edit saving of `users.displayName` / `users.avatarUrl` and a one-off `displayName` backfill.

---

## 5. Current Firestore rules (bookings, trips, users)

Copied verbatim from `firestore.rules`.

### users (`match /users/{userId}`, lines 40-66)

```
match /users/{userId} {
  allow get: if isOwner(userId) || isAdmin();
  // Listing exposes phone + email, so it is admin-only.
  allow list: if isAdmin();

  allow create: if isOwner(userId)
    && (
      // A tourist or a guide claims their own role.
      (request.resource.data.role in ['tourist', 'guide']
        && (!('isActive' in request.resource.data)
            || request.resource.data.isActive == true))
      // The first account of the project may claim the admin role.
      || (request.resource.data.role == 'admin' && noAdminExists())
    );

  allow update: if isAdmin()
    || (isOwner(userId)
        // `.get(..., default)` on purpose: dot-access on a missing
        // field ERRORS, and that error denies the whole rule — so a
        // guide whose document has no `isActive` could never edit
        // their own profile.
        && request.resource.data.get('role', '') == resource.data.get('role', '')
        && request.resource.data.get('isActive', false) == resource.data.get('isActive', false)
        && request.resource.data.get('isApproved', false) == resource.data.get('isApproved', false));

  allow delete: if isAdmin();
}
```

### trips (`match /trips/{tripId}`, lines 177-223)

```
match /trips/{tripId} {
  // Tourists see approved trips, the owner sees their own, admins see
  // everything. Rules are evaluated per document, so a query has to
  // constrain itself (approved trips / own trips).
  allow get: if resource.data.approvalStatus == 'approved'
    || (isSignedIn() && resource.data.guideId == request.auth.uid)
    || isAdmin();

  allow list: if resource.data.approvalStatus == 'approved'
    || (isSignedIn() && resource.data.guideId == request.auth.uid)
    || isAdmin();

  allow create: if isSignedIn()
    && request.resource.data.guideId == request.auth.uid
    && request.resource.data.approvalStatus == 'pending'
    && request.resource.data.title is string
    && request.resource.data.priceEgp is number
    && request.resource.data.capacity is int
    && request.resource.data.capacity > 0
    // The booked counter is owned by the booking flow, never by the
    // publisher.
    && request.resource.data.bookedSeats == 0;

  // The owner edits the content but cannot touch the workflow fields.
  allow update: if isAdmin()
    || (isSignedIn()
        && resource.data.guideId == request.auth.uid
        && request.resource.data.guideId == resource.data.guideId
        && request.resource.data.bookedSeats == resource.data.bookedSeats
        // The owner may not approve their own trip, but they may send
        // a rejected one back for review.
        && (request.resource.data.approvalStatus
              == resource.data.approvalStatus
            || (resource.data.approvalStatus == 'rejected'
                && request.resource.data.approvalStatus == 'pending')));

  // Booking a trip bumps the booked counter. Only that counter may
  // change, it may only grow, and it may never exceed the capacity.
  allow update: if isSignedIn()
    && request.resource.data.diff(resource.data).affectedKeys()
         .hasOnly(['bookedSeats', 'updatedAt'])
    && request.resource.data.bookedSeats > resource.data.bookedSeats
    && request.resource.data.bookedSeats <= request.resource.data.capacity;

  allow delete: if isAdmin()
    || (isSignedIn() && resource.data.guideId == request.auth.uid);
}
```

### bookings (`match /bookings/{bookingId}`, lines 229-258)

```
match /bookings/{bookingId} {
  allow get: if isSignedIn()
    && (resource.data.touristId == request.auth.uid
        || resource.data.guideId == request.auth.uid
        || isAdmin());

  allow list: if isSignedIn()
    && (resource.data.touristId == request.auth.uid
        || resource.data.guideId == request.auth.uid
        || isAdmin());

  allow create: if isSignedIn()
    && request.resource.data.touristId == request.auth.uid
    && request.resource.data.tripId is string
    && request.resource.data.guideId is string
    && request.resource.data.seats is int
    && request.resource.data.seats > 0
    && request.resource.data.totalPrice is number;

  // The tourist may withdraw their own unpaid booking; everything
  // else belongs to the guide or the admin.
  allow update: if isAdmin()
    || (isSignedIn() && resource.data.guideId == request.auth.uid)
    || (isSignedIn() && resource.data.touristId == request.auth.uid
        && resource.data.paymentStatus == 'pending');

  allow delete: if isAdmin()
    || (isSignedIn() && resource.data.touristId == request.auth.uid
        && resource.data.paymentStatus == 'pending');
}
```

Helper functions used by these rules (lines 7-35): `isSignedIn`, `isOwner`, `userRole`, `isAdmin`, `noAdminExists`.

---

## 6. Price formulas (written out)

- **Public trip:** `total = (unitPrice × seats) + (unitPrice × seats × 0.05)` = `unitPrice × seats × 1.05` (`booking_repository.dart:91-92`).
- **Private trip:** `total = totalPrice` passed in by the caller; no service-fee computation in `createPrivateBooking` (`booking_repository.dart:199,228`).

---

## 7. Verdict

**Phase S1 may start: YES**

All S0 preflight checks passed:
- Project id is `triply-f9b82` (correct); plan is Spark; no `functions/` folder; no Cloud Functions needed.
- Paymob variable names recorded (values not printed); no Paymob calls made; sandbox/test status is "stated by Khaled, not verified by code".
- Baselines recorded: analyze 0 errors / 22 info lints; test 50 pass / 1 known failing template test.
- Compatibility inventory completed (bookings fields/status/paymentStatus/seats/price, trips startAt/endAt, users displayName/avatarUrl) with file:line references.
- Current Firestore rules for bookings/trips/users copied into this report.

Nothing was changed or deployed. S0 is complete; do not proceed to any other phase until this report is reviewed.