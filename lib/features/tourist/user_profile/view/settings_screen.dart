import 'package:flutter/material.dart';
import 'package:triply/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/routing/app_routes.dart';
import '../../../common/auth/cubit/auth_cubit.dart';
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
            backgroundColor: AppColors.surfaceDefault,
            appBar: AppBar(
              backgroundColor: AppColors.surfaceDefault,
              elevation: 0,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: AppColors.actionPrimary,
                ),
              ),
              title: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            body: Column(
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
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.borderSubtle),
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
                const Spacer(),
                TextButton(
                  onPressed: () => _logout(context),
                  child: Text(
                    'Log out',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.actionPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
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
