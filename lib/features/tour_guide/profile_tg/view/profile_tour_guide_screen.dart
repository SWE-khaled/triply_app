import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/features/common/AuthTourguide/data/tour_guide_auth_service.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../home_and_notification_tg/view/guide_notifications_screen.dart';
import '../../home_and_notification_tg/widget/guide_bottom_nav.dart';
import '../../../chat/widgets/chat_unread_builder.dart';
import '../cubit/profile_tg_cubit.dart';
import '../view/guide_availability_screen.dart';
import '../view/guide_settings_screen.dart';
import '../widgets/edit_profile_sheet.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_section.dart';
import '../widgets/profile_stats_card.dart';
import '../../role_selection/view/role_selection_screen.dart';

/// Guide profile_tg: thin composer over section widgets.
/// Dialogs + navigation stay here; rows live in widgets/.
class ProfileTourGuideScreen extends StatelessWidget {
  final String guideId;

  const ProfileTourGuideScreen({super.key, required this.guideId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileTgCubit(guideId: guideId)..loadRemoteProfile(),
      child: const _ProfileTourGuideView(),
    );
  }
}

class _ProfileTourGuideView extends StatelessWidget {
  const _ProfileTourGuideView();

  static const int bottomIndex = 3; // Profile

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.accentOrange),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await TourGuideAuthService().signOut();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
        (_) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
      showAppSnackBar(context, 'Logout failed: $e', icon: Icons.error_outline);
    }
  }

  Future<void> _editName(BuildContext context) async {
    final cubit = context.read<ProfileTgCubit>();
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => EditProfileSheet(
        name: cubit.displayName,
        displayAvatar: cubit.displayAvatar,
        about: cubit.displayAbout,
        location: cubit.displayLocation,
        phone: cubit.displayPhone ?? '',
        pricePerHour: cubit.pricePerHour,
      ),
    );
    // The sheet persists to Firebase/Firestore; pull the saved values in.
    if (saved == true && context.mounted) {
      cubit.pullFirebaseName();
      cubit.loadRemoteProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: BlocBuilder<ProfileTgCubit, ProfileTgState>(
          builder: (context, state) {
            final cubit = context.read<ProfileTgCubit>();
            return SingleChildScrollView(
              child: Column(
                children: [
                  ProfileHeader(
                    displayName: cubit.displayName,
                    displayAvatar: cubit.displayAvatar,
                    displayLocation: cubit.displayLocation,
                    displayPhone: cubit.displayPhone,
                    isVerified: cubit.isVerified,
                    specialty: cubit.specialty,
                    rating: cubit.rating,
                    reviewCount: cubit.reviewCount,
                    onEdit: () => _editName(context),
                  ),
                  const SizedBox(height: 30),
                  ProfileStatsCard(
                    reviews: cubit.reviewCount.toString(),
                    languages: cubit.languages.length.toString(),
                    price: cubit.pricePerHourLabel,
                  ),
                  ProfileMenuSection(
                    languages: cubit.languages,
                    about: cubit.displayAbout,
                    onAvailability: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const GuideAvailabilityScreen(),
                      ),
                    ),
                    onNotifications: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const GuideNotificationsScreen(),
                      ),
                    ),
                    onEarnings: () =>
                        Navigator.of(context).push(AppRoutes.earnings()),
                    onSettings: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const GuideSettingsScreen(),
                      ),
                    ),
                    onLogout: () => _confirmLogout(context),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: ChatUnreadBuilder(
        builder: (context, unread) => GuideBottomNav(
          currentIndex: bottomIndex,
          chatUnread: unread,
          onTap: (index) {
            // The old screens are removed instead of stacked: every screen
            // owns a live Firestore subscription, so keeping them alive
            // would pile them up.
            if (index == 0) {
              Navigator.of(context).pushAndRemoveUntil(
                AppRoutes.guideDashboard(),
                (route) => route.isFirst,
              );
            } else if (index == 1) {
              Navigator.of(context).pushAndRemoveUntil(
                AppRoutes.guideTrips(),
                (route) => route.isFirst,
              );
            } else if (index == 2) {
              Navigator.of(context).pushAndRemoveUntil(
                AppRoutes.guideChats(),
                (route) => route.isFirst,
              );
            }
          },
        ),
      ),
    );
  }
}
