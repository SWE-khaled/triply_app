import 'package:flutter/material.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../tourist/UserProfile/widget/edit_profile_sheet.dart';
import '../../my_trips/widgets/guide_bottom_nav.dart';
import '../controller/profile_controller.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_section.dart';
import '../widgets/profile_stats_card.dart';

/// Guide profile: thin composer over section widgets.
/// Dialogs + navigation stay here; rows live in widgets/.
class ProfileTourGuideScreen extends StatefulWidget {
  final String guideId;

  const ProfileTourGuideScreen({super.key, required this.guideId});

  @override
  State<ProfileTourGuideScreen> createState() => _ProfileTourGuideScreenState();
}

class _ProfileTourGuideScreenState extends State<ProfileTourGuideScreen> {
  late final ProfileController _controller;
  int bottomIndex = 2; // Profile

  @override
  void initState() {
    super.initState();
    _controller = ProfileController(guideId: widget.guideId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
    showAppSnackBar(
      context,
      'Logged out (auth handoff pending)',
      icon: Icons.info_outline,
    );
  }

  void _todo(String what) {
    showAppSnackBar(
      context,
      '$what is not available yet',
      icon: Icons.info_outline,
    );
  }

  Future<void> _editName() async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => EditProfileSheet(
        name: _controller.displayName,
        photoUrl: _controller.guide.avatarUrl,
      ),
    );
    // The sheet persists to Firebase; pull the saved values in.
    if (saved == true && mounted) {
      _controller.pullFirebaseName();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final guide = _controller.guide;
          return SingleChildScrollView(
            child: Column(
              children: [
                ProfileHeader(
                  guide: guide,
                  displayName: _controller.displayName,
                  displayAvatar: _controller.displayAvatar,
                  onEdit: _editName,
                ),
                const SizedBox(height: 30),
                ProfileStatsCard(
                  reviews: guide.reviewCount.toString(),
                  languages: guide.languages.length.toString(),
                  price: 'EGP ${guide.pricePerHour}${guide.currency}',
                ),
                ProfileMenuSection(
                  languages: guide.languages,
                  about: guide.about,
                  onAvailability: () => _todo('Availability'),
                  onNotifications: () => _todo('Notifications'),
                  onEarnings: () =>
                      Navigator.of(context).push(AppRoutes.earnings()),
                  onSettings: () => _todo('Settings'),
                  onLogout: () => _confirmLogout(context),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: GuideBottomNav(
        currentIndex: bottomIndex,
        onTap: (i) {
          if (i == bottomIndex) return;
          if (i == 1) {
            Navigator.of(context).pop();
            return;
          }
          _todo('This section');
        },
      ),
    );
  }
}
