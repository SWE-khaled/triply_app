import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Canonical text styles (Poppins). New code should use these instead of
/// inline GoogleFonts calls so typography stays consistent.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get screenTitle => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.title,
  );

  static TextStyle get screenSubtitle =>
      GoogleFonts.poppins(fontSize: 13, color: AppColors.subtitle);

  static TextStyle get cardTitle => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.title,
  );

  static TextStyle get sectionTitle => GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.title,
  );

  static TextStyle get bodySmall =>
      GoogleFonts.poppins(fontSize: 12, color: AppColors.dateText);

  static TextStyle get labelGray =>
      GoogleFonts.poppins(fontSize: 11, color: AppColors.subtitle);

  static TextStyle get priceLarge => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.price,
  );

  static TextStyle button({double size = 14}) => GoogleFonts.poppins(
    fontSize: size,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}
