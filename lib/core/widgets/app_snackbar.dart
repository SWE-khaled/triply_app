import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Shared styled SnackBar so every message looks the same.
/// Same arch: pure UI helper in core, no state, no packages.
void showAppSnackBar(
  BuildContext context,
  String msg, {
  IconData icon = Icons.check_circle,
  Duration duration = const Duration(seconds: 2),
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.tabSelectedBg,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 6,
        duration: duration,
      ),
    );
}
