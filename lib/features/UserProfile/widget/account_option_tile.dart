import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

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
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon,
                      size: 22, color: AppColors.guidesName),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.guidesName,
                    ),
                  ),
                ),
                if (switchValue != null)
                  Switch(
                    value: switchValue!,
                    activeThumbColor: AppColors.guidesName,
                    onChanged: onSwitchChanged,
                  )
                else ...[
                  if (trailingText != null)
                    Text(
                      trailingText!,
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.textGrey),
                    ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right,
                      size: 22, color: AppColors.textGrey),
                ],
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(height: 1, indent: 72, color: Color(0xFFEEEEEE)),
      ],
    );
  }
}