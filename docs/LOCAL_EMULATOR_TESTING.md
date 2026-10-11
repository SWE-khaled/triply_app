# Local Emulator Testing (Triply)

Manual full-app verification without touching production. Production
(`triply-f9b82` via `lib/main.dart`) is unchanged and stays the default;
everything below is opt-in and isolated.

## 1. Required services and ports

| Service    | Default local port | Purpose                              |
| ---------- | ------------------ | ------------------------------------ |
| Firestore  | 8090               | All app reads/writes                 |
| Auth       | 9099               | Email/password sign-in for test users|
| Functions  | 5001               | Booking/cancel/admin/verify callables|

Port 8080 is occupied by an unrelated system process — never use or
disturb it. If a port above is taken, pick another free one and pass it
through (see launch command).

## 2. Start and stop the emulators

From the repo root, Firebase CLI + Java are required (the Firestore jar
is cached after the first download):

```powershell
# Use a TEMPORARY config outside the repo (never edit firebase.json):
# C:\Temp\triply-emu\firebase.json with firestore rules/indexes paths,
# emulator ports, and a "functions" junction pointing at <repo>\functions.
firebase emulators:start --only auth,firestore,functions `
  --project demo-localtest
```

Stop with Ctrl+C (foreground) or stop the `firebase`/`java` processes
you started. Emulator data is in-memory and vanishes on stop. To wipe
mid-session without restarting, run a `clearFirestore()` script or
restart the suite.

Seed demo data only with disposable fixtures (admin SDK against
`FIRESTORE_EMULATOR_HOST`, demo project ids only). See
`tool/phase*_emu_probe.dart` headers and `docs/FIRESTORE_SCHEMA.md`.

## 3. Launch the app in emulator mode

```powershell
flutter run -d chrome --target lib/main_emulator.dart `
  --dart-define=TRIPLY_EMULATOR_PROJECT=demo-localtest `
  --dart-define=TRIPLY_EMULATOR_HOST=127.0.0.1:8090 `
  --dart-define=TRIPLY_EMULATOR_AUTH_HOST=127.0.0.1:9099 `
  --dart-define=TRIPLY_EMULATOR_FUNCTIONS_HOST=127.0.0.1 `
  --dart-define=TRIPLY_EMULATOR_FUNCTIONS_PORT=5001
```

(On an Android emulator use `10.0.2.2` instead of `127.0.0.1`.)
`lib/main_emulator.dart` validates the configuration first: any
non-`demo-*` project, missing endpoint, or Google production host shows
a blocking error screen and the app never initializes Firebase.

## 4. Verify the connection

* The run log shows `Triply emulator mode: app started on <demo-id>` and
  never mentions `triply-f9b82`.
* Register a fresh tourist/guide from the app's own screens, then check
  the emulator (REST `GET
  http://127.0.0.1:8090/v1/projects/<demo>/databases/(default)/documents/users`)
  shows only your test users — never real ones.

## 5. Unsupported in emulator mode

* Google sign-in (real OAuth; use email/password test accounts).
* Paymob checkout (external sandbox; fails closed with "not configured"
  unless test keys are supplied — never use production keys).
* Cloudinary uploads (external dev account, unchanged by this setup).
* Push notifications (no FCM transport in the app).

## 6. Paymob Sandbox vs Firebase Emulator testing

Firebase Emulator testing (this document) covers everything up to the
provider boundary: booking/cancel/admin callables, rules, and the app's
fail-closed behavior when verification is unavailable. Paymob Sandbox
testing additionally needs test API keys (root `.env`:
`PAYMOB_API_KEY/INTEGRATION_ID/IFRAME_ID` plus the Functions secret)
and exercises real provider scenarios (success/decline/webhooks).
Never mix the two: sandbox keys stay out of source control, and
production endpoints are never used for tests.
