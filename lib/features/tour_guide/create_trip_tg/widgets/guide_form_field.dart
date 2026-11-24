import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/app_theme_dark.dart';

/// Cream form field + teal section label shared by the Create Trip form.
class GuideFormLabel extends StatelessWidget {
  final String text;

  const GuideFormLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppThemeColors.resolve(
          context,
          light: AppColors.priceTeal,
          dark: AppThemeDark.homeSeeAll,
        ),
      ),
    );
  }
}

class GuideFormField extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final bool readOnly;
  final VoidCallback? onTap;

  const GuideFormField({
    super.key,
    required this.hint,
    this.onChanged,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppThemeColors.resolve(
          context,
          light: const Color(0xFFFBF6EC),
          dark: AppThemeDark.surfaceElevated,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        maxLines: maxLines,
        minLines: maxLines > 1 ? 3 : 1,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            fontSize: 12,
            color: AppThemeColors.resolve(
              context,
              light: AppColors.hint,
              dark: AppThemeDark.textDisabled,
            ),
          ),
          border: InputBorder.none,
        ),
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: AppThemeColors.resolve(
            context,
            light: AppColors.textDark,
            dark: AppThemeDark.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// Two labeled fields side by side.
class GuideTwoCol extends StatelessWidget {
  final String leftLabel;
  final Widget leftField;
  final String rightLabel;
  final Widget rightField;

  const GuideTwoCol({
    super.key,
    required this.leftLabel,
    required this.leftField,
    required this.rightLabel,
    required this.rightField,
  });

  @override
  Widget build(BuildContext context) {
    Widget col(String label, Widget field) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GuideFormLabel(text: label),
            const SizedBox(height: 6),
            field,
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        col(leftLabel, leftField),
        const SizedBox(width: 10),
        col(rightLabel, rightField),
      ],
    );
  }
}

/// Small teal "+ Add ..." row action.
class GuideAddRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const GuideAddRow({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppThemeColors.resolve(
                context,
                light: AppColors.priceTeal,
                dark: AppThemeDark.homeSeeAll,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Round × remove button for dynamic rows.
class GuideRemoveButton extends StatelessWidget {
  final VoidCallback onTap;

  const GuideRemoveButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppThemeColors.resolve(
            context,
            light: const Color(0xFFFDE8E0),
            dark: AppThemeDark.surfaceElevated,
          ),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.close,
          size: 15,
          color: AppThemeColors.resolve(
            context,
            light: AppColors.accentOrange,
            dark: AppThemeDark.homeGuidePrice,
          ),
        ),
      ),
    );
  }
}
