# Triply Firebase Implementation Report (2026-10-09, branch `Back-end`)

> Companion to `docs/TRIPLY_MASTER_DOCUMENTATION.md` (which remains the
> architecture source of truth) and `docs/FIRESTORE_SCHEMA.md` (field-level
> reference). Everything below describes what is IN THE SOURCE — nothing was
> deployed, no cloud data was touched.

## 1. What was built (local, verified)
- **Core:** `lib/core/firebase/{firestore_paths,firestore_converters,firestore_result}.dart`
  (canonical paths, Timestamp-safe conversions, `FirestoreResult`/`FirestorePage`
  + status vocabularies). `cloud_functions ^5.1.3` added to `pubspec.yaml`
  (Flutter rezolved, `flutter pub get` clean).
- **Models (12):** `lib/data/firestore/models/{app_user,guide_profile,guide_verification,place,trip,booking,payment,post,story,notification,review,app_settings}_doc.dart`
  — all with `fromMap` (legacy/mock-key tolerant) + client-safe `toCreateMap`/`toClientMap`
  that exclude every privileged field.
- **Datasources (14):** `lib/data/firestore/datasources/` — users, guideProfiles,
  guideVerifications, places, trips, bookings, payments, posts(+likes), stories,
  notifications, reviews, appSettings, admins + query helper (cursor pagination,
  friendly errors).
- **Repositories (7) + pricing + mappers:** `booking_pricing.dart` (mirrors the
  Function; matches both cubits' display math), `mappers/firestore_mappers.dart`
  (canonical docs → EXISTING UI models, no View changes), repositories for
  trips/places/guides/bookings/community/notifications/guideTrips/settings —
  all Firestore-first with mock fallback so first paint never blanks.
- **Auth/feature bridges (additive only):** tourist signup writes `role:tourist`
  + `isActive:true`; guide register dual-writes `guideProfiles/`; verification
  submit dual-writes `guideVerifications/`; `AdminAccessService` (server-backed
  gate, cubit untouched); `loadRemote`/`refreshRemote`/`searchRemote`/
  `submitTripToFirestore`/`toggleLikePersistent`/mark-read-remote on the
  existing cubits (constructors + sync methods unchanged).
- **Rules/indexes/config:** `firestore.rules` (no `allow … if true` anywhere),
  `firestore.indexes.json` (23 composite indexes matching the actual queries),
  `firebase.json` extended (flutter block preserved + firestore/functions/emulators).
- **Functions:** `functions/{package.json,index.js}` — `createBooking`,
  `onTripCreated`, `onBookingStatusChanged`, `decideTripStatus`,
  `decideVerification`, `verifyPaymobTransaction`, `onPostLikeWritten`,
  `onReviewWritten`, `cleanupExpiredStories`, `provisionAdmin`.
  `node --check` + full load test pass (`functions load OK` after `npm install`).
- **Seed:** `tool/export_seed_json.dart` (158 places + 3 trips exported OK) +
  `tool/seed_firestore.js` (dry-run OK; emulator commit path + production
  double-guard verified by refusal test).
- **Tests:** `test/{firestore_converters,booking_pricing,firestore_models}_test.dart`
  — **32/32 pass**. Pre-existing `test/widget_test.dart` (dead counter template)
  left untouched.

## 2. Verification results (actual runs)
- `flutter analyze lib/data/firestore lib/core/firebase` → **No issues found**.
- `flutter analyze` (full) → 38 infos, 0 errors (all pre-existing; new code adds zero).
- `flutter test` (3 new files) → **All tests passed (32/32)**. Two initial failures
  were wrong test expectations (Timestamp local-time, default pending status) —
  fixed in test code, implementation untouched.
- `dart run tool/export_seed_json.dart` → 158 places, 3 trips.
- `node tool/seed_firestore.js --dry-run` → plan printed, zero writes.
- Prod-guard refusal test → aborted as designed (no target / no approval).
- `functions load OK` after local `npm install` (Node 24 vs engines Node 20
  warning only; Cloud runtime uses 20 per `package.json`).

## 3. What is NOT done / needs Console + credentials + approval
- NOT deployed: rules, indexes, functions (files only).
- Emulator end-to-end (rules unit tests, booking tx contention, `listApproved`
  pagination against seeded emulator) — needs `firebase emulators:start`.
- Admin bootstrap (`docs/ADMIN_PROVISIONING.md`) — needs Console access.
- Paymob server secret (`PAYMOB_API_KEY`) — needs Functions secrets config;
  sandbox key STILL hardcoded in `paymob_service.dart` (rotate before release).
- Cloudinary preset STILL unsigned/hardcoded (`cloudinary_service.dart`) —
  migrate to server-signed uploads (documented, not implemented).
- `verifyPaymobTransaction` order-status interpretation must be confirmed
  against live Paymob sandbox responses before real money.
- Mock trips carry `guideName` only (no `guideId`) → skipped by seeder until
  attributed; guide `users` docs must exist before trip import.
- Reviews collection is schema-only (no UI); likes/comments counts are
  Function-aggregated; FCM push is out of scope (in-app docs only).
- Full `flutter test` includes the dead `widget_test.dart` (fails as before —
  pre-existing, not caused by this work).

## 4. Files changed/added (tracked + untracked)
- Added (core/data layer): 3 firebase utils, 12 models, 14 datasources,
  7 repositories, pricing, mappers (see `git status` below).
- Added (platform): `firestore.rules`, `firestore.indexes.json`,
  `functions/package.json`, `functions/index.js`.
- Added (tooling/tests/docs): `tool/export_seed_json.dart`,
  `tool/seed_firestore.js`, `tool/seed_data/{places,trips}.json`,
  3 test files, `docs/{FIRESTORE_SCHEMA,ADMIN_PROVISIONING,DEPLOYMENT_CHECKLIST,FIREBASE_IMPLEMENTATION_REPORT}.md`.
- Modified (minimal, justified): `pubspec.yaml` (+cloud_functions),
  `firebase.json` (extended), `.gitignore` (functions/emulator artifacts),
  `AuthRepository` (role/isActive on signup), `TourGuideAuthService`
  (dual-writes), 6 cubits (additive bridges only), `trip_doc.dart` (dead stub
  removed), 2 test files (expectation fixes).
- UI/navigation/screens: untouched. No deletions. No cloud modifications.

## 5. Exact next steps (safe order)
1. Review this report + `FIRESTORE_SCHEMA.md` + rules diff.
2. `firebase emulators:start` → seed emulator → run app against emulator →
   exercise booking/approval/verification/payment flows.
3. Complete admin bootstrap in Console (verify `triply-f9b82`).
4. Configure `PAYMOB_API_KEY` as a Functions secret; rotate hardcoded keys.
5. Approve + deploy rules → indexes → functions (in that order).
6. Seed production places (attributed trips afterwards).
7. Post-deploy verification per `DEPLOYMENT_CHECKLIST.md` §6.

This system is NOT production-ready until steps 2–7 pass: payment verification
against live Paymob, emulator-tested rules, and the admin bootstrap are still
outstanding by design (they require Console/credentials/approval).
