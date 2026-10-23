import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/constants/app_routes.dart';
import 'package:triply/features/common/AuthTourist/cubit/auth_cubit.dart';
import '../../../common/AuthTourguide/data/tour_guide_auth_service.dart';
import '../../../common/AuthTourguide/view/tour_guide_verification_screen.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/circle_icon_button.dart';
import '../../../../../core/widgets/app_snackbar.dart';
import '../../../../../core/widgets/profile_avatar.dart';
import '../../../../../core/widgets/state_views.dart';
import '../cubit/dashboard_cubit.dart';
import '../model/guide_dashboard_booking_request.dart';
import '../model/guide_dashboard_stats.dart';
import '../../my_trips_tg/model/guide_trip.dart';
import '../widget/dashboard_booking_request_card.dart';
import '../widget/guide_bottom_nav.dart';
import '../widget/stat_card.dart';
import '../../../../../core/data/repositories/guide_notifications_repository.dart';
import '../model/guide_notification.dart';
import 'booking_details_screen.dart';
import 'guide_notifications_screen.dart';

/// Cream tint from Figma (verification banner). Local const only — the
/// global theme in `core/theme/` is left untouched.
const Color _cream = Color(0xFFFAF5EA);

/// Tour-guide home: header, verification banner, stat grid, new bookings.
class GuideDashboardScreen extends StatelessWidget {
  const GuideDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardCubit(),
      child: const _GuideDashboardView(),
    );
  }
}

/// The badge on the notifications bell: the number of unread ones.
class _UnreadBadge extends StatelessWidget {
  final int count;

  const _UnreadBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.accentOrange,
          shape: BoxShape.circle,
        ),
      );
    }
    return Container(
      constraints: const BoxConstraints(minWidth: 16),
      height: 16,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.accentOrange,
        shape: BoxShape.circle,
      ),
      child: Text(
        count > 9 ? '9+' : '$count',
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _GuideDashboardView extends StatefulWidget {
  const _GuideDashboardView();

  @override
  State<_GuideDashboardView> createState() => _GuideDashboardViewState();
}

class _GuideDashboardViewState extends State<_GuideDashboardView> {
  final GuideNotificationsRepository _notifications =
      GuideNotificationsRepository();

  /// Live — the badge follows the notifications without a refresh.
  late final Stream<List<GuideNotification>> _notificationsStream;

  /// Live — the guide's own name from Firestore. Firebase Auth's
  /// `displayName` is empty for e-mail sign-ups, so this is the
  /// fallback; the session-only mock name is never shown again.
  String _firestoreName = '';
  StreamSubscription<String>? _nameSubscription;

  @override
  void initState() {
    super.initState();
    _notificationsStream = _notifications.watchNotifications();
    _nameSubscription = TourGuideAuthService()
        .watchMyName()
        .listen((name) {
          if (!mounted) return;
          setState(() => _firestoreName = name);
        });
  }

  @override
  void dispose() {
    _nameSubscription?.cancel();
    super.dispose();
  }

  void _openNotifications(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const GuideNotificationsScreen()));
  }

  /// Opens the profile of the signed-in guide — their own public page,
  /// what the tourists see once the admin approves it.
  void _openProfile(BuildContext context) {
    final uid = context.read<AuthCubit>().user?.uid;
    if (uid == null) {
      showAppSnackBar(
        context,
        'Sign in to see your profile',
        icon: Icons.info_outline,
      );
      return;
    }
    Navigator.of(context).push(AppRoutes.guideProfile(uid));
  }

  @override
  Widget build(BuildContext context) {
    // Same sources of truth as the Profile page (ProfileController):
    // Firebase user first (EditProfileSheet persists the name/photo there
    // and calls AuthCubit.refreshUser, so this rebuilds on change).
    // Without a photo the bundled default avatar is shown — never a
    // stock face. Rebuilds via AuthCubit.
    final authUser = context.watch<AuthCubit>().user;
    final firebasePhoto = authUser?.photoURL?.trim() ?? '';
    final firebaseName = authUser?.displayName?.trim() ?? '';
    final guideName = firebaseName.isNotEmpty
        ? firebaseName
        : (_firestoreName.isNotEmpty ? _firestoreName : 'Guide');
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<DashboardCubit, DashboardState>(
                builder: (context, state) {
                  return switch (state) {
                    DashboardSuccess(
                      :final stats,
                      :final bookings,
                      :final showVerificationBanner,
                    ) =>
                      SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        child: _dashboardContent(
                          context,
                          stats: stats,
                          bookings: bookings,
                          showVerificationBanner: showVerificationBanner,
                          firebasePhoto: firebasePhoto,
                          guideName: guideName,
                        ),
                      ),
                    // The loading and the error views fill the whole body,
                    // so their spinner sits in the middle of the screen.
                    DashboardInitial() ||
                    DashboardLoading() => const AppLoadingView(),
                    DashboardError(:final error) => AppErrorView(
                      message: error,
                      onRetry: () => context.read<DashboardCubit>().load(),
                    ),
                  };
                },
              ),
            ),
            GuideBottomNav(
              currentIndex: 0,
              onTap: (index) {
                if (index == 1) {
                  // The old screens are removed instead of stacked: every
                  // screen owns a live Firestore subscription, so keeping
                  // them alive would pile them up.
                  Navigator.of(context).pushAndRemoveUntil(
                    AppRoutes.guideTrips(),
                    (route) => route.isFirst,
                  );
                } else if (index == 2) {
                  _openProfile(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// The dashboard content, rendered once the state is a success.
  Widget _dashboardContent(
    BuildContext context, {
    required GuideDashboardStats stats,
    required List<BookingRequest> bookings,
    required bool showVerificationBanner,
    required String firebasePhoto,
    required String guideName,
  }) {
    final avatarUrl = firebasePhoto.isNotEmpty
        ? firebasePhoto
        : ProfileAvatar.defaultAvatar;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        _header(context, avatarUrl),
        const SizedBox(height: 16),
        if (showVerificationBanner) ...[
          _verificationBanner(context),
          const SizedBox(height: 20),
        ] else
          const SizedBox(height: 4),
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
          'Welcome back, $guideName',
          style: const TextStyle(fontSize: 13, color: AppColors.subtitle),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.people_outline,
                value: '${stats.totalBookings}',
                label: 'Total Bookings',
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.calendar_today_outlined,
                value: '${stats.upcomingTrips}',
                label: 'Upcoming Trips',
                // No Upcoming tab exists in My Trips; Active
                // holds the scheduled upcoming trips.
                onTap: () => Navigator.push(
                  context,
                  AppRoutes.guideTrips(initialStatus: GuideTripStatus.active),
                ),
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
                onTap: () => Navigator.push(
                  context,
                  AppRoutes.guideTrips(initialStatus: GuideTripStatus.active),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.layers_outlined,
                value: '${stats.completedTrips}',
                label: 'Completed Trips',
                onTap: () => Navigator.push(
                  context,
                  AppRoutes.guideTrips(
                    initialStatus: GuideTripStatus.completed,
                  ),
                ),
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
                onTap: () => Navigator.push(context, AppRoutes.earnings()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.notifications_none_outlined,
                value: '${stats.pendingRequests}',
                label: 'Pending Requests',
                onTap: () => Navigator.push(
                  context,
                  AppRoutes.guideTrips(initialStatus: GuideTripStatus.pending),
                ),
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
        for (final b in bookings) ...[
          BookingRequestCard(
            booking: b,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BookingDetailsScreen(bookingId: b.id),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ],
    ),
    );
  }

  Widget _header(BuildContext context, String avatarUrl) {
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
        StreamBuilder<List<GuideNotification>>(
          stream: _notificationsStream,
          builder: (context, snapshot) {
            final unread = (snapshot.data ?? const <GuideNotification>[])
                .where((n) => n.isUnread)
                .length;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                CircleIconButton(
                  icon: Icons.notifications_none_outlined,
                  onTap: () => _openNotifications(context),
                  backgroundColor: Colors.white,
                  iconColor: AppColors.title,
                  size: 50,
                  iconSize: 24,
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: _UnreadBadge(count: unread),
                ),
              ],
            );
          },
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _openProfile(context),
          behavior: HitTestBehavior.opaque,
          child: ClipOval(
            child: ProfileAvatar(imageUrl: avatarUrl, width: 45, height: 45),
          ),
        ),
      ],
    );
  }

  void _openVerification(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TourGuideVerificationScreen()),
    );
  }

  Widget _verificationBanner(BuildContext context) {
    final cubit = context.read<DashboardCubit>();
    final status = cubit.verificationStatus;
    final pending = status == 'pending';
    return GestureDetector(
      onTap: () => _openVerification(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
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
              child: Icon(
                pending ? Icons.hourglass_top : Icons.person_outline,
                size: 22,
                color: AppColors.title,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pending
                        ? 'Waiting for admin approval'
                        : 'Verification required',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.title,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    pending
                        ? 'Your documents are under review by the admin.'
                        : 'Verify your guide license to publish trips.',
                    style: TextStyle(fontSize: 12, color: AppColors.subtitle),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: AppColors.title),
          ],
        ),
      ),
    );
  }
}
