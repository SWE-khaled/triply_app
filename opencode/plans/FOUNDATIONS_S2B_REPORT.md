# Triply Foundations — Phase S2b Report

**Status:** implementation complete; verification is partially blocked by the
configured Flutter SDK lock (see “Numbers vs baseline”). Do **not** start S3.  
**Project:** `triply-f9b82` — Firebase SPARK (free) plan.  
**Deploy:** NONE (this phase makes no deploy of any kind — no rules, no indexes).  
**Recorded baseline:** `flutter analyze` = 0 errors / 22 info lints; `flutter test` = 75 pass / 1 known failing template test (`test/widget_test.dart`).

## Continuation audit and completion

When this continuation began, the working tree and `opencode/backups/S2b/`
showed that the guide-form fix, self-heal service, decision-logic tests, and
the S2b report were already present. The implementation matched Tasks 1, 2,
and 4, and most of Task 3.

One requirement was still missing: `ProfileSelfHealService` could run again
for repeated Firebase Auth state emissions in the same signed-in session. This
continuation added an in-memory UID guard before the Firestore read/write and
resets it only after explicit sign-out. Thus each authenticated session gets
at most one silent attempt (including an unsuccessful attempt); a later
sign-in gets one new attempt. The service still writes only missing
`displayName` and, when that write is needed, a missing `avatarUrl` with a
merge update. It never writes `role`, `isActive`, or `isApproved`.

Before that small completion edit, snapshots of the then-current new service
and its test were added to `opencode/backups/S2b/`. Existing S2b backups were
left untouched. No Firebase data was read or changed.

---

## Task 1 — endAt consistency (guide trip form)

### The question answered

**Which of the two decides the saved `endAt` today (before the fix)?**  
The **duration dropdown** decides `endAt`, NOT the End Time picker. In S2, `endAt` was computed as `startAt + durationHours(dropdown)`, while the End Time picker only wrote to `endTimeCtrl` and was never read when computing `endAt`.

**What happens when they disagree?**  
Example: start `10:00`, End Time `15:00`, duration dropdown `"2 hours"` → `endAt` is saved as `12:00` (10:00 + 2h), and the End Time `15:00` is ignored. The two contradict each other.

### Already completed: the fix (ONE source of truth: End Time)

- `endAt` is now parsed from the picked **date + End Time** (same day as the start). The End Time the guide picks is the single source of truth; the duration dropdown no longer influences `endAt`.
- `duration` is **derived** from `endAt - startAt` (e.g. `"5 hours"`, `"Full Day"` for 8 h) and shown in a read-only Duration field, so it can never contradict start/end.
- Validation: end time must be after the start time on the same day. If End Time is not after start (equal or earlier), validation fails with a clear message — **"End time must be after the start time."** — and never rolls silently to the next day.
- `startAt` behaviour is unchanged (date + time pickers, unreadable time still falls back to midnight).
- Edit mode pre-fills `endTimeCtrl` from the existing trip's `endAt` and recomputes the derived duration.

Files changed (Task 1):
- `lib/features/tour_guide/create_trip_tg/cubit/create_trip_cubit.dart`
- `lib/features/tour_guide/create_trip_tg/view/create_trip_screen.dart`
- `lib/features/tour_guide/create_trip_tg/widgets/form_sections.dart`

---

## Task 2 — Admin trip form

**Finding:** none found. A continuation audit searched `lib/features/admin_dashboard/` and `lib/core/data/repositories/` for any admin screen or repository that creates or edits trips (start/end date/time, `startAt`/`endAt`). The admin dashboard (`d_trips_view.dart`, `admin_trips_repository.dart`) only **reads** trips and approves/rejects/cancels them by writing `approvalStatus`/`rejectionReason` — it never creates or edits a trip's date/time. **No changes needed** for this task.

---

## Task 3 — displayName self-heal

**New file:** `lib/core/services/profile_self_heal_service.dart`

After a user signs in (tourist and guide) and when the app restores an existing session, the service reads the user's own `users/{uid}` document. If `displayName` is missing/empty and Firebase Auth has a non-empty display name, it writes **only** the missing `displayName` (and `avatarUrl` if missing, from the Auth photo URL or `''`) with a merge update.

Properties:
- Silent and at most one attempt/write per authenticated session; repeated Auth
  state events for the same user return before any Firestore read or write.
- Never touches `role`, `isActive` or `isApproved`.
- Never blocks login; all errors are swallowed.
- Pure decision logic (`decideProfileUpdates`) is separated from Firestore so it can be tested with a fake seam (plain strings, no Firebase).

Wired into:
- `lib/features/common/AuthTourist/cubit/auth_cubit.dart` — `healAfterSignIn()` runs in `_onAuthState` whenever a user is present (covers sign-in and session restore).
- `lib/features/common/AuthTourguide/data/tour_guide_auth_service.dart` — `healAfterSignIn()` runs after a successful guide sign-in (role confirmed `guide`).

---

## Task 4 — Unit tests

**`test/features/tour_guide/create_trip_cubit_test.dart`** (rewritten):
- `endAt` is the end time, not start + duration (disagreeing inputs: start 10:00, End Time 15:00, duration "2 hours" → `endAt` = 15:00, duration derived "5 hours").
- `Full Day` = 8 h derived duration.
- End time pre-fill (edit mode) produces consistent `endAt` and duration.
- Validation fails when end time is before or equal to start time.
- `startAt` parsing tests preserved unchanged.

**`test/core/services/profile_self_heal_service_test.dart`** (new):
- `decideProfileUpdates` write-needed vs no-write cases using plain strings (fake seam, no Firestore): missing name+photo → both written; missing name, no photo → avatar `''`; name present → no write; whitespace-only Auth name → no write.

---

## Files changed in S2b

- `lib/features/tour_guide/create_trip_tg/cubit/create_trip_cubit.dart`
- `lib/features/tour_guide/create_trip_tg/view/create_trip_screen.dart`
- `lib/features/tour_guide/create_trip_tg/widgets/form_sections.dart`
- `lib/core/services/profile_self_heal_service.dart`
- `lib/features/common/AuthTourist/cubit/auth_cubit.dart`
- `lib/features/common/AuthTourguide/data/tour_guide_auth_service.dart`
- `test/features/tour_guide/create_trip_cubit_test.dart`
- `test/core/services/profile_self_heal_service_test.dart`
- `opencode/plans/FOUNDATIONS_S2B_REPORT.md`

Backups are retained under `opencode/backups/S2b/`; no non-test Firestore
document, deployment configuration, Cloud Function, or secret was changed.

---

## Numbers vs baseline

| Check | Baseline (S2) | After S2b | Result |
|-------|---------------|-----------|--------|
| `flutter analyze` errors | 0 | 0 | PASS |
| `flutter analyze` info lints | 22 | 22 | PASS (no new lints) |
| `flutter test` passing | 75 | 83 (recorded by the prior S2b report) | re-run blocked |
| `flutter test` failing | 1 (`widget_test.dart`) | 1 (recorded by the prior S2b report) | re-run blocked |

`flutter analyze` itself was attempted before and after the completion edit,
but it waited on an active `flutter.bat.lock` in the configured Flutter SDK
and emitted no diagnostics. As a safe fallback, the bundled Dart SDK ran
`analyze` after the completion edit and reported exactly **0 errors / 22 info
lints**; its nonzero process exit was only a denied telemetry-timestamp write
outside this workspace after analysis completed. A direct-Dart attempt to run
the two S2b tests did not execute tests because the sandbox could not fetch
`flutter_lints` from pub.dev. No test failure was observed, but a full
`flutter test` still needs to be rerun after the external SDK lock clears.

---

## Manual checklist (Khaled)

| # | Manual check | Status |
|---|--------------|--------|
| (a) Create a guide trip with start 10:00, End Time 15:00; confirm the form shows consistent derived duration (5 hours) | pending Khaled |
| (b) Try End Time before start; confirm the validation error "End time must be after the start time." | pending Khaled |
| (c) Edit that trip; confirm date/start/end fields are pre-filled correctly | pending Khaled |

---

## Test data

No test accounts or documents were created, read, modified, or deleted. `tool/backfill_display_name.dart` was left untouched and not executed (per task). **Nothing to delete; confirmed none exists.**

---

## Rollback

No deploy was performed, so there is nothing to roll back in Firestore.

For code changes, restore each modified file from `opencode/backups/S2b/`:
- `lib/core/services/profile_self_heal_service.dart` — delete (new file)
- `lib/features/common/AuthTourist/cubit/auth_cubit.dart` — restore from `opencode/backups/S2b/auth_cubit.bak`
- `lib/features/common/AuthTourguide/data/tour_guide_auth_service.dart` — restore from `opencode/backups/S2b/tour_guide_auth_service.bak`
- `lib/features/tour_guide/create_trip_tg/cubit/create_trip_cubit.dart` — restore from `opencode/backups/S2b/create_trip_cubit.bak`
- `lib/features/tour_guide/create_trip_tg/view/create_trip_screen.dart` — restore from `opencode/backups/S2b/create_trip_screen.bak`
- `lib/features/tour_guide/create_trip_tg/widgets/form_sections.dart` — restore from `opencode/backups/S2b/form_sections.bak`
- `test/features/tour_guide/create_trip_cubit_test.dart` — restore from `opencode/backups/S2b/create_trip_cubit_test.bak`
- `test/core/services/profile_self_heal_service_test.dart` — delete (new file)

The pre-completion snapshots added by this continuation are:

- `opencode/backups/S2b/profile_self_heal_service.bak`
- `opencode/backups/S2b/profile_self_heal_service_test.bak`

**Do not proceed to S3.**
