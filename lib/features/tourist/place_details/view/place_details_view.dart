import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/place_detail_cubit.dart';
import '../cubit/place_detail_state.dart';
import '../cubit/place_guides_cubit.dart';
import '../cubit/place_guides_state.dart';
import '../cubit/place_stories_cubit.dart';
import '../cubit/place_stories_state.dart';
import '../cubit/place_trips_cubit.dart';
import '../cubit/place_trips_state.dart';
import '../data/place_resolver.dart';

import 'package:triply/core/theme/app_colors.dart';
import 'package:triply/core/routing/app_routes.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/app_theme_dark.dart';
import '../../../../core/widgets/circle_back_button.dart';
import '../../../../core/widgets/network_image_fallback.dart';
import '../../map/model/place.dart';
import '../../guides/view/guide_profile_screen.dart';
import '../model/guide.dart';
import '../model/story.dart';
import '../model/trip.dart';
import '../widget/about_tab.dart';
import '../widget/guides_tab.dart';
import '../widget/stories_tab.dart';
import '../widget/trips_tab.dart';

class PlaceDetailScreen extends StatefulWidget {
  final String placeId;

  const PlaceDetailScreen({super.key, required this.placeId});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  static const List<String> tabs = ['About', 'Guides', 'Trips', 'Stories'];

  late final PlaceResolver _resolver;
  late final PlaceInfoCubit _infoCubit;
  late final PlaceGuidesCubit _guidesCubit;
  late final PlaceTripsCubit _tripsCubit;
  late final PlaceStoriesCubit _storiesCubit;

  /// Tab selection is pure UI state and stays in the View.
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _resolver = PlaceResolver(placeId: widget.placeId);
    _infoCubit = PlaceInfoCubit(placeId: widget.placeId, resolver: _resolver);
    _guidesCubit = PlaceGuidesCubit(resolver: _resolver);
    _tripsCubit = PlaceTripsCubit(resolver: _resolver);
    _storiesCubit = PlaceStoriesCubit(resolver: _resolver);
  }

  @override
  void dispose() {
    _infoCubit.close();
    _guidesCubit.close();
    _tripsCubit.close();
    _storiesCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _infoCubit),
        BlocProvider.value(value: _guidesCubit),
        BlocProvider.value(value: _tripsCubit),
        BlocProvider.value(value: _storiesCubit),
      ],
      child: BlocBuilder<PlaceInfoCubit, PlaceInfoState>(
        builder: (context, infoState) {
          return BlocBuilder<PlaceGuidesCubit, PlaceGuidesState>(
            builder: (context, guidesState) {
              return BlocBuilder<PlaceTripsCubit, PlaceTripsState>(
                builder: (context, tripsState) {
                  return BlocBuilder<PlaceStoriesCubit, PlaceStoriesState>(
                    builder: (context, storiesState) {
                      return _buildForState(
                        context,
                        infoState,
                        guidesState,
                        tripsState,
                        storiesState,
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildForState(
    BuildContext context,
    PlaceInfoState infoState,
    PlaceGuidesState guidesState,
    PlaceTripsState tripsState,
    PlaceStoriesState storiesState,
  ) {
    final allLoaded =
        infoState is PlaceInfoSuccess &&
        guidesState is PlaceGuidesSuccess &&
        tripsState is PlaceTripsSuccess &&
        storiesState is PlaceStoriesSuccess;

    if (!allLoaded) {
      final errors = [
        if (infoState is PlaceInfoError) infoState.error,
        if (guidesState is PlaceGuidesError) guidesState.error,
        if (tripsState is PlaceTripsError) tripsState.error,
        if (storiesState is PlaceStoriesError) storiesState.error,
      ];
      final error = errors.isEmpty ? null : errors.first;
      if (error != null) {
        return _buildError(
          error,
          infoState,
          guidesState,
          tripsState,
          storiesState,
        );
      }
      return Scaffold(
        backgroundColor: AppThemeColors.resolve(
          context,
          light: Colors.white,
          dark: AppThemeDark.backgroundPrimary,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return _buildSuccess(
      context,
      infoState.place,
      guidesState.guides,
      tripsState.trips,
      storiesState.stories,
    );
  }

  /// The existing screen, unchanged — now fed by the four independent states.
  Widget _buildSuccess(
    BuildContext context,
    Place place,
    List<Guide> guides,
    List<Trip> trips,
    List<Story> stories,
  ) {
    return Scaffold(
      backgroundColor: AppThemeColors.resolve(
        context,
        light: Colors.white,
        dark: AppThemeDark.backgroundPrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                NetworkImageFallback(
                  imageUrl: place.imageUrl,
                  width: double.infinity,
                  height: 320,
                  fit: BoxFit.cover,
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleBackButton(
                          backgroundColor: AppThemeColors.resolve(
                            context,
                            light: Colors.white,
                            dark: AppThemeDark.surfaceElevated,
                          ),
                          iconColor: AppThemeColors.resolve(
                            context,
                            light: Colors.black,
                            dark: AppThemeDark.iconPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Transform.translate(
              offset: const Offset(0, -28),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                decoration: BoxDecoration(
                  color: AppThemeColors.resolve(
                    context,
                    light: Colors.white,
                    dark: AppThemeDark.backgroundPrimary,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                        color: AppThemeColors.resolve(
                          context,
                          light: AppColors.titleDark,
                          dark: AppThemeDark.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppColors.accentOrange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${place.city}  ·  ${place.category}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppThemeColors.resolve(
                              context,
                              light: AppColors.textGrey,
                              dark: AppThemeDark.textSecondary,
                            ),
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 15,
                          color: AppColors.starGold,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          place.rating.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0,
                          ),
                        ),
                        Text(
                          ' (${place.reviewsCount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')} reviews)',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                            color: AppThemeColors.resolve(
                              context,
                              light: AppColors.textGrey,
                              dark: AppThemeDark.textSecondary,
                            ),
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      place.shortDescription,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        letterSpacing: 0,
                        height: 2,
                        color: AppThemeColors.resolve(
                          context,
                          light: const Color(0xFF526B72),
                          dark: AppThemeDark.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(tabs.length, (i) {
                          final selected = _selectedTabIndex == i;
                          return Padding(
                            padding: EdgeInsets.only(
                              right: i == tabs.length - 1 ? 0 : 8,
                            ),
                            child: ChoiceChip(
                              label: Text(tabs[i]),
                              selected: selected,
                              onSelected: (_) =>
                                  setState(() => _selectedTabIndex = i),
                              selectedColor: AppColors.primaryTeal,
                              backgroundColor: AppThemeColors.resolve(
                                context,
                                light: AppColors.chipGrey,
                                dark: AppThemeDark.surfaceElevated,
                              ),
                              labelStyle: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : AppThemeColors.resolve(
                                        context,
                                        light: AppColors.chipTextGrey,
                                        dark: AppThemeDark.textSecondary,
                                      ),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                letterSpacing: 0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide.none,
                              ),
                              showCheckmark: false,
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_selectedTabIndex == 0)
                      AboutTab(place: place)
                    else if (_selectedTabIndex == 1)
                      GuidesTab(
                        guides: guides,
                        onGuideTap: (guide) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  GuideProfileScreen(guideId: guide.id),
                            ),
                          );
                        },
                      )
                    else if (_selectedTabIndex == 2)
                      TripsTab(
                        trips: trips,
                        onViewDetails: (trip) {
                          Navigator.of(context).push(
                            AppRoutes.tripDetails(
                              context.read<PlaceTripsCubit>().publicTripFor(
                                trip,
                              ),
                            ),
                          );
                        },
                        onChat: (_) {},
                      )
                    else
                      StoriesTab(
                        stories: stories,
                        // Placeholder: no Story-detail in Figma.
                        onStoryTap: (_) {},
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Any section can fail on its own; only the failed sections are retried.
  Widget _buildError(
    String error,
    PlaceInfoState infoState,
    PlaceGuidesState guidesState,
    PlaceTripsState tripsState,
    PlaceStoriesState storiesState,
  ) {
    return Scaffold(
      backgroundColor: AppThemeColors.resolve(
        context,
        light: Colors.white,
        dark: AppThemeDark.backgroundPrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_off_outlined,
                size: 48,
                color: AppThemeColors.resolve(
                  context,
                  light: Colors.grey,
                  dark: AppThemeDark.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppThemeColors.resolve(
                    context,
                    light: Colors.black87,
                    dark: AppThemeDark.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  if (infoState is PlaceInfoError) _infoCubit.retry();
                  if (guidesState is PlaceGuidesError) _guidesCubit.retry();
                  if (tripsState is PlaceTripsError) _tripsCubit.retry();
                  if (storiesState is PlaceStoriesError) {
                    _storiesCubit.retry();
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
