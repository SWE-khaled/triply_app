const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');

const PROD = 'triply-f9b82';
const args = process.argv.slice(2);
const has = (f) => args.includes(f);
const project = args[args.indexOf('--project') + 1];
const commit = has('--commit');

async function main() {
  if (project !== PROD) throw new Error(`Use --project ${PROD}`);
  if (commit && !(has('--allow-prod') && process.env.CONFIRM_PROD === 'true')) {
    throw new Error('Need --allow-prod and CONFIRM_PROD=true');
  }
  if (process.env.FIRESTORE_EMULATOR_HOST) {
    throw new Error('FIRESTORE_EMULATOR_HOST is set; unset it first');
  }

  const guide = { userId: 'g1', pricePerHour: 100, isVerified: true };
  const trip = {
    guideId: 'g1',
    approvalStatus: 'approved',
    title: 'Demo Public Trip',
    capacity: 10,
    priceEgp: 1000,
    currency: 'EGP',
  };

  console.log('Plan: guideProfiles/g1, guideProfiles/guide-demo-1, trips/trip-demo-public');
  if (!commit) { console.log('DRY-RUN: no writes performed.'); return; }

  initializeApp({ projectId: project });
  const db = getFirestore();
  const ts = { updatedAt: FieldValue.serverTimestamp() };

  await db.collection('guideProfiles').doc('g1').set({ ...guide, ...ts }, { merge: true });
  await db.collection('guideProfiles').doc('guide-demo-1').set({ ...guide, ...ts }, { merge: true });

  const ref = db.collection('trips').doc('trip-demo-public');
  const snap = await ref.get();
  const data = { ...trip, ...ts };
  if (!snap.exists || typeof (snap.data() || {}).bookedSeats !== 'number') data.bookedSeats = 0;
  await ref.set(data, { merge: true });

  console.log('Done. Check trips/trip-demo-public approvalStatus in the Console.');
}

main().catch((e) => { console.error('SEED ABORTED:', e.message); process.exit(1); });
