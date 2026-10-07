import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:triply/features/tourist/UserProfile/widget/edit_profile_sheet.dart';
import 'package:triply/features/tourist/community/view/community_view.dart';
import 'package:triply/features/tourist/home/view/home_screen.dart';
import 'package:triply/features/tourist/map/view/map_view.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../common/AuthTourist/providers/auth_provider.dart';
import '../../../common/AuthTourist/data/auth_repository.dart';
import '../../../tour_guide/role_selection/view/role_selection_screen.dart';
import '../controller/profile_controller.dart';
import '../widget/account_option_tile.dart';
import '../widget/profile_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key,});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileController(),
      child: const _ProfileBody(),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProfileController>();
    final firebaseUser = context.watch<AuthProvider>().user;
    final name = (firebaseUser?.displayName?.trim().isNotEmpty ?? false)
        ? firebaseUser!.displayName!.trim()
        : 'Traveler';
    final email = (firebaseUser?.email?.trim().isNotEmpty ?? false)
        ? firebaseUser!.email!.trim()
        : 'No email linked';
    final photoUrl = firebaseUser?.photoURL;
    final phoneFuture = firebaseUser == null
        ? Future<String?>.value()
        : AuthRepository().getUserPhone(firebaseUser.uid);

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color.fromARGB(255, 252, 248, 241),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ProfileHeader(
                    name: name,
                    photoUrl: photoUrl,
                    onEdit: () => showModalBottomSheet<bool>(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (_) => EditProfileSheet(
                        name: firebaseUser?.displayName ?? '',
                        photoUrl: photoUrl,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 13),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _stat('${controller.stats['trips'] ?? 0}', 'Trips'),
                    _stat('${controller.stats['places'] ?? 0}', 'Places'),
                    _stat('${controller.stats['photos'] ?? 0}', 'Photos'),
                    _stat(
                      '${controller.stats['reviews'] ?? 0}',
                      'Reviews',
                      last: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Account',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.guidesName,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  AccountOptionTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    switchValue: controller.notificationsEnabled,
                    onSwitchChanged: controller.toggleNotifications,
                  ),
                  AccountOptionTile(
                    icon: Icons.language_outlined,
                    title: 'Language',
                    trailingText: controller.selectedLanguage,
                    onTap: () => _showLanguageSheet(context, controller),
                  ),
                  AccountOptionTile(
                    icon: Icons.shield_outlined,
                    title: 'Privacy & security',
                    onTap: () => Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.privacySecurity),
                  ),
                  AccountOptionTile(
                    icon: Icons.sos_outlined,
                    title: 'SOS / Emergency',
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.emergency),
                  ),
                  AccountOptionTile(
                    icon: Icons.help_outline,
                    title: 'Help & support',
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Help & support is not available yet'),
                      ),
                    ),
                  ),
                  AccountOptionTile(
                    icon: Icons.info_outline,
                    title: 'About Triply',
                    showDivider: false,
                    onTap: () => showDialog<void>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('About Triply'),
                        content: const Text(
                          'Triply\nExplore. Experience. Egypt.\nVersion 1.0.0',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: TextButton.icon(
                onPressed: () => _confirmLogout(context),
                icon: const Icon(
                  Icons.logout_outlined,
                  color: AppColors.accentOrange,
                ),
                label: const Text(
                  'Log out',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentOrange,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Triply',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textGrey,
                ),
              ),
            ),
            const Center(
              child: Text(
                'Explore. Experience. Egypt.',
                style: TextStyle(fontSize: 13, color: AppColors.textGrey),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  email,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
              ),
            ),
            FutureBuilder<String?>(
              future: phoneFuture,
              builder: (context, snapshot) {
                final phone = snapshot.data;
                if (phone == null || phone.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4, left: 16, right: 16),
                  child: Center(
                    child: Text(
                      phone,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar:  AppBottomNav(
        currentIndex: 4,
        onTap: (index) {
          if (index == 0) {
          Navigator.push(context,MaterialPageRoute(builder: ((context)=>HomeScreen())));
          }
          else if (index == 1) {
            Navigator.of(context).push(AppRoutes.myTrips());
          }
          else if (index == 2) {
            Navigator.push(context,MaterialPageRoute(builder: ((context)=>MapScreen()))); 
          }
           else if (index == 3) {
            Navigator.push(context,MaterialPageRoute(builder: ((context)=>CommunityScreen())));//community
         }           

        },
      ),
    );
  }

  Widget _stat(String value, String label, {bool last = false}) {
    return Expanded(
      child: Container(
        decoration: last
            ? null
            : const BoxDecoration(
                border: Border(right: BorderSide(color: Color(0xFFEEEEEE))),
              ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.guidesName,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSheet(BuildContext context, ProfileController controller) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                'Language',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.guidesName,
                ),
              ),
            ),
            RadioGroup<String>(
              groupValue: controller.selectedLanguage,
              onChanged: (value) {
                if (value == null) return;
                controller.setLanguage(value);
                Navigator.of(sheetContext).pop();
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final language in controller.languages)
                    RadioListTile<String>(
                      title: Text(language),
                      value: language,
                      activeColor: AppColors.guidesName,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
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
    try {
      await context.read<AuthProvider>().signOut();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
        (_) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
    }
  }
}
