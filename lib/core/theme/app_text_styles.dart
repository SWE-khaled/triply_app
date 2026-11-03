import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ================= Home (Tourist) =================
  static const TextStyle heroTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.pureWhite,
    height: 1.2,
  );
  static TextStyle get heroSubtitle => TextStyle(
    fontSize: 12,
    letterSpacing: 1.2,
    color: AppColors.pureWhite.withValues(alpha: 0.7),
    fontWeight: FontWeight.w500,
  );
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );
  static const TextStyle pageTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );
  static const TextStyle seeAll = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryTeal,
  );
  static const TextStyle cardTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: AppColors.pureWhite,
  );
  static TextStyle get cardSubtitle => TextStyle(
    fontSize: 12,
    color: AppColors.pureWhite.withValues(alpha: 0.7),
  );
  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.textDark,
  );
  static const TextStyle bodyGrey = TextStyle(
    fontSize: 13,
    color: AppColors.textGrey,
  );
  static const TextStyle price = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.accentOrange,
  );

  // ================= Trips (Poppins) =================
  static TextStyle get screenTitle => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static TextStyle get screenSubtitle =>
      GoogleFonts.poppins(fontSize: 13, color: AppColors.guideLabel);

  static TextStyle get tripCardTitle => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.titleDark,
  );

  static TextStyle get tripSectionTitle => GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.titleDark,
  );

  static TextStyle get bodySmall =>
      GoogleFonts.poppins(fontSize: 12, color: AppColors.dateText);

  static TextStyle get labelGray =>
      GoogleFonts.poppins(fontSize: 11, color: AppColors.guideLabel);

  static TextStyle get priceLarge => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.priceTeal,
  );

  static TextStyle button({double size = 14}) => GoogleFonts.poppins(
    fontSize: size,
    fontWeight: FontWeight.w600,
    color: AppColors.pureWhite,
  );

  // =========================================================================
  // Admin Dashboard text styles (prefix: admin)
  // =========================================================================

  // ── Sidebar / Logo ──────────────────────────────────────
  static TextStyle get adminLogoTitle => GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.adminPrimary,
  );

  static TextStyle get adminLogoSubtitle => GoogleFonts.inter(
    fontSize: 9,
    fontWeight: FontWeight.w600,
    color: AppColors.adminTextMuted,
    letterSpacing: 1.8,
  );

  static TextStyle get adminNavItemActive => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle get adminNavItemInactive => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.adminPrimary,
  );

  static TextStyle get adminSidebarUserName => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.adminTextPrimary,
  );

  static TextStyle get adminSidebarUserRole => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.adminTextMuted,
  );

  static TextStyle get adminLogoutText => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.adminLogoutRed,
  );

  // ── Page Header ─────────────────────────────────────────
  static TextStyle get adminPageTitle => GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.adminTextPrimary,
  );

  static TextStyle get adminPageSubtitle => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.adminTextMuted,
  );

  static TextStyle get adminBadgeText => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.adminTextPrimary,
  );

  // ── Card / Section ──────────────────────────────────────
  static TextStyle get adminSectionTitle => GoogleFonts.inter(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.adminTextPrimary,
  );

  static TextStyle get adminSectionSubtitle => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.adminTextMuted,
  );

  // ── Stats ───────────────────────────────────────────────
  static TextStyle get adminStatValue => GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.adminTextPrimary,
  );

  static TextStyle get adminStatLabel => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.adminTextMuted,
  );

  static TextStyle get adminStatPercent => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.adminPositiveGreen,
  );

  static TextStyle get adminStatPercentDanger => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.adminDanger,
  );

  // ── Table ───────────────────────────────────────────────
  static TextStyle get adminTableHeader => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.adminTextMuted,
  );

  static TextStyle get adminTableCell => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.adminTextPrimary,
  );

  static TextStyle get adminTableCellMuted => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.adminTextMuted,
  );

  static TextStyle get adminLinkText => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.adminTextLink,
  );

  // ── Buttons ─────────────────────────────────────────────
  static TextStyle get adminButtonPrimary => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle get adminButtonDanger => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.adminDanger,
  );

  static TextStyle get adminButtonSecondary => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.adminTextPrimary,
  );

  static TextStyle get adminButtonOutline => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.adminTextSecondary,
  );

  // ── Dialog ──────────────────────────────────────────────
  static TextStyle get adminDialogTitle => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.adminTextPrimary,
  );

  static TextStyle get adminDialogSubtitle => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.adminTextMuted,
  );

  static TextStyle get adminFieldLabel => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.adminTextPrimary,
  );

  static TextStyle get adminFieldValue => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.adminTextPrimary,
  );

  // ── Misc ────────────────────────────────────────────────
  static TextStyle get adminPendingActionsCount => GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.adminTextPrimary,
  );

  static TextStyle get adminPostCardTitle => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.adminTextPrimary,
  );

  static TextStyle get adminPostCardAuthor => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.adminTextMuted,
  );
}
