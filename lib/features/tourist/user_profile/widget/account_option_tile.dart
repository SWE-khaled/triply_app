import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/app_theme_dark.dart';

class AccountOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailingText;
  final bool? switchValue;
  final ValueChanged<bool>? onSwitchChanged;
  final VoidCallback? onTap;
  final bool showDivider;

  const AccountOptionTile({
    super.key,
    required this.icon,
    required this.title,
    this.trailingText,
    this.switchValue,
    this.onSwitchChanged,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: switchValue != null ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppThemeColors.resolve(
                      context,
                      light: AppColors.inputFill,
                      dark: AppThemeDark.surfaceElevated,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    color: AppThemeColors.resolve(
                      context,
                      light: AppColors.guidesName,
                      dark: AppThemeDark.homeSeeAll,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppThemeColors.resolve(
                        context,
                        light: AppColors.guidesName,
                        dark: AppThemeDark.homeGuideName,
                      ),
                    ),
                  ),
                ),
                if (switchValue != null)
                  Switch(
                    value: switchValue!,
                    activeThumbColor: AppThemeColors.resolve(
                      context,
                      light: AppColors.guidesName,
                      dark: AppThemeDark.homeSeeAll,
                    ),
                    onChanged: onSwitchChanged,
                  )
                else ...[
                  if (trailingText != null)
                    Text(
                      trailingText!,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppThemeColors.resolve(
                          context,
                          light: AppColors.textGrey,
                          dark: AppThemeDark.homeGuideSecondary,
                        ),
                      ),
                    ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    size: 22,
                    color: AppThemeColors.resolve(
                      context,
                      light: AppColors.textGrey,
                      dark: AppThemeDark.homeGuideSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 72,
            color: AppThemeColors.resolve(
              context,
              light: const Color(0xFFEEEEEE),
              dark: AppThemeDark.borderSubtle,
            ),
          ),
      ],
    );
  }
}
