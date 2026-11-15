# Triply — Project File & Mock-Data Audit

| Field | Value |
|---|---|
| Audit date | 2026-11-15 |
| Branch | `main` |
| Baseline commit | `47c6d2e7eafca18511c3942dbf28cf6374c7feb4` |
| Audit type | Read-only static audit (no app code changed) |
| Report location | `docs/PROJECT_FILE_AUDIT.md` (new file, the only file created) |
| Pre-existing worktree changes | 5 files, listed below; not authored by this audit |

Pre-existing modified files (present before the audit, left untouched):

1. `lib/features/tourist/booking/view/booking_screen.dart`
2. `lib/features/tourist/booking_public/view/booking_public_screen.dart`
3. `lib/features/tourist/checkout/view/mobile_wallet_view.dart`
4. `lib/features/tourist/checkout/view/payment_view.dart`
5. `lib/features/tourist/checkout/view/visa_view.dart`

Line numbers in this report refer to the working tree at the baseline commit plus those five pre-existing edits. Everything below is evidence-based static analysis; no runtime execution of the app was performed.

---

## 1. Executive summary

### 1.1 Headline numbers

| Metric | Count |
|---|---:|
| Git-tracked files | 592 |
| Dart files under `lib/` | 369 |
| Lines under `lib/` | 52,587 |
| Dart `part` owner files / `part-of` files | 27 / 27 |
| Mock data files under `lib/core/data/mock/` | 30 |
| Mock seed files under `lib/core/data/seed/` | 1 |
| Tracked asset files | 28 |
| Test files | 1 |
| Dart files reachable from `lib/main.dart` | 351 (324 libraries + 27 `part` files) |
| Dart files unreachable from `lib/main.dart` | 18 (1,653 lines) |
| `flutter analyze --no-pub` | 13 issues, **all `info`**, 0 errors, 0 warnings |
| `flutter test --no-pub` | **1 test, 1 failure** |

### 1.2 Most important conclusions

1. **The private-guide booking flow books a mock guide with the wrong identity and the wrong money unit.** `GuideProfileScreen` passes a real Firestore guide uid into `BookingScreen`; `BookingCubit` can only match mock ids `g1…gN`, so it silently falls back to `mockGuides.first` ("Omar El-Rashidy", `$85/hr`). The real booking document is then written with the real `guideId` but the mock guide's name/image and a `$` rate treated as EGP. Confidence: **HIGH**.
2. **Payment confirmation is client-asserted, not Paymob-verified.** Both live booking flows record the booking id as the Paymob `paymentId`, and Firestore rules accept any non-empty `paymentId` from the booking owner. The repository has no server-side verification and there is no `functions/` directory. A signed-in tourist can mark their own booking `paid` without a real transaction. Confidence: **HIGH**.
3. **Paymob's secret API key is used by the client and `.env` is declared as a Flutter asset.** `pubspec.yaml:75` bundles `.env`; `paymob_settings.dart:24-42` reads `PAYMOB_API_KEY`; `payment_view.dart:55-70` posts it from the app. This is a credential-exposure design issue independent of whether the local `.env` is git-ignored. Confidence: **HIGH**.
4. **Fake data can surface on normal paths, not only in tests.** Home place cards, place-detail stories, search results, profile statistics, and the private-booking place picker are mock-only. Several repository reads return `null` on failure and cubits substitute mock guides/trips, so a network or rules failure silently turns fake records into bookable content. Confidence: **HIGH**.
5. **The "Booking Confirmed" step of the private booking UI is unreachable.** `BookingCubit.confirm()` (line 165) has no caller, `stepIndex` never reaches 3, and `_buildSuccess()` (line 474) therefore never renders. Confidence: **HIGH**.
6. **Repository hygiene and duplicated domain models increase risk.** 18 unreachable files (1,653 lines), 43 tracked `opencode/backups` / `opencode/plans` artifacts, 12 unreferenced assets, one missing referenced asset, four `Guide` models, five `Trip` models, three `Place` models, two full `EditProfileSheet` implementations, and four separate Cloudinary upload paths. Confidence: **HIGH** for existence; **MEDIUM** for the impact of each duplication.

---

## 2. Scope, method, and safety

### 2.1 In scope

- Every tracked file in the repository, with detailed analysis of `lib/`, `test/`, `tool/`, `assets/`, `firebase.json`, `firestore.rules`, `firestore.rules.before-S1`, and `pubspec.yaml`.
- Static import graph from `lib/main.dart`.
- Route builders and named-route usage.
- Mock-data declarations, importers, and call sites.
- Duplicate class/model implementations.
- Hardcoded, placeholder, and session-only data paths.
- Validation commands: `flutter analyze --no-pub`, `flutter test --no-pub`.

### 2.2 Out of scope

- Runtime/manual UI testing, device testing, and Firebase emulator execution.
- Reading or printing the contents of `.env` or any credential file.
- Editing, deleting, renaming, moving, or formatting app code.
- Changing `pubspec.yaml`/`pubspec.lock`, Firebase rules, indexes, or deploying anything.
- Committing, pushing, or changing branches.
- Auditing the five pre-existing uncommitted edits as if they were baseline.

### 2.3 Method

- `git ls-files`, `git status --short`, `git diff --stat`, `git rev-parse HEAD`.
- Inline Python (no temporary files) to build the import graph, count lines, find zero-inbound files, find duplicate class/basename declarations, and map asset references.
- Targeted `grep`/file reads for each finding.
- `flutter analyze --no-pub` and `flutter test --no-pub`.

### 2.4 Confidence scale

- **HIGH** — directly visible in code/config with an unambiguous call chain.
- **MEDIUM** — visible code pattern whose production impact depends on data/state not exercised here.
- **LOW** — inference from naming/structure; needs runtime confirmation.

---

## 3. Project file inventory

### 3.1 Tracked-file breakdown

| Area | Count | Notes |
|---|---:|---|
| `lib/` Dart | 369 | 342 non-`part` libraries + 27 `part-of` files |
| `test/` Dart | 1 | default counter smoke test |
| `tool/` Dart | 3 | manual developer scripts |
| Assets | 28 | 16 referenced, 12 unreferenced (see §8.4) |
| Platform scaffolding | — | `android/`, `ios/`, `web/`, `windows/`, `linux/`, `macos/` |
| Config | — | `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, `firebase.json`, `firestore.rules`, `firestore.indexes.json`, `.metadata`, `.gitignore`, `README.md` |
| Tracked backups/plans | 43 | `opencode/backups/**`, `opencode/plans/**` |
| **Total tracked** | **592** | |

### 3.2 `lib/` layout by area

| Path prefix | Dart files |
|---|---:|
| `lib/features/tourist` | 140 |
| `lib/features/tour_guide` | 73 |
| `lib/core/data` | 58 |
| `lib/features/admin_dashboard` | 31 |
| `lib/core/widgets` | 17 |
| `lib/features/common` | 17 |
| `lib/features/chat` | 12 |
| `lib/core/services` | 4 |
| `lib/features/splash` | 4 |
| `lib/core/theme` | 3 |
| `lib/core/constants`, `lib/core/helper`, `lib/core/network` | 2 each |
| `lib/core/routing`, `lib/core/utils`, `lib/main.dart`, `lib/firebase_options.dart` | 1 each |

### 3.3 Entry points and backend surface

- App entry: `lib/main.dart:31` → Firebase init → dotenv load → `PaymobSettings.initialize()` → `runApp`.
- Startup routing: `lib/features/splash/view/startup_gate.dart:35-50` dispatches by role to tourist home, guide dashboard, admin login, or auth screens.
- Firebase project config: `lib/firebase_options.dart` (generated), `firebase.json:23-26` (Firestore only).
- **There is no `functions/` directory and `firebase.json` has no Functions configuration.** All Firestore writes and payment confirmation happen from the client.

### 3.4 Non-runtime repository clutter

- 43 tracked files under `opencode/backups/` and `opencode/plans/` (`.bak` Dart files, old rules, old index files).
- `firestore.rules.before-S1` is a stale tracked copy of the security rules.
- `tool/generate_report_pdf.dart` is stale: it still describes a duplicate `AppRoutes` in `d_app_routes.dart` that no longer exists (line 269).
- `devtools_options.yaml`, `firestore-debug.log`, `triply.iml`, `.idea`, `.vscode`, `build/` are local/IDE artifacts; `build/` and `firestore-debug.log` are not tracked.

---

## 4. Import graph and reachability

### 4.1 Method and reconciliation

The graph follows `import` statements (including `package:triply/...`) and `part` directives from `lib/main.dart`.

- 369 total `lib` Dart files.
- 324 ordinary libraries are reachable by `import`.
- 27 `part-of` files become reachable through the 27 `part` directives of their owners.
- **351 files reachable**, **18 files unreachable**.

The earlier apparent "324 reachable / 45 unreachable" figure counts all 27 `part-of` files as unreachable because they are not imported directly. They are in fact loaded through their owning library, so the accurate result is 351/18.

### 4.2 The 18 genuinely unreachable files

All 18 also have **zero inbound imports** and no dynamic reference.

| File | Lines | What it is | Confidence |
|---|---:|---|---|
| `lib/core/data/mock/dashboard/d_mock_guides.dart` | 87 | admin mock guide model + list | HIGH |
| `lib/core/data/mock/dashboard/d_mock_notifications.dart` | 132 | admin mock bookings/notifications/places | HIGH |
| `lib/core/data/mock/dashboard/d_mock_places.dart` | 129 | admin mock posts/trip applications | HIGH |
| `lib/core/data/mock/dashboard/d_mock_search.dart` | 61 | admin mock users | HIGH |
| `lib/core/data/mock/dashboard/d_mock_trips.dart` | 56 | admin mock trips | HIGH |
| `lib/core/data/mock/tourist/mock_community.dart` | 73 | community stories/posts fixtures | HIGH |
| `lib/core/data/mock/tourist/mock_guide_raw.dart` | 22 | raw guide fixtures | HIGH |
| `lib/core/data/repositories/admin_posts_repository.dart` | 190 | Firestore posts + hardcoded seed post | HIGH |
| `lib/core/data/seed/guide_seed.dart` | 136 | writes mock guide dataset into Firestore | HIGH |
| `lib/features/common/auth/views/tourist/forgot_password/view/new_password_screen.dart` | 122 | `confirmPasswordReset` screen | HIGH |
| `lib/features/common/auth/widgets/auth_header.dart` | 68 | unused auth header widget | HIGH |
| `lib/features/tour_guide/profile_tg/model/guide.dart` | 71 | guide-side duplicate model | HIGH |
| `lib/features/tour_guide/profile_tg/model/trip.dart` | 51 | guide-side duplicate model | HIGH |
| `lib/features/tour_guide/profile_tg/widgets/card_profile.dart` | 150 | unused profile card | HIGH |
| `lib/features/tour_guide/profile_tg/widgets/tour_card.dart` | 93 | unused tour card | HIGH |
| `lib/features/tourist/place_details/model/place.dart` | 75 | duplicate place model (the other place-details models are used) | HIGH |
| `lib/features/tourist/search/widget/app_filter_chip.dart` | 38 | unused filter chip | HIGH |
| `lib/features/tourist/user_profile/widget/profile_header.dart` | 99 | unused tourist header (guide header is used) | HIGH |

Total dead Dart: **1,653 lines**, about 3.1% of `lib/`.

### 4.3 Reachable-but-only-via-dead-route files

`AppRoutes.trips()` (`lib/core/routing/app_routes.dart:64`) has **no caller**. It is the only reference to:

- `lib/features/tourist/trips/view/trips_screen.dart`
- `lib/features/tourist/trips/cubit/trips_cubit.dart`
- `lib/features/tourist/trips/cubit/trips_state.dart`

Classification: **POSSIBLY_UNUSED** (reachable in the graph, unreachable in the running app). Confidence: **HIGH**. Note that `TripsCubit` here is a different library from `lib/features/admin_dashboard/d_trips/cubit/trips_cubit.dart`, which is live.

### 4.4 File classification summary

| Class | Count | Definition used here |
|---|---:|---|
| CONFIRMED_USED | 320 | Reachable non-generated libraries, invoked from a live route/screen |
| INDIRECTLY_USED | 27 | `part-of` files loaded by a reachable owner |
| POSSIBLY_UNUSED | 3 | Reachable only through `AppRoutes.trips()` |
| STRONG_UNUSED_CANDIDATE | 18 | Zero inbound imports and unreachable from `main.dart` |
| CONFIGURATION_OR_GENERATED | 1 | `lib/firebase_options.dart` |
| UNCERTAIN | 0 | — |
| **Total `lib` Dart** | **369** | |

Outside `lib/`: 1 `TEST_ONLY` file; 28 assets and 148 platform/config files as `CONFIGURATION_OR_GENERATED`; 43 tracked backup/plan files as repository clutter (`STRONG_UNUSED_CANDIDATE` for runtime); 3 `tool/` scripts as developer tooling (`UNCERTAIN`/manual-use).

---

## 5. Route and navigation reachability

### 5.1 Route builders

| Builder | Called? | Evidence |
|---|---|---|
| `splash`, `popular`, `tripDetails`, `booking`, `myTrips`, `guideDashboard`, `guideTrips`, `guideTripDetails`, `travelers`, `createTrip`, `editTrip`, `manageTrip`, `guideProfile`, `earnings`, `chatList`, `guideChats`, `chatRoom`, `chatWithGuide`, `bookingConfirmed`, `goToMyTrips` | Yes | calls across `main.dart`, home, trip details, guide screens, chat |
| `trips()` | **No** | no `AppRoutes.trips(` occurrence in `lib/` or `test/` |
| `backToTrip()` | **No** | defined at `app_routes.dart:257`, no caller |

### 5.2 Navigation nuances

- `GuideProfileScreen` is reached from four live places: `home_screen.dart:138`, `guides_list_screen.dart:71`, `place_details_view.dart:220`, and `trip_details_screen.dart:132`. The last one resolves the guide **by name against mock data** (see §10.2).
- `NotificationsScreen` is live via `AppRoutes.notifications` in `main.dart:67` and `home_screen.dart:369`.
- `SettingsScreen` and `MyPostsScreen` are live from `profile_screen.dart:108` and `:210`.
- `NewPasswordScreen` is never instantiated and no deep-link handler reads an `oobCode`; the forgot-password flow only sends the Firebase reset email (`forgot_password_screen.dart:38`, `auth_repository.dart:339`). The reset screen is dead.
- `GuidesListScreen` is live from `home_screen.dart:115`.
- `PopularTripsScreen` is live only through `AppRoutes.popular()`, which is called once.

---

## 6. Mock data inventory

All paths below are under `lib/core/data/mock/` unless noted. "Consumers" are direct importers; production reachability is analysed in §7.

| # | File | Key symbol(s) | Direct consumers | Class |
|---:|---|---|---|---|
| 1 | `tourist/mock_guides.dart` | `mockGuides`, `mockGuideLanguageFilters` | booking, guides, guide profile, home, place details, trip details | ACTIVE_RUNTIME_MOCK |
| 2 | `tourist/mock_guides1.dart` | `mockGuides1` | place details guide fallback | FALLBACK_MOCK |
| 3 | `tourist/mock_places.dart` | `mockPlaces` | booking, home, map, place details, search | ACTIVE_RUNTIME_MOCK |
| 4 | `tourist/mock_palces_raw.dart` | `mockPlacesRaw` | home display-image override | ACTIVE_RUNTIME_MOCK |
| 5 | `tourist/mock_place_trips.dart` | `mockPlaceTrips` | place-details trip fallback | FALLBACK_MOCK |
| 6 | `tourist/mock_stories.dart` | `mockStories` | place-details stories, always | ACTIVE_RUNTIME_MOCK |
| 7 | `tourist/mock_search.dart` | `mockRecentSearches`, `mockPopularSearches`, `mockPopularDestinations` | search, always | ACTIVE_RUNTIME_MOCK |
| 8 | `tourist/mock_profile.dart` | `mockProfileStats`, `mockLanguages`, `mockDefaultLanguage` | profile cubit, always | ACTIVE_RUNTIME_MOCK |
| 9 | `tourist/mock_emergency_contacts.dart` | `mockEmergencyContactsRaw` | profile cubit, always | ACTIVE_RUNTIME_MOCK |
| 10 | `tourist/mock_notifications.dart` | `mockNotificationsRaw` | tourist notifications repository | FALLBACK_MOCK |
| 11 | `tourist/mock_trip_details.dart` | `mockTripDetailsJson` | `TripDetailsSource` | FALLBACK_MOCK |
| 12 | `tourist/mock_trips.dart` | `mockTripsForGuide` | guide profile cubit | FALLBACK_MOCK |
| 13 | `tourist/mock_trips_public.dart` | `mockTripsJson` | my trips, place details, popular, (dead) trips cubit | FALLBACK_MOCK |
| 14 | `tourist/mock_trips_raw.dart` | `mockTripsRaw` | home trip fallback | FALLBACK_MOCK |
| 15 | `tourguide/mock_booking_details.dart` | `mockBookingDetailsRaw` | earnings/dashboard/notifications/travelers mocks, dashboard repository | FALLBACK_MOCK |
| 16 | `tourguide/mock_earnings.dart` | `mockEarningsJson` | dashboard repository | FALLBACK_MOCK |
| 17 | `tourguide/mock_guide_dashboard.dart` | `mockGuideDashboardRaw`, `mockBookingRequestsRaw` | dashboard cubit + repository | FALLBACK_MOCK |
| 18 | `tourguide/mock_guide_notifications.dart` | `mockGuideNotificationsRaw` | guide notifications repository, seed | FALLBACK_MOCK |
| 19 | `tourguide/mock_guide_profile.dart` | `mockGuideProfileJson`, `mockGuideId = 'g2'` | other tour-guide mocks | FALLBACK_MOCK |
| 20 | `tourguide/mock_guide_shared.dart` | date/currency helpers | other tour-guide mocks | FALLBACK_MOCK |
| 21 | `tourguide/mock_guide_trip_details.dart` | `mockGuideTripDetailsJson` | guide trip details source, repository, seed | FALLBACK_MOCK |
| 22 | `tourguide/mock_guide_trips.dart` | `mockGuideTripsJson` | guide trips store/repository, dashboard mocks, seed | FALLBACK_MOCK |
| 23 | `tourguide/mock_travelers.dart` | `mockTravelersJson` | dashboard repository | FALLBACK_MOCK |
| 24 | `dashboard/d_mock_guides.dart` | `MockGuide`, `mockGuides` | **none** | UNUSED_MOCK |
| 25 | `dashboard/d_mock_notifications.dart` | `MockBooking`, `MockNotification`, `mockPlaces` | **none** | UNUSED_MOCK |
| 26 | `dashboard/d_mock_places.dart` | `MockPost`, `MockTripApplication` | **none** | UNUSED_MOCK |
| 27 | `dashboard/d_mock_search.dart` | `MockUser`, `mockUsers` | **none** | UNUSED_MOCK |
| 28 | `dashboard/d_mock_trips.dart` | `MockTrip`, `mockTrips` | **none** | UNUSED_MOCK |
| 29 | `tourist/mock_community.dart` | `mockCommunityStories`, `mockCommunityPosts` | **none** | UNUSED_MOCK |
| 30 | `tourist/mock_guide_raw.dart` | `mockGuidesRaw` | **none** | UNUSED_MOCK |

Additional mock source outside `mock/`:

| File | Symbol | Consumer | Class |
|---|---|---|---|
| `lib/core/data/seed/guide_seed.dart` | `GuideSeed.run()` | **none** | DEBUG_OR_DEVELOPMENT_ONLY / STRONG_UNUSED_CANDIDATE |

### 6.1 Classification totals

| Class | Count |
|---|---:|
| ACTIVE_RUNTIME_MOCK | 7 |
| FALLBACK_MOCK | 16 |
| DEBUG_OR_DEVELOPMENT_ONLY | 1 (`guide_seed.dart`, also unreachable) |
| TEST_ONLY | 0 |
| UNUSED_MOCK | 7 |
| UNCERTAIN | 0 |
| **Total mock files** | **30 + 1 seed** |

---

## 7. Mock-data classification and runtime impact

### 7.1 ACTIVE_RUNTIME_MOCK (fake data on the happy path)

| Mock | Where it is forced into the UI | Evidence | Impact |
|---|---|---|---|
| `mock_places` | Home place row is assigned unconditionally; Search catalog; private-booking place picker; Map initial list | `home_cubit.dart:82`; `search_cubit.dart:11`; `booking_cubit.dart:43`; `map_cubit.dart:15` | Home and search never show Firestore places; new real places are invisible outside Map/Place Details |
| `mock_palces_raw` | Home card images override | `home_cubit.dart:148` | Display-only fake imagery |
| `mock_stories` | Place-details stories are assigned unconditionally | `place_detail_cubit.dart:72` | Story rings are always fake |
| `mock_search` | Recent/popular searches and destinations | `search_cubit.dart:14` | Fake search history and destinations |
| `mock_profile` | Languages, default language, profile stats | `profile_cubit.dart:70-77,87` | Fake stats/languages for real users |
| `mock_emergency_contacts` | Emergency contacts | `profile_cubit.dart:79-80` | Fake emergency contacts presented as user data |
| `mock_guides` | Booking guide lookup; trip-details guide navigation; list fallback | `booking_cubit.dart:59-64`; `trip_details_screen.dart:127-130`; `guides_cubit.dart:43` | Wrong-guide profile/booking; fake bookable guides |

### 7.2 FALLBACK_MOCK (fake data after a failed read)

Public repositories swallow errors and return `null`:

- `public_guides_repository.dart:30-32,42-44`
- `public_trips_repository.dart:38-40,58-60,68-70`
- `booking_repository.dart` returns `null` for failed booking reads (see `my_trips_cubit.dart:50-52`)

Cubits then substitute mocks:

| Fallback | Evidence |
|---|---|
| Guides list | `guides_cubit.dart:43,88` |
| Home guides/trips | `home_cubit.dart:85,91,164-186` |
| Guide profile guide + trips | `guide_profile_cubit.dart:84-93` |
| Guide profile trips on null | `guide_profile_cubit.dart:54-56` |
| Place details place/guides/trips | `place_detail_cubit.dart:64,68-80,254-266` |
| Popular trips | `popular_cubit.dart:44-45,72` |
| My Trips | `my_trips_cubit.dart:51-52,160-204` |
| Trip details | `trip_details_cubit.dart:38-47`; `trip_details_source.dart:16-51` |
| Tourist notifications | `tourist_notifications_repository.dart:45,57,100` |
| Guide notifications | `guide_notifications_repository.dart:51,63,70,80` |
| Guide dashboard counts/bookings | `dashboard_cubit.dart:118-141` |
| Guide booking details/travelers/earnings | `guide_dashboard_repository.dart:153,156,174,183,194,201,225` |
| Guide trips list | `guide_trips_repository.dart:60-62,102,109,119,357-364` |
| Guide session trips | `guide_trips_store.dart:35-38` |

**Runtime scenario:** a signed-in tourist opens Guides while offline or while a rules/index error occurs → sees `g1…gN` mock guides → opens one → `GuideProfileCubit` falls back to `mockGuides.first` (regardless of the tapped id) → taps "Book Private Guide" → the booking flow creates a real Firestore booking with a mock guide id and mock price. Confidence: **HIGH**.

### 7.3 Why the fallback is not safe

- The fallback is indistinguishable from real content: there is no "offline sample" banner.
- Some fallbacks are keyed incorrectly:
  - `GuideProfileCubit._mockGuide()` compares `g.id == ''` (`guide_profile_cubit.dart:85-88`), so it always returns `mockGuides.first`. The intended comparison is presumably `g.id == guideId`.
  - `_mockTrips()` always returns the first mock guide's trips (`guide_profile_cubit.dart:93`).
  - `TripDetailsSource.getByTripId` falls back to the first mock entry for unknown ids, mixing the real trip card with fake about/itinerary/meeting point (`trip_details_source.dart:26-50`).
- Guide dashboard counters can show mock totals before/without live metrics (`dashboard_cubit.dart:128-141`).

### 7.4 UNUSED_MOCK

The five `d_mock_*.dart` admin fixtures and `mock_community.dart` / `mock_guide_raw.dart` have no importers. `CommunityCubit` and admin user-post screens use Firestore repositories, not these fixtures. Confidence: **HIGH**.

---

## 8. Unused and possibly unused files

### 8.1 STRONG_UNUSED_CANDIDATE — 18 files

See the table in §4.2. Additional notes:

- `admin_posts_repository.dart` is a complete, otherwise-functional Firestore repository (`fetchPosts`, `watchPosts`, `createPost`, `deletePost`) plus `ensureInitialPostIfEmpty()` (`:124-153`) that writes a hardcoded tourist post with an Unsplash image. Because nothing imports the file, neither the repository nor the seed runs. Confidence: **HIGH**.
- `guide_seed.dart` would write the full mock guide dataset into Firestore for the signed-in guide (`:43-135`). It is unreachable from the app. If it is run manually from a developer console against production, it injects fake trips/notifications. Confidence: **HIGH** that it is not wired; **MEDIUM** on operational risk.
- `new_password_screen.dart` contains a working `confirmPasswordReset` call (`:40-41`) but is unreachable and there is no deep link. Confidence: **HIGH**.

### 8.2 POSSIBLY_UNUSED — 3 files

`trips_screen.dart`, `trips_cubit.dart`, `trips_state.dart`, only referenced by the uncalled `AppRoutes.trips()` (`app_routes.dart:64-69`).

### 8.3 Dead symbols inside used files

| Symbol | Evidence | Note |
|---|---|---|
| `BookingCubit.confirm()` | `booking_cubit.dart:165-182` | no caller |
| `BookingScreen._buildSuccess()` | `booking_screen.dart:474-530` | only reachable at `stepIndex == 3`, which only `confirm()` sets |
| `GuideTripsStore.allTrips()` | `guide_trips_store.dart:35-38` | no caller; the store's `add/update/delete/applyUpdates` are used |
| `AppRoutes.backToTrip()` | `app_routes.dart:257-260` | no caller |
| `AdminPostsRepository.ensureInitialPostIfEmpty()` | `admin_posts_repository.dart:124-153` | no caller (whole file unused) |

Confidence: **HIGH** for all.

### 8.4 Assets

- 28 tracked assets; 16 have a literal reference in Dart, **12 have none**:
  - `assets/images/nav_bar_icons/Bold/*.svg` (5)
  - `assets/images/nav_bar_icons/Linear/*.svg` (5)
  - `assets/images/svg/riply_text.svg`
  - (the two directories are declared in `pubspec.yaml:79-80` but no code references them)
- **One referenced asset is missing:** `AppAsset.defaultAvatar = 'assets/images/svg/default_avatar.svg'` (`app_asset.dart:10`) is used by `ProfileAvatar` (`profile_avatar.dart:32,51-62`), but the file does not exist. `Image.asset` falls through to the `errorBuilder` placeholder at runtime, so this is a broken/blank-avatar bug rather than a crash. Confidence: **HIGH** (static file check); **MEDIUM** on exact visual impact.

### 8.5 Non-runtime clutter

- 43 tracked files under `opencode/backups/**` and `opencode/plans/**`.
- `firestore.rules.before-S1` (stale rules copy).
- `tool/generate_report_pdf.dart` (stale PDF generator content).
- `tool/backfill_display_name.dart`, `tool/chat_rules_check.dart` (manual maintenance scripts; not part of the app build).

### 8.6 Test coverage

- Only `test/widget_test.dart`. It is the unmodified Flutter counter template and does not test Triply behavior. It both imports `MyApp` (which requires Firebase) and asserts `find.text('0')`. See §11.2.

---

## 9. Duplicate implementations

### 9.1 Duplicate top-level class names

Detected automatically across `lib/`:

| Class | Copies | Files |
|---|---:|---|
| `Guide` | 4 | `tourist/guides/model/guide.dart` (used), `tourist/home/model/guide.dart` (used), `tourist/place_details/model/guide.dart` (used), `tour_guide/profile_tg/model/guide.dart` (**unused**) |
| `Trip` | 5 | `tourist/guides/model/trip.dart`, `tourist/home/model/trip.dart`, `tourist/place_details/model/trip.dart`, `tourist/trips/models/trip.dart`, `tour_guide/profile_tg/model/trip.dart` (**unused**) |
| `Place` | 3 | `tourist/home/model/place.dart`, `tourist/map/model/place.dart`, `tourist/place_details/model/place.dart` (**unused**) |
| `GuideCard` | 3 | guides (165 lines), place details (142), trip details (167) |
| `TripCard` | 4 | guides (93), home (58), place details (185), trips (226) |
| `ProfileHeader` | 2 | tourist (**unused**), guide (used) |
| `EditProfileSheet` | 2 | tourist (435 lines), guide (324 lines) |
| `GuidesCubit` | 2 | admin (live), tourist (live) — same name, different domains |
| `TripsCubit` | 2 | admin (live), tourist (**only dead route**) — same name, different domains |
| `_EditProfileSheetState` | 2 | private state classes of the two sheets |
| `_StatItem` | 2 | guide profile screen + guide stats card |
| `_TripCardSkeleton` | 2 | two guide skeletons |

### 9.2 The `Guide`/`Trip`/`Place` fragmentation is a correctness risk, not just style

- `PublicGuide.pricePerHour` is documented as **EGP** (`public_guide.dart:19-20`), and `mock_guide_profile.dart:23` uses `3750` EGP.
- `mock_guides.dart` uses **USD-style** values (`85`, `75`, `65`) with `currency: '$'` (`mock_guides.dart:18-19`).
- `booking_screen.dart:192` labels the rate as `EGP`, while `booking_screen.dart:717` prefixes the total with `guide.currency` (`$`), and `PaymentView` always charges `currency: 'EGP'` (`payment_view.dart:79,122`).
- `PublicGuide.fromDocument` defaults `currency` to `'$'` (`public_guide.dart:57`), so a real guide document missing `currency` also inherits the wrong symbol.

This model fragmentation is the root enabler of the wrong-guide/wrong-price finding in §10.1. Confidence: **HIGH**.

### 9.3 Duplicate `EditProfileSheet`

The two sheets are near-identical in purpose and both contain their own `_uploadImage`:

- Tourist: `user_profile/widget/edit_profile_sheet.dart:163-178`
- Guide: `profile_tg/widgets/edit_profile_sheet.dart:88-105`

Both hardcode the same Cloudinary cloud name `yl49wcys` and preset `djowcnxm`, and both duplicate the multipart/JSON parsing. Confidence: **HIGH**.

### 9.4 Four Cloudinary upload paths

1. `lib/core/services/cloudinary_service.dart:9-51` (package `cloudinary_public`, account `gfhygmmz`, preset `triply_tour_guide_info`, guide-verification folder).
2. `lib/features/tourist/community/data/community_cloudinary_uploader.dart:12-41` (account `yl49wcys`, preset `djowcnxm`).
3. Tourist edit-profile inline upload (§9.3).
4. Guide edit-profile inline upload (§9.3).

Paths 2–4 share the same account/preset but implement the same HTTP request three times. Confidence: **HIGH**.

### 9.5 Other duplication/ambiguity

- `AppRoutes` and `AdminRoutes` live in one file (`app_routes.dart:33,266`); this is acceptable but the file mixes tourist, guide, chat, and admin routing.
- `GuideCard`/`TripCard` copies are feature-specific, but three of the six are only used by the dead `TripsScreen` or by unused place-details widgets. See §4.2 and §8.2.
- `mock_guides.dart` and `mock_guide_raw.dart` describe the same guide dataset in two shapes; the raw version is unused.

---

## 10. Hardcoded, placeholder, and fake data paths

### 10.1 Critical: private booking resolves to the wrong mock guide and the wrong currency

Chain:

1. `guide_profile_screen.dart:330` → `BookingScreen(guideId: _controller.guide.id)`.
   - After a successful Firestore read, `_controller.guide.id` is the **real guide uid** (`guide.dart:38-40` maps `id` from `PublicGuide.id`).
2. `booking_cubit.dart:59-64`:
   ```dart
   Guide get guide {
     return mockGuides.firstWhere(
       (g) => g.id == guideId,
       orElse: () => mockGuides.first,
     );
   }
   ```
   Mock ids are `g1…gN` (`mock_guides.dart:7,23,39…`), so a real uid never matches and `orElse` returns `mockGuides.first`.
3. `mock_guides.dart:7-19` — first entry is `Omar El-Rashidy`, `$85/hr`, currency `$`.
4. `booking_screen.dart:78,192,373,717,830-833` renders that mock guide's name, avatar/cover, `$` rate, and `EGP` label.
5. `booking_screen.dart:861-871` writes a **real** Firestore booking via `BookingRepository().createPrivateBooking` with:
   - `guideId: guideId` (real uid),
   - `guideName` / `title` from the mock guide (`booking_screen.dart:863-864`),
   - `totalPrice: _controller.total` computed from `85` (`price_calculator.dart:16-18`).
6. `PaymentView` charges `widget.price` as **EGP cents** (`payment_view.dart:65,79,122`).

Result: a tourist booking a real EGP-priced guide sees another person's name/photo, is charged `85 × hours × travelers × 1.05` **EGP** (roughly two orders of magnitude below a real EGP rate such as `3750/hr`), and the guide receives a booking whose title names a different guide. Confidence: **HIGH**.

Additional related issues in the same flow:

- `booking_screen.dart:867` hardcodes `paymentMethod: 'card'` before the user chooses Visa/wallet, so the booking's audit field can be wrong.
- `booking_screen.dart:901` and `booking_public_screen.dart:105` store `paymentId: bookingId` with the comment "test-only demo; no real money moves", even though real Paymob calls run.
- `BookingCubit`'s header comment says "Local mock state only — no backend" (`booking_cubit.dart:10-11`), which is false for this screen.

### 10.2 Trip-details guide navigation uses mock data

`trip_details_screen.dart:126-133`:

```dart
final guide = mockGuides.firstWhere(
  (g) => g.name == guideName,
  orElse: () => mockGuides.first,
);
Navigator.push(... GuideProfileScreen(guideId: guide.id));
```

A real trip whose `guideName` is not one of the mock names opens **Omar El-Rashidy's profile**. Even when the name matches, it opens a mock id (`g1…`) that has no Firestore guide document, so the profile falls back to mock data again. Confidence: **HIGH**.

### 10.3 Guide-profile fallback always shows the first mock guide

`guide_profile_cubit.dart:84-93`:

```dart
final found = mockGuides.firstWhere(
  (g) => g.id == '',       // never true for real non-empty ids
  orElse: () => mockGuides.first,
);
...
static List<Trip> _mockTrips() => mockTripsForGuide(mockGuides.first.id);
```

When the Firestore guide is absent/unreadable, every guide id opens the same guide and the same trips. Confidence: **HIGH**.

### 10.4 Session-only booking records presented as real

`my_bookings_public.dart:1-3` calls itself "Session-only record of confirmed bookings (mock phase, no backend)". It is written before/after real Firestore writes:

- `booking_public_cubit.dart:83` records before the Firestore booking is created.
- `booking_screen.dart:879-887` records the private booking after Firestore creation.
- `my_trips_cubit.dart:51-52` uses the session store as the fallback; `:187-203` synthesizes private "trips" from it.

These records survive navigation but not app restart. They can make My Trips show a booking that is absent from Firestore (or vice versa), and the profile "Trips" counter is driven by them (`profile_cubit.dart:76`). Confidence: **HIGH** for the mechanism; **MEDIUM** for user-visible inconsistency.

### 10.5 Hardcoded seed and placeholder data

| Location | What is hardcoded | Live? |
|---|---|---|
| `admin_posts_repository.dart:124-153` | A tourist post "Amazing day in Egypt! ✨" with an Unsplash URL, written if `posts` is empty | No (whole file unused) |
| `guide_seed.dart:43-135` | Full mock guide trips/details/notifications written to Firestore | No (unreachable) |
| `mock_search.dart` | Recent searches, popular destinations | Yes (always) |
| `mock_profile.dart` | Profile stats (`mockProfileStats`) and languages | Yes (always) |
| `mock_emergency_contacts.dart` | Emergency contacts | Yes (always) |
| `mock_places.dart` / `mock_palces_raw.dart` | Home/search/booking place catalog | Yes (always for home/search/booking) |
| `mock_stories.dart` | Place stories | Yes (always) |
| `profile_cubit.dart:76` | "Trips" count from the session store | Yes |
| `cloudinary_service.dart:10-11`, `community_cloudinary_uploader.dart:13-14`, both edit sheets | Cloudinary cloud names and unsigned presets | Yes (public by design; duplication is the issue) |

### 10.6 Placeholder behavior left in shipped screens

- Apple sign-in button is a no-op `TODO` (`sign_in_screen.dart:336-343`).
- Chat buttons on My Trips/Popular/Trips show placeholder toasts (`my_trips_screen.dart:236`, `popular_trips_screen.dart:130`, `trips_screen.dart:129`). The chat screens themselves exist and are live elsewhere, so these comments are stale.
- Earnings screen has a placeholder toast for a missing destination (`earnings_screen.dart:13`).
- Guide trip details/travelers have placeholder toasts for missing Figma destinations (`guide_trip_details_screen.dart:22`, `travelers_screen.dart:13`).

### 10.7 Security/config observations

- `.env` is declared as a Flutter asset: `pubspec.yaml:75`. `flutter_dotenv` reads it from the bundle (`main.dart:35`). Any secret placed in `.env` (including `PAYMOB_API_KEY`) is extractable from the built app. This is independent of `.gitignore:2`.
- `PaymobSettings._fallbackApiKey` etc. are empty strings (`paymob_settings.dart:24-26`), so no secret is committed in that file. Good.
- The app posts Paymob's authentication request from the client (`payment_view.dart:52-70`), which is where the API key is used. Without a backend, the key is necessarily client-side.
- Firestore rules allow a tourist to create a booking with arbitrary `totalPrice` (`firestore.rules:339-349`) and later self-confirm it with any non-empty `paymentId` (`firestore.rules:361-372`). There is no server-side Paymob verification. Confidence: **HIGH**.

---

## 11. Validation and static analysis

### 11.1 `flutter analyze --no-pub`

Result: **13 issues, all `info`; 0 errors, 0 warnings** (6.1 s). Exit code 1 is caused by info-level findings only.

| File:line | Lint | Finding |
|---|---|---|
| `lib/core/data/my_bookings_public.dart:88` | `library_private_types_in_public_api` | public `entryFor` returns private `_BookingEntry` |
| `lib/core/data/my_bookings_public.dart:96` | `library_private_types_in_public_api` | public `privateEntries` exposes private type |
| `lib/core/data/my_bookings_public.dart:100` | `library_private_types_in_public_api` | public `privateRecords` exposes private type |
| `lib/features/common/auth/views/tour_guide/tour_guide_verification_screen.dart:59` | `use_build_context_synchronously` | context used after await |
| `lib/features/common/role_selection/view/role_selection_screen.dart:148` | `unnecessary_underscores` (×2) | `__` parameter names |
| `lib/features/tour_guide/profile_tg/widgets/edit_profile_sheet.dart:6` | `depend_on_referenced_packages` | imports `package:http` not declared in `pubspec.yaml` |
| `lib/features/tourist/community/data/community_cloudinary_uploader.dart:3` | `depend_on_referenced_packages` | imports `package:http` not declared |
| `lib/features/tourist/user_profile/widget/edit_profile_sheet.dart:8` | `depend_on_referenced_packages` | imports `package:http` not declared |
| `lib/features/tourist/community/view/location_picker_view.dart:107` | `unnecessary_underscores` | `__` parameter name |
| `lib/features/tourist/community/view/location_picker_view.dart:128` | `unnecessary_underscores` | `__` parameter name |
| `lib/features/tourist/my_trips/view/my_trips_screen.dart:74` | `use_build_context_synchronously` | unrelated `mounted` guard |
| `lib/features/tourist/my_trips/view/my_trips_screen.dart:77` | `use_build_context_synchronously` | unrelated `mounted` guard |

The undeclared `http` dependency is real: three files import it, and `pubspec.yaml` does not list it. The app currently resolves it transitively (likely through another package), which is fragile. Confidence: **HIGH**.

### 11.2 `flutter test --no-pub`

Result: **1 test, 1 failure** in 0.00 s.

- `test/widget_test.dart` is the untouched Flutter counter template (`:14-29`).
- It pumps `const MyApp()` (`:16`), but `MyApp` builds `AuthCubit` and `StartupCubit`, which read `FirebaseAuth`/`FirebaseFirestore`.
- Failure 1: `[core/no-app] No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()`.
- Failure 2: `Found 0 widgets with text "0"` (`widget_test.dart:19`), because the app never renders a counter.

There are no widget tests for Triply flows, no unit tests for `PriceCalculator`/`BookingRepository`, and no integration tests. Confidence: **HIGH**.

### 11.3 Not run

- `flutter build apk/web` — would create build artifacts and is not needed for a read-only audit.
- Firebase emulator/rules tests — no test harness exists in the repository.
- Runtime UI walkthrough — see §2.2.

---

## 12. Critical findings and recommendations

Priorities: **P0** = wrong money/identity or security; **P1** = fake data or broken live flow; **P2** = maintainability/hygiene.

### 12.1 P0 findings

| ID | Finding | Evidence | Impact | Recommendation | Confidence |
|---|---|---|---|---|---|
| P0-1 | Private booking uses a mock guide and treats `$` as EGP | `guide_profile_screen.dart:330`; `booking_cubit.dart:59-64`; `mock_guides.dart:7-19`; `booking_screen.dart:192,717,830-871`; `price_calculator.dart:16-18`; `payment_view.dart:65,79` | Wrong guide name/photo, wrong price, real Firestore booking with wrong amount | Resolve the guide by real uid from Firestore (or pass the full guide model into the flow); store money in integer minor units with an explicit currency; never fall back to `mockGuides.first` for a booking | HIGH |
| P0-2 | Payment success is self-asserted, not verified | `booking_screen.dart:901`; `booking_public_screen.dart:105`; `firestore.rules:339-372`; no `functions/` | A tourist can confirm their own booking as paid with any non-empty `paymentId`; revenue cannot be trusted | Verify Paymob transactions server-side (Cloud Function/webhook), store the real transaction id, and make `status/paymentStatus` writable only by the verifier | HIGH |
| P0-3 | Paymob secret key is bundled in the client | `pubspec.yaml:75`; `paymob_settings.dart:24-42`; `payment_view.dart:52-70` | API key can be extracted from the app and abused | Move Paymob auth/order/payment-key creation to a backend; remove `.env` from Flutter assets; ship only public identifiers | HIGH |

### 12.2 P1 findings

| ID | Finding | Evidence | Impact | Recommendation | Confidence |
|---|---|---|---|---|---|
| P1-1 | Mock data is forced on normal paths | `home_cubit.dart:82`; `search_cubit.dart:11,14`; `place_detail_cubit.dart:72`; `profile_cubit.dart:70-80`; `booking_cubit.dart:43` | Users see fake places, stories, search history, stats, emergency contacts, and booking places even when online | Make these reads Firestore-backed, or mark them explicitly as sample/empty states | HIGH |
| P1-2 | Failed reads silently become fake bookable data | `public_guides_repository.dart:30-32,42-44`; `public_trips_repository.dart:38-40,58-60`; `guides_cubit.dart:43`; `guide_profile_cubit.dart:84-93`; `popular_cubit.dart:45`; `my_trips_cubit.dart:51-52`; `guide_trips_repository.dart:60-62,102,109,119` | Offline/rules failure shows fake guides and trips that can be booked | Return an explicit error/empty state; gate mocks behind `kDebugMode` or a build flag; never use mock ids in write paths | HIGH |
| P1-3 | Offline guide profile always shows the first mock guide | `guide_profile_cubit.dart:85,93` | Every guide id opens Omar El-Rashidy and his trips | Match on `guideId`; return a not-found state instead of `mockGuides.first` | HIGH |
| P1-4 | Trip-details guide link resolves by mock name | `trip_details_screen.dart:126-133` | Real trip opens a mock guide profile | Carry the real guide uid on the trip model and navigate by uid | HIGH |
| P1-5 | Private-booking success UI is dead | `booking_cubit.dart:165`; `booking_screen.dart:53,474-530` | The "Booking Confirmed!" step can never render; dead code misleads maintainers | Remove the dead step or wire it to the real post-payment result | HIGH |
| P1-6 | Booking/payment method and transaction id are inaccurate | `booking_screen.dart:867,901`; `booking_public_screen.dart:105` | Audit trail says `card` even for wallet; `paymentId` is not a Paymob id | Pass the chosen method and the real Paymob transaction id through to the repository | HIGH |
| P1-7 | Session-only booking records can diverge from Firestore | `my_bookings_public.dart:1-3`; `booking_public_cubit.dart:83`; `booking_screen.dart:879-887`; `my_trips_cubit.dart:51-52,160-204`; `profile_cubit.dart:76` | My Trips/Profile can show a booking that does not exist after restart, or hide one | Use Firestore as the single source of truth; keep the session store only as an optimistic cache with reconciliation | MEDIUM |

### 12.3 P2 findings

| ID | Finding | Evidence | Recommendation | Confidence |
|---|---|---|---|---|
| P2-1 | 18 unreachable files, 1,653 lines | §4.2 | Remove or move to a `samples/` area; start with the 7 unused mocks and `guide_seed.dart` | HIGH |
| P2-2 | 3 files only reachable through dead `AppRoutes.trips()` | `app_routes.dart:64-69`; §8.2 | Delete the dead route + `trips_screen.dart`, `trips_cubit.dart`, `trips_state.dart`, or wire the route | HIGH |
| P2-3 | 4 `Guide`, 5 `Trip`, 3 `Place` models | §9.1 | Consolidate around the Firestore `PublicGuide`/`PublicTrip` models; delete unused copies | HIGH |
| P2-4 | Two `EditProfileSheet` and four Cloudinary upload paths | §9.3–9.4 | Extract one profile editor + one upload service; keep account/preset in one config | HIGH |
| P2-5 | 12 unreferenced assets and 1 missing asset | §8.4 | Delete unused nav SVGs/`riply_text.svg`; add `default_avatar.svg` or point `AppAsset.defaultAvatar` at an existing file | HIGH |
| P2-6 | Stale default test fails | `test/widget_test.dart:14-29` | Replace with meaningful tests that initialize Firebase (or inject fakes) | HIGH |
| P2-7 | 5 unused declared dependencies + 1 undeclared dependency | `pubspec.yaml:16,23,40,41,48`; `http` imports in 3 files | Remove `google_maps_flutter`, `firebase_storage`, `lucide_icons_flutter`, `iconsax_flutter`, `pay_with_paymob`; add `http` explicitly | HIGH |
| P2-8 | 43 tracked backup/plan files + stale rules copy | `opencode/backups/**`, `opencode/plans/**`, `firestore.rules.before-S1` | Untrack/move to an external archive; keep one rules file | HIGH |
| P2-9 | 13 analyzer infos | §11.1 | Fix `use_build_context_synchronously`, expose a public booking-entry type, clean underscores, declare `http` | HIGH |
| P2-10 | Global mutation of session data | `guide_trips_store.dart` static lists; `my_bookings_public.dart` static maps; `trip_details_cubit.dart:22` static favorites | Move to instance-scoped repositories or injectable stores; add reset hooks for tests | MEDIUM |

### 12.4 Suggested order of work (not executed)

1. **Stop the money/identity defect:** P0-1 first (guide lookup + currency + amount), then P0-2/P0-3 with a backend verifier.
2. **Remove fake-data write paths:** P1-2/P1-3/P1-4; make mocks debug-only.
3. **Wire or delete dead flows:** P1-5, P2-2.
4. **Clean the tree:** P2-1/P2-3/P2-4/P2-5/P2-7/P2-8.
5. **Add validation:** real widget/unit tests for `PriceCalculator`, booking creation, and payment confirmation; CI running `flutter analyze` and `flutter test`.

---

## Appendix A — Classification reference

| Class | Meaning in this report |
|---|---|
| CONFIRMED_USED | Reachable from `lib/main.dart` and invoked by a live route/screen |
| INDIRECTLY_USED | `part-of` file loaded through a reachable owner library |
| TEST_ONLY | Used only by `test/` |
| CONFIGURATION_OR_GENERATED | Build/config/generated/platform/asset file, not app logic |
| POSSIBLY_UNUSED | Reachable but only through an uncalled route/builder |
| STRONG_UNUSED_CANDIDATE | Zero inbound imports and unreachable from `lib/main.dart` |
| UNCERTAIN | Insufficient static evidence; needs runtime or owner confirmation |
| ACTIVE_RUNTIME_MOCK | Mock data shown on a normal/happy path |
| FALLBACK_MOCK | Mock data substituted after a null/failed read |
| DEBUG_OR_DEVELOPMENT_ONLY | Tool/seed code not shipped in the app runtime |
| TEST_ONLY (mock) | Mock used only by tests (none found) |
| UNUSED_MOCK | Mock file with no importer |
| UNCERTAIN (mock) | Cannot determine reachability statically |

## Appendix B — Read-only commands used

- `git status --short`, `git rev-parse HEAD`, `git branch --show-current`, `git diff --stat`, `git ls-files`
- Inline Python: import graph, line counts, duplicate classes/basenames, mock importers, asset references
- `flutter analyze --no-pub`
- `flutter test --no-pub`
- Targeted `grep`/file reads of the paths cited above

No app source, configuration, dependency, rules, or test file was modified. The only file created by this audit is `docs/PROJECT_FILE_AUDIT.md`.
