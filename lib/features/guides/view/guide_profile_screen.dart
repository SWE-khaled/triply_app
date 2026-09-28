import 'package:flutter/material.dart';
import 'package:triply/features/guides/controller/guide_profile_controller.dart';
import 'package:triply/core/widgets/guide_shared_widgets.dart';
import 'package:triply/features/booking/view/booking_screen.dart';
import 'package:triply/features/guides/widgets/trip_card.dart';

import '../../../core/theme/app_colors.dart';

class GuideProfileScreen extends StatefulWidget {
  final String guideId;

  const GuideProfileScreen({super.key, required this.guideId});

  @override
  State<GuideProfileScreen> createState() => _GuideProfileScreenState();
}

class _GuideProfileScreenState extends State<GuideProfileScreen> {
  late final GuideProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GuideProfileController(guideId: widget.guideId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final guide = _controller.guide;
          final trips = _controller.trips;
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildCover(guide.coverUrl)),
              // SliverToBoxAdapter(child: _buildIdentity()),
              SliverToBoxAdapter(child: _buildStats()),
              SliverToBoxAdapter(child: _buildLanguages()),
              SliverToBoxAdapter(child: _buildAbout()),
              SliverToBoxAdapter(child: _buildTrips(trips)),
              SliverToBoxAdapter(child: SizedBox(height: 96)),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildCover(String coverUrl) {
    return SizedBox(
      height: 320,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Color(0xFF0E5261).withOpacity(0.3), // Adjust color and opacity
                BlendMode.srcATop, // Or BlendMode.darken / BlendMode.multiply
              ),
              child: Image.network(
                coverUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: Color(0xFF3E5A5E),
                  alignment: Alignment.center,
                  child: Icon(Icons.landscape, color: Colors.white54, size: 48),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.15)),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: _CircleIconButton(
              icon: Icons.chevron_left,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          // Positioned(
          //   top: MediaQuery.of(context).padding.top + 8,
          //   right: 16,
          //   child: ListenableBuilder(
          //     listenable: _controller,
          //     builder: (context, _) => _CircleIconButton(
          //       icon: _controller.isBookmarked
          //           ? Icons.bookmark
          //           : Icons.bookmark_border,
          //       onPressed: () {
          //         _controller.toggleBookmark();
          //         AppSnackBar.showAdded(
          //           context: context,
          //           isAdded: _controller.isBookmarked,
          //         );
          //       },
          //     ),
          //   ),
          // ),
          Positioned(
            child: Center(
              child: Column(
                mainAxisAlignment: .center,
                mainAxisSize: .min,
                crossAxisAlignment: .center,
                children: [
                  Container(
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.network(
                        _controller.guide.avatarUrl,
                        width: 85,
                        height: 85,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 84,
                          height: 84,
                          color: AppColors.primaryLight,
                          alignment: Alignment.center,
                          child: Text(
                            _controller.guide.name.isNotEmpty
                                ? _controller.guide.name[0]
                                : '?',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  _buildIdentity(),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 24, // ارتفاع الانحناء فوق الصورة
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentity() {
    final guide = _controller.guide;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 13, 16, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  guide.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              if (guide.isVerified) ...[
                SizedBox(width: 8),
                Icon(Icons.verified, size: 16, color: Color(0xFF4DA7A0)),
              ],
            ],
          ),
          SizedBox(height: 2),
          Text(
            guide.specialty,
            style: TextStyle(fontSize: 13, color: Colors.white),
          ),
          SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RatingRow(
                rating: guide.rating,
                reviewCount: guide.reviewCount,
                ratingColor: Colors.white,
                reviewCountColor: Colors.white.withOpacity(.8),
              ),
              if (guide.location.isNotEmpty) ...[
                SizedBox(width: 8),
                Icon(Icons.location_on, size: 14, color: Color(0xFFD8B66A)),
                SizedBox(width: 2),
                Flexible(
                  child: Text(
                    guide.location,
                    style: const TextStyle(fontSize: 13, color: Colors.white),
                  ),
                ),
              ],
            ],
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
            value:
            '${_profilePrice(guide.pricePerHour)}${guide.currency == '\$' ? ' EGP ' : guide.currency}',
            label: 'Price/hr',
          ),
        ],
      ),
    );
  }

  String _profilePrice(double perHour) {
    // Mock display conversion: $75 -> EGP 3750 (x50) to match Figma example.
    if (_controller.guide.currency == '\$') {
      return (perHour * 50).toStringAsFixed(0);
    }
    return perHour.toStringAsFixed(0);
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
              itemBuilder: (context, i) =>
                  TripCard(trip: trips[i], onTap: () {}),
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
            // const SizedBox(width: 12),
            // InkWell(
            //   // Chat screen does not exist yet — placeholder.
            //   onTap: () {},
            //   borderRadius: BorderRadius.circular(26),
            //   child: Container(
            //     width: 52,
            //     height: 52,
            //     decoration: BoxDecoration(
            //       color: Color(0xFFFAF5EC),
            //       border: Border.all(color: Color(0xFF8A9EA3)),
            //       shape: BoxShape.circle,
            //     ),
            //     child: Icon(Icons.chat_outlined, color: Color(0xFF0E5261)),
            //   ),
            // ),
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

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CircleIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 25),
      ),
    );
  }
}
