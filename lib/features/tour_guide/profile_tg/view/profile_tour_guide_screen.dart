import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/features/common/AuthTourguide/data/tour_guide_auth_service.dart';
import 'package:triply/features/tour_guide/homeandNotificationTr/view/guide_dashboard_screen.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../homeandNotificationTr/view/guide_notifications_screen.dart';
import '../../homeandNotificationTr/widget/guide_bottom_nav.dart';
import '../cubit/profile_tg_cubit.dart';
import '../cubit/profile_tg_state.dart';
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

  static const int bottomIndex = 2; // Profile

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
            final guide = cubit.guide;
            return SingleChildScrollView(
              child: Column(
                children: [
                  ProfileHeader(
                    guide: guide,
                    displayName: cubit.displayName,
                    displayAvatar: cubit.displayAvatar,
                    displayLocation: cubit.displayLocation,
                    displayPhone: cubit.displayPhone,
                    onEdit: () => _editName(context),
                  ),
                  const SizedBox(height: 30),
                  ProfileStatsCard(
                    reviews: guide.reviewCount.toString(),
                    languages: guide.languages.length.toString(),
                    price: '${guide.pricePerHour}${guide.currency}',
                  ),
                  ProfileMenuSection(
                    languages: guide.languages,
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
      bottomNavigationBar: GuideBottomNav(
        currentIndex: bottomIndex,
        onTap: (index) {
         if (index==0){
          // Back to the previous guide screen (dashboard or trips pushed this).
         Navigator.push(context, MaterialPageRoute(builder: (context)=>GuideDashboardScreen()));
         }
         else if(index==1)
         {
          Navigator.of(context).push(AppRoutes.guideTrips());
         }

        },
      ),
    );
  }
}
