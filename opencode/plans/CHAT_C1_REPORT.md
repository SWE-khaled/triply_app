# Triply Chat — Phase C1 Report (Spark-only)

**Project:** `triply-f9b82` (Firebase Spark). **Phase:** C1 of 3 — preflight, rules, indexes.

## Baseline (before any change)

| Check | Result |
|---|---|
| `flutter analyze` | PASS — 0 errors, 22 info lints (matches the known baseline). |
| `flutter test` | PASS — 83 tests pass, 1 known failing template test `test/widget_test.dart` (matches the known baseline). |

## Contract correction — D25 (deployed and verified)

**D25 (accepted design):** the chat document id must be built from the two
participant uids in sorted order, joined with `_` (for example
`[touristId, guideId]..sort()`). It must not depend on which participant is the
tourist. The `touristId`/`guideId` role fields and the `participants` array stay
role-ordered; only the document id is canonical.

**What C1 originally shipped:** `chatId == touristId + '_' + guideId`. That is
the contract mismatch: a reversed role pairing would produce a second id for the
same two people.

**Correction applied and deployed:**

| File | Change |
|---|---|
| `firestore.rules` | Added `chatCanonicalId(a, b)` (puts the lexicographically lower uid first) and changed only the `chats` create condition to `chatId == chatCanonicalId(touristId, guideId)`. No other rule was touched; the S3 and unrelated blocks are unchanged. |
| `tool/chat_rules_check.dart` | Uses the same canonical builder, self-tests both synthetic UID orders before any live Firestore call, creates the chat at the canonical id, and adds a denial check for the reversed id. |
| `opencode/plans/CHAT_FEATURE_PLAN_SPARK.md` | D25/C-D2, the data model, and the rules summary now state the sorted contract. |
| `opencode/plans/rules.before-D25.rules` | Backup of `firestore.rules` immediately before this correction (SHA-256 starts `CDDD26B0…`). |

**D25 deploy (completed):**

| Item | Result |
|---|---|
| Target project | `triply-f9b82` |
| Command | `firebase deploy --only firestore:rules --project triply-f9b82` |
| Result | PASS — completed successfully after the D25 correction |
| `--force` | Not used |
| Spark plan | PASS — no billing change, no Cloud Functions, no emulator |

**Rollback (if ever needed):** restore `opencode/plans/rules.before-D25.rules`
over `firestore.rules`, confirm `firebase use` prints `triply-f9b82`, then run
`firebase deploy --only firestore:rules --project triply-f9b82` (no `--force`).

**Checker corrections and live verification:** the live checker went through
several rounds of fixes before it could produce valid evidence.

- **Transport.** Creates and patches now go through `documents:commit`. Server
  timestamps are sent as `updateTransforms` (`setToServerValue: REQUEST_TIME`),
  never as a `Value`: the earlier `{"timestampValue": null}` encoding left the
  `Value` oneof unset and produced HTTP 400 `Cannot convert
  firestore.v1.Value with type unset.` Explicit timestamps use a
  `TimestampValue` wrapper. (The intermediate `createDocument`/querystring
  `updateMask` fixes were superseded by this commit-based path.)
- **Classification.** Only HTTP 403 with Firestore status `PERMISSION_DENIED`
  counts as a rules denial. Malformed or unexpected responses are `ERROR` and
  count as failures; a create precondition collision is `SKIP`, never `PASS`.
- **Report prerequisite.** `messageCreatedAt` is sent as a timestamp (not a
  string) and is read back from the created message, so it equals the message's
  `createdAt`. Checks whose chat/message prerequisite was not created are
  `SKIP`, never `PASS`.
- **Offline guard.** An encoder self-test asserts one non-null `*Value`
  discriminator per supplied field, that no field is added or dropped, and that
  a server timestamp never reaches `_toValue`.
- `dart analyze tool/chat_rules_check.dart`: 0 errors, 0 warnings; only
  `avoid_print` infos remain.

**Live result:** the run completed with `failures: 0`; the check table is in
STEP 5. No further deploy or production test is required for C1.

**Source note:** the literal D25 note is not stored in this repository. The
contract applied here is the accepted requirement (sorted participant uids),
which is also the canonicalisation recommended in
`opencode/plans/TRIPLY_FULL_APP_TECHNICAL_AUDIT.md` §21.2 Requirement 1.

## STEP 1 — Preflight answers

### 1a. Current rules: helpers and the `users`, `bookings`, `trips` blocks

Helpers (firestore.rules:7-35), reused unchanged:

```
function isSignedIn() {
  return request.auth != null;
}

function isOwner(userId) {
  return isSignedIn() && request.auth.uid == userId;
}

function userRole() {
  return exists(/databases/$(database)/documents/users/$(request.auth.uid))
    ? get(/databases/$(database)/documents/users/$(request.auth.uid)).data.get('role', '')
    : '';
}

function isAdmin() {
  return isSignedIn() && userRole() == 'admin';
}

function noAdminExists() {
  return !exists(/databases/$(database)/documents/appSettings/_bootstrap);
}
```

`users` block (firestore.rules:40-66): owner get/update (role, `isActive`, `isApproved` pinned on self-update), admin list/update/delete, create with role in `['tourist','guide']` (and `isActive` absent-or-true) or first-account admin bootstrap.

`trips` block (firestore.rules:177-224): approved trips public, owner reads/creates (`pending` only)/updates (workflow fields pinned, `bookedSeats` pinned for the owner), a separate signed-in branch bumps only `bookedSeats` within `[0, capacity]`, delete by owner or admin.

`bookings` block (firestore.rules:230-295): get/list by either party or admin; create by the owning tourist only as `pending/pending`; update by admin, by the owning guide (payment fields pinned), by the owning tourist for the exact `pending/pending -> confirmed/paid` transition (with non-empty `paymentId`) or for cancellation (payment state preserved, `cancelledAt`/`cancelledBy: 'tourist'`/`refundStatus` per payment state); delete by admin or by the owning tourist while `paymentStatus == 'pending'`.

### 1b. How a guide is identified, and approval / `isActive`

- **Role:** `users/{uid}` field `role`, value `'guide'` (read by the existing `userRole()` helper, firestore.rules:20-24).
- **Approval:** `users/{uid}` field `isApproved` (bool). The admin writes it in `AdminGuidesRepository.decideVerification` (lib/core/data/repositories/admin_guides_repository.dart:153-155) and `suspendGuide` (line 169-172); the same flag is mirrored on `guides/{uid}` (lines 157-159, 173-175). **Missing value means NOT approved** — the app reads it as `map['isApproved'] as bool? ?? false` (lib/features/common/AuthTourguide/data/tour_guide_auth_service.dart:76-81) and the rules use `.get('isApproved', false)`.
- **Active:** `users/{uid}` field `isActive` (bool). The plan's chat rule treats **missing as active** (`isActive != false`).

### 1c. Where the tourist app gets the guide's name and avatar

- Collection: `guides/{guideId}` (doc id = guide uid), fields `name` and `avatarUrl` — model lib/core/data/models/public_guide.dart:9-11, tolerant read at lines 64-66.
- Repository: lib/core/data/repositories/public_guides_repository.dart:13 (`guidesCollection = 'guides'`), `fetchGuide` at lines 36-45.
- Guide profile screen: lib/features/tourist/guides/view/guide_profile_screen.dart:32 (creates `GuideProfileCubit`), which loads via `fetchGuide` at lib/features/tourist/guides/cubit/guide_profile_cubit.dart:46.
- Trip details screen opens the same `GuideProfileScreen`: lib/features/tourist/trip_details/view/trip_details_screen.dart:125-131.

### 1d. State management, navigation, existing chat stubs

- **State management:** flutter_bloc (Cubit + BlocBuilder), e.g. lib/main.dart:38-44, lib/features/tourist/guides/cubit/guide_profile_cubit.dart:18.
- **Navigation:** plain `MaterialApp` named routes (lib/main.dart:56-70, route names in lib/core/constants/app_routes.dart) plus `MaterialPageRoute` pushes (e.g. lib/features/tourist/trip_details/view/trip_details_screen.dart:131).
- **Existing chat screens/stubs in lib/:** none. The only chat-adjacent artifacts are the `messageCircle` icon in the tourist bottom nav (lib/core/widgets/app_bottom_nav.dart:22 — currently the Community tab) and the unused `chatIconBg` color (lib/core/theme/app_colors.dart:17). No chat models, repositories, cubits, or screens exist.

## STEP 2 — Rules (new match blocks only)

Backup: `opencode/plans/rules.before-C1.rules` (copy of `firestore.rules` before the C1 edits).

New blocks added (all after the existing `notifications` block; no existing rule was touched):

- `chatCanonicalId(a, b)` (the lower uid first, joined with `_`), `chatUserPath(uid)`, `chatUserActive(uid)` (missing doc counts as active), `chatGuideOk(guideId)` (users doc exists, `role == 'guide'`, `isApproved == true`, `isActive != false`), `chatOther(resource)` (the participant that is not the caller).
- **chats read:** participants only (`request.auth.uid in resource.data.participants`), get and list. No `isAdmin()` anywhere in the chat blocks.
- **chats create:** caller is a tourist; `chatId == chatCanonicalId(touristId, guideId)` (the two uids sorted lexicographically, joined with `_`); `guideId` passes `chatGuideOk`; `participants == [touristId, guideId]`; `profiles` holds exactly the two participants' entries, each with only `displayName`/`avatarUrl`; `createdAt` is a timestamp; two allowed shapes — bare (no `lastMessage`/`lastMessageAt`/`lastReadAt`, both `unreadCount` 0) or with the first message in the same batch (`lastMessage` 1-120 chars, `senderId` = caller, `lastMessageAt` timestamp, `unreadCount` = {me: 0, guide: 1}). A guide can never create. No client delete (no delete rule).
- **chats update:** a participant, with both participants active; exactly one of: (A) send — only `lastMessage`/`lastMessageAt`/`unreadCount` change, preview 1-120 chars, `senderId` = caller, the other's `unreadCount` exactly +1, own count unchanged; (B) mark read — only `unreadCount`/`lastReadAt` change, own count reset to 0, other's count unchanged, own `lastReadAt` a timestamp, the other's `lastReadAt` entry pinned; (C) own `profiles` entry only (other's entry pinned).
- **messages read:** participants only (via `get()` on the parent chat).
- **messages create:** sender is a participant (via `getAfter()` on the parent chat, so the first message works in the same batch as the chat create), `senderId == auth.uid`, keys only `senderId`/`text`/`createdAt`, `createdAt == request.time`, text 1-20,000 chars, both participants active.
- **messages update:** sender only, only `text`/`editedAt`, `editedAt == request.time`, within 24h of `createdAt`, both participants active.
- **messages delete:** sender only, within 24h of `createdAt`, both participants active.
- **typing:** participants read; a participant writes only their own doc (`updatedAt == request.time`, key allowlist), including delete of their own doc.
- **reports create:** the reporter is a participant of `chatId`, `reportedUserId` is the other participant, `reportId == reporterId + '_' + messageId`, `reasonCode` in the fixed list, `note` a string of at most 500 chars, `status == 'open'`, no `reviewerId`/`reviewNote` at create, and `get()` on the real message requires the copied `text`, `senderId` and `createdAt` to match it.
- **reports read:** admin or the reporter (own report). **update:** admin only, only `status`/`reviewerId`/`reviewNote`, `status` in the fixed list. **delete:** admin only.

`get()`/`getAfter()` counts per rule: chats create 1 (users doc, cached across the three field reads), chats update 2 (the two users docs), messages create 2 (chat via `getAfter`, cached; the two users docs), messages update/delete 3 (chat + two users docs), typing 1 (chat), reports create 2 (chat + message, each cached). All within Firestore limits.

## STEP 3 — Indexes (additive)

`firestore.indexes.json`: one composite index added for `chats` — `participants` ASCENDING + `lastMessageAt` DESCENDING (COLLECTION scope), matching the chat-list query `where(participants, array-contains: uid).orderBy(lastMessageAt, desc)`. No other query in the plan needs an index. Existing indexes untouched.

## STEP 4 — Deploy

| Check | Result |
|---|---|
| Backup before editing | PASS — `opencode/plans/rules.before-C1.rules` (SHA-256 `D890AE4B…44A6621`, matched the source at copy time) and `opencode/plans/indexes.before-C1.indexes.json`. |
| Rules compile | PASS — `firebase deploy --only firestore:rules --dry-run` reports "compiled successfully" with no warnings. |
| Active Firebase project | PASS — `firebase use` printed `triply-f9b82` immediately before the deploy. |
| Deploy command | `firebase deploy --only firestore:rules,firestore:indexes --project triply-f9b82` — no `--force`. |
| Deploy result | PASS — "released rules firestore.rules to cloud.firestore" and "deployed indexes in firestore.indexes.json successfully". The CLI noted 9 pre-existing console-created indexes not in the file; they were left untouched (no `--force`). |
| Spark plan | PASS — no billing change, no Cloud Function, no emulator. |

**Rollback command** (if needed): restore `opencode/plans/rules.before-C1.rules` over `firestore.rules` (and `opencode/plans/indexes.before-C1.indexes.json` over `firestore.indexes.json`), confirm `firebase use` prints `triply-f9b82`, then run `firebase deploy --only firestore:rules,firestore:indexes --project triply-f9b82` (no `--force`).

## STEP 5 — Verification

`tool/chat_rules_check.dart` was written as specified: it signs in as the two test accounts through the Firebase Auth REST API (credentials only from `CHAT_TEST_TOURIST_EMAIL/PASSWORD`, `CHAT_TEST_GUIDE_EMAIL/PASSWORD`; the web API key comes from the committed app config; nothing secret is printed) and calls the Firestore REST API with the ID token, so the deployed rules are really evaluated. No Admin SDK is used for any check. Optional `CHAT_TEST_THIRD_*` / `CHAT_TEST_ADMIN_*` variables enable the third-account and admin checks when present.

**Status: RUN against the live project and PASSED.** Khaled ran the checker with the tourist and guide test accounts against `triply-f9b82` after the D25 deploy. The run completed with `failures: 0`. Tourist canonical chat creation, message creation, sender editing and the correct report creation all returned HTTP 200. Every executed negative check returned HTTP 403 `PERMISSION_DENIED`, including the reversed-id chat, so the denials are real rules decisions rather than malformed requests. The optional third-account and admin accounts were not supplied, so those checks are SKIP — not PASS. No `ERROR` rows were reported.

Check table (live run, `failures: 0`):

| # | Check | Expected | Result |
|---|---|---|---|
| 1 | tourist creates the chat at the canonical (sorted) id | allowed | **PASS** — HTTP 200 |
| 1b | tourist tries the reversed id for the same pair | denied | **PASS** — HTTP 403 `PERMISSION_DENIED` |
| 2 | guide tries to create a chat with a tourist | denied | **PASS** — HTTP 403 `PERMISSION_DENIED` |
| 3 | tourist creates a chat with a non-guide uid | denied | **PASS** — HTTP 403 `PERMISSION_DENIED` |
| 4 | a third account (or unauthenticated) reads the chat | denied | **PASS** (unauthenticated read) — HTTP 403 `PERMISSION_DENIED`; third-account sub-check **SKIP** (no optional account supplied) |
| 5 | either participant sends a message | allowed | **PASS** — HTTP 200 |
| 6 | a message with `createdAt` not equal to request time | denied | **PASS** — HTTP 403 `PERMISSION_DENIED` |
| 7 | text over 20,000 characters | denied | **PASS** — HTTP 403 `PERMISSION_DENIED` |
| 8 | edit by the sender / by the other person | allowed / denied | **PASS** — HTTP 200 / HTTP 403 `PERMISSION_DENIED` |
| 9 | admin reads the chat | denied (only if a test admin exists, else not tested) | **SKIP** — no optional admin account supplied |
| 10 | report with copied text different from the real one | denied | **PASS** — HTTP 403 `PERMISSION_DENIED` |
| 11 | report with the right copied text | allowed | **PASS** — HTTP 200 |
| 12 | updating another user's `profiles` or `lastReadAt` entry | denied | **PASS** — HTTP 403 `PERMISSION_DENIED` |

The checker self-tests the canonical builder with synthetic uids in both lexical
orders (`aaa_zzz` and `zzz_aaa` both map to `aaa_zzz`) before any live Firestore
call. A live account pair has one actual order, so check 1b proves the other
order is rejected. Execution order is 2 → 1 → 1b so the guide's create attempt
(check 2) sees a canonical id that does not exist yet; otherwise it could be
answered by `ALREADY_EXISTS` instead of the role rule.

**How it was run (Khaled):** the four environment variables for the two test accounts (one tourist, one guide; the guide active and approved) were set, then `dart run tool/chat_rules_check.dart` was executed against the live project. The script printed the canonical id, PASS/FAIL/SKIP per check, and deleted the test message it created (the sender may delete within 24h).

**Cleanup:** the test **chat** and **report** documents have no client delete by design and no Admin SDK credentials were available. Khaled deleted the documents in the Firebase Console and confirmed completion:

- `chats/{sorted(touristUid, guideUid).join('_')}`
- `reports/{guideUid}_c1check_msg`
- Any extra chat path listed by check 1b or 3, if it had unexpectedly passed (it did not).

This cleanup is user-confirmed; it was not independently verified by the assistant.

## Post-change Flutter baseline

C1 touched no Dart code in `lib/` or `test/`. The D25 correction touched only `firestore.rules`, `tool/chat_rules_check.dart`, and the plan/report. `flutter analyze` (0 errors / 22 info) and `flutter test` (83 pass / 1 known `test/widget_test.dart` failure) were recorded before the changes and are unaffected. This reconciliation changed only this report; no Flutter code, rules, indexes, or test data were modified.

## Remaining risks (D25)

- **Deployed and verified:** the D25 canonical create rule is live in
  `triply-f9b82`, and the live checker completed with `failures: 0`.
- **Old-id chats:** any chat created with the pre-D25 tourist-first id would
  remain readable/writable and is not canonical. There is no client delete for
  chats, so it would need Console cleanup before C2. The live checker created
  only the canonical id, checks 1b and 3 did not pass unexpectedly, and Khaled
  removed the test chat; no non-canonical chat documents are known to remain.
- **Separator and charset:** the `_` join is unambiguous only while uids
  contain no `_`. Production users were verified as 28-character alphanumeric
  uids; custom auth or new providers could break that assumption.
- **ASCII assumption:** rules string comparison and Dart `compareTo` agree for
  the current ASCII uids. Non-ASCII uids would need a separate check.
- **Checker proven live:** the commit/transform transport, the 403-only denial
  classification and the `SKIP` handling completed a full live run with
  `failures: 0`. Re-run only if the rules change later.
- **Whole-file deploy:** the deploy releases the entire `firestore.rules` file,
  including the already-live S3/booking changes. Use the
  `rules.before-D25.rules` diff to review D25 in isolation, and the backup as
  the rollback.

## What is still pending for Khaled

1. Optional: supply dedicated third-account and/or admin test accounts to turn
   the two SKIP rows (third-account read, admin read) into PASSes. These checks
   are optional and do not block C2.
2. Re-verify the S3 manual checklist (book / cancel / create trip / guide
   bookings list) after the whole-file rules deploy, as noted in the C1 deploy.
3. Manual cleanup of the C1 test chat/report is completed and user-confirmed.
   No other C1 test data is known to remain.

No further deploy or production test is required for C1.

**Rollback (if ever needed):** restore `opencode/plans/rules.before-D25.rules`
over `firestore.rules`, confirm `firebase use` prints `triply-f9b82`, then run
`firebase deploy --only firestore:rules --project triply-f9b82` (no `--force`).

## Phase C2 may start: YES

All required live checks passed with `failures: 0`. The only SKIPs are the
optional third-account and admin checks for accounts that were not supplied;
they are not failures. Khaled confirmed the test chat and report documents were
removed, and the D25 rules are deployed and verified on `triply-f9b82`.