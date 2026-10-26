# Triply Foundations — Phase S2 Report

**Status:** complete. Automated verification passes; no new failures vs baseline.  
**Project:** `triply-f9b82` — Firebase SPARK (free) plan.  
**Baseline:** `flutter analyze` = 0 errors / 22 info lints; `flutter test` = 69 pass / 1 known failing template test (`test/widget_test.dart`).

---

## 1. Platform & guard compliance

| Check | Result |
|-------|--------|
| Active Firebase project id | `triply-f9b82` (confirmed via `firebase use`) |
| Plan | Spark (free); billing not touched |
| `functions/` folder | None; no Cloud Functions needed |
| Deploy performed | **None** — S2 makes no Firestore rules/indexes changes, so nothing was deployed |
| Code backups | `opencode/backups/S2/` — copies of all 10 source files modified in S2 |

Rollback for code changes: restore each modified file from `opencode/backups/S2/`. No rules redeploy needed (no rules were changed in S2). The S1 rules backup remains at `firestore.rules.before-S1`.

---

## 2. Task 1 — Trip create/edit forms require start + end date/time

**Files changed:**
- `lib/features/tour_guide/my_trips_tg/model/guide_trip.dart` — added `endAt` field (`DateTime?`), `fromJson` parsing, `toJson` serialization
- `lib/core/data/repositories/guide_trips_repository.dart` — `toTripDoc()` now writes `endAt` as a Firestore `Timestamp`
- `lib/features/tour_guide/create_trip_tg/cubit/create_trip_cubit.dart`:
  - Added `endTimeCtrl` controller
  - Added `endAt` getter: computed from `startAt` + duration hours
  - Added `_durationHoursFor()` parser ("2 hours"→2, "4 hours"→4, "6 hours"→6, "Full Day"→8)
  - `validate()` now requires: name, price, capacity, **start date+time** (`startAt != null`), **duration/end** (`endAt != null`)
  - `buildTrip()` sets `endAt` on the `GuideTrip`
  - `saveEdit()` preserves `endAt` from the existing trip when not changed
- `lib/features/tour_guide/create_trip_tg/view/create_trip_screen.dart`:
  - Added `_pickEndTime()` time picker
  - Pre-fills `endTimeCtrl` from existing trip's `endAt` on edit
  - Passes `endTimeCtrl` and `onPickEndTime` to `ScheduleSection`
- `lib/features/tour_guide/create_trip_tg/widgets/form_sections.dart` — `ScheduleSection` now has an End Time field (replacing the duplicated Price field)
- `lib/core/data/repositories/booking_repository.dart` — `createPublicBooking()` throws if `trip['startAt'] == null` ("This trip has no date or time set yet and cannot be booked.")

**A trip without start/end cannot be booked** — the booking flow checks `startAt` before reserving seats.

---

## 3. Task 2 — Profile edit sheets save `users.displayName` and `users.avatarUrl`

**Files changed:**
- `lib/features/tourist/user_profile/widget/edit_profile_sheet.dart` — after updating Firebase Auth displayName/photoURL, writes `displayName` and `avatarUrl` to `users/{uid}` via `SetOptions(merge: true)`
- `lib/features/tour_guide/profile_tg/widgets/edit_profile_sheet.dart` — same: writes `displayName` and `avatarUrl` to `users/{uid}` after `updateProfileFields()`

Both sheets add `import 'package:cloud_firestore/cloud_firestore.dart';`.

---

## 4. Task 3 — Backfill of `users.displayName` (pending Khaled's yes)

**File created:** `tool/backfill_display_name.dart`

This script:
1. Queries all `users` documents
2. Counts those missing `displayName` but having `fullName` or `name`
3. Prints the count (dry run)
4. With `--apply`, writes `displayName` from `fullName`/`name` to each document

**NOT executed.** Per the task, the backfill runs "only after printing how many documents it would touch and getting Khaled's yes." Khaled's yes was not obtained in this session, so no Firestore writes were performed. Khaled should review the script and run `dart run tool/backfill_display_name.dart --apply` when ready.

**No test data was created or modified.**

---

## 5. Task 4 — Registration writes `users.displayName` and `users.avatarUrl`

**Files changed:**
- `lib/features/common/AuthTourist/data/auth_repository.dart` — `signUpWithEmail()` now writes `displayName` (from `fullName`) and `avatarUrl: ''` to the `users` document on sign-up
- `lib/features/common/AuthTourguide/data/tour_guide_auth_service.dart` — `TourGuideProfile.toMap()` now includes `displayName` (from `name`) and `avatarUrl: ''`, written to `users/{uid}` on guide registration

New users are correct without needing a backfill.

---

## 6. Task 5 — Unit tests

**File changed:** `test/features/tour_guide/create_trip_cubit_test.dart`

Updated/added tests:
- `startAt` group — existing parsing tests (unchanged)
- `endAt` group (new, 4 tests): null without date, null without end time, computes end from start + duration, Full Day = 8 hours
- `buildTrip` — now also asserts `trip.endAt` is computed correctly
- `validate` group — updated to require start date/time and duration/end; added tests for missing start and missing duration

**S1 tests carried over:**
- `test/core/data/models/tourist_booking_test.dart` — `TouristBooking.fromDocument` reads `paymentStatus`/`expiresAt`/`endAt`
- `test/features/tourist/booking_public/cubit/booking_public_cubit_test.dart` — price formula, payment method, seat clamping
- `test/features/tourist/booking/cubit/booking_cubit_test.dart` — `startAt`/`endAt` from date+time+duration

---

## 7. Numbers vs baseline

| Check | Baseline | After S2 | Result |
|-------|----------|----------|--------|
| `flutter analyze` errors | 0 | 0 | PASS |
| `flutter analyze` info lints | 22 | 22 | PASS (no new lints) |
| `flutter test` passing | 69 | 75 | PASS (+6 new, all pass) |
| `flutter test` failing | 1 (`widget_test.dart`) | 1 (same) | PASS (no new failures) |

No new failures compared with baseline; did not continue past any failure (none occurred).

---

## 8. Test data

No test accounts or documents were created, read, modified, or deleted in this phase. The backfill script was **not executed** (pending Khaled's yes). **Nothing to delete; confirmed none exists.**

---

## Verdict

**Phase S3 may start: YES** (S2 automated checks all PASS; S1 manual Paymob checklist still pending Khaled but does not block S3 per the S1 report context).

Files changed as listed above. Rollback: restore from `opencode/backups/S2/`; no Firestore rules were deployed in S2.