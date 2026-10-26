# Triply Chat — Phase C2 Report (Flutter data layer)

**Project:** `triply-f9b82` (Firebase Spark). **Phase:** C2 of 3 — models, repository, cubits, unit tests. No UI, no rules change, no deploy.

## Result

| Check | Result |
|---|---|
| New chat tests | **PASS** — 72 tests, all passing. |
| Full `flutter test` | **PASS** vs baseline — `+155 -1`; the only failure is the pre-existing template test `test/widget_test.dart` (“Counter increments smoke test”). |
| Full `flutter analyze` | **PASS** vs baseline — 0 errors, 0 warnings, 50 infos (the same 50 as before C2; no new lint). |
| Changed files formatted | **PASS** — the final `dart format` run reports 0 changed; the first pass reformatted 10 of the 15 new files. |
| New packages | None. |
| Firebase deploy / UI / data writes | None. |

## Baseline (recorded before C2)

| Check | Baseline |
|---|---|
| `flutter analyze` | exit 1 — 0 errors, 0 warnings, **50 infos** |
| `flutter test` | exit 1 — **+83 -1**, only `test/widget_test.dart` |

Reconciliation of the plan’s “22 info lints”: the C2 prompt’s known baseline was recorded
before C1 added `tool/chat_rules_check.dart`, which contributes 28 `avoid_print` infos.
The measured C2 baseline is therefore 22 app infos + 28 checker infos = **50 infos**.
C2 added **zero** infos, warnings or errors.

## Files added (all new — no existing file was modified by C2)

| File | Lines | Purpose |
|---|---:|---|
| `lib/core/data/models/chat_parsing.dart` | 34 | Tolerant `chatString` / `chatInt` / `chatMap` / `chatDateTime` / `chatTimestamp` readers shared by the models. |
| `lib/core/data/models/chat_profile.dart` | 40 | `profiles.<uid>` entry (`displayName`, `avatarUrl`). |
| `lib/core/data/models/chat_message.dart` | 65 | Message model, `isEdited`, 24-hour `canModify`. |
| `lib/core/data/models/chat.dart` | 176 | `Chat`, `ChatLastMessage`, D25 `ChatIds.canonical`, `otherUserId`, `unreadFor`, `lastReadOf`, `toMap`. |
| `lib/core/data/models/report.dart` | 93 | Report model, fixed reason codes, deterministic `idFor`. |
| `lib/core/data/repositories/chat_repository.dart` | 213 | Repository interface, chat exceptions, `ChatErrors`, `ChatText`, `ChatTypingThrottle`. |
| `lib/core/data/repositories/firestore_chat_repository.dart` | 525 | Firestore implementation aligned with the deployed rules. |
| `lib/features/chat/cubit/chat_list_state.dart` | 64 | List state, unread total, search over name + preview. |
| `lib/features/chat/cubit/chat_list_cubit.dart` | 99 | Watches chats, keeps the badge, single-document watch. |
| `lib/features/chat/cubit/chat_room_state.dart` | 87 | Room state (messages, typing, receipts, busy/read-only flags). |
| `lib/features/chat/cubit/chat_room_cubit.dart` | 364 | Room: load, create-on-first-send, send, pagination, mark-read, typing, edit/delete/report, profile. |
| `test/features/chat/fakes/fake_chat_repository.dart` | 432 | In-memory repository used by the cubit tests (no Firebase). |
| `test/core/data/models/chat_models_test.dart` | 34 tests | Models, canonical id, limits, preview, errors. |
| `test/features/chat/cubit/chat_list_cubit_test.dart` | 11 tests | List, unread badge, ordering, search, signed-out. |
| `test/features/chat/cubit/chat_room_cubit_test.dart` | 27 tests | Create, send, read, typing, pagination, receipts, edit/delete/report, profile, read-only. |

`firestore.rules` and `firestore.indexes.json` were already modified by C1 and are
**unchanged by C2**. The deployed `chats` index (`participants` ASC + `lastMessageAt`
DESC) that `watchChats` needs is in place from C1. No Git commit, push, stash, branch
switch or deploy was performed.

## What the data layer does (matches the deployed rules)

- **Canonical id (D25).** `ChatIds.canonical(a, b)` sorts the two uids with
  `compareTo` and joins with `_`. Role fields stay `touristId`/`guideId` and
  `participants` stays `[touristId, guideId]`; only the document id is sorted.
- **First chat.** `openOrCreateChat` is tourist-only (checked against `users/{uid}.role`),
  builds both `profiles` entries, and writes the chat + first message in **one
  atomic batch**: `unreadCount = {me: 0, guide: 1}`, `lastMessage.text` capped at
  120 characters, `lastMessageAt` = server timestamp.
- **Send.** One batch: the message (`createdAt` = server timestamp) + `lastMessage`,
  `lastMessageAt`, `unreadCount.<other> += 1`. The caller’s own counter is never
  written.
- **List.** `where('participants', arrayContains: uid).orderBy('lastMessageAt', desc)`;
  the total badge is the sum of the caller’s counters.
- **Mark read.** Only `lastReadAt.<me>` (server timestamp) and `unreadCount.<me> = 0`.
- **Messages.** Newest 30, then `loadMoreMessages` pages with
  `startAfter([Timestamp])`; messages are de-duplicated when merged.
- **Typing.** `typing/{uid}` with `updatedAt`; throttled twice — in the repository
  (`ChatTypingThrottle`, one write / 3 s) and in the cubit (injectable clock). The
  stream reports markers newer than 5 s.
- **Edit / delete.** Client pre-checks the sender and the 24-hour window and throws
  `ChatValidationException` (a client misuse must not turn the room read-only); a
  real rules denial maps to `ChatPermissionException`.
- **Report.** Fixed reason codes, note ≤ 500 characters, id
  `{reporterId}_{messageId}`, exact copied `text` / `reportedUserId` /
  `messageCreatedAt` Timestamp, `status: 'open'`, no reviewer fields.
- **Profile.** Only `profiles.<me>` is written.
- **Read-only mapping.** `ChatErrors` maps Firestore `permission-denied` (and a chat
  `ChatPermissionException`) to a read-only room; ordinary failures stay retryable.

## Important correction found during verification

The original C2 implementation created the first chat inside a `runTransaction`
with `transaction.get(chatRef)` as the existence check. That read **cannot work
with the deployed rules**: `chats` read is
`resource.data.participants.hasAny([auth.uid])`, and `resource` is `null` for a
missing document, so the rules deny the read before the create can happen. The same
rules file already relies on this behaviour elsewhere — `guideVerifications`
explicitly allows `resource == null` “so a guide who never submitted gets an empty
snapshot instead of permission-denied” (`firestore.rules:76-81`).

The create path was therefore returned to the plan’s wording (“the first message in
a new chat goes in the same batch as the chat document”):

- `_createChat` writes the chat and first message in one `WriteBatch`; no read of a
  possibly-missing document.
- If that batch is denied, the chat already exists: a full-document `set` on an
  existing chat is an *update*, and the update rule rejects this payload (the new
  `createdAt` is always an affected key, and update (A) allows only
  `lastMessage`/`lastMessageAt`/`unreadCount`). The room then sends through
  `sendMessage`, which is the correct behaviour and makes a real denial surface.
- A concurrent create is race-safe for the same reason: the loser’s create is
  denied, then its message is appended by the normal send batch.

This is a behavioural change from the earlier “transaction” decision, and it is the
only way to create the first chat without a rules change. It is based on the
deployed rules and on the app’s own `resource == null` precedent; it has **not**
been exercised against live Firestore (C2 forbids production writes and no test
credentials were available in this session). A live smoke test of one create + send
is recommended before the chat is used in production (see Pending).

## What the 72 tests cover

- **Models (34):** canonical id in both uid orders and for equal uids; role order
  stays out of the id; full/null/wrong-type documents; fallback `participants`;
  every date shape; `toMap` round-trip; profile defaults; message edit state and
  24-hour window; `preview` at 120, over 120, and without splitting a surrogate
  pair; message limit 20,000; note limit 500; report id, reason codes, evidence
  round-trip; typing throttle (interval, reset, custom interval); `ChatErrors`
  mapping (chat exception, rules denial, signed-out, unknown).
- **List cubit (11):** chats + total unread; newest activity first; other users’
  chats excluded; signed-out message; badge recomputed on change; search by name,
  by preview, empty and unmatched; `copyWith`.
- **Room cubit (27):** first message creates the canonical chat atomically with
  profiles and counters; guide cannot create; existing chat reused; empty message
  rejected; recipient-only unread; 120-character preview; permission denial →
  read-only; ordinary failure → not read-only; load with/without id; missing chat;
  mark-read moves only my marker; typing throttle; 30-message page + next page;
  short first page; read receipts from the other `lastReadAt`; edit own/other/late;
  delete; report with copied evidence; own-message report refused; unknown reason
  refused; own profile only; `copyWith`.

The tests use `FakeChatRepository`, whose streams are per-listen
`StreamController` snapshots. Deliberately not `async*`: cancelling an `async*`
subscription to a broadcast stream can leave `Cubit.close()` pending, which timed
out the test harness.

## Verification commands and exact output

| Command | Output |
|---|---|
| `flutter analyze` | `50 issues found` — 0 errors, 0 warnings, 50 infos (all pre-existing). |
| `flutter test` | `+155 -1: Some tests failed` — only `test/widget_test.dart` “Counter increments smoke test”. |
| `flutter test <the 3 chat test files>` | `+72: All tests passed!` |
| `flutter analyze <the 15 chat files>` | `No issues found!` |
| `dart format <the 15 chat files>` | final run: 0 changed (the first pass changed 10). |

## Residual risks / known gaps

1. **No live test of `FirestoreChatRepository`.** The guard forbids an emulator and
   C2 allows no production writes; the cubits are tested against the fake. The
   create-path correction is reasoned from the deployed rules, not observed live.
2. **Preview limit metric.** `ChatText.preview` counts Unicode scalar values (runes).
   The rules use `.size()`, documented as “number of characters”; if the engine
   counts UTF-16 code units instead, a 120-rune preview ending in an astral-plane
   emoji could be 121 units and be denied. Arabic is unaffected (one unit per
   character). Suggested check for the next rules run: add a 120-rune emoji preview
   case to `tool/chat_rules_check.dart`. Not a C3 UI blocker.
3. **Bare chats.** `openOrCreateChat` without a first message creates a chat with no
   `lastMessageAt`; such a chat would be absent from the ordered `watchChats` query.
   The room cubit never does this (it only calls the repository when the user sends),
   so it is reachable only by direct repository use.
4. **Stale chat id.** Reading a nonexistent chat id is denied by the `chats` read
   rule, so the room shows a generic permission error and becomes read-only instead
   of “chat not found”. Only reachable from a stale deep link; C3 should guard its
   entry points.
5. **Typing clock skew.** `watchTyping` compares the server-written `updatedAt` with
   the local clock; a skewed device can stretch or shorten the 5-second window.
   Cosmetic only.
6. **Live index.** `watchChats` depends on the C1 composite index
   (`participants` + `lastMessageAt`), already deployed. No C2 index change.
7. **Report review.** The rules already allow admin review (`status`, `reviewerId`,
   `reviewNote`); C2 implements creation only. Review UI is outside C3.

## Pending for Khaled (not part of C2)

1. Optional live smoke test with the two authorized test accounts, after C3 is
   ready: sign in as the tourist, open a chat, send one message, read it as the
   guide, then delete the chat/message/report documents the test created (chats have
   no client delete). This is the only way to confirm the batch create path end to
   end.
2. Optional: add the emoji-preview case to the rules checker when the rules are next
   exercised.

## Phase C3 may start: YES

All C2 deliverables are in place; formatting, analysis and tests match the baseline
plus 72 new passing tests, and the only failing test is the pre-existing template
test. C2 changed no rules, indexes, UI or production data. The remaining items above
are low-risk notes for C3 and the eventual production smoke test, not blockers for
building the screens.
