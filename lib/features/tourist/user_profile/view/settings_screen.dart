import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/routing/app_routes.dart';
import '../../../common/auth/cubit/auth_cubit.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/app_theme_dark.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../cubit/logout_cubit.dart';
import '../cubit/logout_state.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widget/account_option_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProfileCubit>();
    return BlocProvider(
      create: (_) =>
          LogoutCubit(onSignOut: () => context.read<AuthCubit>().signOut()),
      child: Builder(
        builder: (context) => BlocListener<LogoutCubit, LogoutState>(
          listener: (context, state) {
            if (state is LoggedOut) {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(AppRoutes.signIn, (_) => false);
            } else if (state is LogoutError && state.message != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message!)));
            }
          },
          child: Scaffold(
            backgroundColor: AppThemeColors.resolve(
              context,
              light: Colors.white,
              dark: AppThemeDark.backgroundPrimary,
            ),
            appBar: AppBar(
              backgroundColor: AppThemeColors.resolve(
                context,
                light: Colors.white,
                dark: AppThemeDark.backgroundPrimary,
              ),
              elevation: 0,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: AppThemeColors.resolve(
                    context,
                    light: Color(0xFF0E5865),
                    dark: AppThemeDark.iconPrimary,
                  ),
                ),
              ),
              title: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppThemeColors.resolve(
                    context,
                    light: const Color(0xFF263A40),
                    dark: AppThemeDark.homeSectionTitle,
                  ),
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(14, 14, 14, 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Account',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppThemeColors.resolve(
                            context,
                            light: const Color(0xFF263A40),
                            dark: AppThemeDark.homeSectionTitle,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppThemeColors.resolve(
                          context,
                          light: const Color(0xFFE6EAEB),
                          dark: AppThemeDark.homeGuideBorder,
                        ),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        BlocBuilder<ProfileCubit, ProfileState>(
                          builder: (context, state) => AccountOptionTile(
                            icon: Icons.notifications_outlined,
                            title: 'Notifications',
                            switchValue: state.notificationsEnabled,
                            onSwitchChanged: cubit.toggleNotifications,
                          ),
                        ),
                        BlocBuilder<ThemeCubit, bool>(
                          builder: (context, isDark) => AccountOptionTile(
                            icon: Icons.dark_mode_outlined,
                            title: 'Dark mode',
                            switchValue: isDark,
                            onSwitchChanged: (value) =>
                                context.read<ThemeCubit>().setDarkMode(
                                  value,
                                  role: 'tourist',
                                ),
                          ),
                        ),
                        AccountOptionTile(
                          icon: Icons.shield_outlined,
                          title: 'Privacy & security',
                          onTap: () => Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.privacySecurity),
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
                                  onPressed: () => Navigator.pop(dialogContext),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(14, 20, 14, 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Help & Support',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppThemeColors.resolve(
                            context,
                            light: const Color(0xFF263A40),
                            dark: AppThemeDark.homeSectionTitle,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppThemeColors.resolve(
                          context,
                          light: const Color(0xFFE6EAEB),
                          dark: AppThemeDark.homeGuideBorder,
                        ),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AccountOptionTile(
                      icon: Icons.contact_support_outlined,
                      title: 'Contact Us',
                      showDivider: false,
                      onTap: () =>
                          Navigator.of(context).pushNamed(AppRoutes.contactUs),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => _logout(context),
                    child: Text(
                      'Log out',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppThemeColors.resolve(
                          context,
                          light: Color(0xFF0E5865),
                          dark: AppThemeDark.homeSeeAll,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<LogoutCubit>().logout();
  }
}
