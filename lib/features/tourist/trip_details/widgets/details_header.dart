import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/app_theme_dark.dart';
import '../../../../core/widgets/circle_back_button.dart';

class DetailsHeader extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onBack;

  const DetailsHeader({
    super.key,
    required this.imageUrl,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 300,
          width: double.infinity,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              color: AppThemeColors.resolve(
                context,
                light: const Color(0xFFE6ECEF),
                dark: AppThemeDark.backgroundTertiary,
              ),
              child: Icon(
                Icons.image,
                color: AppThemeColors.resolve(
                  context,
                  light: AppColors.subtitle,
                  dark: AppThemeDark.textSecondary,
                ),
                size: 40,
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                CircleBackButton(
                  icon: Icons.arrow_back_ios_new,
                  onTap: onBack,
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
                const Spacer(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
