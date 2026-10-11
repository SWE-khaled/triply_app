# Admin provisioning (secure procedure)

> The demo `triplykl` email-substring gate (`AdminAuthCubit._hasAccess`) is NOT
> security. Real authorization = `admins/{uid}` presence docs and/or the
> `admin:true` custom claim, enforced by `firestore.rules` + Functions.
> `AdminAccessService` (`lib/features/admin_dashboard/d_auth/data/admin_access_service.dart`)
> checks both. Do NOT deploy rules/Functions before completing step 1.

## Step 1 — First admin (one-time bootstrap, Firebase Console)

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

Any existing admin calls the `provisionAdmin` callable with `{uid}` or
`{email}` of the new admin (from a signed-in admin session). It sets the
custom claim + `admins/{uid}` + `users/{uid}.role=admin`.

```dart
// Example (admin session only):
// FirebaseFunctions.instance.httpsCallable('provisionAdmin').call({'email': 'new-admin@…'});
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
