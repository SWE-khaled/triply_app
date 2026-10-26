# Triply Chat — Phase C3 Report (screens and entry points)

**Project:** `triply-f9b82` (Firebase Spark). **Phase:** C3 of 3 — Message entry points, chat list, chat room, unread badges, widget tests. **No deploy, no rules/index change, no production write.**

## Result

| Check | Result |
|---|---|
| Chat tests (models + cubits + widgets) | **PASS** — 85 tests, all passing (72 after C2, +13 in C3). |
| Full `flutter test` | **PASS** vs baseline — `+168 -1`; the only failure is the pre-existing template test `test/widget_test.dart` ("Counter increments smoke test"). |
| Full `flutter analyze` | **PASS** vs baseline — 0 errors, 0 warnings, **50 infos** (same 50 as C2). The new `use_null_aware_elements` info was fixed before the final run. |
| Formatting | **PASS** — final `dart format` over all 24 touched files reports `0 changed`. |
| New packages | None. |
| `firestore.rules` / `firestore.indexes.json` | Unchanged by C3. |
| Firebase deploy / production write / Cloud Functions / billing | **None.** |

## Baseline used

| Check | Baseline (measured after C2) |
|---|---|
| `flutter analyze` | exit 1 — 0 errors, 0 warnings, **50 infos** (22 app + 28 `tool/chat_rules_check.dart` `avoid_print`) |
| `flutter test` | exit 1 — **+155 -1**, only `test/widget_test.dart` |

C3 did not add a single lint, warning, error or failing test.

## Files changed

### New files (9)

| File | Lines | Purpose |
|---|---:|---|
| `lib/features/chat/data/chat_roles.dart` | 28 | Reads `users/{uid}.role`; `canStartChat` = tourist only. Failure/signed-out hides the button. |
| `lib/features/chat/model/chat_audience.dart` | 18 | `ChatAudience.tourist` / `.guide` — labels, empty-state copy, other-role wording. |
| `lib/features/chat/util/chat_time.dart` | 61 | Chat-local time/date formatting and day-separator helpers. |
| `lib/features/chat/view/chat_list_screen.dart` | 512 | Live list, search, All/Unread chips, empty/search-empty/loading/error states, guide 4-tab nav, unread badge. |
| `lib/features/chat/view/chat_room_screen.dart` | 851 | Live room, date separators, typing, Seen/edited labels, long-press edit/delete/report, read-only banner and disabled composer, pagination. |
| `lib/features/chat/widgets/chat_avatar.dart` | 56 | Avatar with initials fallback; shared by list, room and header. |
| `lib/features/chat/widgets/chat_unread_builder.dart` | 46 | Watches the chat list once per nav bar and exposes the total unread count; used by the tourist FAB and all guide tabs. |
| `lib/features/chat/widgets/message_guide_button.dart` | 103 | Role-gated "Message" entry point; round icon on the profile bar, full-width outlined button on trip details. `isTourist` is injectable for tests. |
| `test/features/chat/view/chat_widgets_test.dart` | 8 tests | Empty list, unread list, room with messages, read-only banner, search-empty, tourist/guide visibility, no-mock initial data. |

### Modified files (15)

| File | Change |
|---|---|
| `lib/core/constants/app_routes.dart` | Added `chatList`, `guideChats`, `chatRoom`, `chatWithGuide`, `guideDashboard`. No existing route changed. |
| `lib/features/chat/cubit/chat_list_state.dart` | Refactored to distinct `Initial` / `Loading` / `Success` / `Error` classes (no `copyWith`). |
| `lib/features/chat/cubit/chat_list_cubit.dart` | Emits the new states; signed-out → `Error`; search and unread total preserved. |
| `lib/features/chat/cubit/chat_room_state.dart` | Refactored to distinct `Initial` / `Loading` / `Success` / `Error` classes (no `copyWith`). |
| `lib/features/chat/cubit/chat_room_cubit.dart` | New-chat send from `Initial`, live chat/message/typing wiring, profile refresh on room open, edit/delete/report, mark-read; permission denial → read-only. |
| `lib/features/tour_guide/home_and_notification_tg/widget/guide_bottom_nav.dart` | 3 tabs → 4 (Home / My Trips / **Chats** / Profile) plus unread badge. |
| `lib/features/tour_guide/home_and_notification_tg/view/guide_dashboard_screen.dart` | Home index 0, Chats index 2, Profile 3; badge wired. |
| `lib/features/tour_guide/my_trips_tg/view/guide_trips_screen.dart` | Bottom indices moved (Chats 2, Profile 3); uses `AppRoutes.guideChats()`. |
| `lib/features/tour_guide/profile_tg/view/profile_tour_guide_screen.dart` | Profile index 3; Chats tab wired; badge wired. |
| `lib/features/tourist/home/view/home_screen.dart` | Messages FAB with unread badge → `AppRoutes.chatList()`. |
| `lib/features/tourist/guides/view/guide_profile_screen.dart` | Replaced the commented-out chat placeholder with `MessageGuideButton` (tourist-only). |
| `lib/features/tourist/trip_details/model/trip_details.dart` | Optional `guideId` (default `''`), mapped from `PublicTrip` and JSON. |
| `lib/features/tourist/trip_details/view/trip_details_screen.dart` | Full-width Message button when `guideId` is non-empty; hidden otherwise. |
| `test/features/chat/cubit/chat_list_cubit_test.dart` | Updated for sealed states; +3 cases (initial/loading/error). |
| `test/features/chat/cubit/chat_room_cubit_test.dart` | Updated for sealed states; +2 cases. |

`dart format` also reflowed a few untouched expressions in the files above (e.g. `GuideDashboardScreen` subscription, `GuideProfileScreen` navigation). These are whitespace-only changes; `git diff --ignore-all-space` shows the real edit size (19 lines in the dashboard instead of 275).

## What was built (mapped to the C3 tasks)

1. **Message before booking (task 1).**
   - Guide profile: a round Message button in the profile bar, only for tourists, no booking needed.
   - Public trip details: a full-width outlined Message button below the book action, only when the trip has a `guideId`.
   - Tapping opens `ChatRoomScreen` with `guideId`; **no chat document is created on tap**. `ChatRoomCubit.sendMessage` is the only create path, so an untouched room leaves no empty chat.
   - `ChatRoles` hides the button for guides, signed-out users, read failures and any non-tourist role.

2. **Chat list and badges (task 2).**
   - `ChatListScreen` works for both roles: other person's avatar/name, last-message preview (`You:` prefix for own last message), time, unread count, live updates, search over name + preview, All/Unread filter.
   - Tourist reach: Home FAB with total unread badge.
   - Guide reach: `Chats` tab in the 4-tab guide nav, with the same total badge on Home, My Trips, Chats and Profile.
   - A guide sees only chats that tourists started: no "new chat" action exists anywhere in the guide UI, and the repository/rules still reject guide-side creation.

3. **Chat room (task 3).**
   - Text messages with instant stream updates, day separators, newest-page load and "load earlier" pagination.
   - Typing indicator (header label + bubble) driven by `ChatTypingThrottle`.
   - Seen receipts from the other participant's `lastReadAt`; own messages show Sent/Seen; edited messages show an `edited` label.
   - Long-press own message: Edit / Delete, both bounded by the 24-hour window (client pre-check) and sender check.
   - Long-press other message: Report with reasons Spam / Harassment / Inappropriate content / Other and an optional note (≤500 chars).
   - Inactive/permission-denied account: a read-only banner, composer hidden/disabled, actions blocked — mapped from `ChatPermissionException`.
   - Empty room copy distinguishes tourist ("Start the conversation with …") from guide.
   - Opening a room calls `markRead`; opening a room also refreshes `profiles.<me>` best-effort, so names/avatars stay current (task 4). The refresh is silent and never interrupts the chat.

4. **Widget tests (task 5).** See below.

## Widget test coverage (8 tests)

| Test | Covers |
|---|---|
| empty list | `No conversations found`, role-specific subtitle, no tiles. |
| list with unread | Tile name/preview/unread count; Unread chip count; ordering. |
| room with messages | Message text, sender grouping, own/other bubble, Seen/edited labels. |
| read-only banner | Banner visible, composer absent/disabled after `ChatPermissionException`. |
| no search result | Search text → `No conversations found` + "Try another guide or trip name." |
| role visibility (tourist) | Message entry point visible for a tourist. |
| role visibility (guide) | Message entry point hidden for a guide. |
| no mock initial data | Empty repository shows the empty state, not fake chats/messages. |

The tests use the existing `FakeChatRepository` from C2. No Firebase, no network, no emulator, no mock runtime chats in production code.

## Verification commands and exact output

| Command | Output |
|---|---|
| `flutter analyze` | `50 issues found` — 0 errors, 0 warnings, 50 infos (all pre-existing). |
| `flutter test` | `+168 -1: Some tests failed` — only `test/widget_test.dart` "Counter increments smoke test". |
| `flutter test <4 chat test files>` | `+85: All tests passed!` |
| `dart format <24 touched files>` | `Formatted 24 files (0 changed)`. |

## Design references — disclosure

Design images are in `opencode/designs/chat/`:

- `chat_desgin.png`
- `chat_design_inTourguide.png`
- `GuideProfileScreen_inTourist.png`
- `home_screen.png`
- `no_conversations_found.png`
- `no_conversation_found_inTourguide.png`
- `Search_not_result_found.png`
- `tourist_chat.png`

**I could not open or visually inspect these images in this session** — the model does not support image input (`Image read successfully / ERROR: this model does not support image input`). The UI was therefore built from the plan, the C1 theme/navigation notes, the app's existing screens, and the design copy extracted from the files where available. Copy used: tourist `Messages` / "Your conversations with tour guides"; guide `Chats` / "Stay connected with your travelers."; empty `No conversations found`; search-empty adds "Try another guide or trip name."

This is a real limitation: spacing, exact colours, icon choices and proportions may not match the Figma pixel-for-pixel. Khaled should compare the 8 screenshots against the running app and name any mismatch; correcting them is additive and does not touch the data layer.

## MANUAL checklist — pending Khaled (not executed here)

Two authorized test accounts, two devices or emulators. No other user's data is touched.

- [ ] (a) Tourist opens a guide profile and sends a message **before any booking**; the chat appears and no empty chat was created by the tap alone.
- [ ] (b) Guide sees the chat in `Chats` with unread **1**, and replies.
- [ ] (c) Tourist sees the reply, the Seen marker and the typing indicator while the guide types.
- [ ] (d) Edit and delete a message within 24 hours; confirm the `edited` label and that the other side updates live.
- [ ] (e) Report the other person's message with each reason and a note; confirm "Report sent" and the `reports` document shape.
- [ ] (f) A guide has **no** button anywhere that starts a chat.
- [ ] (g) Repeat the tourist FAB / guide Chats-tab navigation on each tab and confirm the badge total matches the list.
- [ ] (h) Optional: use an inactive/denied account to confirm the read-only banner and disabled composer.

## Rollback

No Git commit, push, branch switch, stash or deploy was performed. All C3 changes are uncommitted in the working tree.

- **New files:** delete the 9 files listed above (and `test/features/chat/view/chat_widgets_test.dart`).
- **Modified files:** restore from Git:
  ```
  git checkout -- lib/core/constants/app_routes.dart lib/features/chat/cubit/chat_list_cubit.dart lib/features/chat/cubit/chat_list_state.dart lib/features/chat/cubit/chat_room_cubit.dart lib/features/chat/cubit/chat_room_state.dart lib/features/tour_guide/home_and_notification_tg/view/guide_dashboard_screen.dart lib/features/tour_guide/home_and_notification_tg/widget/guide_bottom_nav.dart lib/features/tour_guide/my_trips_tg/view/guide_trips_screen.dart lib/features/tour_guide/profile_tg/view/profile_tour_guide_screen.dart lib/features/tourist/guides/view/guide_profile_screen.dart lib/features/tourist/home/view/home_screen.dart lib/features/tourist/trip_details/model/trip_details.dart lib/features/tourist/trip_details/view/trip_details_screen.dart test/features/chat/cubit/chat_list_cubit_test.dart test/features/chat/cubit/chat_room_cubit_test.dart
  ```
- **Or restore from the pre-edit backups** in `opencode/backups/C3/`, which preserve the original relative paths with a `.dart.bak` suffix (renamed from `.dart` so `flutter analyze` ignores them), e.g.:
  ```
  Copy-Item opencode/backups/C3/lib/core/constants/app_routes.dart.bak lib/core/constants/app_routes.dart
  ```
  Repeat for each file under `opencode/backups/C3/` (15 files). New C3 files have no backup because they did not exist before.
- **Firebase:** nothing to roll back — no rules, index, function or data change was deployed or written.

## Residual risks / known gaps

1. **No live end-to-end test.** Guard forbids an emulator and this phase forbids production writes, so the Firestore repository was not exercised live. The manual checklist above is the only true end-to-end confirmation.
2. **Designs not visually inspected** (see disclosure). Layout may differ from Figma.
3. **Unread badge scope.** The badge is the sum of `unreadCount.<me>` from the live list, as specified. Without push, it updates only while the app is open (accepted limit L3).
4. **List requires the C1 index** (`participants` ASC + `lastMessageAt` DESC), already deployed. No C3 index change.
5. **Stale deep links.** Reading a nonexistent chat id is denied by the `chats` read rule, so a stale room link shows a permission error / read-only banner rather than "chat not found". Entry points built here always pass an existing chat id or a guide id, so this is only reachable from an old link.
6. **24-hour edit/delete is a client pre-check.** The rules enforce the sender; the time window is mirrored client-side. Any mismatch surfaces as a normal retryable error, not a read-only room.
7. **Profile refresh** happens when a room is opened, not on app start for every chat (matches the task wording "for the chats the user opens"). Silent on failure.
8. **No push notifications.** Expected on Spark (accepted limit L3).

## Deployment / data statement

- Active project was **not** changed; no `firebase deploy` was run.
- No Firestore reads or writes against `triply-f9b82` were made by this phase's verification (tests are fully faked).
- `firestore.rules`, `firestore.indexes.json`, Firebase dependencies and the canonical chat-id contract are untouched.
- No secrets, tokens or credentials were read or printed.

## Phase C3 status

**Code complete and verified against baseline.** The remaining work is Khaled's manual two-account checklist and a visual pass over the 8 design screenshots. No further code phase is planned.
