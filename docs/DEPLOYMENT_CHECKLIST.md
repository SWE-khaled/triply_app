# Deployment checklist (explicit approval required — DO NOT RUN yet)

> Nothing below has been deployed. Each step requires verified project +
> explicit approval. Secrets are never committed; `.env` stays gitignored.

## 0. Preconditions
- [ ] `firebase.json` / `firestore.rules` / `firestore.indexes.json` / `functions/` reviewed.
- [ ] Target project verified in Console: **`triply-f9b82`**.
- [ ] Admin bootstrap completed (`docs/ADMIN_PROVISIONING.md` step 1).
- [ ] `PAYMOB_API_KEY` (+ integration/iframe ids if used server-side) stored as
      Functions secrets, NOT in Flutter or the repo.
- [ ] Billing enabled on the Firebase project (required for Functions + scheduler).

## 1. Login + link (safe, no deployment)
```powershell
firebase login
firebase use --add triply-f9b82   # creates .firebaserc alias (local only)
firebase projects:list             # confirm triply-f9b82 is listed
```

## 2. Emulator validation (local, no cloud changes)
```powershell
# Terminal 1 (port 8080 is occupied on some dev machines by an unrelated
# system service — do NOT kill it. Run the emulator on a free port via a
# TEMPORARY config outside the repo; do not change firebase.json ports):
#   {"firestore":{"rules":"<repo>/firestore.rules"},"emulators":{"firestore":{"host":"127.0.0.1","port":8085}}}
# firebase --config <temp>/emu.json emulators:start --only firestore --project demo-triply
# First run downloads ~130 MB (cloud-firestore-emulator jar) — allow time.
# Terminal 2:
cd functions
npm run test:rules   # 25+ Security Rules cases (requires emulator above)
node --test test/guards.test.js
cd ..
flutter test test/firestore_converters_test.dart test/booking_pricing_test.dart test/firestore_models_test.dart
FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 node tool/seed_firestore.js --commit --project demo-triply
```
Expect: rules tests pass against the emulator, guards + Dart tests pass,
seed writes to the emulator only, app points at emulator via
`FirebaseFirestore.instance.useFirestoreEmulator`.
Rules tests MUST pass before deploy — code review is not proof.
Per-feature remote reads stay behind `useRemote = false` consts
(`TripsCubit`, `TripDetailsCubit`, `PlaceDetailCubit`); flip each ONLY after
deploy + verification of that feature, never before.

## 3. Secrets (console / CLI, never in repo)
```powershell
firebase functions:secrets:set PAYMOB_API_KEY --project triply-f9b82
```
Remediation plan (in order; app code untouched until step c):
a. Store the LIVE key as a Functions secret (above) + verify
   `verifyPaymobTransaction` against Paymob sandbox with real credentials.
b. Confirm no client path depends on the hardcoded value
   (`paymob_service.dart` reads `.env` first, fallback second).
c. ONLY after (a)+(b) pass: delete the `_fallbackApiKey` sandbox constant
   from `paymob_service.dart` and FAIL CLOSED when `.env` is missing
   (throw instead of falling back).
d. Rotate the exposed sandbox key in the Paymob dashboard (it lived in git
   history) + restrict API keys by bundle/package + SHA in Console.
e. Cloudinary: same pattern later — keep unsigned preset during migration,
   then move verification uploads to server-issued signed uploads and rotate
   the preset (`cloudinary_service.dart`). Not started.
f. `android/app/google-services.json` is tracked (normal for FlutterFire;
   restrict its API key in Google Cloud Console: Android apps + Maps APIs only).

## 4. Deploy (ONLY after explicit approval, in this order)
```powershell
firebase deploy --only firestore:rules --project triply-f9b82
firebase deploy --only firestore:indexes --project triply-f9b82
firebase deploy --only functions --project triply-f9b82
```
Verify after each: Console shows green status; `firebase firestore:rules:get`
matches the committed file.

## 5. Seed production data (ONLY after rules+functions live + approval)
```powershell
# Double-guarded: refuses without --allow-prod AND CONFIRM_PROD=true.
$env:CONFIRM_PROD = 'true'
node tool/seed_firestore.js --commit --project triply-f9b82 --allow-prod
```
- Import places first; trips with empty `guideId` are skipped by default —
  attribute real guide UIDs, then re-run with `--include-orphan-trips`.
- Re-running is idempotent (stable IDs + merge).
- Backfill (one-time, AFTER rules+functions live, BEFORE announcing):
  - `guideProfiles` docs predating `displayName`/`contactPhone`: for each
    guide, copy `users/{uid}.name` → `displayName` and `users/{uid}.phone` →
    `contactPhone` (guide consented at signup; powers trip-details contact).
    New registrations write both automatically.
  - `stories` docs with ISO-string `expiresAt` (pre-fix clients): rewrite as
    `Timestamp` (or delete if expired — they were invisible to queries and
    uncollectable by cleanup).

## 6. Post-deploy verification
- [ ] Tourist: approved trips visible; booking creates `bookings/{id}` with
      server totals; `bookedSeats` increments; overbooking rejected.
- [ ] Guide: created trip appears as pending in own list + admin queue.
- [ ] Admin: `decideTripStatus` / `decideVerification` flip states; tourist and
      guide see the change; `AdminAccessService.isAuthorized` correct.
- [ ] Paymob: sandbox payment verifies via `verifyPaymobTransaction`
      (booking → confirmed); client-reported success alone does NOT confirm.
- [ ] Community/notifications flow end-to-end; expired stories cleaned daily.

## Rollback
- Rules: redeploy the previous `firestore.rules` from git history.
- Functions: `firebase deploy --only functions` from the previous commit.
- Data: no mass delete (destructive commands are out of scope); fix forward
  with `decide*` callables.
