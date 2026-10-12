/**
 * Bootstrap the FIRST demo admin against the LOCAL Firebase emulators ONLY.
 *
 * Why this exists: `provisionAdmin` is admin-only (requireAdmin runs first),
 * so with zero admins the public Create Account screen can never bootstrap
 * itself — it correctly fails (permission-denied when reachable, not-found
 * when the Functions emulator is down). The first admin must come from a
 * trusted side channel. In production that is the Console procedure
 * (docs/ADMIN_PROVISIONING.md). Locally, this script is the equivalent using
 * the Auth/Admin SDK against the emulators.
 *
 * SAFETY (refuses to touch production):
 * - Requires BOTH FIRESTORE_EMULATOR_HOST and FIREBASE_AUTH_EMULATOR_HOST.
 * - Requires --project <demo-*> (default demo-localtest); refuses
 *   triply-f9b82 and any non-demo-* id.
 * - Never deploys anything; only writes to the emulator via Admin SDK.
 * - Password comes ONLY from env DEMO_ADMIN_PASSWORD (min 6 chars) and is
 *   never printed, logged, or stored. No credentials are hardcoded.
 * - Repeatable: existing demo admin is updated (claim + docs merged), not
 *   duplicated.
 *
 * Usage (PowerShell, from repo root):
 *   $env:FIRESTORE_EMULATOR_HOST='127.0.0.1:8092'
 *   $env:FIREBASE_AUTH_EMULATOR_HOST='127.0.0.1:9099'
 *   $env:DEMO_ADMIN_PASSWORD='local-demo-pass-123'
 *   node tool/bootstrap_first_admin.js --project demo-localtest `
 *     --email admin-triplykl@demo.local --name "Demo Admin"
 *
 * Start emulators first on SAFE ports (never 8080 — occupied by an unrelated
 * system process, PID 10976 — do not touch it). See docs/LOCAL_EMULATOR_TESTING.md:
 *   firebase emulators:start --only auth,firestore,functions --project demo-localtest
 * (with a temporary config mapping firestore->8092, auth->9099, functions->5001
 *  when the default 8080 is unavailable).
 *
 * Verify afterwards: sign in via Admin Login in the app running
 * lib/main_emulator.dart (demo-localtest, 127.0.0.1:8092/9099/5001) and open
 * the Admin Dashboard. A tourist/guide email (even containing triplykl)
 * without the admins doc/claim must still be denied.
 */

const PROD_PROJECT = 'triply-f9b82';

function arg(name) {
  const i = process.argv.indexOf(name);
  return i >= 0 ? process.argv[i + 1] : undefined;
}

function fail(msg) {
  console.error('BOOTSTRAP ABORTED:', msg);
  process.exit(1);
}

// Strict local-only endpoint parsing: the host must be exactly 127.0.0.1
// or localhost with a numeric TCP port. Never rely on substring checks
// alone (a hostile value can embed a trusted-looking substring).
function parseEndpoint(value, name) {
  const sep = value.lastIndexOf(':');
  if (sep <= 0 || sep === value.length - 1) {
    fail(`${name} must look like "host:port" (got "${value}").`);
  }
  const host = value.slice(0, sep).trim().toLowerCase();
  const port = Number(value.slice(sep + 1).trim());
  if (
    (host !== '127.0.0.1' && host !== 'localhost') ||
    !Number.isInteger(port) ||
    port < 1 ||
    port > 65535
  ) {
    fail(
      `${name} must be a local emulator (127.0.0.1 or localhost) with a numeric port (got "${value}").`,
    );
  }
  return {host, port};
}

async function main() {
  const project = arg('--project') || process.env.FIRESTORE_TEST_PROJECT || 'demo-localtest';
  const email = arg('--email') || process.env.DEMO_ADMIN_EMAIL || 'admin-triplykl@demo.local';
  const name = arg('--name') || process.env.DEMO_ADMIN_NAME || 'Demo Admin';
  const password = process.env.DEMO_ADMIN_PASSWORD || '';

  if (project === PROD_PROJECT) fail(`refusing production project ${PROD_PROJECT}.`);
  if (!project.startsWith('demo-')) fail(`project must be demo-* (got "${project}").`);
  const fsHost = process.env.FIRESTORE_EMULATOR_HOST || '';
  const authHost = process.env.FIREBASE_AUTH_EMULATOR_HOST || '';
  if (!fsHost || !authHost) {
    fail('set FIRESTORE_EMULATOR_HOST and FIREBASE_AUTH_EMULATOR_HOST (start the local emulators first).');
  }
  parseEndpoint(fsHost, 'FIRESTORE_EMULATOR_HOST');
  parseEndpoint(authHost, 'FIREBASE_AUTH_EMULATOR_HOST');
  if (!email.includes('@') || !email.toLowerCase().includes('triplykl')) {
    fail('demo admin email must be valid and contain "triplykl" (eligibility hint, not authorization).');
  }
  if (!password || password.length < 6) {
    fail('set DEMO_ADMIN_PASSWORD env (min 6 chars, demo-only, never logged).');
  }

  const admin = require('firebase-admin');
  admin.initializeApp({projectId: project});
  const db = admin.firestore();

  let uid;
  try {
    const existing = await admin.auth().getUserByEmail(email);
    uid = existing.uid;
    console.log(`Found existing demo admin: ${email} uid=${uid}`);
  } catch (_) {
    const created = await admin.auth().createUser({
      email,
      password,
      displayName: String(name).slice(0, 100),
    });
    uid = created.uid;
    console.log(`Created demo admin: ${email} uid=${uid}`);
  }

  await admin.auth().setCustomUserClaims(uid, {admin: true});
  const FieldValue = admin.firestore.FieldValue;
  await db.collection('admins').doc(uid).set(
    {provisionedBy: 'local-bootstrap', provisionedAt: FieldValue.serverTimestamp()},
    {merge: true},
  );
  await db.collection('users').doc(uid).set(
    {role: 'admin', email, updatedAt: FieldValue.serverTimestamp()},
    {merge: true},
  );

  console.log(`Done. project=${project} firestore=${fsHost} auth=${authHost}`);
  console.log(`Admin doc: admins/${uid} (+ claim admin:true). Sign in via Admin Login on main_emulator.dart.`);
  console.log('Password was read from env and never printed.');
}

main().catch((e) => {
  console.error('BOOTSTRAP ABORTED:', e.message);
  process.exit(1);
});
