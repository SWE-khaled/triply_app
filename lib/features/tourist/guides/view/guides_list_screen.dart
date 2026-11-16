import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/widgets/app_shimmer.dart';
import 'package:triply/core/widgets/circle_back_button.dart';
import 'package:triply/core/widgets/state_views.dart';
import 'package:triply/features/tourist/guides/cubit/guides_cubit.dart';

import 'package:triply/features/tourist/guides/view/guide_profile_screen.dart';
import 'package:triply/features/tourist/guides/widgets/guide_card.dart';

class GuidesListScreen extends StatefulWidget {
  const GuidesListScreen({super.key});

  @override
  State<GuidesListScreen> createState() => _GuidesListScreenState();
}

class _GuidesListScreenState extends State<GuidesListScreen> {
  GuidesCubit get _controller => context.read<GuidesCubit>();
  late final TextEditingController _searchFieldController;

  @override
  void initState() {
    super.initState();
    // The Cubit is app-session scoped (provided in main.dart): reuse its
    // retained search text instead of starting a new loading cycle here.
    _searchFieldController = TextEditingController(
      text: _controller.searchQuery,
    );
  }

  @override
  void dispose() {
    _searchFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocProvider.value(
          value: _controller,
          child: BlocBuilder<GuidesCubit, GuidesState>(
            builder: (context, state) {
              if (state is GuidesInitial || state is GuidesLoading) {
                return const _GuidesListSkeleton();
              }
              if (state is GuidesError) {
                return AppErrorView(
                  message: state.error,
                  onRetry: _controller.load,
                );
              }
              final guides = state is GuidesSuccess ? state.guides : const [];
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader()),
                  SliverToBoxAdapter(child: _buildSearch()),
                  SliverToBoxAdapter(child: _buildFilters()),
                  if (guides.isEmpty)
                    SliverToBoxAdapter(child: _EmptyState())
                  else
                    SliverPadding(
                      padding: EdgeInsetsGeometry.only(
                        right: 12,
                        bottom: 16,
                        left: 12,
                      ),
                      sliver: SliverList.separated(
                        itemCount: guides.length,
                        separatorBuilder: (_, _) => SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final g = guides[i];
                          return GuideCard(
                            guide: g,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      GuideProfileScreen(guideId: g.id),
                                ),
                              );
                            },
                            onChatPressed: () {},
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          const CircleBackButton(size: 41),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'All Guides',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              Text(
                '${_controller.totalCount} guides available',
                style: TextStyle(fontSize: 12, color: Color(0xFF8A9EA3)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        controller: _searchFieldController,
        onChanged: _controller.setSearch,
        onSubmitted: (_) {},
        decoration: InputDecoration(
          hintText: 'Search guides by name or specialty...',
          hintStyle: TextStyle(fontSize: 13, color: Color(0xFFAAB8BC)),
          prefixIcon: Icon(Icons.search, color: Color(0xFF8A9EA3), size: 20),
          filled: true,
          fillColor: Color(0xFFF5F5F5),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        padding: EdgeInsetsGeometry.only(
          top: 8,
          right: 16,
          bottom: 8,
          left: 16,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: _controller.languageFilters.length,
        separatorBuilder: (_, _) => SizedBox(width: 8),
        itemBuilder: (context, i) {
          final lang = _controller.languageFilters[i];
          final selected = _controller.selectedLanguage == lang;
          final isAll = lang == 'All';
          return ChoiceChip(
            label: Text(isAll ? 'All' : lang),
            selected: selected,
            onSelected: (_) => _controller.setLanguage(lang),
            showCheckmark: false,
            avatar: _controller.languageFilters[i] != "All"
                ? Icon(
                    Icons.translate,
                    size: 15,
                    color: selected ? Colors.white : Color(0xFF526B72),
                  )
                : null,
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : Color(0xFF526B72),
            ),
            backgroundColor: Color(0xFFF5F5F5),
            selectedColor: Color(0xFF0E5261),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Color(0xFFF5F5F5)),
            ),
          );
        },
      ),
    );
  }
}

class _GuidesListSkeleton extends StatelessWidget {
  const _GuidesListSkeleton();

  @override
  Widget build(BuildContext context) => AppShimmer(
    child: CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                const ShimmerCircle(size: 41),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerLine(width: 110, height: 17),
                    SizedBox(height: 7),
                    ShimmerLine(width: 90, height: 12),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: ShimmerBox(
              width: double.infinity,
              height: 48,
              borderRadius: BorderRadius.all(Radius.circular(14)),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 60,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, index) => ShimmerBox(
                width: [58.0, 82.0, 72.0, 88.0][index],
                height: 36,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: _GuideCardSkeleton(),
              ),
              childCount: 4,
            ),
          ),
        ),
      ],
    ),
  );
}

class _GuideCardSkeleton extends StatelessWidget {
  const _GuideCardSkeleton();

  @override
  Widget build(BuildContext context) => ShimmerCard(
    radius: 20,
    padding: const EdgeInsets.all(12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ShimmerBox(
          width: 56,
          height: 56,
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              ShimmerLine(width: 135, height: 15),
              SizedBox(height: 7),
              ShimmerLine(width: 100, height: 12),
              SizedBox(height: 10),
              Row(
                children: [
                  ShimmerBox(
                    width: 48,
                    height: 20,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  SizedBox(width: 6),
                  ShimmerBox(
                    width: 56,
                    height: 20,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  ShimmerLine(width: 74, height: 12),
                  Spacer(),
                  ShimmerLine(width: 82, height: 13),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Center(
        child: Column(
          spacing: 10,
          children: [
            Text(
              "🔍",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w400),
            ),
            Text(
              'No guides found',
              style: TextStyle(
                color: Color(0xFF0E5261),
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Try a different keyword or filter",
              style: TextStyle(color: Color(0xFF8A9EA3), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
