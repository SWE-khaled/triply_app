# Triply — Backend & Database Audit Report

> Read-only audit. Branch on disk at audit time: `main` (NOT `Back-end` — see §12). Nothing modified except this file.
> Note: written to `.opencode/plans/` because repo writes were permission-blocked at audit time; move to `docs/` when allowed.
> Conventions: claims cited as `path:line`. "NOT VERIFIED" = could not confirm from files read. No secrets printed; credential files reported by path + git-ignore status only.

---

## 1. Architecture Overview

### 1.1 Layers

```
View (screens)
  → Cubit (state + validation)
    → Repository (wraps datasource + Cloud Functions)
      → Datasource (the ONLY layer calling Firestore directly: lib/data/firestore/datasources/)
      → Cloud Functions via httpsCallable (bookings_repository, admin_repository, admin_auth_cubit)
        → Auth (Firebase Auth: sign-in / claims)
        → Storage (Firebase Storage / Cloudinary — see §6)
```

- Datasources (16): `users_datasource.dart`, `trips_datasource.dart`, `places_datasource.dart`, `bookings_datasource.dart`, `posts_datasource.dart`, `stories_datasource.dart`, `reviews_datasource.dart`, `payments_datasource.dart`, `notifications_datasource.dart`, `guide_profiles_datasource.dart`, `guide_verifications_datasource.dart`, `admins_datasource.dart`, `app_settings_datasource.dart`, `trip_cover_storage.dart`, `community_media_storage.dart`, `cloudinary_uploader.dart`.
- Repositories (9): `trips_repository.dart`, `places_repository.dart`, `guides_repository.dart`, `guide_trips_repository.dart`, `bookings_repository.dart`, `notifications_repository.dart`, `community_repository.dart`, `admin_repository.dart`, `settings_repository.dart`.
- Callables used by Flutter (5): `createBooking` (`bookings_repository.dart:90,126`), `cancelBooking` (`:181`), `verifyPaymobTransaction` (`:223`), `decideVerification` (`admin_repository.dart:283`), `provisionAdmin` (`admin_auth_cubit.dart:231-232`).

### 1.2 Screens: MOCK vs REAL Firestore

| Feature | Screen / file | Data source | Path |
|---|---|---|---|
| Trips feed | `trips/view/trips_screen.dart` | Hybrid-with-flag (`useRemote=true`) | `lib/features/tourist/trips/` |
| Trip details | `trip_details/view/trip_details_screen.dart` | Hybrid-with-flag | `lib/features/tourist/trip_details/` |
| My Trips | `my_trips/view/my_trips_screen.dart` | Hybrid-with-flag (server primary) | `lib/features/tourist/my_trips/` |
| Notifications (tourist) | `notifications/view/notifications_screen.dart` | Hybrid-with-flag | `lib/features/tourist/notifications/` |
| Community | `community/view/community_view.dart` | Hybrid-with-flag | `lib/features/tourist/community/` |
| Place details | `place_details/view/place_details_view.dart` | Hybrid (`useRemote=false` header, `useRemoteTrips=true` tab) | `lib/features/tourist/place_details/` |
| Search | `search/view/search_screen.dart` | Firestore (remote-first, local substring fallback) | `lib/features/tourist/search/` |
| Home | `home/view/home_screen.dart` | **MOCK** (`HomeCubit`) | `lib/features/tourist/home/` |
| Map | `map/view/` | **MOCK** (`MapCubit` → `mockPlaces`) | `lib/features/tourist/map/` |
| Guides list | `guides/view/` | **MOCK** (`GuidesCubit` → `mockGuides`; no repository) | `lib/features/tourist/guides/` |
| Guide profile | `guide_profile_screen.dart` | **MOCK** (`GuideProfileCubit`) | `lib/features/tourist/guides/` |
| Popular trips | `popular/view/` | **MOCK** (`PopularCubit` → `mockTripsJson`) | `lib/features/tourist/popular/` |
| Booking (private) | `booking/view/booking_screen.dart` | MOCK state + REAL `createBooking` (gated `isRemoteGuide`) | `lib/features/tourist/booking/` |
| Booking (public) | `booking_public/view/booking_public_screen.dart` | MOCK state + REAL `createBooking` (gated `trip.isRemote`) | `lib/features/tourist/booking_public/` |
| Checkout/Paymob | `checkout/view/` | **MOCK/placeholder** (Paymob SDK token only; no Firestore write) | `lib/features/tourist/checkout/` |
| User profile | `userProfile/view/` | **MOCK** (`ProfileCubit`) | `lib/features/tourist/userProfile/` |
| Guide dashboard / notifications / booking details / my trips / trip details / travelers / earnings / profile | (feature dirs) | Hybrid (remote-first, mock fallback/baseline) | `lib/features/tour_guide/` |
| Create trip | `create_trip_tg/view/` | Hybrid (session store primary; `submitTripToFirestore` writes remote) | `lib/features/tour_guide/create_trip_tg/` |
| Admin dashboard (all 9 pages) | `d_overview`, `d_trips`, `d_trip_applications`, `d_users`, `d_guides`, `d_bookings`, `d_user_posts`, `d_app_settings`, `d_auth` | **REAL Firestore** via `AdminRepository` | `lib/features/admin_dashboard/` |
| Auth tourist / guide | `auth_repository.dart` / `tour_guide_auth_service.dart` | REAL Firebase Auth + Firestore | `lib/features/common/` |

### 1.3 Flags toggling mock vs real

| Flag | Value | File:line |
|---|---|---|
| `TripsCubit.useRemote` | `true` | `lib/features/tourist/trips/cubit/trips_cubit.dart:20` |
| `TripDetailsCubit.useRemote` | `true` | `lib/features/tourist/trip_details/cubit/trip_details_cubit.dart:20` |
| `MyTripsCubit.useRemote` | `true` | `lib/features/tourist/my_trips/cubit/my_trips_cubit.dart:26` |
| `NotificationsCubit.useRemote` | `true` | `lib/features/tourist/notifications/cubit/notifications_cubit.dart:13` |
| `CommunityCubit.useRemote` | `true` | `lib/features/tourist/community/cubit/community_cubit.dart:19` |
| `PlaceDetailCubit.useRemote` | `false` (header mock) | `lib/features/tourist/place_details/cubit/place_detail_cubit.dart:26` |
| `PlaceDetailCubit.useRemoteTrips` | `true` (trips tab) | `lib/features/tourist/place_details/cubit/place_detail_cubit.dart:32` |
| `GuideNotificationsCubit.useRemote` | `true` | `lib/features/tour_guide/homeandNotificationTr/cubit/guide_notifications_cubit.dart:13` |
| `Trip.isRemote` / `Guide.isRemote` | mapper sets `true` for Firestore cards | `lib/data/firestore/mappers/firestore_mappers.dart:53,177` |
| `CheckoutCubit.sandboxMode` | `true` (Paymob Luhn — NOT a mock/remote toggle) | `lib/features/tourist/checkout/cubit/checkout_cubit.dart:57` |

No `kDebugMode` toggles found in `lib/`.

## 2. Firestore Database

### 2.1 Collections & models

| Collection | Model file | Doc ID strategy | Key fields (required / optional) | Who writes | Who reads |
|---|---|---|---|---|---|
| `users` | `app_user_doc.dart` | uid (Auth uid) | req: uid, fullName, email, phone, role; opt: avatarUrl, isActive, timestamps | Client (signup), `provisionAdmin` | Owner/admin (rules); guide display name lookup |
| `trips` | `trip_doc.dart` | auto-id | req: guideId, title; opt: guideName, placeId, description, location, dateLabel, startTime, duration, priceEgp, currency, capacity, bookedSeats, peopleCount, meetingPoint, included, highlights, itinerary, notes, languages, coverImageUrl, imageUrls, category, approvalStatus, rejectionReason, rating, reviewsCount, timestamps | Guide client (`toCreateMap`); Function stamps status/counters | Tourist feed (approved), guide own, admin |
| `bookings` | `booking_doc.dart` | auto-id (Function) | req: touristId, bookingType, guideId; opt: tripId, placeId, tripDate, appointmentAt, timeSlot, seats, durationHours, unitPrice, serviceFee, totalAmount, currency, status, paymentStatus, paymentId, meetingPoint, specialRequests, idempotencyKey, cancelledAt, cancelReason, timestamps | Cloud Function only (client create=false in rules) | Tourist, guide, admin |
| `bookingKeys` | none (inline) | custom = idempotencyKey | bookingId, touristId, fp (SHA-256), createdAt | `createBooking` Function | `createBooking` only (no client access) |
| `guideProfiles` | `guide_profile_doc.dart` | uid | req: userId; opt: displayName, contactPhone, about, location, languages, specialty, pricePerHour, currency, coverUrl, ratingAvg, ratingCount, isVerified, canPublishTrips, timestamps | Client (flags pinned); `decideVerification` | Tourist guide list; `createBooking` (pricePerHour); admin |
| `guideVerifications` | `guide_verification_doc.dart` | custom = guideId | req: guideId, idDocumentUrl, licenseDocumentUrl; opt: status, submittedAt, reviewerId, reviewedAt, rejectionReason | Guide client; `decideVerification` | Owner/admin; admin queue |
| `places` | `place_doc.dart` | custom stable IDs | req: id, name; opt: city, country, category, type, address, lat/long, rating, reviewsCount, shortDescription, about, highlights, imageUrl(s), timestamps | Admin (rules); seed script | Tourist public; search/map/place details |
| `posts` | `post_doc.dart` | auto-id | req: authorId; opt: authorName, authorAvatarUrl, text, imageUrls, location, likesCount, commentsCount, timestamps | Client (author); Function counters | Public feed |
| `posts/{id}/likes/{uid}` | inline (no model) | uid | uid, createdAt (raw map) | Client owner | Public; `onPostLikeWritten` recount |
| `stories` | `story_doc.dart` | auto-id | req: userId, mediaUrl; opt: userName, isVideo, createdAt, expiresAt | Client (toCreateMap computes expiresAt) | Public active feed |
| `notifications` | `notification_doc.dart` | auto-id (Function) | req: userId, title, message; opt: type, relatedEntityId, relatedCollection, isRead, createdAt | Functions only | Recipient (isRead flips only) |
| `payments` | `payment_doc.dart` | auto-id | req: bookingId, touristId; opt: provider, providerReference, paymentTokenRef, amount, currency, status, timestamps, verifiedAt | Client (pending only); Function (succeeded) | Owner/admin; `verifyPaymobTransaction` |
| `admins` | **NO model file** | uid | provisionedBy, provisionedAt (presence doc) | Console/`provisionAdmin`/bootstrap | `isAdmin()` rules + `AdminsDatasource.isAdmin` |
| `appSettings` | `app_settings_doc.dart` | custom key | req: id, value; opt: updatedBy, updatedAt | Admin (`saveServiceFeeRate`) | Functions (`operationalFeeRate`), admin |
| `reviews` | `review_doc.dart` | custom = tripId_touristId | req: tripId, touristId, guideId, rating; opt: comment, timestamps | Client (own touristId) | Public; aggregates. **No UI — dormant** |

### 2.2 Server-owned fields excluded on client writes

| Model | Excluded fields | Map |
|---|---|---|
| `TripDoc` | bookedSeats, rejectionReason, rating, reviewsCount, peopleCount (create); update strips guideId/bookedSeats/peopleCount/approvalStatus/rejectionReason/createdAt | `trip_doc.dart:157-184` |
| `BookingDoc` | status, paymentStatus, unitPrice, serviceFee, totalAmount (Function-owned) | `booking_doc.dart` toCreateMap |
| `GuideProfileDoc` | isVerified, canPublishTrips, ratingAvg, ratingCount | `guide_profile_doc.dart` toClientMap |
| `GuideVerificationDoc` | status, reviewerId, reviewedAt | `guide_verification_doc.dart` toCreateMap |
| `PostDoc` | likesCount, commentsCount (must be 0 on create) | `post_doc.dart:100-108` |
| `AppUserDoc` | role, isActive, createdAt, uid | `app_user_doc.dart` toClientMap |
| `PaymentDoc` | status (create forces pending) | `payment_doc.dart` toCreateMap |

### 2.3 Relationships

- `trips.guideId` → `guideProfiles/{guideId}` (doc must exist for booking: `functions/index.js:279-282`).
- `posts.authorId` → `users/{uid}`; `posts/{id}/likes/{uid}` → `users/{uid}`.
- `stories.userId`, `notifications.userId` → `users/{uid}`.
- `bookings.tripId` → `trips/{tripId}`; `bookings.guideId` → `guideProfiles`.
- `payments.bookingId` → `bookings/{bookingId}`.
- `users/{uid}` == `guideProfiles/{uid}` == `admins/{uid}` (uid is the stable key).
- `trips.placeId` → `places/{placeId}` (place-details tab).
- `guideVerifications` doc ID == `guideId`.

### 2.4 Orphans

- Collections with NO model: `admins` (presence-doc check — acceptable); `likes` subcollection (inline maps); `users/{uid}.verification` legacy nested map written by `decideVerification` (`functions/index.js:543-561`) — no Dart model (read back-compatibly by `guide_verification_doc.dart`).
- Models with no collection reference: **none** (all 12 models map to used collections).

## 3. Security Rules & Indexes

### 3.1 `firestore.rules` (342 lines) — per collection

Header (`firestore.rules:3-12`): "reviewed, NOT YET DEPLOYED". Trust model: `admins/{uid}` + `admin:true` claim; `triplykl` substring NOT recognized (`:10`). Helpers: `isSignedIn()` `:17-19`, `isAdmin()` `:21-31` (claim OR exists admins doc), `isOwner(uid)` `:33-35`.

| Collection | read | create | update | delete |
|---|---|---|---|---|
| `users/{uid}` | get: owner/admin; list: admin | owner; role ∈ {tourist, guide}; isActive pinned | admin, or owner (pinned) | admin |
| `guideProfiles/{uid}` | public | owner; userId==uid; verification/rating flags pinned | same as create | admin |
| `guideVerifications/{vid}` | get: signed-in + (missing OR owner OR admin); list: admin | owner; status==pending; 6-key allowlist | rejected→pending only | false |
| `places/{placeId}` | public | admin | admin | admin |
| `trips/{tripId}` | get/list: approved OR owner-guide OR admin (per-doc) | signed-in; guideId==self; server-reads users.role=='guide'; approvalStatus==pending; no bookedSeats/rejectionReason keys | admin (decision fields) or guide (identity pinned) | admin or owner guide |
| `bookings/{bookingId}` | get/list: participant or admin | **false** | admin, or owner-tourist cancel of UNPAID (all pinned) | **false** |
| `bookingKeys/{key}` | false | false | false | false |
| `payments/{paymentId}` | get/list: owner or admin | signed-in; touristId==self; status==pending; provider==paymob | **false** | **false** |
| `posts/{postId}` | public | author; counters == 0 | author; counters pinned | owner/admin; `likes/{uid}`: read public, write owner |
| `stories/{storyId}` | public | owner; expiresAt must be Timestamp | **false** | owner/admin |
| `notifications/{id}` | get/list: recipient or admin | **false** | recipient flips isRead only | **false** |
| `reviews/{reviewId}` | public | signed-in; touristId==self; rating 1-5 | same | owner/admin |
| `appSettings/{id}` | public | admin | admin | admin |
| `admins/{uid}` | get: owner/admin; list: admin | **false** | **false** | **false** |

### 3.2 Indexes (`firestore.indexes.json` — 21 composite indexes, `fieldOverrides: []`)

trips: (approvalStatus,createdAt)×2, (guideId,createdAt), (guideId,approvalStatus,createdAt), (approvalStatus,category,createdAt) · bookings: (touristId,createdAt), (guideId,createdAt), (tripId,createdAt) · payments: (providerReference,status) · posts: (createdAt), (authorId,createdAt) · stories: (expiresAt), (userId,expiresAt) · notifications: (userId,createdAt), (userId,isRead) · guideVerifications: (status,submittedAt) · places: (category,rating), (rating), (nameLower) · reviews: (tripId,createdAt) · guideProfiles: (isVerified,ratingAvg).

### 3.3 Query-vs-index audit

- All compound queries in `lib/data/firestore/datasources/` covered by existing indexes (trips feed → #1/#5, guide list → #3/#4, admin pending → #2, bookings → #6/#7/#8, notifications → #14).
- Multi-equality queries needing no composite (single-field merge-join): `trips listByPlace` (`trips_datasource.dart:127-132`), `bookings countActiveForTrip` (`:136-142`), `notifications unreadCount/markAllRead` (`:46-71`).
- **MISSING composite indexes: none identified.** Functions' internal queries (idempotencyKey `:134-135`; payments providerReference+status `:683-686` → #9) run via Admin SDK and bypass client indexes.
- `titleLower` is written (`trip_doc.dart:181`) but never queried.

## 4. Cloud Functions (`functions/index.js`, 827 lines, 12 exports)

Guards: `requireAuth` `:56-61`, `isAdminUid` `:63-78` (claim OR admins doc), `requireAdmin` `:80-86`, `notify` `:88-100` (writes `notifications/`), `operationalFeeRate` `:102-110` (reads `appSettings/{key}.value`, default 0.05). Pure logic in `functions/lib/guards.js`.

| Export | Type | Reads → writes | Key validations |
|---|---|---|---|
| `createBooking` | onCall `:120-351` | trips (approved+capacity), guideProfiles (price), bookingKeys, bookings, trips.bookedSeats | requireAuth; idempotencyKey 8-160 chars no `/`; private: travelers 1-10, durationHours 1-24; **trip must be approved** `:194-196`; server pricing |
| `onTripCreated` | onDocumentCreated trips `:355-387` | trips (merge), notifications | `approvalStatus='pending'` **only when null** `:365-366`; titleLower `:367`; bookedSeats=0 when null `:368`; notify only when needsReview && guideId `:377-386` |
| `onTripUpdated` | onDocumentUpdated trips `:398-418` | trips, notifications | Re-pends approved trip when priceEgp/capacity/dateLabel changed (`shouldRependTrip`); loop-safe |
| `onBookingStatusChanged` | onDocumentUpdated bookings `:422-461` | trips.bookedSeats (tx), capacityReleased marker, notifications | Public booking → cancelled: capacity released once |
| `cancelBooking` | onCall `:470-498` | bookings | Owner/admin; idempotent; pending/confirmed only; refundStatus 'owed' + refundAmount when paymentStatus==='succeeded' `:488-496` |
| `decideTripStatus` | onCall `:502-528` | trips, notifications | requireAdmin; approved/rejected/cancelled; returns decidedBy |
| `decideVerification` | onCall `:532-585` | guideVerifications, guideProfiles, users (legacy verification map), notifications | requireAdmin; batch; preserves submitted URLs |
| `verifyPaymobTransaction` | onCall `:593-707` | payments, bookings, Paymob API, notifications | Owner-or-admin on payment AND booking; replay-safe; pending+pending only `:632-641`; **env `PAYMOB_API_KEY` `:642`** (only env var in index.js); `paymobOrderCoversBooking`; dup-check tx `:682-697` |
| `onPostLikeWritten` | onDocumentWritten likes `:711-715` | posts.likesCount | Recount (clients never write counter) |
| `onReviewWritten` | onDocumentWritten reviews `:719-738` | trips.rating/reviewsCount, guideProfiles.ratingAvg/ratingCount | Recomputes last 200 |
| `cleanupExpiredStories` | onSchedule daily `:742-749` | stories | Hard-delete expired, 400/batch |
| `provisionAdmin` | onCall `:753-827` | admins/{uid}, users/{uid}, custom claims, Auth users | requireAdmin; target email must contain `triplykl` (eligibility only) `:763-769,804-816`; getUserByEmail or createUser (pw≥6) `:780-801`; admin claim `:817` + admins doc `:818-821` + users.role `:822-825` |

### Deployment status: NOT DEPLOYED

- `functions/index.js:4` — "DO NOT DEPLOY without explicit approval".
- `docs/DEPLOYMENT_CHECKLIST.md:3` — "Nothing below has been deployed."
- `docs/FIREBASE_FINAL_AUDIT.md:5` — "Nothing deployed".
- `docs/FIREBASE_IMPLEMENTATION_REPORT.md:59` — "NOT deployed: rules, indexes, functions".
- `.github/workflows/firestore-rules.yml:8-10` — CI never runs `firebase deploy`; runs tests + emulator rules suite on demo-triply `:45-47,83-87`.
- `firebase.json:1` — functions deploy config exists; no `.firebaserc` on disk (verified absent).

## 5. Auth

- **Providers:** email/password for all 3 roles — tourist (`auth_repository.dart:183-197`), guide (`tour_guide_auth_service.dart:135-185`), admin (`admin_auth_cubit.dart:138-141`). Google sign-in: **tourist only** (`auth_repository.dart:8,199-223`; UI `sign_in_screen.dart:151`). Password reset: `auth_repository.dart:225-227`.
- **Role storage:** `users/{uid}.role` (tourist|guide|admin). Tourist signup writes 'tourist' only when doc new (`auth_repository.dart:52-61`); guide signup 'guide' (`tour_guide_auth_service.dart:33-43,102`); 'admin' written **only** by `provisionAdmin` (`functions/index.js:822-825`). Admin privilege stored twice: `admins/{uid}` doc `:818-821` + `admin:true` claim `:817`.
- **Post-login decision:** tourist fail-closed requires 'tourist' else sign-out (`auth_repository.dart:91-126`); guide requires 'guide' (`tour_guide_auth_service.dart:135-185`); admin → `AdminAccessService.isAuthorized` (`admin_access_service.dart:21-28`): `AdminsDatasource.isAdmin` (`admins_datasource.dart:15-20`) **or** `hasAdminClaim` with one forced refresh (`:33-45`). UI-only `isEligibleAdminEmail` (triplykl) grants nothing (`admin_auth_cubit.dart:44-47`).
- **uid-matching:** `users/{uid}`, `guideProfiles/{uid}`, `admins/{uid}` all keyed by the real Auth uid — a provisioned admin only works if the Auth user exists (bootstrap: `bootstrap_first_admin.js:102-115`).

## 6. Storage & Local Persistence

- **Firebase Storage** (`firebase_storage: ^12.3.0`, `pubspec.yaml:23`): ONE usage — `TripCoverStorage` (`trip_cover_storage.dart:3,17-18,32-35`) uploads `trip_covers/{uid}/{ts}_{filename}`; called from `create_trip_cubit.dart:380,473`.
- `storage.rules` exists (`:11-26`: community_posts + trip_covers, owner-write, <5MB, image/*) but header says wire into firebase.json `:5-6` — `firebase.json:1` has **no `storage` key** (not wired/deployed). community_posts rule vestigial (posts → Cloudinary).
- **Cloudinary** primary image path (unsigned preset — rotation = remediation `docs/DEPLOYMENT_CHECKLIST.md:59-61`): `CloudinaryUploader` (`cloudinary_uploader.dart:12-13,17-41`) post photos (`community_media_storage.dart:43`); `CloudinaryService` (`cloudinary_service.dart:9-35`) avatars (`edit_profile_sheet.dart:55`) + verification docs (`tour_guide_verification_screen.dart:107-108`). Functions do no uploads.
- **URL-holding Firestore fields:** `users.avatarUrl` (`app_user_doc.dart:15`), legacy `users.verification.{idDocumentUrl,licenseDocumentUrl}` (`tour_guide_auth_service.dart:202-210`), `guideProfiles.coverUrl` (`guide_profiles_datasource.dart:89`), `guideVerifications.{idDocumentUrl,licenseDocumentUrl}` (`guide_verifications_datasource.dart:22-29`), `trips.{coverImageUrl,imageUrls}` (`trip_doc.dart:178-179`), `posts.{imageUrls,imageUrl}` (`post_doc.dart:100-101`), `places.imageUrls` (`place_doc.dart:61`).
- **Local storage:** NO Hive / SharedPreferences / flutter_secure_storage / path_provider in `pubspec.yaml` (grep `lib/`: zero). Local-only: `.env` (client Paymob keys, `main_emulator.dart:101`, `paymob_service.dart:33-40`) and `MyBookingsPublic` in-memory session map (`my_bookings_public.dart:13`, cleared on logout `auth_provider.dart:92-94`). All persistent state → Firestore; its offline cache disabled in emulator mode (`main_emulator.dart:88`).

## 7. What IS Stored vs NOT Stored

| Data / feature | Stored in | Persists after restart? | Notes |
|---|---|---|---|
| Trips / bookings / payments | Firestore | yes | server-owned status/totals/counters |
| Places | Firestore (seed only) | yes | read-only for tourists |
| Users / guideProfiles | Firestore | yes | role/isActive server-owned |
| Notifications / posts / likes / stories | Firestore | yes | stories auto-expire (24h) |
| Admins | Firestore `admins` + custom claim | yes | Console/Functions only |
| Guide verification docs | Cloudinary URLs in Firestore | yes | |
| Trip cover images | Firebase Storage `trip_covers/` | yes | |
| My bookings (tourist quick view) | **Memory only** (`MyBookingsPublic`) | no | session-only map (`my_bookings_public.dart:13`) |
| Home / map / popular / guides list / guide-profile UI | **MOCK only** | no | never reaches backend |
| Search popular terms | **MOCK** (`mock_search.dart`) | no | |
| Guide earnings / dashboard aggregates | **MOCK** (`mock_earnings.dart`, `mock_guide_dashboard.dart`) | no | display-only maps |
| Emergency contacts / onboarding slides / nav icons | **const in widgets/mock** | n/a | |
| Checkout / payment keys | `.env` (client Paymob) | yes (file) | server reads its own env (`index.js:642`) |
| Reviews | Firestore | yes | **no UI — dormant** |

TODOs/stubs: `review_doc.dart:5-7` (roadmap, no UI); checkout is placeholder (no Firestore write); `seed_booking_prod.js` (untracked, production-targeting — §8); `tool/export_seed_json.dart` referenced by `seed_firestore.js:38` but its output is the checked-in JSON.

## 8. Emulator Mode

### 8.1 Config files & ports

| Service | `firebase.json` (repo) | `.firebase-emulator.local.json` | `C:\Temp\triply-emu\firebase.json` |
|---|---|---|---|
| UI | 4000 | 4000 (127.0.0.1) | 4000 (127.0.0.1) |
| Firestore | **8081** (no host) | **8092** (127.0.0.1) | **8091** (127.0.0.1) |
| Auth | 9099 | 9099 (127.0.0.1) | 9099 (127.0.0.1) |
| Functions | 5001 | 5001 (127.0.0.1) | 5001 (127.0.0.1) |

- `.firebase-emulator.local.json` exists (untracked) with explicit loopback hosts; repo `firebase.json` has no host keys; Temp config uses absolute Windows paths + `functions` junction (`C:\Temp\triply-emu\functions` → repo `functions`). No storage emulator; no export/import flags anywhere. No `.firebaserc` (absent — verified).
- **Port mismatch risk:** three configs, three Firestore ports (8081/8091/8092) — seeding against the wrong one silently writes elsewhere.

### 8.2 Flutter emulator connection

- `lib/main_emulator.dart` (dedicated entry): `EmulatorConfig.validate` `:66` → `useAuthEmulator` `:81`, Firestore `Settings` host `:85-89`, `useFunctionsEmulator` `:90`. Failure → blocking error screen, app never starts (`:94-99`). Config from `--dart-defines` (`TRIPLY_EMULATOR_PROJECT/HOST/AUTH_HOST/FUNCTIONS_HOST/FUNCTIONS_PORT`, doc block `:15-22`).
- `lib/core/firebase/emulator_config.dart`: project must start `demo-` (`:87-89`); hosts banned if ending `googleapis.com`/`firebaseio.com`/`firebaseapp.com`/`cloudfunctions.net` (`:62-73,103-115`); numeric ports only (`:116-121`); malformed → `StateError` (`:40-74`).
- Normal entry `lib/main.dart`: **NO emulator calls** — production options only. A normal run cannot point at the emulator. No platform branching in emulator wiring (Android 10.0.2.2 only mentioned in docs comment — NOT VERIFIED in code).

### 8.3 Risk check

- App → emulator by mistake: impossible in normal run; only via dedicated `main_emulator.dart` + demo defines.
- Emulator config → production: `EmulatorConfig` bans production hosts/projects before Firebase init; app initializes DEFAULT app with demo project id (`main_emulator.dart:73-80`). Seed scripts refuse `triply-f9b82` outright (`seed_booking_demo.js:87-89`, `bootstrap_first_admin.js:82-83`).

### 8.4 Emulator data persistence

In-memory only — no export/import flags in any config; `.firebase/` git-ignored (`.gitignore:58`). No `.firebase/` data dir or emulator-export dir found in the repo (root listing).

### 8.5 Seed scripts

| Script | Purpose | Flags | Safety guards | Collections written | Production? |
|---|---|---|---|---|---|
| `tool/seed_firestore.js` | Import checked-in mock JSON | `--dry-run` (default), `--commit --project`, `--include-orphan-trips` | needs emulator host or creds; prod needs `--allow-prod` + `CONFIRM_PROD=true` `:84-86`; orphans skipped `:63-64`; idempotent merge ≤400/batch `:93-104` | `places` (141), `trips` (0 of 3 — all orphans) | Only with explicit double-guard |
| `tool/seed_booking_demo.js` | Minimal bookable demo data (emulator) | `--project demo-localtest` | strict parseEndpoint (127.0.0.1/localhost + numeric port) `:66-84`; demo-* only `:87-89`; auth host same `:93-95`; bookedSeats preserved `:111-133` | guideProfiles/g1, guide-demo-1, trips/trip-demo-public, users/tourist-demo, users/g1 + 2 Auth users | **NO** |
| `tool/seed_booking_prod.js` (untracked, new) | Production demo trip + guide profile | `--project triply-f9b82` required `:11`; `--commit` needs `--allow-prod` + `CONFIRM_PROD=true` `:12-14`; refuses if `FIRESTORE_EMULATOR_HOST` set `:15-17`; dry-run default `:30` | project-id + env double-guard + emulator refusal; no host allow-list | guideProfiles/g1, guide-demo-1, trips/trip-demo-public (merge; bookedSeats only when absent `:42`) | **YES — only prod-writing script** |
| `tool/bootstrap_first_admin.js` | First demo admin (emulator) | `--project demo-localtest`, `--email`, `--name`; password via `DEMO_ADMIN_PASSWORD` env | strict parseEndpoint `:53-74`; demo-* only `:82-83`; triplykl eligibility `:91-93`; pw ≥6 never logged `:94-96,130` | admins/{uid}, users/{uid}, Auth user, claim `:117-126` | **NO** |

No secrets logged by any script; `pass1234` is a hardcoded emulator-only demo convention (`seed_booking_demo.js:146`).

## 9. MOCK DATA INVENTORY

All 24 files under `lib/core/data/mock/` (16 tourist + 8 tourguide). "Up?" = uploadable to Firestore as-is.

| Mock file | Contents | # items | Model/class | FS collection | Up? | Needed relations | Field mismatches (mock vs model) |
|---|---|---|---|---|---|---|---|
| `tourist/mock_trip_details.dart` | List\<Map\> (camelCase) | 3 (d1-d3) | `TripDetails` | none (denormalized into trips) | No | tripId (present t1-t3) | mock has tag/groupType/guideAvatarUrl/topRatedGuide/priceEgp/notes/itinerary; model lacks guideId/placeId/approvalStatus/bookedSeats/capacity/currency/startTime |
| `tourist/mock_trips_raw.dart` | List\<Map\> | 2 (t1,t2) | home `Trip` | none | No | none | home-model only; no guide_id |
| `tourist/mock_trips_public.dart` | List\<Map\> | 3 (t1-t3) | `Trip` (trips model) | trips | No | **guideId missing** (has guideName only) | lacks placeId/startTime/bookedSeats/currency; TripDoc requires guideId (`trip_doc.dart:50`) |
| `tourist/mock_trips.dart` | List\<Map> → List\<Trip> | 4 (t1-t4) | guides `Trip` | none | No | guide_id present (g1,g2) | lacks approvalStatus/capacity/placeId |
| `tourist/mock_stories.dart` | List\<Map\> | 1 | `Story` | none | No | **userId missing** (has place_id/author_name) | StoryDoc needs userId/mediaUrl/expiresAt |
| `tourist/mock_search.dart` | 3 List\<String> + 1 List\<Map> | 14 | none | none | No | n/a | plain strings, no model |
| `tourist/mock_profile.dart` | Map + List\<String> + String | 4 stats + 3 langs | none (local consts) | none | No | n/a | not a collection |
| `tourist/mock_place_trips.dart` | List\<Map\> | 1 | place `Trip` | trips | No | place_id present | lacks guideId/approvalStatus |
| `tourist/mock_places.dart` | List\<Map\> (3668 lines) | **141** | `Place` | places | No | none needed | mock keys snake_case matching Place.fromJson; **internal inconsistency**: tour_guide nested object `:27-38` vs plain string `:700+`; no country field; PlaceDoc needs imageUrls/nameLower/cityLower/geo |
| `tourist/mock_palces_raw.dart` | List\<Map\> | 3 (p1-p3) | none (image override) | places (image only) | No | id present | display-only |
| `tourist/mock_notifications.dart` | List\<Map\> | 4 (n1-n4) | `NotificationItem` | notifications | No | **userId missing** | NotificationDoc needs userId/type/createdAt/relatedEntity |
| `tourist/mock_guide_raw.dart` | List\<Map\> | 2 (g1,g2) | none — **ORPHANED (no imports)** | guideProfiles (conceptual) | No | none | dead code |
| `tourist/mock_guides1.dart` | List\<Map\> | 2 (omar_elrashidy, nour_abdallah) | place `Guide` | guideProfiles | No | none (no userId) | uses reviews_count/verified (vs review_count/is_verified in canonical) |
| `tourist/mock_guides.dart` | List\<Map> → List\<Guide> + lang filters | 6 (g1-g6) | `Guide` (guides model) + home | guideProfiles | No | **userId missing** (id g1-g6 ≠ userId) | GuideProfileDoc needs userId/displayName/contactPhone/ratingAvg/ratingCount/isVerified/canPublishTrips |
| `tourist/mock_emergency_contacts.dart` | List\<Map\> | 3 (e1-e3) | `EmergencyContact` | none (static config) | No | n/a | static Egypt numbers |
| `tourist/mock_community.dart` | 2 × List\<Map> (stories+posts) | 6 | `CommunityStory`, `CommunityPost` | stories, posts | No | **authorId missing** (has author_name) | PostDoc needs authorId; StoryDoc needs mediaUrl/expiresAt |
| `tourguide/mock_travelers.dart` | List\<Map\> | 3 (u1-u3) | `Traveler` | none | No | tripId present but = **g1 (a guide id — semantic mismatch)** | not a collection |
| `tourguide/mock_guide_trip_details.dart` | List\<Map\> | 1 (gd1) | `GuideTripDetails` | none | No | tripId present (g1) | extra `included` field vs tourist TripDetails |
| `tourguide/mock_guide_trips.dart` | List\<Map\> | 5 (g1-g5) | `GuideTrip` | trips | No | **guideId missing** | status values active/pending/completed/rejected (model also has cancelled); no guideId/phone |
| `tourguide/mock_guide_profile.dart` | single Map | 1 | none — **ORPHANED (no imports)** | guideProfiles | n/a | dead code |
| `tourguide/mock_guide_notifications.dart` | List\<Map\> | 3 (gn1-gn3) | `GuideNotification` | notifications | No | **userId missing** | same as tourist notifications |
| `tourguide/mock_guide_dashboard.dart` | 1 Map + 1 List\<Map> | 1 stats + 2 requests | `GuideDashboardStats`, `BookingRequest` | none (aggregate) | No | none | display-only maps |
| `tourguide/mock_earnings.dart` | single Map w/ nested list | 1 summary + 2 activities | `EarningsSummary` | none (aggregate) | No | none | display-only |
| `tourguide/mock_booking_details.dart` | List\<Map\> | 2 (b1,b2) | `BookingDetails` | bookings | No | **touristId/guideId missing** | mock has guest_name/traveler_count/price_label only; BookingDoc needs full pricing/identity |

### 9.1 Duplicates & source of truth

| Family | Files | IDs | Source of truth |
|---|---|---|---|
| Guides | `mock_guides.dart` (6, g1-g6) / `mock_guides1.dart` (2, slugs) / `mock_guide_raw.dart` (2, g1-g2) | conflicting | **`mock_guides.dart`** — imported by guides_repository, guides_cubit, guide_profile_cubit, booking_cubit, home_cubit, place_detail_cubit |
| Trips | `mock_trips_public.dart` (3) / `mock_trips.dart` (4) / `mock_trips_raw.dart` (2) | all share t1-t3 with different content | **`mock_trips_public.dart`** for public feed (trips_cubit, popular_cubit, home_screen); `mock_trips.dart` for guide profile |
| Places | `mock_places.dart` (141) / `mock_palces_raw.dart` (3) | — | **`mock_places.dart`** (6 importers); palces_raw is legacy image override (home_cubit only) |

### 9.2 Mock IDs vs real backend IDs

- Mock guides `g1-g6`, trips `t1-t4`, posts `post_*`, stories `story_*`, users `u1-u3` — **none exist in Firestore**. Real docs use uid (users/guideProfiles/admins), auto-id (trips/bookings/posts/stories/notifications/payments), custom (places slugs, guideVerifications=guideId, reviews=tripId_touristId).
- The tourist feed fallback serves mock cards whose ids the server has never seen — the proven root cause of the "Trip not found" booking failure (fixed by the `isRemote` provenance gate, §1.3).
- Seeded demo data must reuse REAL ids: e.g. `guideProfiles/guide1`, `guideProfiles/g1`, `trips/trip-demo-public` (see `seed_booking_demo.js`).

### 9.3 What must NOT be uploaded to production

- **users / notifications / stories / likes** — all keyed to a real Auth uid (`users/{uid}`, `notifications.userId`, `stories.userId`); uploading them without Auth users creates orphan docs, and rules forbid client create for notifications anyway.
- **posts** — `authorId` must be a real uid; mock posts have author_name only.
- **payments/bookings** — Function-created; seeding them bypasses pricing/capacity logic (seed scripts correctly avoid them).
- **guideVerifications** — `idDocumentUrl/licenseDocumentUrl` point to Cloudinary; must reference real guide uids.
- Only **places** (141, from `tool/seed_data/places.json`) and **trips attributed to a real guideId** are safe to upload — and trips land `pending` until approved.

### 9.4 Other mock data outside lib/core/data/mock/

- `lib/data/mock/` — 5 dead admin fixtures (d_mock_trips, d_mock_search [actually users], d_mock_places [posts+applications], d_mock_notifications, d_mock_guides): **zero imports** (verified).
- Inline consts: onboarding slides (`onboarding_screen.dart:17`), search popular terms (`search_cubit.dart:25,34`), earnings months (`earnings_cubit.dart:65`), home place ids (`home_cubit.dart:25`), nav icons (`guide_bottom_nav.dart:31`), admin settings options (`d_app_settings_view.dart:28`).
- Hardcoded demo hints: `triplykl` substring gate in `admin_auth_cubit.dart:46`, `admin_create_account_view.dart:125` (UI-only, NOT security — rules don't recognize it, `firestore.rules:10`).

## 10. Seeding Readiness Plan (plan only — nothing executed)

Upload order by dependency: **users → guideProfiles → guideVerifications → trips → places → posts(+likes) → stories → notifications → appSettings**. Admins via trusted procedure only.

| Collection | Doc ID | Final JSON shape (1 sample) | Conversions needed |
|---|---|---|---|
| `users` | = Auth uid | `{"fullName":"Omar","email":"o@x.dev","phone":"+2010","role":"guide","isActive":true}` | create Auth user first; role must be tourist/guide (rules `:45-47`); omit createdAt/uid on client maps |
| `guideProfiles` | = same uid | `{"userId":"<uid>","displayName":"Omar","pricePerHour":100,"isVerified":false,"canPublishTrips":false,"ratingAvg":0,"ratingCount":0}` | isVerified/ratingAvg stay 0 (Function-owned); coverUrl from Storage if any |
| `trips` | auto-id | `{"guideId":"<uid>","title":"Nile Day","priceEgp":1000,"capacity":10,"dateLabel":"2026-11-02"}` | **omit** bookedSeats/approvalStatus/rejectionReason (rules `:136-143`); `onTripCreated` trigger then sets approvalStatus=pending/titleLower/bookedSeats=0 (`index.js:365-368`) — approve via `decideTripStatus` for bookability |
| `places` | stable slug | `{"name":"Pyramids","city":"Giza","latitude":29.9,"longitude":31.1,"category":"historical","nameLower":"pyramids","cityLower":"giza","imageUrls":[...]}` | lat/long → GeoPoint if using client SDK (Admin SDK takes raw numbers + rules); snake→camel per PlaceDoc; createdAt → Timestamp |
| `posts` | auto-id | `{"authorId":"<uid>","text":"...","likesCount":0,"commentsCount":0}` | counters MUST be 0 (rules `:237-238`); images via Cloudinary first, URLs in imageUrls |
| `stories` | auto-id | `{"userId":"<uid>","mediaUrl":"<cloudinary>","expiresAt":"<Timestamp>"}` | **expiresAt must be a Firestore Timestamp, not string** (rules `:266`); `toCreateMap` computes now+24h |
| `notifications` | auto-id | `{"userId":"<uid>","title":"...","message":"...","type":"general","isRead":false}` | Function-created only (rules `:285`); createdAt → Timestamp |
| `appSettings` | `serviceFeeRate` | `{"value":0.05}` | read by `operationalFeeRate` (`index.js:102-110`) |
| `admins` | = Auth uid | `{"provisionedBy":"console-bootstrap","provisionedAt":"<Timestamp>"}` | Console/Functions only (rules `:322`); plus `setCustomUserClaims` + sign-out/in |

Trigger/rules side-effects when seeding with Admin SDK: Admin SDK bypasses rules, so writes succeed — but `onTripCreated` fires on trip create (status→pending, notify guide if guideId set); `onReviewWritten` never fires for backfilled reviews (stays 0 — matches client defaults); `onPostLikeWritten` never fires for seeded likes (counters must be seeded consistently); `onTripUpdated` re-pends trips edited after approval when priceEgp/capacity/dateLabel change (`index.js:398-418`) — do not edit those fields post-approval without expecting re-pending; `stories.expiresAt` as a string will be invisible to queries and uncollectable by cleanup (DEPLOYMENT_CHECKLIST.md:88-89).

## 11. Problems & Risks (by severity)

**HIGH**
1. **Everything un-deployed** — rules/indexes/functions exist but "NOT YET DEPLOYED" (`firestore.rules:3-5`, `functions/index.js:4`, checklist). Rules tests pass only on the emulator.
2. **Production-touching seed script** — `tool/seed_booking_prod.js` (untracked) writes to `triply-f9b82` behind a project-id + env double-guard; no host allow-list. One env mistake = production write.
3. **Port mismatch across 3 emulator configs** (8081/8091/8092) — silent wrong-target seeding risk (§8.1).
4. **Exposed production service-account key** was pasted into this conversation (previous turns) — rotate immediately.

**MEDIUM**
5. `storage.rules` not wired into firebase.json (`firebase.json:1` has no storage key; rules header `:5-6` says to wire) — Storage uploads work only via rules-disabled default or will fail post-deploy.
6. `mock_places.dart` internal inconsistency: `tour_guide` nested object vs string (`:27-38` vs `:700+`); no `country` field anywhere.
7. `titleLower` written but never queried; `mock_travelers` tripId references a guide id (g1) — semantic mismatch.
8. Rules NOT deployed → production Firestore is at default-deny until deployed; any prod read/write from the app fails until then.
9. Orphaned mock files/symbols (`mock_guide_raw.dart`, `mock_guide_profile.dart`, `mockPopularSearches/Destinations`, entire `lib/data/mock/` dir) — dead code misleading future seeders.
10. Root `node_modules/` + `package.json`/`package-lock.json` are untracked and NOT git-ignored (gitignore covers only `functions/node_modules/` `:57`, `tool/node_modules/` `:67`) — `git add -A` would sweep them in.

**LOW**
11. Checkout is placeholder (no Firestore write; Paymob keys only in `.env`).
12. Reviews collection dormant (no UI).
13. `verifyPaymobTransaction` env key `PAYMOB_API_KEY` must be a Functions secret — not set anywhere yet.
14. `seed_data/trips.json` imports 0/3 (all orphans) — effectively unusable without guide attribution.

## 12. Open Questions

1. Which branch is canonical — the session plan said `Back-end`, disk says `main` (with the trip-not-found fix committed). Should the audit target `Back-end` instead?
2. Which emulator config is authoritative for local testing (8081 / 8091 / 8092)? Who maintains `.firebase-emulator.local.json`?
3. Is `seed_booking_prod.js` intended to stay (prod-writing tool) or be removed/renamed?
4. Will `storage.rules` be wired + Cloudinary preset rotated (DEPLOYMENT_CHECKLIST remediation e/f)?
5. Who owns approving trips in production — is the admin `decideTripStatus` path the only approver, and is the admin role to be bootstrapped per environment?
6. Paymob Sandbox keys for `verifyPaymobTransaction` (Functions secret) — owner and timeline?
7. Should `titleLower` be dropped or indexed?
8. Android emulator loopback (10.0.2.2) — needed or is 127.0.0.1 acceptable for the emulator setup used?

---
*End of report.*

