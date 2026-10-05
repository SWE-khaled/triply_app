import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Sticky Preview / Submit bar. Fixed halves (no flex → ParentData-safe).
class FormBottomBar extends StatelessWidget {
  final double halfWidth;
  final VoidCallback onPreview;
  final VoidCallback onSubmit;
  final String submitLabel;

  const FormBottomBar({
    super.key,
    required this.halfWidth,
    required this.onPreview,
    required this.onSubmit,
    this.submitLabel = 'Submit for Approval',
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: halfWidth,
              child: GestureDetector(
                onTap: onPreview,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  // no `alignment` here, it makes the Container expand
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F1E7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Preview as Tourist',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: halfWidth,
              child: GestureDetector(
                onTap: onSubmit,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.tabSelectedBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    submitLabel,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.button(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
