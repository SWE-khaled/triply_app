import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/features/tourist/place_details/view/place_details_view.dart';
import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';
import '../../../../core/theme/app_colors.dart';
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
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  const CircleBackButton(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: textController,
                      onChanged: controller.setQuery,
                      onSubmitted: controller.submit,
                      decoration: InputDecoration(
                        hintText: 'Search places, guides, trips...',
                        hintStyle: const TextStyle(
                            fontSize: 14, color: AppColors.textGrey),
                        prefixIcon:
                            const Icon(Icons.search, color: AppColors.textDark),
                        suffixIcon: controller.query.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  textController.clear();
                                  controller.clearQuery();
                                },
                                icon: const Icon(Icons.cancel,
                                    size: 18, color: AppColors.textGrey),
                              )
                            : null,
                        filled: true,
                        fillColor: AppColors.inputFill,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
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
            const SizedBox(height: 6,),
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
          Text('Results (${controller.results.length})',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.guidesName)),
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
            const Text('Recent Searches',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.guidesName)),
            GestureDetector(
              onTap: controller.clearRecents,
              child: const Text('Clear all',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentOrange)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final r in controller.recentSearches)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time,
                    size: 18, color: AppColors.textGrey),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      textController.text = r;
                      controller.submit(r);
                    },
                    child: Text(r,
                        style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.primaryTeal)),
                  ),
                ),
                GestureDetector(
                  onTap: () => controller.removeRecent(r),
                  child: const Icon(Icons.close,
                      size: 16, color: AppColors.textGrey),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        const Text('Popular Searches',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.guidesName)),
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
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(place.name, style: const TextStyle(fontSize: 13)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Popular Destinations',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.guidesName)),
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
