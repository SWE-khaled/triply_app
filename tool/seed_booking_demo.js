/**
 * Seed MINIMUM demo data for public + private booking against the LOCAL
 * Firestore (and optionally Auth) emulators ONLY.
 *
 * Why: the app's private flow uses mock guide ids (g1..g4) while
 * `createBooking` requires real `guideProfiles/{guideId}` docs, and the
 * public flow requires real `trips/{tripId}` docs with
 * approvalStatus=='approved' + capacity. An empty emulator therefore fails
 * with server NOT_FOUND (`Trip not found.` / `Guide not found.`), which the
 * client surfaces as `not found`. The checked-in `tool/seed_data/*.json`
 * only covers places + orphan trips (no guideId/approvalStatus) and never
 * creates guideProfiles — so it cannot fix booking by itself.
 *
 * What this seeds (idempotent merge, stable demo ids):
 * - guideProfiles/g1        {userId:'g1', pricePerHour:100, isVerified:true}
 *   (matches mock guide g1 used by the private UI; server price is
 *   authoritative — display totals may differ until the server responds)
 * - guideProfiles/guide-demo-1 (same shape, for explicit demo navigation)
 * - trips/trip-demo-public  {guideId:'g1', approvalStatus:'approved',
 *   title, capacity:10, bookedSeats:0, priceEgp:1000, currency:'EGP'}
 * - users/tourist-demo + users/g1 docs (role hints; Auth users below are
 *   what actually authenticates)
 * - Auth emulator users (only when FIREBASE_AUTH_EMULATOR_HOST is set):
 *   tourist-demo@demo.local / guide-demo@demo.local (demo-only password
 *   'pass1234', same convention as functions/test/callables.test.js —
 *   emulator-only, never production, never logged beyond the email).
 *
 * SAFETY:
 * - Requires FIRESTORE_EMULATOR_HOST; refuses without it.
 * - Parses the host/port strictly: host must be exactly 127.0.0.1 or
 *   localhost with a numeric port (substring checks alone cannot prove
 *   locality). The optional Auth host gets the same check when set.
 * - Requires --project <demo-*> (default demo-localtest); refuses
 *   triply-f9b82 and any non-demo-* id (never production).
 * - Writes via Admin SDK with set(...,{merge:true}) — re-running never
 *   duplicates and never wipes existing emulator data. The demo trip's
 *   `bookedSeats` is written only on create (never reset to 0), so repeat
 *   runs preserve live booking counters.
 * - No Paymob keys, no secrets, no production endpoints.
 *
 * Usage (from repo root, emulators running on safe ports — never 8080):
 *   $env:FIRESTORE_EMULATOR_HOST='127.0.0.1:8092'
 *   $env:FIREBASE_AUTH_EMULATOR_HOST='127.0.0.1:9099'
 *   node tool/seed_booking_demo.js --project demo-localtest
 *
 * Then in the app (lib/main_emulator.dart on demo-localtest):
 * - Public: book trips/trip-demo-public (approved, 10 seats).
 * - Private: book guide g1 (guideProfiles/g1 now exists).
 */

const PROD_PROJECT = 'triply-f9b82';

function arg(name) {
  const i = process.argv.indexOf(name);
  return i >= 0 ? process.argv[i + 1] : undefined;
}

function fail(msg) {
  console.error('SEED ABORTED:', msg);
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
  if (project === PROD_PROJECT) fail(`refusing production project ${PROD_PROJECT}.`);
  if (!project.startsWith('demo-')) fail(`project must be demo-* (got "${project}").`);
  const fsHost = process.env.FIRESTORE_EMULATOR_HOST || '';
  if (!fsHost) fail('set FIRESTORE_EMULATOR_HOST (start the local emulators first).');
  parseEndpoint(fsHost, 'FIRESTORE_EMULATOR_HOST');
  const authHost = process.env.FIREBASE_AUTH_EMULATOR_HOST || '';
  const withAuth = !!authHost;
  if (withAuth) parseEndpoint(authHost, 'FIREBASE_AUTH_EMULATOR_HOST');

  const admin = require('firebase-admin');
  admin.initializeApp({projectId: project});
  const db = admin.firestore();
  const FieldValue = admin.firestore.FieldValue;

  // Firestore fixtures (merge = idempotent, preserves existing fields).
  await db.collection('guideProfiles').doc('g1').set(
    {userId: 'g1', pricePerHour: 100, isVerified: true, updatedAt: FieldValue.serverTimestamp()},
    {merge: true},
  );
  await db.collection('guideProfiles').doc('guide-demo-1').set(
    {userId: 'guide-demo-1', pricePerHour: 100, isVerified: true, updatedAt: FieldValue.serverTimestamp()},
    {merge: true},
  );
  // Preserve live counters on reruns: even with merge:true, writing
  // `bookedSeats: 0` would silently erase real bookings. Seed the counter
  // only when the trip doc is created (or lacks the field).
  const tripRef = db.collection('trips').doc('trip-demo-public');
  const tripSnap = await tripRef.get();
  const tripSeed = {
    guideId: 'g1',
    approvalStatus: 'approved',
    title: 'Demo Nile Day (emulator)',
    titleLower: 'demo nile day (emulator)',
    capacity: 10,
    priceEgp: 1000,
    currency: 'EGP',
    meetingPoint: 'Demo Gate',
    updatedAt: FieldValue.serverTimestamp(),
  };
  if (
    !tripSnap.exists ||
    typeof (tripSnap.data() || {}).bookedSeats !== 'number'
  ) {
    tripSeed.bookedSeats = 0;
  }
  await tripRef.set(tripSeed, {merge: true});
  await db.collection('users').doc('tourist-demo').set({role: 'tourist', updatedAt: FieldValue.serverTimestamp()}, {merge: true});
  await db.collection('users').doc('g1').set({role: 'guide', updatedAt: FieldValue.serverTimestamp()}, {merge: true});

  console.log(`Seeded Firestore on ${project} (${fsHost}): guideProfiles/g1, guideProfiles/guide-demo-1, trips/trip-demo-public.`);

  if (withAuth) {
    const demoUsers = [
      ['tourist-demo', 'tourist-demo@demo.local'],
      ['guide-demo', 'guide-demo@demo.local'],
    ];
    for (const [uid, email] of demoUsers) {
      try {
        await admin.auth().createUser({uid, email, password: 'pass1234'});
        console.log(`Created auth user ${email} uid=${uid}`);
      } catch (e) {
        if (e.code === 'auth/uid-already-exists' || e.code === 'auth/email-already-exists') {
          console.log(`Auth user exists: ${email}`);
        } else {
          throw e;
        }
      }
    }
  } else {
    console.log('Auth emulator not set — skipped demo Auth users (register via app UI instead).');
  }
  console.log('Done. Re-run anytime (idempotent).');
}

main().catch((e) => {
  console.error('SEED ABORTED:', e.message);
  process.exit(1);
});
