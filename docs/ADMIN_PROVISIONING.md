# Admin provisioning (secure procedure)

> The demo `triplykl` email-substring gate (`AdminAuthCubit._hasAccess`) is NOT
> security. Real authorization = `admins/{uid}` presence docs and/or the
> `admin:true` custom claim, enforced by `firestore.rules` + Functions.
> `AdminAccessService` (`lib/features/admin_dashboard/d_auth/data/admin_access_service.dart`)
> checks both. Do NOT deploy rules/Functions before completing step 1.

## Step 1 — First admin

### A. Local Emulator first-admin bootstrap (current testing workflow)

Local testing uses a `demo-*` project only — never production Firebase:

1. Start the emulators with the local config (`.firebase-emulator.local.json`):
   Firestore `127.0.0.1:8092`, Auth `127.0.0.1:9099`, Functions
   `127.0.0.1:5001`, UI `127.0.0.1:4000`.
2. Before running any script, verify the target is local: the project ID
   starts with `demo-`, and the Firestore/Auth hosts are `127.0.0.1` or
   `localhost`. `tool/bootstrap_first_admin.js` enforces both and refuses
   `triply-f9b82` and production-looking endpoints.
3. Run (password via local env only, never committed or logged):
   ```powershell
   $env:FIRESTORE_EMULATOR_HOST='127.0.0.1:8092'
   $env:FIREBASE_AUTH_EMULATOR_HOST='127.0.0.1:9099'
   $env:DEMO_ADMIN_PASSWORD='<local-only, min 6 chars>'
   node tool/bootstrap_first_admin.js --project demo-localtest `
     --email admin-triplykl@demo.local --name "Demo Admin"
   ```
4. The script creates the Auth user (if missing), sets the `admin:true`
   claim, and writes `admins/{uid}` + `users/{uid}.role=admin`. It is
   repeatable and merges instead of duplicating.

### B. Production first-admin provisioning (documentation only)

This section is **NOT part of the current local testing workflow**. Never
execute it against production now, and never modify production Firebase.
The first production admin must still come from a controlled trusted
procedure (kept here so the requirement is not lost):

1. In the Firebase Console, open project **`triply-f9b82`** (verify the project
   ID in the project settings — do NOT assume the local checkout is linked).
2. Authentication → Users → locate the legitimate administrator's account
   (create it via the app first if needed). Copy its **UID**.
3. Firestore → Data → create collection **`admins`**, document ID = that UID,
   fields: `provisionedBy: "console-bootstrap"`, `provisionedAt: <now timestamp>`.
4. (Recommended) Also set the custom claim via `functions` shell or Admin SDK:
   `admin.auth().setCustomUserClaims(uid, {admin: true})`.
5. Have the admin sign out and back in (refreshes the ID token with claims).

## Step 2 — Further admins (no console needed afterwards)

Only an **already-authorized, signed-in admin** can call the `provisionAdmin`
callable with `{uid}` or `{email}` of the new admin. It sets the
custom claim + `admins/{uid}` + `users/{uid}.role=admin`.

`triplykl` is an **eligibility** requirement, not authorization: the target
email must contain `triplykl` (case-insensitive, enforced server-side in
`provisionAdmin`), but the substring alone never grants anything. A newly
created account must still sign in successfully and pass server-side
authorization (`AdminAccessService.isAuthorized`) before reaching the
dashboard; anything else is signed back out.

```dart
// Example (admin session only):
// FirebaseFunctions.instance.httpsCallable('provisionAdmin').call({'email': 'new-admin-triplykl@…'});
// The target email must contain "triplykl" (enforced server-side); the
// substring alone never authorizes — only an already-signed-in admin caller
// can provision.
```

## Step 3 — Verify (before announcing)

1. As the new admin: `AdminAccessService().isAuthorized()` → true.
2. As a normal tourist/guide: `isAuthorized()` → false.
3. Firestore read of another user's `users/{uid}` as non-admin → denied.
4. `decideTripStatus` / `decideVerification` as non-admin → `permission-denied`.

## Step 4 — Remove the demo gate (only after steps 1–3 pass in production)

Replace `AdminAuthCubit._hasAccess` with `AdminAccessService().isAuthorized`
+ Firebase sign-in. Until then the cubit keeps its demo flow so the app
keeps working; rules/Functions already reject unauthorized admin operations
server-side regardless of what the client UI shows.

## Never
- Never write `role: admin` from the Flutter client (rules reject it).
- Never share service-account keys; store them outside the repo.
- Never run this procedure against the wrong project — always confirm
  `triply-f9b82` in Console + `--project triply-f9b82` in CLI output.
