# Triply MVCW Refactor Plan (corrected vs checkout `feature/Amr-pages`)

Baseline: `flutter analyze` = 6 infos, 0 errors (file_names + unnecessary_underscores + use_super_parameters + unnecessary_string_interpolations).
Branch state: `lib/core/widgets/` empty, `lib/features/community/widget/` empty, `lib/features/map/widget/` has 1 dead file.

## 0. Ground truth (verified in tree)

- `lib/main.dart:4` imports `features/map/view/map_view.dart`, class `MapScreen`. There is no `map_screen.dart` to copy/delete.
- `lib/features/map/view/map_view.dart:119-190` inlines search TextField + filter chips; `lib/features/map/widget/map_search_field.dart:9-21` defines unused `SearchBoxWidget` + `DummyController` + local `AppColors` — dead code, must be rewritten not moved.
- `lib/features/map/view/map_view.dart:239-274` and `lib/features/community/view/community_screen.dart:203-237` each inline a `BottomNavigationBar` (the "two identical nav blocks").
- `lib/features/community/view/new_share_screen.dart:5` imports `package:triply/features/community/view/location_picker_screen.dart` but disk file is `Location_picker_screen.dart` (capital L). Works on Windows, breaks on case-sensitive CI. Not `views/community/...` as in original Step 3.
- Place-detail split: `lib/features/map/view/place_detail_screen.dart` + `lib/features/map/controller/place_detail_controller.dart` + `lib/views/place_detail/tabs/` (3: guides, stories, trips) + `lib/views/place_detail/widgets/` (4: about_tab, guide_card, story_card, trip_card) = 7 widget files.
- Step-1 "§2 / 8 core widgets spec" is not in this session context — specs must be derived from duplicates before creating files.

## 1. Step 1 — 8 core widgets (blocks everything else)

Create in `lib/core/widgets/` from duplicates found in tree (nav ×2 in map_view/community_screen, `_CircleButton` in place_detail_screen, back chevron in composer/picker, star pills in map_view/place-detail, cream `0xFFF7F0DF` chips in community/composer, `Image.network/errorBuilder` fallbacks, delete `AlertDialog`s in post_card/story-viewer, Share `ElevatedButton` in composer):

`app_bottom_nav.dart`, `circle_icon_button.dart`, `app_header.dart`, `rating_badge.dart`, `location_tag_chip.dart`, `network_image_fallback.dart`, `confirm_delete_dialog.dart`, `primary_button.dart`.

Do not wire into screens yet. `flutter analyze` per file before merge.

## 2. Step 2 — Map track (`refactor/map-mvcw`)

- `map_view.dart` already exists — do NOT copy from `map_screen.dart`.
- Rewrite `map_search_field.dart` as controlled widget (`controller`, `onChanged`, `onSubmitted`, `onClear`), delete `DummyController`/local `AppColors`.
- Create `map_filter_chips.dart`, `map_place_marker.dart`, `place_preview_card.dart`; replace `map_view.dart:119-190`, `map_view.dart:48-66`, `map_view.dart:279-416` with imports + calls.
- No `map_screen.dart` to delete; `main.dart` import already correct.

## 3. Step 3 — Community track (`refactor/community-mvcw`, biggest)

- Rename in place first (fixes capital-L): `community_screen.dart → community_view.dart`, `new_share_screen.dart → share_composer_view.dart`, `story_viewer_screen.dart → story_viewer_view.dart`, `Location_picker_screen.dart → location_picker_view.dart`.
- Fix composer import FIRST: `new_share_screen.dart:5` package import → relative `location_picker_view.dart`.
- Extract 14 widgets in order: story_ring → my_story_bubble → post_images → post_card → share_segment_tabs, media_picker_box, selected_image_preview, selected_images_grid, post_text_field, location_row → story_progress_bars, story_viewer_header → location_category_chip, location_place_row. Analyze after each.

## 4. Step 4 — Place-details track (`refactor/place-details-mvcw`)

- Create `lib/features/place_details/{view,widget,controller,model}/`.
- `git mv`: `features/map/view/place_detail_screen.dart → place_details/view/place_details_view.dart`; 7 files from `views/place_detail/{tabs,widgets}/` → `place_details/widget/`; `features/map/controller/place_detail_controller.dart → place_details/controller/`.
- Fix `../../../` depth changes; update navigators (`map_view.dart:41-45` + grep for other `PlaceDetailScreen` imports). Delete `lib/views/place_detail/`.

## 5. Step 5 — Swap to core (each track, after Step 1 merges, separate commits)

Both navs → AppBottomNav; `_CircleButton`/back chevrons → CircleIconButton; composer+picker headers → AppHeader; star pills → RatingBadge; cream chips → LocationTagChip; image+fallback → NetworkImageFallback; delete dialogs → ConfirmDeleteDialog; Share button → PrimaryButton. Never mix swap + move in one commit.

## 6. Final verify

`flutter analyze` → zero new issues vs 6-info baseline. Smoke: Map → card → Details tabs → back → Community → composer → viewer → picker.
Merge order: core → map → place-details → community (largest last), then delete refactor branches.
