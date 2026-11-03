import 'package:flutter/material.dart';

/// Central palette for the Triply app.
///
/// Use these in code as `AppColors.<name>` so every screen shares one
/// source of truth for colors.
class AppColors {
  AppColors._();

  // =========================================================================
  // Primary
  // =========================================================================
  static const Color primary = Color(0xFF0C4A56);
  static const Color primaryLight = Color(0xFFEAF3F4);
  static const Color primaryText = Color(0xFF0C4A56);
  static const Color primaryTeal = Color(0xFF0E5261);
  static const Color guidesName = Color.fromARGB(255, 35, 93, 89);
  static const Color deepNile = Color(0xFF0E5261);
  static const Color nileCyan = Color(0xFF196B7D);

  // =========================================================================
  // Backgrounds & surfaces
  // =========================================================================
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color softSand = Color(0xFFF9F8F3);
  static const Color warmCream = Color(0xFFF4F1EA);
  static const Color background = Colors.white;
  static const Color pageBackground = Color(0xFFF7F8F8);
  static const Color searchBg = Color(0xFFF2F4F4);
  static const Color chatIconBg = Color(0xFFF2F4F4);
  static const Color inputFill = Color(0xFFF2F2F2);
  static const Color fieldBackground = Color(0xFFF4F5F6);
  static const Color lightCircleBg = Color(0xFFEFF3F3);
  static const Color storyBg = Color(0xFFFFF8ED);

  // =========================================================================
  // Text
  // =========================================================================
  static const Color textPrimary = Color(0xFF0E5261);
  static const Color textSecondary = Color(0xFF6E8B90);
  static const Color textDark = Color(0xFF111827);
  static const Color textGrey = Color(0xFF8A8A8A);
  static const Color subtitle = Color(0xFF7A8A8E);
  static const Color hint = Color(0xFF9AA9AD);
  static const Color dateText = Color(0xFF526B72);
  static const Color guideLabel = Color(0xFF8A9EA3);
  static const Color title = Color(0xFF0E5261);
  static const Color titleDark = Color(0xFF111111);
  static const Color titleDetails = Color(0xFF0E5261);

  // =========================================================================
  // Borders & dividers
  // =========================================================================
  static const Color borderColor = Color(0x1A0E5261);
  static const Color iconGrey = Color(0xFF9AA5A9);
  static const Color cardBorder = Color(0xFFE5EAEA);
  static const Color cardShadow = Color(0x1A000000);
  static const Color fieldBorder = Color(0xFFE3E6E8);

  // =========================================================================
  // Accent
  // =========================================================================
  static const Color price = Color(0xFFE07B39);
  static const Color priceTeal = Color(0xFF0E5261);
  static const Color accentOrange = Color(0xFFE86A2C);
  static const Color pin = Color(0xFFE2703A);
  static const Color star = Color(0xFFF5A623);
  static const Color starGold = Color(0xFFD8B66A);
  static const Color iconDetails = Color(0xFF86A8B0);

  // =========================================================================
  // Tabs
  // =========================================================================
  static const Color tabSelectedBg = Color(0xFF0E5261);
  static final Color tabUnselectedBg = Colors.black.withValues(alpha: 0.06);
  static const Color tabUnselected = Color(0xffFBF7EF);

  // =========================================================================
  // Bottom nav
  // =========================================================================
  static const Color bottomNavSelected = Color(0xFF0E4B4A);
  static const Color bottomNavUnselected = Color(0xFFB0BEC5);

  // =========================================================================
  // Guided tour
  // =========================================================================
  static const Color guidedTourText = Color(0xFF4DA7A0);
  static final Color guidedTourBg = const Color(0xFF4DA7A0).withValues(alpha: 0.15);
  static const Color bulletGold = Color(0xFFD8B66A);
  static const Color chipGrey = Color(0xFFF0F3F3);
  static const Color chipTextGrey = Color(0xFF526B72);
  static const Color darkTeal = Color(0xFF0E4A56);
  static const Color darkTealEnd = Color(0xFF1C6670);
  static const Color mutedTeal = Color(0xFF7FA8AC);
  static const Color signInDark = Color(0xFF14555F);
  static const Color successTeal = Color(0xFF3FAE9A);

  // =========================================================================
  // Admin Dashboard (prefix: admin)
  // =========================================================================

  // Primary teal palette
  static const Color adminPrimary = Color(0xFF1B4F5C);
  static const Color adminPrimaryLight = Color(0xFFDEF0EE);

  // Backgrounds
  static const Color adminBackground = Color(0xFFECF0F5);
  static const Color adminCardBg = Color(0xFFFFFFFF);
  static const Color adminSidebarBg = Color(0xFFFFFFFF);
  static const Color adminInputBg = Color(0xFFF5F6F8);
  static const Color adminDocumentPreviewBg = Color(0xFFF7F4EF);

  // Text
  static const Color adminTextPrimary = Color(0xFF1A3344);
  static const Color adminTextSecondary = Color(0xFF6B7280);
  static const Color adminTextMuted = Color(0xFF9CA3AF);
  static const Color adminTextLink = Color(0xFF1B4F5C);

  // Status — Active / Approved / Confirmed
  static const Color adminStatusActiveBg = Color(0xFFDEF2EE);
  static const Color adminStatusActiveText = Color(0xFF0E7B6B);

  // Status — Pending
  static const Color adminStatusPendingBg = Color(0xFFF5EDD8);
  static const Color adminStatusPendingText = Color(0xFF7A5A20);

  // Status — Suspended / Inactive
  static const Color adminStatusSuspendedBg = Color(0xFFE5E7EB);
  static const Color adminStatusSuspendedText = Color(0xFF374151);

  // Status — Cancelled
  static const Color adminStatusCancelledBg = Color(0xFFFEE2E2);
  static const Color adminStatusCancelledText = Color(0xFFDC2626);

  // Danger / Destructive
  static const Color adminDanger = Color(0xFFD4504A);
  static const Color adminDangerLight = Color(0xFFFDECEA);

  // Divider & borders
  static const Color adminDivider = Color(0xFFE5E7EB);
  static const Color adminBorderLight = Color(0xFFEDF0F5);

  // Sidebar active item
  static const Color adminSidebarActiveBg = Color(0xFF1B4F5C);
  static const Color adminSidebarActiveText = Colors.white;
  static const Color adminSidebarInactiveText = Color(0xFF1B4F5C);

  // Misc
  static const Color adminLogoutRed = Color(0xFFD4504A);
  static const Color adminManageAllGreen = Color(0xFF1B4F5C);
  static const Color adminPendingChipBg = Color(0xFFF5EDD8);
  static const Color adminPendingChipText = Color(0xFF7A5A20);
  static const Color adminPositiveGreen = Color(0xFF0E7B6B);
  static const Color adminStatBadgeBg = Color(0xFFF0F3F6);
  static const Color adminStatBadgeText = Color(0xFF6B7280);
}
