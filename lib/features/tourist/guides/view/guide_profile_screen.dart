import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/routing/app_routes.dart';
import 'package:triply/features/tourist/guides/cubit/guide_profile_cubit.dart';
import 'package:triply/features/tourist/guides/model/guide.dart';
import 'package:triply/features/tourist/guides/model/trip.dart' as guide_trip;
import 'package:triply/features/tourist/trips/models/trip.dart' as trips_model;
import 'package:triply/core/widgets/guide_shared_widgets.dart';
import 'package:triply/features/tourist/booking/view/booking_screen.dart';
import 'package:triply/features/tourist/guides/widgets/trip_card.dart';
import 'package:triply/features/chat/widgets/message_guide_button.dart';
import 'package:triply/core/widgets/state_views.dart';

import '../../../../core/theme/app_colors.dart';

class GuideProfileScreen extends StatefulWidget {
  final String guideId;

  const GuideProfileScreen({super.key, required this.guideId});

  @override
  State<GuideProfileScreen> createState() => _GuideProfileScreenState();
}

class _GuideProfileScreenState extends State<GuideProfileScreen> {
  late final GuideProfileCubit _controller;

  @override
  void initState() {
    super.initState();
    // Owned here (like the old controller) so helpers keep working
    // unchanged; provided below for BlocBuilder rebuilds.
    _controller = GuideProfileCubit(guideId: widget.guideId);
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: AppColors.surfaceDefault,
        appBar: AppBar(
          backgroundColor: AppColors.surfaceDefault,
          scrolledUnderElevation: 0.0,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          ),
          title: const Text(
            'Guide profile',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
        ),
        body: BlocBuilder<GuideProfileCubit, GuideProfileState>(
          builder: (context, state) {
            if (state is GuideProfileInitial || state is GuideProfileLoading) {
              return const AppLoadingView();
            }
            if (state is GuideProfileError) {
              return AppErrorView(
                message: state.error,
                onRetry: _controller.load,
              );
            }
            if (state is! GuideProfileSuccess) return const AppLoadingView();
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildIdentity(state.guide)),
                SliverToBoxAdapter(child: _buildStats(state.guide)),
                SliverToBoxAdapter(child: _buildLanguages(state.guide)),
                SliverToBoxAdapter(child: _buildAbout(state.guide)),
                SliverToBoxAdapter(
                  child: _buildTrips(state.trips, state.guide),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 96)),
              ],
            );
          },
        ),
        bottomNavigationBar: BlocBuilder<GuideProfileCubit, GuideProfileState>(
          builder: (context, state) => state is GuideProfileSuccess
              ? _buildBottomBar(state.guide)
              : const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildIdentity(Guide guide) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: Image.network(
                  guide.avatarUrl,
                  width: 66,
                  height: 66,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 66,
                    height: 66,
                    color: AppColors.primaryLight,
                    alignment: Alignment.center,
                    child: Text(
                      guide.name.isNotEmpty ? guide.name[0] : '?',
                      style:  TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            guide.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:  TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (guide.isVerified) ...[
                          const SizedBox(width: 5),
                           Icon(
                            Icons.verified,
                            size: 17,
                            color: AppColors.actionSecondary,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      guide.specialty,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:  TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (guide.location.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        guide.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:  TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          RatingRow(
            rating: guide.rating,
            reviewCount: guide.reviewCount,
            ratingColor: AppColors.textPrimary,
            reviewCountColor: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildStats(Guide guide) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _StatItem(value: guide.reviewCount.toString(), label: 'Reviews'),
          _divider(),
          _StatItem(
            value: guide.languages.length.toString(),
            label: 'Languages',
          ),
          _divider(),
          _StatItem(
            value: '${guide.formatPrice(guide.pricePerHour)}/hr',
            label: 'Price/hr',
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 32, color: AppColors.textTertiary);
  }

  Widget _buildLanguages(Guide guide) {
    final langs = guide.languages;
    if (langs.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: langs
            .map(
              (l) => LanguageChip(
                label: l,
                backgroundColor: AppColors.surfaceDefault,
                textColor: AppColors.textSecondary,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildAbout(Guide guide) {
    final about = guide.about;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            about.isNotEmpty ? about : 'No description yet.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Opens the existing Trip Details for a guide trip; the public
  /// booking flow starts from there (no direct jump into booking).
  void _openTripDetails(
    BuildContext context,
    guide_trip.Trip trip,
    Guide guide,
  ) {
    Navigator.of(context).push(
      AppRoutes.tripDetails(
        trips_model.Trip(
          id: trip.id,
          title: trip.title,
          dateLabel: trip.dateLabel,
          guideName: guide.name,
          guideId: guide.id,
          guideAvatarUrl: guide.avatarUrl,
          peopleCount: trip.bookedSeats,
          priceEgp: trip.price,
          imageUrl: trip.imageUrl,
          status: trips_model.TripStatus.upcoming,
          category: 'historical',
          capacity: trip.capacity,
        ),
      ),
    );
  }

  Widget _buildTrips(List<guide_trip.Trip> trips, Guide guide) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Trips',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 14),
          if (trips.isEmpty)
             Text(
              'No trips available',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: trips.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, i) => TripCard(
                trip: trips[i],
                // Opens the trip details first; booking starts from there.
                onTap: () => _openTripDetails(context, trips[i], guide),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(Guide guide) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BookingScreen(guide: guide),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textPrimary,
                  minimumSize: const Size(0, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: const Text(
                  'Book Private Guide',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Original chat button size; AnimatedSize smooths the
            // layout change when it appears after loading.
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: MessageGuideButton(
                guideId: guide.id,
                guideName: guide.name,
                guideAvatar: guide.avatarUrl,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}
