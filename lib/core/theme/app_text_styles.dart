import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Canonical text styles. Home styles use the default font (const),
/// trips styles use Poppins (getters).
class AppTextStyles {
  AppTextStyles._();

  // ================= Home =================
  static const TextStyle heroTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Color.fromARGB(255, 255, 255, 255),
    height: 1.2,
  );
  static const TextStyle heroSubtitle = TextStyle(
    fontSize: 12,
    letterSpacing: 1.2,
    color: Color.fromARGB(179, 255, 255, 255),
    fontWeight: FontWeight.w500,
  );
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18,
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
    color: Colors.white,
  );
  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 12,
    color: Colors.white70,
  );
  static const TextStyle body =
      TextStyle(fontSize: 14, color: AppColors.textDark);
  static const TextStyle bodyGrey =
      TextStyle(fontSize: 13, color: AppColors.textGrey);
  static const TextStyle price = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.accentOrange,
  );

  // ================= Trips (Poppins) =================
  static TextStyle get screenTitle => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.titleDark,
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
        color: Colors.white,
      );
}


