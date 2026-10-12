/**
 * provisionAdmin callable integration tests — LOCAL emulators ONLY.
 *
 * Run (emulators on the safe temp config, demo project):
 *   firebase --config C:\Temp\triply-emu\firebase.json emulators:exec `
 *     --only auth,firestore,functions --project demo-localtest `
 *     "npm --prefix functions run test:provision"
 * (add a `test:provision` script before first use; or run node directly with
 *  the emulator env vars below exported.)
 *
 * Env:
 *   FIRESTORE_EMULATOR_HOST, FIREBASE_AUTH_EMULATOR_HOST (required — the file
 *     refuses to run without them so it can NEVER touch production),
 *   FIRESTORE_TEST_PROJECT (default 'demo-localtest'),
 *   FUNCTIONS_TEST_PORT (default 5001), FUNCTIONS_TEST_REGION (default
 *   'us-central1', the v2 platform default).
 *
 * Covers: eligible provisioning by an admin (claim + admins doc + users role
 * consistent), triplykl rejection, unauthenticated/non-admin rejection,
 * invalid input, existing-user safety, concurrent-provision consistency, and
 * triplykl-email tourists denied admin operations.
 */
const {describe, it, before} = require('node:test');
const assert = require('node:assert/strict');
const admin = require('firebase-admin');

const PROJECT = process.env.FIRESTORE_TEST_PROJECT || 'demo-localtest';
if (!process.env.FIRESTORE_EMULATOR_HOST || !process.env.FIREBASE_AUTH_EMULATOR_HOST) {
  throw new Error(
    'provision_admin.test.js requires emulators: set FIRESTORE_EMULATOR_HOST and ' +
    'FIREBASE_AUTH_EMULATOR_HOST. Refusing to run elsewhere.',
  );
}
if (!PROJECT.startsWith('demo-')) {
  throw new Error(`Refusing: test project must be demo-*, got ${PROJECT}.`);
}

admin.initializeApp({projectId: PROJECT});
const db = admin.firestore();

const AUTH_HOST = process.env.FIREBASE_AUTH_EMULATOR_HOST;
const FN_PORT = Number(process.env.FUNCTIONS_TEST_PORT || 5001);
const FN_REGION = process.env.FUNCTIONS_TEST_REGION || 'us-central1';
const FN_BASE = `http://127.0.0.1:${FN_PORT}/${PROJECT}/${FN_REGION}`;

const tokens = {};

async function signIn(email, password) {
  const res = await fetch(
    `http://${AUTH_HOST}/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=fake-api-key`,
    {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({email, password, returnSecureToken: true}),
    },
  );
  if (!res.ok) throw new Error(`sign-in failed for ${email}: ${res.status}`);
  const body = await res.json();
  return body.idToken;
}

/** Invoke a callable; returns {ok, status, payload, message}. Never throws on app errors. */
async function call(fn, token, data) {
  const headers = {'Content-Type': 'application/json'};
  if (token) headers.Authorization = `Bearer ${token}`;
  const res = await fetch(`${FN_BASE}/${fn}`, {
    method: 'POST',
    headers,
    body: JSON.stringify({data}),
  });
  const body = await res.json().catch(() => ({}));
  if (res.ok) return {ok: true, status: res.status, payload: body.result};
  return {ok: false, status: (body.error && body.error.status) || `HTTP_${res.status}`, message: (body.error && body.error.message) || ''};
}

async function provisionedState(uid) {
  const user = await admin.auth().getUser(uid);
  const adminDoc = await db.collection('admins').doc(uid).get();
  const userDoc = await db.collection('users').doc(uid).get();
  return {
    claim: (user.customClaims || {}).admin === true,
    doc: adminDoc.exists,
    role: userDoc.exists ? userDoc.data().role : null,
    provisionedBy: adminDoc.exists ? adminDoc.data().provisionedBy : null,
  };
}

before(async () => {
  // Operator (admin), ordinary tourist, and triplykl-email non-admin.
  // Passwords are emulator-only fixtures (same convention as callables.test.js).
  for (const [uid, email] of [
    ['pa-admin', 'pa-admin-triplykl@test.dev'],
    ['pa-tourist', 'pa-tourist@test.dev'],
    ['pa-sneaky', 'sneaky-triplykl@test.dev'],
  ]) {
    try {
      await admin.auth().createUser({uid, email, password: 'pass1234'});
    } catch (e) {
      if (e.code !== 'auth/uid-already-exists' && e.code !== 'auth/email-already-exists') throw e;
    }
    tokens[uid] = await signIn(email, 'pass1234');
  }
  await db.collection('admins').doc('pa-admin').set({provisionedBy: 'test-bootstrap'});
  await db.collection('users').doc('pa-admin').set({role: 'admin'});
  await db.collection('users').doc('pa-tourist').set({role: 'tourist'});
  await db.collection('users').doc('pa-sneaky').set({role: 'tourist'});
});

describe('provisionAdmin: authorized eligible provisioning', () => {
  it('admin provisions an eligible email (claim + doc + role consistent)', async () => {
    const r = await call('provisionAdmin', tokens['pa-admin'], {
      email: 'pa-new-triplykl@test.dev', password: 'Test1234!', displayName: 'PA New',
    });
    assert.equal(r.ok, true);
    assert.equal(r.payload.admin, true);
    assert.equal(r.payload.provisionedBy, 'pa-admin');
    const st = await provisionedState(r.payload.uid);
    assert.equal(st.claim, true);
    assert.equal(st.doc, true);
    assert.equal(st.role, 'admin');
    assert.equal(st.provisionedBy, 'pa-admin');
  });

  it('rejects email without triplykl (case-insensitive policy)', async () => {
    const r = await call('provisionAdmin', tokens['pa-admin'], {
      email: 'plain@test.dev', password: 'Test1234!',
    });
    assert.equal(r.ok, false);
    assert.equal(r.status, 'INVALID_ARGUMENT');
    const upper = await call('provisionAdmin', tokens['pa-admin'], {
      email: 'PA-UPPER-TRIPLYKL@test.dev', password: 'Test1234!',
    });
    assert.equal(upper.ok, true);
  });

  it('rejects unauthenticated callers', async () => {
    const r = await call('provisionAdmin', null, {
      email: 'pa-ghost-triplykl@test.dev', password: 'Test1234!',
    });
    assert.equal(r.ok, false);
    assert.equal(r.status, 'UNAUTHENTICATED');
  });

  it('rejects authenticated non-admin callers', async () => {
    const r = await call('provisionAdmin', tokens['pa-tourist'], {
      email: 'pa-other-triplykl@test.dev', password: 'Test1234!',
    });
    assert.equal(r.ok, false);
    assert.equal(r.status, 'PERMISSION_DENIED');
  });

  it('rejects invalid email/password input', async () => {
    const badEmail = await call('provisionAdmin', tokens['pa-admin'], {
      email: 'not-an-email', password: 'Test1234!',
    });
    assert.equal(badEmail.ok, false);
    assert.equal(badEmail.status, 'INVALID_ARGUMENT');
    const empty = await call('provisionAdmin', tokens['pa-admin'], {});
    assert.equal(empty.ok, false);
    assert.equal(empty.status, 'INVALID_ARGUMENT');
    // New address + too-short password keeps the legacy not-found signal
    // (never creates, never elevates).
    const shortPw = await call('provisionAdmin', tokens['pa-admin'], {
      email: 'pa-short-triplykl@test.dev', password: '123',
    });
    assert.equal(shortPw.ok, false);
    assert.equal(shortPw.status, 'NOT_FOUND');
  });

  it('handles an existing Auth user safely (same uid, no duplicate)', async () => {
    // Idempotent setup: re-runs against a dirty emulator reuse the user.
    let pre;
    try {
      pre = await admin.auth().createUser({
        email: 'pa-exist-triplykl@test.dev', password: 'pass1234',
      });
    } catch (e) {
      if (e.code !== 'auth/email-already-exists') throw e;
      pre = await admin.auth().getUserByEmail('pa-exist-triplykl@test.dev');
    }
    await db.collection('users').doc(pre.uid).set({role: 'tourist'});
    const r = await call('provisionAdmin', tokens['pa-admin'], {
      email: 'pa-exist-triplykl@test.dev', password: 'Test1234!',
    });
    assert.equal(r.ok, true);
    assert.equal(r.payload.uid, pre.uid);
    const st = await provisionedState(pre.uid);
    assert.equal(st.claim, true);
    assert.equal(st.doc, true);
    assert.equal(st.role, 'admin');
  });

  it('concurrent provisions converge on one consistent admin', async () => {
    const email = 'pa-race-triplykl@test.dev';
    const results = await Promise.all([
      call('provisionAdmin', tokens['pa-admin'], {email, password: 'Test1234!'}),
      call('provisionAdmin', tokens['pa-admin'], {email, password: 'Test1234!'}),
    ]);
    assert.ok(results.every((r) => r.ok));
    assert.equal(results[0].payload.uid, results[1].payload.uid);
    const st = await provisionedState(results[0].payload.uid);
    assert.equal(st.claim, true);
    assert.equal(st.doc, true);
    assert.equal(st.role, 'admin');
  });

  it('uid-addressed provisioning enforces the same eligibility rule', async () => {
    let outsider;
    try {
      outsider = await admin.auth().createUser({
        email: 'outsider@test.dev', password: 'pass1234',
      });
    } catch (e) {
      if (e.code !== 'auth/email-already-exists') throw e;
      outsider = await admin.auth().getUserByEmail('outsider@test.dev');
    }
    const denied = await call('provisionAdmin', tokens['pa-admin'], {uid: outsider.uid});
    assert.equal(denied.ok, false);
    assert.equal(denied.status, 'INVALID_ARGUMENT');
    const st = await provisionedState(outsider.uid);
    assert.equal(st.claim, false);
    assert.equal(st.doc, false);
  });
});

describe('provisionAdmin: triplykl email alone grants nothing', () => {
  it('triplykl tourist cannot provision or decide verifications', async () => {
    const p = await call('provisionAdmin', tokens['pa-sneaky'], {
      email: 'pa-friend-triplykl@test.dev', password: 'Test1234!',
    });
    assert.equal(p.ok, false);
    assert.equal(p.status, 'PERMISSION_DENIED');
    const d = await call('decideVerification', tokens['pa-sneaky'], {
      guideId: 'guide1', decision: 'approved',
    });
    assert.equal(d.ok, false);
    assert.equal(d.status, 'PERMISSION_DENIED');
    const st = await provisionedState('pa-sneaky');
    assert.equal(st.claim, false);
    assert.equal(st.doc, false);
  });
});
