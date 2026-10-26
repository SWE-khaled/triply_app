# Triply Chat Feature Plan: SPARK-ONLY version (replaces `CHAT_FEATURE_PLAN.md`)

**Status:** proposal for review. **Project:** `triply-f9b82` (Firebase **Spark**, no Cloud Functions).
**What changed from the old plan:** chat exists **before booking**, as a feature tied to the guide. No Blaze, no Functions, no push. Foundations are no longer a dependency except that the S3 rules are live.

---

## 0. طريقة الاستخدام (بالعربي)

1. **الملف ده بيحل محل `CHAT_FEATURE_PLAN.md`.** امسح القديم من `opencode/plans/` عشان OpenCode ماياخدش منه Functions وBlaze.
2. **قبل ما تبدأ:** شغّل `flutter analyze` و`flutter test` بنفسك، وجرّب في التطبيق 3 حاجات (حجز بكارت test، إلغاء، رحلة جديدة من المرشد) عشان تتأكد إن قواعد S3 شغالة. وخد `git commit` للحالة الحالية عشان الرجوع يبقى سهل.
3. **جهّز حسابين test:** توريست ومرشد (المرشد لازم يكون نشط ومعتمد). هتحط إيميلاتهم وباسورداتهم في environment variables على جهازك بس، وماتبعتهمش في أي شات.
4. **شغّل C1 ثم C2 ثم C3** كل واحدة في session جديدة، وانسخ **اللي جوه الـ code block بس**.
5. **ماتروحش للـ phase اللي بعدها** إلا لما التقرير يقول `may start: YES`.
6. **الـ push مش موجود.** الإشعار هيبقى بادج الرسائل الجديدة جوه التطبيق بس.

---

## 1. Decisions

### 1.1 Product (kept from the old plan unless noted)

| # | Decision |
|---|---|
| D1 | Chat is between a Tourist and a Tour Guide, for inquiries. |
| **D2 (changed)** | **Available before booking.** No booking is needed, and booking state never affects the chat. |
| **D14 (changed)** | **Only the tourist can start a chat.** The guide cannot open a conversation with a tourist; the guide sees and replies to chats tourists started. |
| D6, D7 | One private chat per (tourist, guide) pair, one continuous chat, no group chat. |
| D8 | Text only. |
| D9 (minus push) | Instant delivery, unread badge, read receipts, typing indicator. **No push notifications** (they need a server). |
| D11 | Chat is private. Admin cannot read chats. |
| D12, D13 | Sender can edit or delete own message within 24 hours; deleted disappears; edited shows an "edited" label. |
| D15, D30 | Report only (no Block). Reasons: spam, harassment, inappropriate content, other, plus optional note up to 500 characters. Admin sees only the reported message. |
| D16 | Chat list item: other person's name and avatar, last message preview, time, unread count. |
| D17 | No user-visible max length; a technical ceiling of 20,000 characters is enforced in rules. |
| D25 | The chat document id is canonical: the two participant uids sorted lexicographically and joined with `_`. The `touristId`/`guideId` role fields stay role-ordered. |
| D36, D37 | Search by name and last message; total unread badge = sum from the chat list on the client. |

Removed because they depended on bookings or servers: D3, D4, D5, D18 to D21, D23, D24, D29, D31 to D33, D35 (the Message button now just opens the chat).

### 1.2 Platform and design

| # | Decision |
|---|---|
| C-D1 | Stay on Spark. No Cloud Functions; every rule is enforced by Firestore rules and every counter is written by the client. |
| C-D2 | Chat ID is canonical (D25): the two participant uids sorted lexicographically, joined with `_`. The tourist creates the chat document; the rules check the caller is the tourist, the other uid is an active approved guide, and the ID equals the canonical id of the two uids (whichever sorts first). The chat is created when the first message is sent, in one batch. |
| C-D3 | `chats/{id}/messages`, `chats/{id}/typing/{uid}`, and `reports/{reporterId}_{messageId}` as before. |
| C-D4 | Each participant writes only their own `profiles.<uid>` (displayName, avatarUrl). On creation the tourist writes both entries, because `users` docs are readable only by their owner. |
| C-D5 | The sender's client updates `lastMessage`, `lastMessageAt` and the recipient's `unreadCount` in the same batch as the message. Each client writes only its own `lastReadAt` and resets its own `unreadCount`. |
| C-D6 | A chat is read-only when either account has `isActive == false`, checked in rules with `get()` on `users` at write time (missing counts as active). No trigger. |
| C-D7 | Reports are created by the client; rules read the real message with `get()` and require the copied text, senderId and createdAt to match, so evidence cannot be forged. |
| C-D8 | Verification of rules uses test accounts through the Firebase Auth and Firestore REST APIs (rules really apply). The Admin SDK is used only to delete test data, and only if credentials exist; otherwise Khaled deletes it in the Console. |
| C-D9 | Old Foundations booking and payment work is untouched; the S3 rules stay live and chat rules are new blocks only. |

## 2. Data model

**`chats/{id}`** (id = the two participant uids sorted lexicographically, joined by `_`, e.g. `[touristId, guideId]..sort()`): `touristId`, `guideId`, `participants` (`[touristId, guideId]`), `profiles` (`uid -> {displayName, avatarUrl}`), `lastMessage` (`{text (max 120), senderId, createdAt}`), `lastMessageAt`, `unreadCount` (`uid -> number`), `lastReadAt` (`uid -> timestamp`), `createdAt`.

**`chats/{id}/messages/{messageId}`**: `senderId`, `text`, `createdAt` (must equal request time), `editedAt` (optional).

**`chats/{id}/typing/{uid}`**: `updatedAt` (written about every 3 seconds while typing).

**`reports/{reporterId}_{messageId}`**: `reporterId`, `reportedUserId`, `chatId`, `messageId`, `text`, `messageCreatedAt`, `reasonCode`, `note`, `status` (`open | resolved | dismissed`), `reviewerId`, `reviewNote`, `createdAt`.

## 3. Security rules (summary for C1)

New match blocks only; unmatched paths stay denied; no `isAdmin()` in any chat, message or typing rule.

- **chats read:** only participants (`request.auth.uid in resource.data.participants`); list queries filter with `array-contains`.
- **chats create:** `auth.uid == touristId`, the caller's role is tourist, `guideId` is a guide with `isActive != false` (and approved if the app uses an approval field), `chatId == sorted([touristId, guideId]).join('_')` (rules compare the two uids and require the lower one first), `participants == [touristId, guideId]`, counters start at 0, keys limited. Guide cannot create. No client delete.
- **chats update:** a participant may change only: `lastMessage`, `lastMessageAt`, the OTHER participant's `unreadCount` by exactly +1 (together with a new last message), their own `unreadCount` (reset to 0), their own `lastReadAt`, their own `profiles` entry. Both participants must be active.
- **messages create:** sender is a participant, `senderId == auth.uid`, keys limited to `senderId, text, createdAt`, `createdAt == request.time`, text 1 to 20,000 characters, parent chat exists (use `getAfter` so it also works in the same batch that creates the chat), both users active. **update:** sender only, only `text` and `editedAt`, `editedAt == request.time`, within 24h of `createdAt`. **delete:** sender only, within 24h.
- **typing:** participants read; a participant writes only their own doc with `updatedAt == request.time`.
- **reports:** create by a participant of that chat, reporting the other participant, matching the real message; no client update or delete by the reporter; admin reads and updates only `status`, `reviewerId`, `reviewNote`.

## 4. Phases

| Phase | What we do | Deploy |
|---|---|---|
| **C1** | Preflight read-only, chat rules and indexes, REST-based rules check. | `firestore:rules` and `firestore:indexes` |
| **C2** | Flutter models, repository, cubits and unit tests. No UI. | none |
| **C3** | Message button, chat list, chat room, unread badge. | none |

---

### Phase C1 Prompt: Preflight, rules and indexes

**What we do:** read the current code and rules, then add the chat rules and indexes on top of the already-deployed S3 rules.

```
GUARD CLAUSE (include at the top of every phase prompt):
1. Modify only the files listed in this prompt. Additive changes only: do
   not rename or delete existing files, collections, rules, indexes. In
   firestore.rules add NEW match blocks only; never edit existing ones.
2. Do not start or configure any emulator. There is no test environment:
   all verification runs against the real project `triply-f9b82`, using
   only the dedicated test accounts named below.
3. The project stays on the Firebase SPARK (free) plan. Never enable
   billing, never create or deploy Cloud Functions, never ask Khaled to
   upgrade. Before ANY deploy: print the active Firebase project id and
   abort unless it is `triply-f9b82`. Deploy only the targets this phase
   lists (--only firestore:rules and/or --only firestore:indexes). Never
   use --force. Save the current rules/indexes to a backup file before
   deploying and state the exact rollback command.
4. Test data: use only the two test accounts Khaled names (one tourist,
   one guide). Never read, modify, or delete data of any other user. The
   Admin SDK is allowed ONLY to delete the test data this phase created,
   and only if credentials are already in the environment; otherwise list
   the documents for Khaled to delete in the Firebase Console. Never use
   the Admin SDK to claim a rule works: it bypasses rules.
5. Never print, log, or commit secrets, passwords, ID tokens or
   service-account keys; read credentials from environment variables only.
6. Before changing anything, record the baseline of `flutter analyze` and
   `flutter test` (last known: 0 errors, 22 info lints, about 83 tests
   pass, 1 known failing template test test/widget_test.dart). After your
   changes, require NO NEW failures compared with that baseline. Stop and
   report on the first new failure; do not continue past it. If the
   Flutter SDK is locked by another process, say so and ask Khaled to
   close other Flutter processes; do not skip the check silently.
7. End with a short verification report: what was changed/deployed, what
   was tested, PASS/FAIL per check, and what is still pending for Khaled.

CONTEXT
Spark-only Chat, Phase C1 of 3. Read opencode/plans/CHAT_FEATURE_PLAN_SPARK.md
(sections 1 to 3) and opencode/plans/FOUNDATIONS_S3_REPORT.md. The S3
rules in firestore.rules are LIVE; do not weaken them.

STEP 1: PREFLIGHT (read-only, report before editing)
a. Print the helpers and the `users`, `bookings`, `trips` blocks of the
   current firestore.rules. Reuse existing helpers; do not edit them.
b. In rules, how is a guide identified (`role == 'guide'`) and how is
   approval and `isActive` represented on `users` docs (field names and
   what a missing value means)? Report the exact field names.
c. Where does the tourist app get the guide's name and avatar for the guide
   profile and trip screens (which collection/fields)? Report file:line.
d. Which state management and navigation the app uses, and any existing
   chat/message screens or stubs in lib/. Report paths only.
Write the answers into opencode/plans/CHAT_C1_REPORT.md (no leading dot).

STEP 2: RULES (new match blocks only; backup firestore.rules first to
opencode/plans/rules.before-C1.rules)
Implement section 3 of the plan exactly: chats, chats/{id}/messages,
chats/{id}/typing, reports. Important details:
- Do not use isAdmin() in any chats/messages/typing rule.
- The message `create` rule must use getAfter() on the parent chat path
  (not get()), because the first message is written in the same batch as
  the chat document. Use get() on users/{uid} to check both participants
  are active (`isActive != false`, missing counts as active).
- The report `create` rule must get() the real message document and require
  the copied text, senderId and createdAt to equal it.
- Keep every get()/getAfter() count within Firestore's limits.

STEP 3: INDEXES (firestore.indexes.json, additive)
Composite index for the chat list: chats where `participants`
array-contains uid, ordered by `lastMessageAt` descending. Add others only
if a query in the plan needs one.

STEP 4: DEPLOY
Print the active project id; abort unless `triply-f9b82`. Deploy with
`firebase deploy --only firestore:rules,firestore:indexes`. No --force.

STEP 5: VERIFY (no emulator, no Admin SDK for checks)
Write tool/chat_rules_check.dart: a Dart script that signs in as the two
test accounts through the Firebase Auth REST API (email and password from
environment variables CHAT_TEST_TOURIST_EMAIL, CHAT_TEST_TOURIST_PASSWORD,
CHAT_TEST_GUIDE_EMAIL, CHAT_TEST_GUIDE_PASSWORD; the Web API key from the
existing app config; print none of them) and calls the Firestore REST API
with the ID token, so the rules are really evaluated. Check and report
PASS/FAIL for at least: tourist creates the chat (allowed); guide tries to
create a chat with a tourist (denied); tourist creates a chat with a
non-guide uid (denied); a third account cannot read the chat (denied);
either participant sends a message (allowed); a message with createdAt not
equal to request time (denied); text over 20000 characters (denied); edit
by the sender (allowed) and by the other person (denied); admin reading
the chat (denied, only if a test admin exists, else say not tested);
report with the copied text different from the real one (denied); report
with the right text (allowed); updating another user's `profiles` entry
or `lastReadAt` entry (denied).
Then clean up: delete the test chat, messages, typing and report docs.

REPORT
Write opencode/plans/CHAT_C1_REPORT.md: preflight answers, rules summary
(allowed/denied in words), the check table, backups, rollback, cleanup
status, and the line "Phase C2 may start: YES/NO". Do not start C2.
```

---

### Phase C2 Prompt: Flutter data layer

**What we do:** repository, models and cubits for chat, with unit tests. No screens yet.

```
GUARD CLAUSE (include at the top of every phase prompt):
1. Modify only the files listed in this prompt. Additive changes only: do
   not rename or delete existing files, collections, rules, indexes. In
   firestore.rules add NEW match blocks only; never edit existing ones.
2. Do not start or configure any emulator. There is no test environment:
   all verification runs against the real project `triply-f9b82`, using
   only the dedicated test accounts named below.
3. The project stays on the Firebase SPARK (free) plan. Never enable
   billing, never create or deploy Cloud Functions, never ask Khaled to
   upgrade. Before ANY deploy: print the active Firebase project id and
   abort unless it is `triply-f9b82`. Deploy only the targets this phase
   lists (--only firestore:rules and/or --only firestore:indexes). Never
   use --force. Save the current rules/indexes to a backup file before
   deploying and state the exact rollback command.
4. Test data: use only the two test accounts Khaled names (one tourist,
   one guide). Never read, modify, or delete data of any other user. The
   Admin SDK is allowed ONLY to delete the test data this phase created,
   and only if credentials are already in the environment; otherwise list
   the documents for Khaled to delete in the Firebase Console. Never use
   the Admin SDK to claim a rule works: it bypasses rules.
5. Never print, log, or commit secrets, passwords, ID tokens or
   service-account keys; read credentials from environment variables only.
6. Before changing anything, record the baseline of `flutter analyze` and
   `flutter test` (last known: 0 errors, 22 info lints, about 83 tests
   pass, 1 known failing template test test/widget_test.dart). After your
   changes, require NO NEW failures compared with that baseline. Stop and
   report on the first new failure; do not continue past it. If the
   Flutter SDK is locked by another process, say so and ask Khaled to
   close other Flutter processes; do not skip the check silently.
7. End with a short verification report: what was changed/deployed, what
   was tested, PASS/FAIL per check, and what is still pending for Khaled.

CONTEXT
Spark-only Chat, Phase C2 of 3. Read CHAT_FEATURE_PLAN_SPARK.md and
opencode/plans/CHAT_C1_REPORT.md (must say C2 may start: YES, else STOP).
No deploy in this phase.

TASKS
1. Models: Chat, ChatMessage, ChatProfile, Report with tolerant
   fromDocument/toMap (missing fields must not crash).
2. ChatRepository (behind an interface so tests can fake it):
   - openOrCreateChat(guideId, guideName, guideAvatar): tourist only; use the
     D25 canonical id (the caller uid and guideId sorted lexicographically,
     joined with '_'; never tourist-first blindly); if the chat does not
     exist, create it with profiles for both, unreadCount 0 for both. Never
     creates a chat when the caller is a guide.
   - sendMessage: ONE batch writes the message (createdAt =
     FieldValue.serverTimestamp()), updates lastMessage (text truncated to
     120 chars), lastMessageAt, unreadCount.<other> += 1. The first message
     in a new chat goes in the same batch as the chat document.
   - watchChats(uid) (participants array-contains, lastMessageAt desc),
     watchMessages(chatId) with pagination (most recent 30, load more).
   - markRead(chatId): sets lastReadAt.<me> = server time and
     unreadCount.<me> = 0.
   - editMessage / deleteMessage (24 hours, enforced by rules; the UI only
     hides the buttons by time), setTyping (at most every 3 seconds),
     reportMessage (reason code from the fixed list, optional note up to
     500 chars, deterministic id reporterId_messageId).
   - updateMyProfile(chatId): writes only the caller's own profiles entry.
3. ChatListCubit (with total unread = sum from the list), ChatRoomCubit
   (messages, typing, read receipts derived from the other's lastReadAt,
   send/edit/delete/report states, read-only state when the write is
   denied because an account is inactive).
4. Unit tests with a fake repository for: first message creates chat plus
   message, the canonical chat id for both uid orders (tourist-first and
   guide-first produce the same id), a guide cannot create a chat, unread
   increments for the recipient only, markRead resets own count, typing
   throttle, 120-char preview truncation, pagination, error to read-only
   mapping.
No UI. No new packages unless unavoidable (ask first).

REPORT
Write opencode/plans/CHAT_C2_REPORT.md: files changed, numbers vs baseline,
what the tests cover, and "Phase C3 may start: YES/NO". Do not start C3.
```

---

### Phase C3 Prompt: Screens and entry points

**What we do:** the chat UI: a Message button before booking, chat list, chat room, unread badge.

```
GUARD CLAUSE (include at the top of every phase prompt):
1. Modify only the files listed in this prompt. Additive changes only: do
   not rename or delete existing files, collections, rules, indexes. In
   firestore.rules add NEW match blocks only; never edit existing ones.
2. Do not start or configure any emulator. There is no test environment:
   all verification runs against the real project `triply-f9b82`, using
   only the dedicated test accounts named below.
3. The project stays on the Firebase SPARK (free) plan. Never enable
   billing, never create or deploy Cloud Functions, never ask Khaled to
   upgrade. Before ANY deploy: print the active Firebase project id and
   abort unless it is `triply-f9b82`. Deploy only the targets this phase
   lists (--only firestore:rules and/or --only firestore:indexes). Never
   use --force. Save the current rules/indexes to a backup file before
   deploying and state the exact rollback command.
4. Test data: use only the two test accounts Khaled names (one tourist,
   one guide). Never read, modify, or delete data of any other user. The
   Admin SDK is allowed ONLY to delete the test data this phase created,
   and only if credentials are already in the environment; otherwise list
   the documents for Khaled to delete in the Firebase Console. Never use
   the Admin SDK to claim a rule works: it bypasses rules.
5. Never print, log, or commit secrets, passwords, ID tokens or
   service-account keys; read credentials from environment variables only.
6. Before changing anything, record the baseline of `flutter analyze` and
   `flutter test` (last known: 0 errors, 22 info lints, about 83 tests
   pass, 1 known failing template test test/widget_test.dart). After your
   changes, require NO NEW failures compared with that baseline. Stop and
   report on the first new failure; do not continue past it. If the
   Flutter SDK is locked by another process, say so and ask Khaled to
   close other Flutter processes; do not skip the check silently.
7. End with a short verification report: what was changed/deployed, what
   was tested, PASS/FAIL per check, and what is still pending for Khaled.

CONTEXT
Spark-only Chat, Phase C3 of 3. Read CHAT_FEATURE_PLAN_SPARK.md and
opencode/plans/CHAT_C2_REPORT.md (must say C3 may start: YES, else STOP).
No deploy in this phase. Follow the app's existing design, theme, state
management and navigation (see CHAT_C1_REPORT.md section on them).

TASKS
1. A "Message" button on the guide profile screen and on the public trip
   details screen, visible to tourists only, no booking required. It opens
   the chat room (creating the chat on the first sent message, not on tap,
   so empty chats are not created).
2. Chat list screen for both roles (name and avatar of the other person,
   last message preview, time, unread count), reachable from the main
   navigation of each role, plus the total unread badge (sum from the
   list). A guide sees only chats that tourists started and has no way to
   start one.
3. Chat room screen: text messages, instant updates, typing indicator,
   read receipts (seen), "edited" label, long-press menu: edit and delete
   (own message, within 24 hours only), report (other person's message:
   reason list spam / harassment / inappropriate content / other plus an
   optional note). Read-only banner when an account is inactive.
4. On opening a room call markRead; on each login or app start call
   updateMyProfile for the chats the user opens (so names stay current).
5. Widget tests for the main states (empty list, list with unread, room
   with messages, read-only banner). No UI redesign outside chat.

VERIFY
Automated: analyze and test, no new failures vs baseline.
MANUAL (Khaled, two test accounts, two devices or emulators): (a) tourist
opens a guide and sends a message before any booking; (b) the guide sees
the chat in the list with unread 1 and replies; (c) the tourist sees the
reply, seen marks, typing indicator; (d) edit and delete a message; (e)
report a message; (f) a guide has no button that starts a chat.

REPORT
Write opencode/plans/CHAT_C3_REPORT.md: files changed, numbers vs baseline,
manual checklist (pending Khaled), rollback (restore changed files from
git or from a backup folder opencode/backups/C3/ created before editing).
```

---

## 5. Accepted limits (Spark, test-only)

| # | Limit |
|---|---|
| L1 | A tourist can open a chat with any active guide; rules cannot rate-limit spam. |
| L2 | `lastMessage` and `unreadCount` are written by clients; a modified app could write a wrong preview or count, which only affects the chat list, never message contents. |
| L3 | Without push, a user sees new messages only when the app is open; the unread badge shows them on the next open. |
| L4 | Each message write costs a few extra reads in rules (`get` on users, `getAfter` on the chat). Fine for the free quota in a demo. |
| L5 | A modified app could set a wrong display name in its own `profiles` entry, same as it can in `users`. |

## 6. Out of scope

Push notifications, a server, Block, group chats, attachments, retention or cleanup of old messages, admin UI for reports.
