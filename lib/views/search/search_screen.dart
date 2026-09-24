import 'package:flutter/material.dart';
import '../../controllers/search_controller.dart' as c;
import '../../models/search_filter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_filter_chip.dart';
import '../../core/widgets/circle_back_button.dart';
import '../../core/widgets/destination_row.dart';
import '../../core/widgets/empty_state.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final c.SearchController controller;
  late final TextEditingController textController;

  @override
  void initState() {
    super.initState();
    controller = c.SearchController();
    textController = TextEditingController();
    controller.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    controller.removeListener(_refresh);
    controller.dispose();
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  for (final f in SearchFilter.values)
                    AppFilterChip(
                      label: f.label,
                      selected: controller.activeFilter == f,
                      onSelected: () => controller.setFilter(f),
                    ),
                ],
              ),
            ),
            const Divider(height: 16),
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
                  color: AppColors.primaryTeal)),
          const SizedBox(height: 12),
          for (final d in controller.results)
            DestinationRow(
              title: d['name'] ?? '',
              subtitle: d['subtitle'] ?? '',
              imageUrl: d['image_url'] ?? '',
              // TODO(Figma): no details screen in Figma.
              onTap: () {},
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
                    color: AppColors.primaryTeal)),
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
                color: AppColors.primaryTeal)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final p in controller.popularSearches)
              GestureDetector(
                onTap: () {
                  textController.text = p;
                  controller.submit(p);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(p, style: const TextStyle(fontSize: 13)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Popular Destinations',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryTeal)),
        const SizedBox(height: 12),
        for (final d in controller.popularDestinations)
          DestinationRow(
            title: d['name'] ?? '',
            subtitle: d['subtitle'] ?? '',
            imageUrl: d['image_url'] ?? '',
            // TODO(Figma): no details screen in Figma.
            onTap: () {},
          ),
      ],
    );
  }
}
