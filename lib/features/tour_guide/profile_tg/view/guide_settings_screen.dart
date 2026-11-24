import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/app_theme_dark.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/circle_back_button.dart';

/// Guide settings: only actions that really work in this project.
/// Biometric login does not exist — it is not listed.
class GuideSettingsScreen extends StatelessWidget {
  const GuideSettingsScreen({super.key});

  Future<void> _resetPassword(BuildContext context) async {
    final email = FirebaseAuth.instance.currentUser?.email?.trim() ?? '';
    if (email.isEmpty) {
      showAppSnackBar(
        context,
        'No signed-in account email found',
        icon: Icons.error_outline,
      );
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!context.mounted) return;
      showAppSnackBar(
        context,
        'Reset link sent to $email',
        icon: Icons.check_circle,
      );
    } catch (e) {
      if (!context.mounted) return;
      showAppSnackBar(
        context,
        'Could not send reset link: $e',
        icon: Icons.error_outline,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeColors.resolve(
        context,
        light: Colors.white,
        dark: AppThemeDark.backgroundPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleBackButton(
                    backgroundColor: AppThemeColors.resolve(
                      context,
                      light: Colors.white,
                      dark: AppThemeDark.surfaceElevated,
                    ),
                    iconColor: AppThemeColors.resolve(
                      context,
                      light: Colors.black,
                      dark: AppThemeDark.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Settings',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppThemeColors.resolve(
                        context,
                        light: AppColors.title,
                        dark: AppThemeDark.homeSectionTitle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppThemeColors.resolve(
                    context,
                    light: Colors.white,
                    dark: AppThemeDark.surfaceDefault,
                  ),
                  border: Border.all(
                    color: AppThemeColors.resolve(
                      context,
                      light: AppColors.cardBorder,
                      dark: AppThemeDark.borderSubtle,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _SettingsRow(
                      icon: Icons.lock_reset_outlined,
                      label: 'Reset password',
                      onTap: () => _resetPassword(context),
                    ),
                    BlocBuilder<ThemeCubit, bool>(
                      builder: (context, isDark) => _SettingsThemeRow(
                        isDark: isDark,
                        onChanged: (value) => context
                            .read<ThemeCubit>()
                            .setDarkMode(value, role: 'guide'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Help & Support',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppThemeColors.resolve(
                    context,
                    light: AppColors.title,
                    dark: AppThemeDark.homeSectionTitle,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: AppThemeColors.resolve(
                    context,
                    light: Colors.white,
                    dark: AppThemeDark.surfaceDefault,
                  ),
                  border: Border.all(
                    color: AppThemeColors.resolve(
                      context,
                      light: AppColors.cardBorder,
                      dark: AppThemeDark.borderSubtle,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: _SettingsRow(
                  icon: Icons.contact_support_outlined,
                  label: 'Contact Us',
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.contactUs),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Triply for Guides · Version 1.0.0',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppThemeColors.resolve(
                    context,
                    light: AppColors.subtitle,
                    dark: AppThemeDark.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsThemeRow extends StatelessWidget {
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const _SettingsThemeRow({required this.isDark, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.dark_mode_outlined,
            size: 20,
            color: AppThemeColors.resolve(
              context,
              light: AppColors.priceTeal,
              dark: AppThemeDark.homeSeeAll,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Dark mode',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppThemeColors.resolve(
                  context,
                  light: AppColors.priceTeal,
                  dark: AppThemeDark.homeSectionTitle,
                ),
              ),
            ),
          ),
          Switch(value: isDark, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _SettingsRow({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: AppThemeColors.resolve(
                context,
                light: AppColors.priceTeal,
                dark: AppThemeDark.homeSeeAll,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppThemeColors.resolve(
                    context,
                    light: AppColors.priceTeal,
                    dark: AppThemeDark.textPrimary,
                  ),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: AppThemeColors.resolve(
                context,
                light: AppColors.subtitle,
                dark: AppThemeDark.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
