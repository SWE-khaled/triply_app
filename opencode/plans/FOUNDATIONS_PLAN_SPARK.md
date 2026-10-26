# Triply Foundations Plan: SPARK-ONLY version (replaces `FOUNDATIONS_PLAN.md`)

**Status:** proposal, based on Khaled's decisions: no Blaze plan, no Google Play release, Paymob payments are TEST/sandbox only (no real money). Review before running anything.
**Project:** `triply-f9b82` (Firebase **Spark** plan, no Cloud Functions). **Base facts:** `TRIPLY_FULL_APP_TECHNICAL_AUDIT.md`.
**Purpose:** give Chat what it needs from bookings and profiles (real `startAt`/`endAt`, booking states, `displayName`/`avatarUrl`) without a server.

---

## 0. طريقة الاستخدام (بالعربي)

1. **الملف ده بيحل محل `FOUNDATIONS_PLAN.md`.** مفيش Blaze ولا Cloud Functions ولا webhook ولا secrets.
2. **مفيش خطوات يدوية للدفع تتعمل غير اتنين:** تتأكد في لوحة Paymob إن الوضع **test** (M5)، وتعمل الدفع التجريبي بإيدك (M6) لما OpenCode يطلبه.
3. **حط الملفات** في `.opencode/plans/` وشغّل الـ phases بالترتيب `S0` ثم `S1` ثم `S2` ثم `S3` ثم `S4`، كل واحدة في **session جديدة**، وانسخ **اللي جوه الـ code block بس**.
4. **ماتروحش للـ phase اللي بعدها** إلا لما التقرير يبقى **كله PASS** ومكتوب إن الـ test data اتمسحت.
5. **لو مفاتيح Paymob طلعت live:** وقّف وماتدفعش. استنى مفاتيح sandbox.
6. **الأسرار:** ماتبعتش أي key في أي شات.
7. **اكتب في الـ README:** "Payments are Paymob TEST mode only. Booking confirmation happens in the app, not on a server."

---

## 1. Decisions

| # | Decision |
|---|---|
| S-D1 | Stay on Spark. No Cloud Functions, no scheduler, no webhook. All Foundations phases F1-F3 are dropped. |
| S-D2 | Paymob stays initialised from the app with sandbox keys. The key is not rotated because it is a test key and the app is not published. If it turns out to be live: stop (old D51). |
| S-D3 | The app confirms payment when the Paymob WebView reports success. This is NOT secure for real money and is acceptable only for this test-mode demo. |
| S-D4 | Booking states: `pending` -> `confirmed` -> `completed` (display-derived) and `cancelled`. Unpaid `pending` bookings expire after 30 minutes, applied lazily when My Trips loads. |
| S-D5 | Seats are reserved and released inside Firestore transactions from the client, bounded by rules. |
| S-D6 | No automatic refunds: cancelling a paid booking sets `refundStatus: 'owed'`; the admin handles it manually. |
| S-D7 | Kept unchanged from before: D22 (`displayName`/`avatarUrl`), D29/D47 (trips need `startAt`/`endAt`), D46 (real private date/time/hours), D48 (Cloudinary avatars), D34 (ignore 3 legacy bookings). |

## 2. What changes in the Chat plan

`CHAT_FEATURE_PLAN.md` must be adjusted before running it: FC1 (Blaze, Functions) and FC2 (server-written `status`/`paymentStatus`) no longer hold; phase C3 (FCM push, a Function) is dropped or replaced with in-app unread badges; D24 (Functions runtime) is replaced by Firestore rules only. This plan does not edit that file.

## 3. Manual steps for Khaled

| ID | Step | When |
|---|---|---|
| M5 | Confirm in the Paymob dashboard that the keys and integration IDs are **test mode**. | before any payment test |
| M6 | Make the test payments (card and wallet, test mode) when S1 and S4 ask for them. | S1, S4 |

(M1-M4 and M7 from the old plan are removed.)

## 4. Phases

| Phase | What we do | Deploy target |
|---|---|---|
| **S0** | Read-only preflight and compatibility inventory. | none |
| **S1** | Flutter: booking and payment flow, private booking form, real cancel. | none (app code) |
| **S2** | Flutter: trip form dates, profile fields, `displayName` backfill. | none (app code; one backfill) |
| **S3** | Rules hardening without a server. | `firestore:rules` |
| **S4** | End-to-end verification and wrap-up. | none |

Order is fixed: S3 only after S1 and S2 are tested, because it narrows what the client may write.

---

### Phase S0 Prompt: Preflight (read-only)

**What we do:** collect facts. Nothing is changed or deployed.

```
GUARD CLAUSE (include at the top of every phase prompt):
1. Modify only the files listed in this prompt. Additive changes only:
   do not rename or delete existing files, collections, rules, indexes.
2. Do not start or configure any emulator. There is no test environment:
   all verification runs against the real project, using only the dedicated
   test accounts described below.
3. The project stays on the Firebase SPARK (free) plan. Never enable
   billing, never create or deploy Cloud Functions, never ask Khaled to
   upgrade. Before ANY deploy: print the active Firebase project id and
   abort unless it is `triply-f9b82`. Deploy only the targets this phase
   lists (--only firestore:rules or --only firestore:indexes). Never use
   force flags. Save a copy of the current rules/indexes before deploying
   and state how to roll back.
4. Test data: every test account and document is flagged `isTest: true`.
   After verification, delete ALL test data and confirm deletion. Never
   read, modify, or delete non-test data.
5. Never print, log, or commit secrets or service-account keys; read
   credentials from environment variables only.
6. Before changing anything, record the baseline of `flutter analyze` and
   `flutter test` (known baseline: 0 errors, 22 info lints, 50 tests pass,
   1 known failing template test test/widget_test.dart). After your
   changes, require NO NEW failures compared with that baseline. Stop and
   report on the first new failure; do not continue past it.
7. End with a short verification report: what was changed/deployed, what
   was tested, pass/fail per check, and confirmation that test data is gone.

CONTEXT
Spark-only Foundations, Phase S0 of 5. Read-only. Base facts:
.opencode/plans/TRIPLY_FULL_APP_TECHNICAL_AUDIT.md.

TASKS (report only, change nothing)
1. Platform: print the active Firebase project id; confirm the plan is Spark
   (read-only check; do not touch billing). Confirm no `functions/` folder
   or Cloud Functions are needed by the app.
2. Paymob (no calls to Paymob): list the NAMES (not values) of the PAYMOB_*
   variables the app reads, and where. Do not infer test/live from the key
   text. Khaled has stated the keys are Paymob sandbox/test keys; record
   that as "stated by Khaled, not verified by code".
3. Baselines: `flutter analyze` and `flutter test` numbers.
4. Compatibility inventory: every place the app reads or writes `bookings`
   (fields, status and paymentStatus literals, seat changes on
   `trips.bookedSeats`, price formula for public and private trips),
   `trips.startAt/endAt`, `users.displayName/avatarUrl`. File and line.
5. Current Firestore rules for `bookings`, `trips`, `users`, copied into
   .opencode/plans/FOUNDATIONS_S0_REPORT.md.

REPORT
Write .opencode/plans/FOUNDATIONS_S0_REPORT.md with the above, the price
formulas written out, and one line "Phase S1 may start: YES/NO".
Do not proceed to any other phase.
```

---

### Phase S1 Prompt: Booking and payment flow (Flutter, test payments)

**What we do:** make the booking data complete and the payment flow consistent, with Paymob test keys from the app and no server. Includes one small additive rules patch (task 0), because the current rules would block seat release and cancelling a paid booking.

```
GUARD CLAUSE (include at the top of every phase prompt):
1. Modify only the files listed in this prompt. Additive changes only:
   do not rename or delete existing files, collections, rules, indexes.
2. Do not start or configure any emulator. There is no test environment:
   all verification runs against the real project, using only the dedicated
   test accounts described below.
3. The project stays on the Firebase SPARK (free) plan. Never enable
   billing, never create or deploy Cloud Functions, never ask Khaled to
   upgrade. Before ANY deploy: print the active Firebase project id and
   abort unless it is `triply-f9b82`. Deploy only the targets this phase
   lists (--only firestore:rules or --only firestore:indexes). Never use
   force flags. Save a copy of the current rules/indexes before deploying
   and state how to roll back.
4. Test data: every test account and document is flagged `isTest: true`.
   After verification, delete ALL test data and confirm deletion. Never
   read, modify, or delete non-test data.
5. Never print, log, or commit secrets or service-account keys; read
   credentials from environment variables only.
6. Before changing anything, record the baseline of `flutter analyze` and
   `flutter test` (known baseline: 0 errors, 22 info lints, 50 tests pass,
   1 known failing template test test/widget_test.dart). After your
   changes, require NO NEW failures compared with that baseline. Stop and
   report on the first new failure; do not continue past it.
7. End with a short verification report: what was changed/deployed, what
   was tested, pass/fail per check, and confirmation that test data is gone.

CONTEXT
Spark-only Foundations, Phase S1 of 5. Read FOUNDATIONS_S0_REPORT.md first
(it is in `opencode/plans/` in this repo, no leading dot; if it is missing
or says NO, STOP). Facts from that report that shape this phase: new
bookings are currently written with `paymentStatus: 'paid'` BEFORE any
payment; the current `trips` rule only lets `bookedSeats` GROW; the current
`bookings` rule lets a tourist update or delete only while
`paymentStatus == 'pending'`. Payments are Paymob TEST/sandbox
only. There is no server: the app decides, so keep every write small and
explicit.

TASKS
0. Rules patch (additive, deploy with --only firestore:rules, save the old
   file first): (a) in the `trips` seat-counter rule allow `bookedSeats` to
   also DECREASE, never below 0 and never above `capacity` (needed to
   release seats on cancel/expiry); (b) in the `bookings` rule let the
   owning tourist update their own booking to `status: 'cancelled'` (with
   the cancel fields) even when `paymentStatus == 'paid'` (needed to
   cancel a paid booking). Change nothing else; S3 tightens the rest.
   Before coding, find every place where the guide or admin screens read or
   write booking `status` (e.g. accept/reject, confirmed) and list them in
   the report, so the new `confirmed` meaning does not break them.
1. Create the booking as `status: 'pending'`, `paymentStatus: 'pending'`
   with new fields: `startAt`, `endAt`, `expiresAt` (= now + 30 min),
   `paymentMethod` ('card'|'wallet'), `refundStatus: 'none'`, `createdAt`.
   Keep all existing denormalised fields with the same meaning.
2. Seats (public trips): reserve seats in ONE Firestore transaction together
   with creating the booking; abort if seats are not available. Release
   them in one transaction on cancel or expiry.
3. Pay through the existing Paymob WebView with the test keys. Only when the
   WebView reports success: set `status: 'confirmed'`, `paymentStatus:
   'paid'`, `paymentId` (the transaction id Paymob returns). On failure or
   close: leave `pending`.
4. Private booking: replace mock duration/date text with a date picker, a
   time picker and an hours selector; compute `startAt` and `endAt` from
   them.
5. Lazy expiry (no scheduler): when My Trips loads, any of the user's own
   bookings still `pending` after `expiresAt` is cancelled and its seats
   released. Display a `confirmed` booking whose `endAt` has passed as
   Completed (display only, no write).
6. Cancel: sets `status: 'cancelled'`, `cancelledAt`, `cancelledBy:
   'tourist'`, `refundStatus: 'owed'` if `paymentStatus == 'paid'` else
   `'none'`, and releases seats. Remove any false refund claim: the message
   is "booking cancelled; the team will handle the refund (test payment)".
7. Add unit tests for the service and cubit transitions (pending,
   confirmed, failed, cancelled, expired). No UI redesign.

VERIFY
Automated: analyze/test with no new failures vs baseline.
MANUAL (Khaled, Paymob TEST mode, test accounts): (a) public booking paid by
card; (b) public booking paid by wallet (test number); (c) private booking
with date, time and hours; (d) cancel a paid booking; (e) close the payment
WebView without paying and confirm it expires after 30 minutes when My
Trips is opened. Afterwards read the results (read-only) and delete the
test data the run created.

REPORT
Files changed, tests added, numbers vs baseline, the manual checklist with
results, rollback (revert changed files), confirmation test data is gone.
```

---

### Phase S2 Prompt: Trip form dates, profile fields, displayName backfill

**What we do:** make trips bookable (`startAt`/`endAt` required) and add the profile fields chat needs.

```
GUARD CLAUSE (include at the top of every phase prompt):
1. Modify only the files listed in this prompt. Additive changes only:
   do not rename or delete existing files, collections, rules, indexes.
2. Do not start or configure any emulator. There is no test environment:
   all verification runs against the real project, using only the dedicated
   test accounts described below.
3. The project stays on the Firebase SPARK (free) plan. Never enable
   billing, never create or deploy Cloud Functions, never ask Khaled to
   upgrade. Before ANY deploy: print the active Firebase project id and
   abort unless it is `triply-f9b82`. Deploy only the targets this phase
   lists (--only firestore:rules or --only firestore:indexes). Never use
   force flags. Save a copy of the current rules/indexes before deploying
   and state how to roll back.
4. Test data: every test account and document is flagged `isTest: true`.
   After verification, delete ALL test data and confirm deletion. Never
   read, modify, or delete non-test data.
5. Never print, log, or commit secrets or service-account keys; read
   credentials from environment variables only.
6. Before changing anything, record the baseline of `flutter analyze` and
   `flutter test` (known baseline: 0 errors, 22 info lints, 50 tests pass,
   1 known failing template test test/widget_test.dart). After your
   changes, require NO NEW failures compared with that baseline. Stop and
   report on the first new failure; do not continue past it.
7. End with a short verification report: what was changed/deployed, what
   was tested, pass/fail per check, and confirmation that test data is gone.

CONTEXT
Spark-only Foundations, Phase S2 of 5. S1 report must show all PASS, else STOP.

TASKS
1. Trip create/edit forms (guide and admin) require start and end date and
   time and save `startAt`/`endAt` on the trip. A trip without them cannot be
   booked (the booking button explains why).
2. Both profile edit sheets (tourist and guide) save `users.displayName` and
   `users.avatarUrl` (avatars stay on Cloudinary; write the returned URL).
3. A one-off backfill of `users.displayName` for existing users from their
   existing name fields (fullName/name), run once with the Admin SDK
   against real data only after printing how many documents it would touch
   and getting Khaled's yes. Ignore the 3 legacy bookings.
4. The app currently reads names from Firebase Auth `displayName`, and
   registration writes `avatarUrl: ''`. Make registration and both profile
   edit sheets also write the Firestore `users.displayName` and
   `users.avatarUrl`, so new users are correct without a backfill.
5. Unit tests for the changed forms/services. No UI redesign.

REPORT
Files changed, numbers vs baseline, backfill count, rollback, test data gone.
```

---

### Phase S3 Prompt: Rules hardening (no server)

**What we do:** tighten Firestore rules as far as possible without a server. This is the only phase that edits existing rules.

```
GUARD CLAUSE (include at the top of every phase prompt):
1. Modify only the files listed in this prompt. Additive changes only:
   do not rename or delete existing files, collections, rules, indexes.
2. Do not start or configure any emulator. There is no test environment:
   all verification runs against the real project, using only the dedicated
   test accounts described below.
3. The project stays on the Firebase SPARK (free) plan. Never enable
   billing, never create or deploy Cloud Functions, never ask Khaled to
   upgrade. Before ANY deploy: print the active Firebase project id and
   abort unless it is `triply-f9b82`. Deploy only the targets this phase
   lists (--only firestore:rules or --only firestore:indexes). Never use
   force flags. Save a copy of the current rules/indexes before deploying
   and state how to roll back.
4. Test data: every test account and document is flagged `isTest: true`.
   After verification, delete ALL test data and confirm deletion. Never
   read, modify, or delete non-test data.
5. Never print, log, or commit secrets or service-account keys; read
   credentials from environment variables only.
6. Before changing anything, record the baseline of `flutter analyze` and
   `flutter test` (known baseline: 0 errors, 22 info lints, 50 tests pass,
   1 known failing template test test/widget_test.dart). After your
   changes, require NO NEW failures compared with that baseline. Stop and
   report on the first new failure; do not continue past it.
7. End with a short verification report: what was changed/deployed, what
   was tested, pass/fail per check, and confirmation that test data is gone.

CONTEXT
Spark-only Foundations, Phase S3 of 5. S1 and S2 reports must be all PASS
and the app already works with the new flow, else STOP. Save the current
rules to .opencode/plans/rules.before-S3.rules first.

TASKS (edit firestore.rules; deploy with --only firestore:rules)
1. bookings create: only a signed-in tourist with `touristId == auth.uid`,
   and only with `status == 'pending'` and `paymentStatus == 'pending'`
   (a tourist cannot create an already-paid booking).
2. bookings update by the owning tourist: allowed only to (a) confirm
   payment `pending -> confirmed/paid` with `paymentId` present, (b) cancel
   (`-> cancelled` with cancel fields), nothing else. Use
   `request.resource.data.diff(resource.data).affectedKeys().hasOnly([...])`.
   Price, seat and user fields cannot change. Guide cannot change payment
   fields. The admin branch is unchanged.
3. trips: the branch that lets any signed-in user write `bookedSeats` is
   replaced by: a signed-in user may change ONLY `bookedSeats`, by at most
   the booking's seat count, never below 0 and never above the trip's
   capacity.
4. Nothing else changes. State plainly in the report what is NOT enforced
   without a server (a user could still fake a `paid` status with a
   fabricated `paymentId`); this is accepted because payments are test-only.

VERIFY
Using the Admin SDK and test accounts, prove allowed paths still work and
each denied path is denied (a tourist cannot write another user's booking,
cannot change price, cannot create a `paid` booking). Delete test data.

REPORT
Table of allowed/denied checks with PASS/FAIL, rollback = redeploy the saved
rules file, test data gone.
```

---

### Phase S4 Prompt: End-to-end verification and wrap-up

**What we do:** prove the whole flow works and tell the Chat plan what is true now.

```
GUARD CLAUSE (include at the top of every phase prompt):
1. Modify only the files listed in this prompt. Additive changes only:
   do not rename or delete existing files, collections, rules, indexes.
2. Do not start or configure any emulator. There is no test environment:
   all verification runs against the real project, using only the dedicated
   test accounts described below.
3. The project stays on the Firebase SPARK (free) plan. Never enable
   billing, never create or deploy Cloud Functions, never ask Khaled to
   upgrade. Before ANY deploy: print the active Firebase project id and
   abort unless it is `triply-f9b82`. Deploy only the targets this phase
   lists (--only firestore:rules or --only firestore:indexes). Never use
   force flags. Save a copy of the current rules/indexes before deploying
   and state how to roll back.
4. Test data: every test account and document is flagged `isTest: true`.
   After verification, delete ALL test data and confirm deletion. Never
   read, modify, or delete non-test data.
5. Never print, log, or commit secrets or service-account keys; read
   credentials from environment variables only.
6. Before changing anything, record the baseline of `flutter analyze` and
   `flutter test` (known baseline: 0 errors, 22 info lints, 50 tests pass,
   1 known failing template test test/widget_test.dart). After your
   changes, require NO NEW failures compared with that baseline. Stop and
   report on the first new failure; do not continue past it.
7. End with a short verification report: what was changed/deployed, what
   was tested, pass/fail per check, and confirmation that test data is gone.

CONTEXT
Spark-only Foundations, Phase S4 of 5. S1-S3 reports must be all PASS.

TASKS
1. Khaled runs one full flow with test accounts in Paymob test mode:
   tourist books and pays a public trip (card), then a private trip
   (wallet), the guide sees the confirmed bookings, the tourist cancels one.
   OpenCode reads the results (read-only) and checks fields and seat counts.
2. Write .opencode/plans/FOUNDATIONS_DONE.md listing what Chat can rely on
   (bookings with startAt/endAt/status, users.displayName/avatarUrl) and
   what it cannot (no server: no scheduled completion, no push, payments
   test-only).
3. Delete all test data and confirm.

REPORT
Table of checks PASS/FAIL, and one line "Chat Phase C1 may start: YES/NO".
```

---

## 5. Out of scope

- A trusted payment server, refunds screen, push notifications, scheduled jobs.
- Chat itself and its Flutter client.
- Other audit findings that do not block chat or bookings.

## 6. Review items before running (please confirm)

| # | Item |
|---|---|
| R1 | Anyone with a modified app could write `paid` themselves; S3 limits but cannot prevent this. Accepted for test-only payments. |
| R2 | `completed` is derived in the UI, not written, so any Chat rule that needs `status == 'completed'` must use `endAt` instead. |
| R3 | Lazy expiry only runs when that tourist opens My Trips, so a seat can stay reserved until then. |
| R5 | `users` can only be read by the owner or admin (rules), so Chat will need a way to show the other person's name and avatar (for example copying `displayName`/`avatarUrl` into the chat document). Decide this in the Chat plan. |
| R4 | The 4 existing trips have no `endAt` and cannot be booked until edited (D47). |
