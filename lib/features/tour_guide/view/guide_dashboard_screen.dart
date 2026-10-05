import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/circle_icon_button.dart';
import '../../../../core/widgets/network_image_fallback.dart';
import '../controller/guide_dashboard_controller.dart';
import '../widget/dashboard_booking_request_card.dart';
import '../widget/guide_bottom_nav.dart';
import '../widget/stat_card.dart';
import 'booking_details_screen.dart';
import 'guide_notifications_screen.dart';

/// Cream tint from Figma (verification banner). Local const only — the
/// global theme in `core/theme/` is left untouched.
const Color _cream = Color(0xFFFAF5EA);

/// Tour-guide home: header, verification banner, stat grid, new bookings.
class GuideDashboardScreen extends StatefulWidget {
  const GuideDashboardScreen({super.key});

  @override
  State<GuideDashboardScreen> createState() => _GuideDashboardScreenState();
}

class _GuideDashboardScreenState extends State<GuideDashboardScreen> {
  late final DashboardController controller;

  @override
  void initState() {
    super.initState();
    controller = DashboardController();
    controller.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    controller.removeListener(_refresh);
    controller.dispose();
    super.dispose();
  }

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GuideNotificationsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = controller.stats;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(stats.avatarUrl),
                    const SizedBox(height: 16),
                    _verificationBanner(),
                    const SizedBox(height: 20),
                    const Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.title,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Welcome back, ${stats.guideName}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.subtitle,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            icon: Icons.people_outline,
                            value: '${stats.totalBookings}',
                            label: 'Total Bookings',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            icon: Icons.calendar_today_outlined,
                            value: '${stats.upcomingTrips}',
                            label: 'Upcoming Trips',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            icon: Icons.work_outline,
                            value: '${stats.activeTrips}',
                            label: 'Active Trips',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            icon: Icons.layers_outlined,
                            value: '${stats.completedTrips}',
                            label: 'Completed Trips',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            icon: Icons.credit_card_outlined,
                            value: stats.earningsLabel,
                            label: 'Earnings',
                            highlighted: true,
                            valueTeal: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            icon: Icons.notifications_none_outlined,
                            value: '${stats.pendingRequests}',
                            label: 'Pending Requests',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'New bookings',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.title,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final b in controller.bookings) ...[
                      BookingRequestCard(
                        booking: b,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  BookingDetailsScreen(bookingId: b.id),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ),
            GuideBottomNav(
              currentIndex: 0,
              // TODO(Figma): My Trips / Profile destinations not in scope.
              onTap: (i) {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(String avatarUrl) {
    return Row(
      children: [
        const Text(
          'Triply',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.title,
          ),
        ),
        const Spacer(),
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleIconButton(
              icon: Icons.notifications_none_outlined,
              onTap: _openNotifications,
              backgroundColor: Colors.white,
              iconColor: AppColors.title,
              size: 40,
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.accentOrange,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        ClipOval(
          child: NetworkImageFallback(
            imageUrl: avatarUrl,
            width: 40,
            height: 40,
            fallbackIcon: Icons.person_outline,
          ),
        ),
      ],
    );
  }

  Widget _verificationBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              size: 22,
              color: AppColors.title,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verification required',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.title,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Verify your guide license to publish trips.',
                  style: TextStyle(fontSize: 12, color: AppColors.subtitle),
                ),
              ],
            ),
          ),
          GestureDetector(
            // TODO(Figma): no verification destination in Figma.
            onTap: () {},
            behavior: HitTestBehavior.opaque,
            child: const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.title,
            ),
          ),
        ],
      ),
    );
  }
}
