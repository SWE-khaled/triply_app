import 'package:flutter/material.dart';
import 'package:triply/core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/app_theme_dark.dart';
import '../../../../core/widgets/circle_back_button.dart';
import '../widget/account_option_tile.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardDecoration = BoxDecoration(
      color: AppThemeColors.resolve(
        context,
        light: Colors.grey.withValues(alpha: .1),
        dark: AppThemeDark.homeGuideSurface,
      ),
      borderRadius: BorderRadius.circular(20),
      border: isDark ? Border.all(color: AppThemeDark.homeGuideBorder) : null,
    );

    return Scaffold(
      backgroundColor: AppThemeColors.resolve(
        context,
        light: AppColors.background,
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
                      dark: AppThemeDark.iconPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Privacy & security',
                    style: AppTextStyles.pageTitle.copyWith(
                      color: AppThemeColors.resolve(
                        context,
                        light: AppColors.textDark,
                        dark: AppThemeDark.homeSectionTitle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: cardDecoration,
                child: Column(
                  children: [
                    AccountOptionTile(
                      icon: Icons.lock_reset_outlined,
                      title: 'Reset password',
                      showDivider: false,
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.forgotPassword),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
