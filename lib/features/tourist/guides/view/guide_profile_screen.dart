import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/constants/app_routes.dart';
import 'package:triply/features/tourist/guides/cubit/guide_profile_cubit.dart';

import 'package:triply/features/tourist/guides/model/trip.dart' as guide_trip;
import 'package:triply/features/tourist/trips/models/trip.dart' as trips_model;
import 'package:triply/core/widgets/guide_shared_widgets.dart';
import 'package:triply/features/tourist/booking/view/booking_screen.dart';
import 'package:triply/features/tourist/guides/widgets/trip_card.dart';
import 'package:triply/features/chat/widgets/message_guide_button.dart';

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
      body: BlocProvider.value(
        value: _controller,
        child: BlocBuilder<GuideProfileCubit, GuideProfileState>(
          builder: (context, _) {
            final trips = _controller.trips;
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildIdentity()),
                SliverToBoxAdapter(child: _buildStats()),
                SliverToBoxAdapter(child: _buildLanguages()),
                SliverToBoxAdapter(child: _buildAbout()),
                SliverToBoxAdapter(child: _buildTrips(trips)),
                SliverToBoxAdapter(child: SizedBox(height: 96)),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildIdentity() {
    final guide = _controller.guide;
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
                      style: const TextStyle(
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
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF263A40),
                            ),
                          ),
                        ),
                        if (guide.isVerified) ...[
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.verified,
                            size: 17,
                            color: Color(0xFF4DA7A0),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      guide.specialty,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF526B72),
                      ),
                    ),
                    if (guide.location.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        guide.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF71868B),
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
            ratingColor: const Color(0xFF263A40),
            reviewCountColor: const Color(0xFF71868B),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final guide = _controller.guide;
    return Container(
      margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Color(0xFFFAF5EC),
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
            value: '${guide.pricePerHour}${guide.currency}',
            label: 'Price/hr',
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 32, color: Color(0xFF8A9EA3));
  }

  Widget _buildLanguages() {
    final langs = _controller.guide.languages;
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
                backgroundColor: Color(0xFFF5F5F5),
                textColor: Color(0xFF526B72),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildAbout() {
    final about = _controller.guide.about;
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
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            about.isNotEmpty ? about : 'No description yet.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF526B72),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Opens the existing Trip Details for a guide trip; the public
  /// booking flow starts from there (no direct jump into booking).
  void _openTripDetails(BuildContext context, guide_trip.Trip trip) {
    Navigator.of(context).push(
      AppRoutes.tripDetails(
        trips_model.Trip(
          id: trip.id,
          title: trip.title,
          dateLabel: trip.dateLabel,
          guideName: _controller.guide.name,
          peopleCount: 1,
          priceEgp: trip.price,
          imageUrl: trip.imageUrl,
          status: trips_model.TripStatus.upcoming,
          category: 'historical',
          capacity: 12,
        ),
      ),
    );
  }

  Widget _buildTrips(List trips) {
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
              color: Color(0xFF1A1A1A),
            ),
          ),
          if (trips.isEmpty)
            const Text(
              'No trips available',
              style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 13),
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
                onTap: () =>
                    _openTripDetails(context, trips[i] as guide_trip.Trip),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
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
                      builder: (_) =>
                          BookingScreen(guideId: _controller.guide.id),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
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
            MessageGuideButton(
              guideId: _controller.guide.id,
              guideName: _controller.guide.name,
              guideAvatar: _controller.guide.avatarUrl,
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
              color: Colors.black,
            ),
          ),
          SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 12, color: Color(0xFF8A9EA3))),
        ],
      ),
    );
  }
}
