import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary teal palette
  static const Color primary = Color(0xFF1B4F5C);
  static const Color primaryLight = Color(0xFFDEF0EE);

  // Backgrounds
  static const Color background = Color(0xFFECF0F5);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color sidebarBg = Color(0xFFFFFFFF);
  static const Color inputBg = Color(0xFFF5F6F8);
  static const Color documentPreviewBg = Color(0xFFF7F4EF);

  // Text
  static const Color textPrimary = Color(0xFF1A3344);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textLink = Color(0xFF1B4F5C);

  // Status — Active / Approved / Confirmed
  static const Color statusActiveBg = Color(0xFFDEF2EE);
  static const Color statusActiveText = Color(0xFF0E7B6B);

  // Status — Pending
  static const Color statusPendingBg = Color(0xFFF5EDD8);
  static const Color statusPendingText = Color(0xFF7A5A20);

  // Status — Suspended / Inactive
  static const Color statusSuspendedBg = Color(0xFFE5E7EB);
  static const Color statusSuspendedText = Color(0xFF374151);

  // Status — Cancelled
  static const Color statusCancelledBg = Color(0xFFFEE2E2);
  static const Color statusCancelledText = Color(0xFFDC2626);

  // Danger / Destructive
  static const Color danger = Color(0xFFD4504A);
  static const Color dangerLight = Color(0xFFFDECEA);

  // Divider & borders
  static const Color divider = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFEDF0F5);

  // Sidebar active item
  static const Color sidebarActiveBg = Color(0xFF1B4F5C);
  static const Color sidebarActiveText = Colors.white;
  static const Color sidebarInactiveText = Color(0xFF1B4F5C);

  // Misc
  static const Color logoutRed = Color(0xFFD4504A);
  static const Color manageAllGreen = Color(0xFF1B4F5C);
  static const Color pendingChipBg = Color(0xFFF5EDD8);
  static const Color pendingChipText = Color(0xFF7A5A20);
  static const Color positiveGreen = Color(0xFF0E7B6B);
  static const Color statBadgeBg = Color(0xFFF0F3F6);
  static const Color statBadgeText = Color(0xFF6B7280);
}
