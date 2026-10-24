/**
 * Guarded Firestore seed importer for Triply (places + trips).
 *
 * SAFETY (never auto-uploads to production):
 * - Default mode is --dry-run: reads tool/seed_data/*.json, validates every
 *   doc, prints counts + first IDs, writes NOTHING.
 * - --commit requires BOTH:
 *     1. --project <projectId> explicitly, AND
 *     2. a Firestore target: FIRESTORE_EMULATOR_HOST set, or
 *        GOOGLE_APPLICATION_CREDENTIALS pointing at a service account.
 * - The production project id (triply-f9b82) additionally requires
 *   --allow-prod AND env CONFIRM_PROD=true (double-guard).
 * - Writes are idempotent: stable mock IDs → set(..., {merge:true}) in
 *   batches of ≤400. Re-running never duplicates.
 * - Trips with empty guideId are SKIPPED unless --include-orphan-trips
 *   (mock trips carry guideName only; attribute a real guideId first).
 *
 * Usage:
 *   node tool/seed_firestore.js --dry-run
 *   FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 node tool/seed_firestore.js --commit --project demo-triply
 *   # production (explicit approval only):
 *   CONFIRM_PROD=true node tool/seed_firestore.js --commit --project triply-f9b82 --allow-prod
 */

const fs = require('fs');
const path = require('path');

const PROD_PROJECT = 'triply-f9b82';

function arg(name) {
  const i = process.argv.indexOf(name);
  return i >= 0 ? process.argv[i + 1] : undefined;
}
const has = (name) => process.argv.includes(name);

function loadJson(rel) {
  const p = path.join(__dirname, 'seed_data', rel);
  if (!fs.existsSync(p)) throw new Error(`Missing ${p}. Run: dart run tool/export_seed_json.dart`);
  const arr = JSON.parse(fs.readFileSync(p, 'utf8'));
  if (!Array.isArray(arr)) throw new Error(`${rel} must be a JSON array`);
  return arr;
}

function validatePlace(p, i) {
  if (!p.id || typeof p.id !== 'string') throw new Error(`places[${i}]: missing string id`);
  if (!p.name) throw new Error(`places[${i}] (${p.id}): missing name`);
  if (typeof p.latitude !== 'number' || typeof p.longitude !== 'number') {
    throw new Error(`places[${i}] (${p.id}): latitude/longitude must be numbers`);
  }
}

function validateTrip(t, i) {
  if (!t.id || typeof t.id !== 'string') throw new Error(`trips[${i}]: missing string id`);
  if (!t.title) throw new Error(`trips[${i}] (${t.id}): missing title`);
}

async function main() {
  const commit = has('--commit');
  const project = arg('--project');
  const places = loadJson('places.json');
  const trips = loadJson('trips.json');
  places.forEach(validatePlace);
  const orphan = trips.filter((t) => !t.guideId);
  const importableTrips = has('--include-orphan-trips') ? trips : trips.filter((t) => t.guideId);
  importableTrips.forEach(validateTrip);

  console.log(`Seed plan: ${places.length} places, ${importableTrips.length} trips` +
    (orphan.length && !has('--include-orphan-trips') ? ` (${orphan.length} orphan trip(s) skipped — no guideId)` : ''));

  if (!commit) {
    console.log('DRY-RUN: no writes performed.');
    console.log('Sample place IDs:', places.slice(0, 5).map((p) => p.id).join(', '));
    console.log('Sample trip IDs:', importableTrips.slice(0, 5).map((t) => t.id).join(', ') || '(none)');
    console.log('To write to the EMULATOR: FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 node tool/seed_firestore.js --commit --project <id>');
    return;
  }

  if (!project) throw new Error('--commit requires --project <projectId>');
  const usingEmulator = !!process.env.FIRESTORE_EMULATOR_HOST;
  const hasCreds = !!process.env.GOOGLE_APPLICATION_CREDENTIALS;
  if (!usingEmulator && !hasCreds) {
    throw new Error('No Firestore target: set FIRESTORE_EMULATOR_HOST or GOOGLE_APPLICATION_CREDENTIALS.');
  }
  if (project === PROD_PROJECT && !(has('--allow-prod') && process.env.CONFIRM_PROD === 'true')) {
    throw new Error(`Refusing production write to ${PROD_PROJECT} without --allow-prod and CONFIRM_PROD=true.`);
  }

const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
initializeApp({ projectId: project });
const db = getFirestore();

  let written = 0;
  const batchWrite = async (col, docs) => {
    for (let i = 0; i < docs.length; i += 400) {
      const batch = db.batch();
      for (const d of docs.slice(i, i + 400)) {
        const {id, ...data} = d;
batch.set(db.collection(col).doc(id), {...data, updatedAt: FieldValue.serverTimestamp()}, {merge: true});      }
      await batch.commit();
      written += Math.min(400, docs.length - i);
      console.log(`  ${col}: ${Math.min(i + 400, docs.length)}/${docs.length}`);
    }
  };

  console.log(`Committing to project "${project}"${usingEmulator ? ' (EMULATOR)' : ''}…`);
  await batchWrite('places', places);
  if (importableTrips.length) await batchWrite('trips', importableTrips);
  console.log(`Done. ${written} doc(s) upserted (idempotent — safe to re-run).`);
}

main().catch((e) => {
  console.error('SEED ABORTED:', e.message);
  process.exit(1);
});
