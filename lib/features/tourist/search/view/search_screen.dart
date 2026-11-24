import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/features/tourist/place_details/view/place_details_view.dart';
import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/app_theme_dark.dart';
import '../../../../core/widgets/circle_back_button.dart';
import '../widget/destination_row.dart';
import '../widget/empty_state.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final SearchCubit controller;
  late final TextEditingController textController;

  @override
  void initState() {
    super.initState();
    // Owned here (like the old controller) so the body below keeps working
    // unchanged; provided below for BlocBuilder rebuilds.
    controller = SearchCubit();
    textController = TextEditingController();
  }

  @override
  void dispose() {
    controller.close();
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: controller,
      child: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, _) {
          return Scaffold(
            backgroundColor: AppThemeColors.resolve(
              context,
              light: Colors.white,
              dark: AppThemeDark.backgroundPrimary,
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      children: [
                        CircleBackButton(
                          backgroundColor: AppThemeColors.resolve(
                            context,
                            light: Colors.white,
                            dark: AppThemeDark.surfaceDefault,
                          ),
                          iconColor: AppThemeColors.resolve(
                            context,
                            light: Colors.black,
                            dark: AppThemeDark.iconPrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: textController,
                            onChanged: controller.setQuery,
                            onSubmitted: controller.submit,
                            decoration: InputDecoration(
                              hintText: 'Search places, guides, trips...',
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: AppThemeColors.resolve(
                                  context,
                                  light: AppColors.textGrey,
                                  dark: AppThemeDark.textDisabled,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: AppThemeColors.resolve(
                                  context,
                                  light: AppColors.textDark,
                                  dark: AppThemeDark.textSecondary,
                                ),
                              ),
                              suffixIcon: controller.query.isNotEmpty
                                  ? IconButton(
                                      onPressed: () {
                                        textController.clear();
                                        controller.clearQuery();
                                      },
                                      icon: Icon(
                                        Icons.cancel,
                                        size: 18,
                                        color: AppThemeColors.resolve(
                                          context,
                                          light: AppColors.textGrey,
                                          dark: AppThemeDark.textSecondary,
                                        ),
                                      ),
                                    )
                                  : null,
                              filled: true,
                              fillColor: AppThemeColors.resolve(
                                context,
                                light: AppColors.inputFill,
                                dark: AppThemeDark.surfaceDefault,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: _buildBody(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (controller.showEmptyState) {
      return const EmptyState(
        title: 'No results found',
        subtitle: 'Try a different keyword or filter',
      );
    }
    if (!controller.showDefaultContent) {
      // SearchResult state: matches found.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Results (${controller.results.length})',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppThemeColors.resolve(
                context,
                light: AppColors.guidesName,
                dark: AppThemeDark.homeSectionTitle,
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (final place in controller.results)
            DestinationRow(
              title: place.name,
              subtitle: '${place.city} · ${place.category}',
              imageUrl: place.imageUrl,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PlaceDetailScreen(placeId: place.id),
                  ),
                );
              },
            ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Searches',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppThemeColors.resolve(
                  context,
                  light: AppColors.guidesName,
                  dark: AppThemeDark.homeSectionTitle,
                ),
              ),
            ),
            GestureDetector(
              onTap: controller.clearRecents,
              child: Text(
                'Clear all',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppThemeColors.resolve(
                    context,
                    light: AppColors.accentOrange,
                    dark: AppThemeDark.homeGuidePrice,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final r in controller.recentSearches)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppThemeColors.resolve(
                context,
                light: const Color(0xFFF7F7F7),
                dark: AppThemeDark.homeGuideSurface,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 18,
                  color: AppThemeColors.resolve(
                    context,
                    light: AppColors.textGrey,
                    dark: AppThemeDark.homeGuideSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      textController.text = r;
                      controller.submit(r);
                    },
                    child: Text(
                      r,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppThemeColors.resolve(
                          context,
                          light: AppColors.primaryTeal,
                          dark: AppThemeDark.homeGuideName,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => controller.removeRecent(r),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: AppThemeColors.resolve(
                      context,
                      light: AppColors.textGrey,
                      dark: AppThemeDark.homeGuideSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        Text(
          'Popular Searches',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppThemeColors.resolve(
              context,
              light: AppColors.guidesName,
              dark: AppThemeDark.homeSectionTitle,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final place in controller.popularSearches)
              GestureDetector(
                onTap: () {
                  textController.text = place.name;
                  controller.submit(place.name);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppThemeColors.resolve(
                      context,
                      light: Colors.transparent,
                      dark: AppThemeDark.surfaceDefault,
                    ),
                    border: Border.all(
                      color: AppThemeColors.resolve(
                        context,
                        light: const Color(0xFFE0E0E0),
                        dark: AppThemeDark.borderSubtle,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    place.name,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppThemeColors.resolve(
                        context,
                        light:
                            Theme.of(context).textTheme.bodyMedium?.color ??
                            Colors.black87,
                        dark: AppThemeDark.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Popular Destinations',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppThemeColors.resolve(
              context,
              light: AppColors.guidesName,
              dark: AppThemeDark.homeSectionTitle,
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final place in controller.popularDestinations)
          DestinationRow(
            title: place.name,
            subtitle: '${place.city} · ${place.category}',
            imageUrl: place.imageUrl,
            onTap: () {
              textController.text = place.name;
              controller.submit(place.name);
            },
          ),
      ],
    );
  }
}
