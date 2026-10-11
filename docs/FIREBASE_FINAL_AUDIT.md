# Triply Firebase — Final Independent Audit (2026-10-09, branch `Back-end`)

> Scope: verify the "all eight phases complete" implementation report against
> the actual source. Read-only audit except ONE safe additive fix (§8).
> Nothing deployed, no cloud data touched, no credentials exposed.
> Verdict: **solid foundation, NOT production-ready** — 3 High + 7 Medium
> findings must be remediated and emulator-tested before any deploy.
> Firebase project: `triply-f9b82`. Rules/indexes/Functions exist as files only.

## 0. Method + test evidence

| Check (exact command, `D:\applications flutter\triply`) | Outcome |
|---|---|
| `flutter analyze` | 38 infos, **0 errors**. All 38 pre-existing (`my_bookings_public` private-type ×3, `tour_guide_auth_service` null-aware ×4, `use_build_context_synchronously` ×11, `paymob_service` prints ×15, misc ×5). New code adds zero. |
| `flutter test test/firestore_converters_test.dart test/booking_pricing_test.dart test/firestore_models_test.dart` | **32/32 pass** (converters 9, pricing 8, models 15). |
| `flutter test test/widget_test.dart` (alone) | **Fails independently** — pre-existing dead counter template: `FirebaseException [core/no-app]` at `lib/main.dart:41` (`AuthProvider` → `AuthRepository` → `FirebaseAuth.instance` with no `Firebase.initializeApp()` in test), then `Expected: exactly one matching candidate / Found 0 widgets with text "0"` (`test/widget_test.dart:19`). Unrelated to this work; left untouched. |
| `dart run tool/export_seed_json.dart` | OK: 158 places, 3 trips → `tool/seed_data/`. |
| `node tool/seed_firestore.js --dry-run` | OK: plan printed, zero writes, 3 orphan trips skipped. |
| `node tool/seed_firestore.js --commit --project triply-f9b82` (no target) | Refused as designed (`No Firestore target…`). |
| `node --check functions/index.js` + load test | Pass (`functions load OK`, local `npm install`; engines Node 20 vs local Node 24 warning only). |
| `firestore.indexes.json` JSON validity | Valid (re-checked after §8 fix). |
| Emulator / rules-unit / Functions-integration tests | **NOT run** (no emulator started during audit) — nothing in this repo claims otherwise. |

## 1. Firestore Security (`firestore.rules`, 227 lines)

### HIGH H1 — `trips allow list` leaks ALL trips to ANY signed-in user
- `firestore.rules:96`: `allow list: if isSignedIn();`
- The comment on lines 93–95 claims per-doc `get` "additionally restricts"
  list results — **false**: list queries are authorized by the `list` rule only.
- Exploit: register a free tourist account → `collection('trips').get()` (or REST)
  → dump every `pending`/`rejected`/`cancelled` trip incl. `guideId`, price,
  `meetingPoint`, `rejectionReason`. Competitor/moderation-bypass harvesting.
- Fix (behavior-changing, NOT applied): scope list reads — e.g. deny broad list
  and serve tourist feed/guide lists/admin queue via callables or per-query
  constrained rules + client filters; at minimum correct the comment and add an
  emulator rules test proving pending trips are invisible to non-owners.

### HIGH H2 — `bookings allow list` leaks ALL bookings (PII) to ANY signed-in user
- `firestore.rules:120`: `allow list: if isSignedIn() && (isAdmin() || true);`
  (`|| true` makes the admin check dead code.)
- Exploit: any authed user lists `bookings` → tourist names/phones (via linked
  `touristId`), `totalAmount`, `meetingPoint`, `specialRequests`/notes,
  trip dates. Same class as H1.
- Fix (NOT applied): restrict list to owner-scoped queries served by Functions,
  or store a `participants[]` array and gate with
  `request.auth.uid in resource.data.participants` per doc via get-only + narrow
  list; add emulator test with two tourists asserting mutual invisibility.

### HIGH H3 — `notifications allow list` leaks ALL users' notifications
- `firestore.rules:189`: `allow list: if isSignedIn();` while `get` (line 188)
  is recipient-only. Exploit: list `notifications` → read everyone's booking/
  verification/payment messages. Same fix pattern as H1/H2 (NOT applied).

### HIGH H4 — Paid-booking cancel path has no refund handling (money dispute)
- Rules `firestore.rules:127-135` let an owner tourist flip ANY active booking
  (incl. `paymentStatus: succeeded`) to `cancelled`; `onBookingStatusChanged`
  (`functions/index.js:278-286`) releases capacity unconditionally.
- There is deliberately no refund flow ("Do not invent a refund policy"), so a
  paid cancel ends as: tourist charged, booking cancelled, seats resold, payment
  still `succeeded`. Worse, `verifyPaymobTransaction` (index.js:422-431) later
  forces such a booking back to `confirmed` WITHOUT re-incrementing capacity
  (see F6b) → double-booked seats.
- Fix (NOT applied): block client cancel when `paymentStatus == succeeded`
  (route paid cancels through a Function that applies the decided refund policy);
  add `paid→cancelled→re-verify` state-transition test.

### MEDIUM M1 — Legacy verification gate is client-writable (banner bypass)
- `TourGuideAuthService.isVerificationApproved`
  (`lib/features/common/AuthTourguide/data/tour_guide_auth_service.dart:226-236`)
  reads `users/{uid}.verification.reviewStatus`, but the users update rule
  (`firestore.rules:46-50`) pins only `role`/`isActive` — an owner can write
  `verification: {reviewStatus: 'approved'}` (and `isApproved: true`, also unpinned)
  on their own doc → dashboard banner (`dashboard_cubit.dart:42-50`) hides.
- Contained: canonical `guideProfiles.isVerified/canPublishTrips` stay false,
  and trip creation does not check verification (M3), while tourist visibility
  still requires admin approval — so no end-run to publication. Fix (NOT
  applied): gate the banner on `guideProfiles`/`guideVerifications` doc instead
  of the legacy map; pin or drop the legacy `verification`/`isApproved` fields
  in the users update rule.

### MEDIUM M2 — `guideProfiles` create is unsatisfiable via the app's own writer
- Rule `firestore.rules:58-64` requires `request.resource.data.isVerified == false`
  (etc.) on create, but `GuideProfileDoc.toClientMap()` omits those keys and the
  datasource uses merge-write — absent `== false` fails → the registration
  dual-write (`tour_guide_auth_service.dart:104-115`) is DENIED on first create.
  Swallowed by try/catch (silent). Updates on field-less docs compare null==null
  and pass, so only creation breaks.
- Fix (NOT applied): use `.get('isVerified', false)`-style defaults in the rule
  or include explicit `false`/`0` in the client create payload; add emulator test
  for first-time guide registration.

### MEDIUM M3 — Trip creation enforces no guide eligibility or field validity
- `firestore.rules:97-99` + `functions/index.js:246-268` (`onTripCreated`
  normalizes status/titleLower/bookedSeats only): any signed-in user (even
  unverified, even `role: tourist`) can create trips with empty titles, negative
  prices, or `capacity: 0`; `canPublishTrips` is never consulted.
- Consequence is queue spam for admins (tourists still only see approved trips),
  but combined with M1 the "unverified guides can't publish" product rule is
  unenforced. Fix (NOT applied): require `role == guide` + verified profile
  (read via `get()` in rules or check in a create-trip callable) and validate
  title/price/capacity ranges.

### MEDIUM M4 — Owner can edit price/capacity of approved trips with live bookings
- `trips update` (`firestore.rules:101-107`) + `updateClientFields`
  (`trips_datasource.dart:118-131`) strip only identity/status/counters; price,
  capacity, dates stay editable post-approval with no re-pend and no
  `capacity >= bookedSeats` guard → price bait-and-switch for future bookers,
  stranded over-capacity bookings.
- Fix (NOT applied): re-pend edited trips (`approvalStatus → pending`) or lock
  price/capacity once `bookedSeats > 0`; document the chosen product rule.

### MEDIUM M5 — Stories expiry is broken end-to-end (type mismatch + phantom normalizer)
- `StoryDoc.toCreateMap` writes `expiresAt` as ISO **string**
  (`lib/data/firestore/models/story_doc.dart:62-69`), while
  `StoriesDatasource.listActive/listByUser`
  (`stories_datasource.dart:24-43`) and `cleanupExpiredStories`
  (`functions/index.js:477-484`) compare against `Timestamp`. Firestore type
  order (string > timestamp) makes `string > now` ALWAYS true and `< now` NEVER
  true → expired stories stay visible forever; scheduled cleanup deletes nothing
  client-created; the "Function normalizes it" comment (`story_doc.dart:59-61`)
  describes a Function that does not exist.
- Fix (NOT applied — wire-format/behavior change): write `expiresAt` as
  `Timestamp` (client-computed `createdAt+24h` is acceptable; server normalizes
  on create if a trigger is added); add a unit test asserting `toCreateMap`
  expiry type (this exact test is missing and would have caught the bug).

### MEDIUM M6 — `verifyPaymobTransaction` never matches amounts + resurrects cancelled bookings
- `functions/index.js:414`: success = order paid-in-full OR captured OR
  `payment_status == 'paid'` — but the order's `amount_cents` is never compared
  to the booking's `totalAmount`, and `currency` is never checked.
  Exploit: pay a small/old order, reference its id from a `pending` payment on
  an expensive booking (payment create binds `bookingId` client-side with no
  ownership/amount check — see M7) → booking confirmed without full payment.
- `index.js:422-431`: on success forces `status: 'confirmed'` regardless of
  current status → cancelled bookings resurrect WITHOUT re-incrementing
  `bookedSeats` (capacity was released at cancel) → silent overbooking.
- Also unvalidated against live Paymob shapes (documented assumption).
- Fix (NOT applied): compare `order.amount_cents == round(total*100)` (+currency),
  reject unless current status is `pending` (or re-reserve capacity in-tx);
  sandbox-test the response-shape assumption before real money.

### MEDIUM M7 — Payment docs bindable to other users' bookings, amounts unchecked
- `firestore.rules:146-149`: any authed user can create a `pending` `paymob`
  payment with ANY `bookingId` and ANY `amount` (no booking-ownership or
  amount-vs-booking check) → fake/confusing pending payments attachable to
  victims' bookings (no money moves, but admin/UX confusion + enables M6's
  amount-confusion path).
- Fix (NOT applied): create payments via Function (preferred) or require
  `bookingId`'s `touristId == request.auth.uid` + `amount == booking.totalAmount`
  via `get()` in rules.

### LOW L1 — `posts` update pins `likesCount` but not `commentsCount`
- `firestore.rules:160-163`: owner can inflate `commentsCount` (cosmetic).
  Fix: pin it like `likesCount`, or drop the field.

### LOW L2 — Reviews writable without ever booking the trip
- `firestore.rules:203-206`: any signed-in user can review any trip (no
  completed-booking check), change `guideId`, and the doc-id convention
  (`tripId_touristId`, `review_doc.dart:34-35`) is unenforced → duplicate/
  cross-trip reviews possible; aggregates (`index.js:454-473`) ingest them.
  Roadmap-only collection; fix when review UI ships.

### LOW L3 — Verification/guideVerification spam + no re-submit path
- `guideVerifications` create (`firestore.rules:74-76`) accepts any doc id with
  `guideId == self` → unlimited pending docs per user (quota noise); meanwhile
  update is `false`, and the app's own resubmit path uses merge-set
  (`tour_guide_auth_service.dart:174-185`) → resubmission after rejection is
  DENIED (silently swallowed). Decide one canonical id and allow owner
  pending-resubmit; or route resubmits through a callable.

### LOW L4 — Unbounded free-text writes
- Booking `specialRequests`/`meetingPoint`, post text, trip text fields have no
  length caps in rules or Functions (1 MB doc ceiling is the only bound).
  Add lengths when abuse appears; negligible now.

### LOW L5 — `markAllRead` silently caps at 100
- `notifications_datasource.dart:62-73`: `.limit(100)` batch; users with 100+
  unread keep stale badges. Paginate or document the cap.

### What the rules get RIGHT (verified)
- No `allow read, write: if true` anywhere; least-privilege per collection.
- `users` create blocks `role: admin` (`firestore.rules:40-42`); updates pin
  `role`/`isActive` (46-50); list restricted to admins (37) — note this
  intentionally breaks `getGuidePhoneByName` for non-admins (§3, I3).
- `bookings` create is `false` (124) — Function-only creation, correct.
- `payments` update/delete `false` (151); `notifications` create/delete `false`
  (191); `guideVerifications` update/delete `false` (78) — trusted paths only.
- `likes/{uid}` ownership (`isOwner(uid)`, 168-171); `admins/*` client writes
  `false` (224); `appSettings`/`places` writes admin-only (215, 84).
- `isAdmin()` checks claim OR `admins/` doc (21-26); `exists()` reads don't
  recurse into rules. First-admin bootstrap correctly requires Console (§6 docs
  match implementation).

## 2. Cloud Functions (`functions/index.js`, 511 lines; 10 exports verified)

- AuthN/Z: `requireAuth` on all callables; `requireAdmin` (claim OR admins doc)
  on `decideTripStatus`, `decideVerification`, `provisionAdmin` — correct.
  `verifyPaymobTransaction` correctly restricts to payer-or-admin (389).
- Pricing is server-side in-tx for public (141-180: tx reads trip, checks
  `approved`, checks capacity, computes from DB price) and server-computed for
  private (206-209, from `guideProfiles.pricePerHour`) — matches
  `booking_pricing.dart` math. Client totals never trusted. Good.
- **F1 — idempotency race (HIGH, see H-appendix):** dedupe pre-check (126-130)
  runs OUTSIDE the transaction; two concurrent same-key calls both pass →
  duplicate bookings + double `bookedSeats` decrement. Fix: idempotency-key doc
  id or key-scoped transaction.
- **F2 — dedupe leaks any booking to any key-holder (HIGH):** lines 126-130
  return the existing booking without checking `existing.touristId == caller`;
  keys are predictable (`uid_tripId_date_seats` per client guidance) → PII
  disclosure (meeting point, notes, amounts). Fix: enforce ownership on the
  dedupe path.
- **F3 — private booking to nonexistent guide yields a total-0 booking
  (MEDIUM):** lines 206-207 default missing profile to `pricePerHour 0`; no
  existence/verified check. Fix: `not-found` when profile missing; require
  verified/canPublish.
- **F4 — date robustness (LOW):** invalid `tripDate`/`appointmentAt` strings make
  `Timestamp.fromDate(new Date(NaN))` throw a non-`HttpsError` (INTERNAL to
  client); past dates accepted; public bookings allow null `tripDate`.
  Fix: validate + `invalid-argument`.
- **F5 — notify-after-commit failure mode (LOW, acceptable):** if `notify`
  throws post-commit (184-191, 233-240), the client sees an error though the
  booking exists; retry hits dedupe (modulo F1/F2) and returns it. Documented
  behavior; keep.
- Triggers: `onTripCreated` skips no-op writes (255) and can't loop (no trips
  update-trigger) — safe. `onBookingStatusChanged` releases capacity once per
  transition (278) but is **not retry-safe**: at-least-once redelivery after a
  successful decrement double-releases → capacity drift (MEDIUM; needs
  idempotent marker or transactional guard). Like/review aggregates recompute
  from truth (idempotent, good). `cleanupExpiredStories` batch ≤400 (good) but
  inert against string-`expiresAt` (M5).
- `decideVerification` legacy mirror (351-360) shallow-replaces `users`
  `verification`, wiping legacy doc URLs/submittedAt (canonical copies survive)
  — LOW data-loss nit; merge fields instead.
- `provisionAdmin` cannot bootstrap a first admin by itself (correct — Console
  procedure in `ADMIN_PROVISIONING.md` matches); email enumeration limited to
  admins. OK.
- Secrets: only `process.env.PAYMOB_API_KEY` referenced (392, 405); nothing
  hardcoded — correct. Paymob response-shape assumption (414) is honest but
  unverified (needs sandbox run).

## 3. Application integration (bridges exist, nothing calls them)

- Verified by grep: ZERO call sites in any View/Screen for `loadRemote`,
  `refreshRemote`, `searchRemote`, `submitTripToFirestore`,
  `toggleLikePersistent`, `mark*ReadRemote`, `isAuthorized`/`hasAdminClaim`,
  `BookingsRepository.createPublic/createPrivate/createPendingPayment`, or any
  `*Repository(` constructor outside cubit default params. `AdminAccessService`
  is defined but never used; `AdminAuthCubit` still uses the `triplykl` demo gate
  (deliberate until provisioning completes).
- Consequently every feature still runs 100% on mocks/session stores:
  `MyBookingsPublic` (booking/my-trips/trip-details/profile counter),
  `GuideTripsStore` (dashboard/my-trips/availability/create-edit),
  `TripDetailsSource`/`GuideTripDetailsSource`, `mock*` lists, `d_mock_*` +
  in-memory `AdminSession`. Cross-role sharing is still zero at runtime — the
  data layer is dormant plumbing, exactly as Appendix C discloses.
- **I1 — silent fallback masking (MEDIUM):** every bridge keeps mocks on
  failure/empty with no error surfacing (`trips_cubit.dart:35-42`,
  `community_cubit.dart:138-164`, etc.). Post-launch this shows stale mock
  trips as if live during outages. Fix: emit an error/notice state or a
  "offline showing samples" indicator before Views start calling bridges.
- **I2 — payment verification unwired:** Paymob flow is still client-only
  (`paymob_service.dart` with hardcoded sandbox fallback key); no caller of
  `createPendingPayment`/`verifyPaymobTransaction` exists. Until wired, "paid"
  bookings remain client-asserted — the exact condition the architecture was
  built to end.
- **I3 — latent regression on deploy:** `AuthRepository.getGuidePhoneByName`
  (`auth_repository.dart:60-80`) queries `users where role==guide`, but rules
  restrict `users` list to admins → returns null for all non-admins after deploy.
  Rewrite against `guideProfiles` (public) or a callable before go-live.
- **I4 — dual-write fragility:** guide `guideProfiles` create will be denied
  (M2); verification resubmit denied (L3); both swallowed by try/catch —
  failures are invisible in logs. Add logging/metrics on best-effort writes.
- Auth compat otherwise verified: tourist signup (`role: tourist`, `isActive`,
  `auth_repository.dart:27-42`) and guide register (`role: guide`, no
  `isActive` key → passes the `!in` branch) satisfy the users create rule;
  `updateProfileFields` merge preserves pinned fields; Google sign-in still
  writes no `users` doc (pre-existing gap: `signInGuide` throws for doc-less
  users — unchanged behavior).

## 4. Schema / queries vs rules vs indexes

- Paths/fields in all 14 datasources match `FirestorePaths` and model
  serializers; status vocabularies consistent (`pending|approved|rejected|
  cancelled`, booking 4-states, paymob 4-states, verification 3-states).
- **Missing index (FIXED in this audit, §8):** `TripsDatasource.listPending`
  (`trips_datasource.dart:89-96`) orders `createdAt` ASCENDING, but
  `firestore.indexes.json` only had `(approvalStatus ASC, createdAt DESC)` →
  would have failed at runtime with a missing-index error. Added the ASC
  variant; file re-validated as JSON (now 23 entries).
- **M5 (stories string-vs-Timestamp)** breaks `listActive`/`listByUser`
  semantics and `cleanupExpiredStories` (detailed above).
- Pagination cursors are dropped by `TripsRepository`/`GuideTripsRepository`
  (no `last`/`hasMore` passthrough) and `GuideTripsRepository.myTrips` drops
  `startAfter` — infinite lists cannot paginate yet (LOW; no UI consumes them).
- All other composites verified present: tourist/guide/place/category trip
  queries, tourist/guide/trip/idempotency booking queries
  (`countActiveForTrip`'s `tripId+status whereIn` covered),
  posts feed/author, stories (post-fix type), notifications user+time and
  user+isRead, verifications status+submittedAt, places category+rating and
  `nameLower` range, reviews trip+time, profiles verified+rating.

## 5. Tests — review of the 32 + gaps

- The 32 pass as claimed (re-ran: `flutter test` on the three files → All
  tests passed). Notable strength: `firestore_models_test.dart` asserts
  client payloads exclude privileged fields (trip/user/guide/payment/likes) —
  genuine negative-security coverage at the serializer layer. Pricing tests pin
  both cubits' display math; converter tests pin Timestamp handling.
- **Missing (no new tests, recommended):** (a) story `toCreateMap` expiry-type
  test — would have caught M5; (b) Firestore rules emulator tests, esp.
  H1/H2/H3 list-isolation, M1 legacy-gate pin, M2 first-create; (c) Functions
  tests — F1 race, F2 dedupe-ownership, F6 amount-match + cancelled-resurrect,
  retry-safety of the cancel trigger; (d) repository tests (datasources are
  entirely untested; fallback paths untested); (e) seed idempotency test beyond
  dry-run; (f) index coverage test mapping each datasource query to an index
  entry (would have caught the §4 ASC gap).
- `widget_test.dart` failure reproduced independently (see §0) — pre-existing,
  unrelated, must NOT be "fixed" by deletion; replace with real widget tests
  during hardening.

## 6. Documentation vs source (discrepancies)

- `FIREBASE_IMPLEMENTATION_REPORT.md:32` says "23 composite indexes" — the file
  had **22** at audit time (counted via `collectionGroup` occurrences). Now
  moot: the §8 fix legitimately brings it to 23. Report §1 says "Repositories
  (7)" — **8** repository files exist (trips, places, guides, bookings,
  community, notifications, guideTrips, settings). Minor count errors; the
  substance (file lists, commands, outcomes) verified accurate, including the
  honest "NOT production-ready" §3/§5 and non-deployment statements.
- `FIRESTORE_SCHEMA.md` states notifications are recipient-only and "Created
  ONLY by Functions" — half-true under the rules: `get`/create-match, but
  `list` is any-authed (H3). Schema should note the list-scope gap until fixed.
- `ADMIN_PROVISIONING.md` matches `isAdminUid` logic (claim OR doc) and the
  required Console bootstrap — accurate. Step 4 (replace demo gate) correctly
  marked future; `AdminAuthCubit` still demo — consistent, not a discrepancy.
- `DEPLOYMENT_CHECKLIST.md` — all steps gated, `--project` flags present,
  `.firebaserc` absent (good: no implied linkage), rollback sane. Accurate.
- `TRIPLY_MASTER_DOCUMENTATION.md` Appendix C accurately discloses dormant
  bridges, hardcoded secrets pending rotation, and undeployed status; the
  NestJS §§17–19 supersession note is correct per the confirmed decision.
  The hardcoded Paymob fallback (`paymob_service.dart:20-23`) and unsigned
  Cloudinary preset (`cloudinary_service.dart:9-13`) remain in source as
  documented — rotation still outstanding (carried risk, restated in §7).

## 7. Prioritized remediation plan (nothing below applied except §8 item)

1. **P0 — close list-scope leaks (H1/H2/H3):** constrain `trips`/`bookings`/
   `notifications` list rules; add emulator tests (two-user invisibility,
   pending-trip invisibility). Re-audit after change.
2. **P0 — Function money bugs (F1/F2/F6 + H4):** transactional idempotency,
   dedupe ownership check, amount+currency match on verify, status-gated
   transitions, paid-cancel policy decision (product input required — refund
   behavior is the open business question; do not invent it).
3. **P1 — stories expiry type (M5)** + cleanup backfill for string docs;
   legacy verification gate migration (M1); `guideProfiles` create rule (M2);
   trip create/update eligibility + re-pend rule (M3/M4); missing-resubmit (L3).
4. **P1 — integration wiring:** call bridges from Views behind a feature flag
   with visible offline/error states (fixes I1); wire payment verify flow (I2);
   migrate `getGuidePhoneByName` off `users` list (I3); log best-effort write
   failures (I4).
5. **P2 — hardening:** emulator suite (rules + functions + seed on emulator +
   index-exercising queries), repository/datasource unit tests, replace dead
   `widget_test`, rotate hardcoded Paymob/Cloudinary secrets, server-signed
   uploads, unbounded-text caps, `markAllRead` pagination, review-flow rules
   when UI ships.
6. **Deploy only after 1–4 + `DEPLOYMENT_CHECKLIST.md` preconditions, in the
   documented order (rules → indexes → functions → bootstrap → seed → verify).**

## 8. Change applied during this audit

- `firestore.indexes.json`: added the missing composite index
  `(trips: approvalStatus ASC, createdAt ASC)` required by
  `TripsDatasource.listPending` (`trips_datasource.dart:89-96`, oldest-first
  admin queue). Additive, valid JSON (23 entries), no UI/behavior change until
  deployed. This is the ONLY file modified; everything else is reported,
  not fixed, per instructions.

---

## 9. P0 REMEDIATION (applied after the audit above, same branch, undeployed)

All seven P0 items were remediated in source. Only additive/restrictive
changes; UI, navigation, auth flows, Cloudinary, and Paymob client code are
untouched. Nothing deployed, no cloud data touched, no live payment API called.

### 9.1 Rules fixes (`firestore.rules`)
- **P0-1 (H1):** `trips allow list` is now per-document —
  `approvalStatus == 'approved'` (public, incl. anonymous feed browsing),
  OR owner (`guideId == self`), OR admin (`firestore.rules:99-101`). Every
  client query was re-checked against it: `listApproved` (approvalStatus==),
  `listByGuide` (guideId==), `listPending` (admin), `listByPlace`
  (placeId+approved) all satisfy it; unfiltered/cross-status queries are
  denied document-wise. No client change required.
- **P0-2 (H2):** removed the dead `|| true`; `bookings allow list` is now
  per-document participant-or-admin (`:129-133`). `get` unchanged (already
  scoped). New deny-all `bookingKeys/{key}` block (`:163-169`) for the
  idempotency ledger (Function-only via Admin SDK).
- **P0-3 (H3):** notifications `get` adds admin (`:224-226`), `list` is
  per-document recipient-or-admin (`:230-232`), `update` pins every field but
  `isRead` (`:237-246`, nullable keys via `.get()` defaults). `payments`
  `list` is per-document payer-or-admin (`:178-180`) so the dormant
  `getByBooking`/`streamByBooking` owner queries keep working.
- **P0-4 (rules half):** owner client-cancel now additionally requires
  `paymentStatus in ['pending','failed']` (`:146`), pins `paymentStatus` and
  all price/identity fields (`:148-158`, `.get()` defaults for nullable
  `tripId`/`placeId` so private-booking cancels still pass). Paid cancels are
  denied client-side and routed to `cancelBooking`.
- Deliberately NOT changed (out of P0 scope, still open): `M1` legacy
  verification map, `M2` guideProfiles first-create payload shape, `M3/M4`
  trip eligibility/re-pend, `L1-L5` nits.

### 9.2 Functions fixes (`functions/index.js` + new `functions/lib/guards.js`)
- **P0-5:** idempotency is transactional — `bookingKeys/{key}` is read AND
  written inside the same Firestore transaction as the booking + capacity
  increment (public) or booking (private). Concurrent same-key requests
  serialize on the key doc; capacity races remain closed by the trip-doc
  transaction as before. Key format validated (`validIdempotencyKey`,
  8–160 chars, no `/`); `tripDate`/`appointmentAt` validated
  (`parseDateOrNull`, garbage → `invalid-argument`); private path now
  `not-found`s on missing guide profiles (no more total-0 ghost bookings).
- **P0-6:** key docs store `{bookingId, touristId, fp}` (request fingerprint);
  on conflict the owner gets the ORIGINAL booking returned directly
  (`_deduped`, no second booking, no capacity change), while a different
  caller gets `permission-denied` with no booking data
  (`classifyKeyConflict`). A same-owner retry with a MATERIALLY different
  request is rejected (`failed-precondition`, key-bound fingerprint mismatch)
  rather than silently resolving to the unrelated original booking.
  Pre-fingerprint keys (no `fp`) keep deduplicating for compatibility.
- **P0-4 (function half):** new `cancelBooking` callable (owner-or-admin,
  idempotent on already-cancelled, `pending|confirmed`-only) records
  `refundStatus: owed|none` + `refundAmount` (no money moved — refund policy
  still a product decision). The cancel trigger is now retry-safe via an
  in-transaction `capacityReleased` marker (re-reads the booking, skips when
  set; marker write re-triggers with unchanged status → early return, no loop).
- **P0-7:** `verifyPaymobTransaction` now (a) early-returns succeeded payments
  (`_deduped`, no side effects — replay-safe); (b) requires an existing
  `pending` booking with `pending` payment (cancelled/confirmed can no longer
  resurrect, so released capacity can't double-book); (c) matches
  `amount_cents` AND `currency` against the server booking total
  (`paymobOrderCoversBooking`); (d) rejects already-consumed provider orders
  (new `payments: providerReference+status` index added to
  `firestore.indexes.json`, now 24 entries). Secrets handling unchanged
  (`process.env` only).
- `functions/lib/guards.js` holds the pure decision logic imported by
  `index.js`; `package.json` gains `test`/`test:rules`/`lint` scripts (deploy
  config untouched).

### 9.3 Client fixes (Dart, additive only)
- `BookingsRepository.createPublic/createPrivate`: `already-exists` now
  refetches the caller's own booking (`_fetchDeduped`, participant-scoped get
  — fail-closed) instead of throwing; cross-user conflicts surface as
  permission errors. New `cancelViaServer` wraps the `cancelBooking` callable
  (paid path). `BookingsDatasource.cancelByTourist` unchanged (unpaid path)
  with corrected docstring. No View/cubit wiring changed (still P1).

### 9.4 Test evidence (exact commands, `D:\applications flutter\triply`)
- `node --test test/guards.test.js` (in `functions/`) → **17/17 pass**:
  cancel gating, confirm/resurrect gating, amount+currency matcher incl.
  underpayment/foreign-currency/unpaid fixtures, key validation, conflict
  classification (incl. no-disclosure), date parsing.
- `flutter test test/firestore_converters_test.dart
  test/booking_pricing_test.dart test/firestore_models_test.dart` → **32/32
  pass** (unchanged, regression-clean).
- `flutter analyze` (scoped, 11 dirs) → 14 infos, all pre-existing, 0 new.
- `node --check` on `index.js`, `lib/guards.js`, `test/rules.test.js` +
  `functions load OK` → pass.
- **Emulator rules suite (`functions/test/rules.test.js`, 25 cases: anon
  feed, pending-leak denial, guide scoping, cross-user booking/notification/
  payment reads, paid-cancel denial, tamper denial, admin paths) is WRITTEN
  but NOT EXECUTED.** Environment has Java 21 + firebase-tools 15.31, but
  port 8080 is held by a system process (`ApplicationWebServer.exe`, left
  alone) and the 130 MB Firestore emulator jar downloads at ~60–100 KB/s
  (timed out at ~15 MB after 280 s; partial file removed; no stray processes
  left — 8085 free). So: **rules are reviewed + logic-tested, NOT runtime-
  proven.** Run `npm run test:rules` against a local emulator before deploy;
  `FIRESTORE_EMULATOR_PORT`/`FIRESTORE_TEST_PROJECT` env overrides are built in.
- Callable emulator tests (concurrent booking, end-to-end idempotency,
  cancel/verify flows) likewise not run — same blocker. The `verify` path
  additionally requires Paymob sandbox credentials (never called live here).

### 9.5 Remaining risks / manual review required
1. Rules MUST pass the emulator suite before deploy (review is not proof).
2. Paymob `order` shape assumption (`amount_cents`/`currency`/`is_captured`/
   `payment_status`) still needs a sandbox run with real credentials.
3. Refund policy for `refundStatus: owed` is undecided (product input).
4. `M1/M2/M3/M4/L1-L5`, dormant View wiring, `getGuidePhoneByName` rule
   conflict, stories string-expiry, secret rotation — all still open (P1+).
   → RESOLVED by §10 below, except secret rotation (plan only) and View
   wiring (deliberately deferred — see §11).
5. `verifyPaymobTransaction` uses global `fetch` (Node 20 runtime provides it;
   Cloud Functions node20 confirmed in `package.json` engines).
6. `bookingKeys` docs accumulate forever — add a TTL/cleanup if key volume
   matters (LOW). → Still open (unchanged).

---

## 10. P1 REMEDIATION (applied after §9, same branch, undeployed)

UI, navigation, auth flows, Cloudinary, and Paymob client code untouched.
Nothing deployed, no cloud data touched, no live payment API called.
`verifyPaymobTransaction` replay check additionally hardened: the
duplicate-order check and both writes now run in ONE transaction
(`functions/index.js`, formerly check-then-batch).

### 10.1 Stories Timestamp consistency (M5 — FIXED)
- `StoryDoc.toCreateMap` (`lib/data/firestore/models/story_doc.dart:58-70`)
  now writes `expiresAt` as `Timestamp.fromDate(...)` instead of an ISO
  string; the false "Function normalizes it" comment is replaced with the
  real contract. `fromMap` still reads legacy strings (backward compatible).
- Rules pin `expiresAt is timestamp` on create
  (`firestore.rules`, stories block) so string expiries are rejected instead
  of silently breaking queries/cleanup.
- Tests: new Dart cases (Timestamp-type payload + TTL window; legacy-string
  read) and new emulator rules cases (Timestamp allowed, string denied).
- Residual: pre-fix string docs need the backfill in
  `DEPLOYMENT_CHECKLIST.md` §5 (rewrites as Timestamp or delete-if-expired).

### 10.2 guideProfiles first-create (M2 — FIXED)
- Rules use `.get('field', default)` comparisons for the four server-owned
  fields (`firestore.rules`, guideProfiles block): first-time creates may
  omit them (absent == default), explicit escalation still mismatches.
  Merge-updates are unaffected (merged values compared). No client change
  needed; emulator test covers omitted-flags create + flag-escalation denial.

### 10.3 Trip create eligibility + validation (M3 — FIXED, scoped)
- Rules require the creator's `users` doc `role == 'guide'` (server-side
  `get()`, never client input) plus `title` non-empty, `priceEgp is number`
  `>= 0`, `capacity is int >= 1`. Publish-gating for UNVERIFIED guides is
  deliberately NOT enforced here: the app's stated flow lets
  verification-pending guides submit (everything lands `pending`);
  enforcement stays in the admin approval workflow.
- Emulator tests updated (valid payloads) + new denial cases (tourist create,
  empty title, negative price, zero capacity).

### 10.4 Re-pend on commercial edits (M4 — DECIDED + IMPLEMENTED)
- Decided rule (was NEEDS CLARIFICATION): edits to `priceEgp`/`capacity`/
  `dateLabel` on an APPROVED trip return it to `pending`; editorial fixes
  stay live. Existing bookings keep locked-in terms.
- New `onTripUpdated` trigger (`functions/index.js`) guarded by pure
  `guards.shouldRependTrip` (approved→approved + commercial diff only):
  resets status, clears stale `rejectionReason`, notifies the guide.
  Loop-safe (own write is approved→pending; admin/pending edits never match).
- Unit-tested (`guards.test.js`: re-pend cases + editorial/loop cases).

### 10.5 Legacy verification preservation (FIXED)
- `decideVerification` reads the `users` doc first and merges decision fields
  over preserved `idDocumentUrl`/`licenseDocumentUrl`/`submittedAt` via pure
  `guards.mergeLegacyVerification` (unit-tested incl. missing-map case).
- Verification resubmit path opened in rules (rejected→pending, exact key
  allowlist, reviewer fields dropped) and the app resubmit switched to
  overwrite (`SetOptions(merge: false)`) so it satisfies the allowlist;
  emulator tests cover resubmit-allowed / approved-locked / reviewer-smuggle.

### 10.6 Silent fallbacks (I1/I4 — MITIGATED, not eliminated)
- Remote bridges now report: `loadRemote`/`refreshRemote` return
  `Future<bool>` (true = remote data applied), `toggleLikePersistent` and
  notification mark-remotes return persistence ack; all log via `debugPrint`
  on fallback (`trips_cubit.dart`, `guide_trips_cubit.dart`,
  `community_cubit.dart`, `notifications_cubit.dart`;
  `submitTripToFirestore` already returned `remoteError`). Safe: zero callers
  exist, no tests reference the old signatures.
- Best-effort dual-writes now log failures (`tour_guide_auth_service.dart`).
- Full elimination (visible offline states in Views) stays P2: it requires
  View changes, out of scope for a data-layer task.

### 10.7 Secrets (PLAN ONLY — no code changed)
- Concrete ordered plan added to `DEPLOYMENT_CHECKLIST.md` §3 (secret first,
  sandbox-verify, then delete fallback + fail closed, then rotate, then
  Cloudinary signed uploads). Verified: `.env` gitignored + untracked;
  `google-services.json` tracked (normal; restrict its key in Console).
- `getGuidePhoneByName` migrated to public `guideProfiles`
  (`displayName`→`contactPhone`) with legacy `users` fallback
  (`auth_repository.dart:65+`); registration dual-write supplies both fields;
  `GuideProfileDoc` extended (defaults keep old docs parsing);
  `GuidesRepository` prefers canonical fields with per-guide best-effort
  `users` read (fixes the post-deploy always-fallback flaw).

### 10.8 Test evidence (exact commands, `D:\applications flutter\triply`)
- `node --test test/guards.test.js` (in `functions/`) → **21/21 pass**
  (17 prior + `shouldRependTrip` ×2 + `mergeLegacyVerification` ×2).
- `flutter test test/firestore_converters_test.dart
  test/booking_pricing_test.dart test/firestore_models_test.dart` → **35/35
  pass** (32 prior + story Timestamp + legacy-string + guide contact fields).
- `flutter analyze` (touched dirs) → 14 infos, all pre-existing, 0 new.
- `node --check` on `index.js`, `lib/guards.js`, `test/rules.test.js` +
  `functions load OK` → pass.
- `functions/test/rules.test.js` extended for P1 (eligibility denials,
  resubmit matrix, Timestamp-type stories, omitted-flags create) — still
  NOT EXECUTED (emulator jar download infeasible on this link; see §9.4 and
  §12). `npm run test:rules` + env overrides ready for a better link.

## 11. FEATURE INTEGRATION TRACE (Phase 4 — status, not wiring)

Decision: Views stay on mocks/session data until AFTER deploy (wiring them now
would break the app: empty project, undeployed rules, no emulator proof).
`loadRemote`-family bridges now return explicit remote-applied booleans so
future wiring can show offline states. Per-feature state:

| Feature | View → Cubit → Data (today) | Firestore path | Status |
|---|---|---|---|
| Tourist auth / password reset | screens → `AuthProvider` → `AuthRepository` | Auth + `users` merge | LIVE (pre-existing) |
| Tourist profile phone | `profile_screen` → `getUserPhone` | `users/{uid}` get (owner) | LIVE (pre-existing) |
| Trip-details guide contact | `trip_details_screen:187` → `getGuidePhoneByName` | `guideProfiles` first, `users` fallback | LIVE, deploy-safe (§10.7) |
| Guide register/login/verification | auth views → `TourGuideAuthService` | Auth + `users` + Cloudinary + dual-writes | LIVE (pre-existing + P1 logging) |
| Guide profile view/edit | `profile_tour_guide_screen:30,92` → `loadRemoteProfile`; `edit_profile_sheet:126` → `updateProfileFields` | `users/{uid}` read/merge | LIVE (pre-existing) |
| Dashboard verification banner | `DashboardCubit` → `isVerificationApproved` | legacy map read | LIVE but spoofable (M1 open) |
| Tourist trips/popular/my-trips, map/search/place, bookings, checkout, community/stories, notifications | screens → cubits → mocks / `MyBookingsPublic` / local stores | dormant bridges (`loadRemote` etc. exist, zero View callers — verified by grep) | MOCK/SESSION |
| Guide trips/dashboard-stats/create/edit/travelers/earnings | screens → cubits → `GuideTripsStore` + mocks | dormant bridges | MOCK/SESSION |
| Admin (all 8 pages) | views → `d_mock_*` + `AdminSession` | `AdminAccessService` dormant; `triplykl` demo gate live | MOCK/LOCAL |
| Checkout/Paymob + payment verify | `PaymobService` client flow | `createPendingPayment`/`verifyPaymobTransaction` dormant | CLIENT-ONLY (I2 open) |

Post-deploy flip order (each: wire View → bridge bool → offline notice →
emulator-verify): places/trips reads → bookings → community → notifications →
guide trips → admin reads → admin actions → payment-verify wiring.

## 12. Emulator status (final)

Port 8080 remains held by system `ApplicationWebServer.exe` (PID 11428,
verified unchanged — not touched). Repo `firebase.json` keeps 8080; local
runs must use a temp `--config` override on a free port (procedure in
`DEPLOYMENT_CHECKLIST.md` §2). A resumable jar download was attempted in
background but the link sustains only ~60–100 KB/s for the 130 MB artifact
(~13 MB in ~25 min); the attempt was stopped per the "stop retrying expensive
downloads" instruction. Net: **no emulator execution in this phase either —
rules/callables are reviewed + logic-tested (21 + 35 green), NOT
runtime-proven.** This is the single gating item before deploy.

## 13. Remaining risks (updated)
1. Emulator suite (rules + callables) unexecuted — gate deploy on it.
2. Paymob sandbox run with real credentials outstanding (shape assumption).
3. Refund policy undecided (product input; `refundStatus: owed` is bookkeeping).
4. View wiring deliberately deferred to post-deploy (trace in §11).
5. Secret rotation + signed uploads per checklist §3 (plan documented).

---

## 14. TRIPS FEED + TRIP DETAILS — PREPARED, DISABLED (no deploy)

Scope honored: trips feed + trip details (+ place header) only. No booking,
payment, guide, community, notification, or admin wiring. No cloud changes,
no deployment. Emulator gate REMAINS BLOCKED (jar unfetchable — §12
procedure validated up to the download; background attempts killed, partials
removed, ports 8080/8085 verified clean afterward). Rules are NOT
runtime-verified — restated explicitly.

### 14.1 Kill-switch mechanism (implemented, per-feature)
Each wired feature owns `static const bool useRemote = false` in its cubit
file (`TripsCubit`, `TripDetailsCubit`, `PlaceDetailCubit`). No global
abstraction: Views check the flag before any remote call, so with the
default `false` NO request fires, NO offline banner shows, and mocks render
exactly as before. Activation = flip one const post-deploy; rollback = flip
back or revert the feature commit. Repositories additionally construct
lazily (no Firebase touch at construction — keeps tests/offline startup
clean) and return explicit `Failure` instead of disguising errors as mock
`Ok` (the silent-mock fallback was removed from `TripsRepository`;
fallback display stays in cubits with visible notice).

### 14.2 Trips feed (`trips_screen.dart`, `trips_cubit.dart`)
Post-frame gated `loadRemote()` on open + tab switch, duplicate-guarded,
offline SnackBar labels mocks as samples on `false`. UI/layout/tabs/cards/
navigation untouched. Tests: new `test/trips_cubit_test.dart` — 5/5 pass
(flag default, mock baseline, success, empty, failure).

### 14.3 Trip details (`trip_details_cubit.dart` + screen)
New `TripsRepository.tripDetails()` (doc → mapped UI model, explicit
Empty/Failure) + `TripDetailsCubit.loadRemote()` returning bool.
`TripDetailsScreen` converted Stateless → Stateful MECHANICALLY (same build,
args, helpers; `tabs` static kept; `trip`/`isBooked` via getters): conversion
was necessary for mount-guarded failure SnackBar — no other honest failure
surface exists in a Stateless widget. Args/navigation/guide-contact/booking
card untouched. Tests: new `test/trip_details_cubit_test.dart` — 5/5 pass.

### 14.4 Place header (`place_detail_cubit.dart`, `place_details_view.dart`)
`loadRemotePlace()` refreshes ONLY the header (same `Place` class end to end —
no mapping layer); favorite preserved; guides/trips/stories tabs untouched.
Screen was already Stateful: initState addition only. Tests: new
`test/place_detail_cubit_test.dart` — 5/5 pass (incl. favorite+tabs kept).

### 14.5 Verification this phase
- `flutter test` (3 new files): 15/15 pass. Older suites re-run: 35/35 pass.
  `node --test guards.test.js`: 21/21 pass. No emulator execution claimed.
- `flutter analyze` on touched dirs: 2 infos, both pre-existing in untouched
  `place_details/widget/trip_card.dart`; 0 new. Full-project: 38 infos,
  0 errors (baseline unchanged).
- Diff: additive-only edits to 3 repos/cubits/screens listed above + 3 new
  test files; no deletions, no rule/test weakening.
- Still mock-backed (unchanged): my-trips, bookings, checkout/Paymob-verify,
  community/stories, notifications, guide trips/create/dashboard/travelers/
  earnings, search/map (beyond header), guides list, admin. Live (unchanged):
  auth, profile/phone, guide register/verification, profile edit, contact
  lookup.
6. View wiring deliberately deferred to post-deploy (trace in §11).
