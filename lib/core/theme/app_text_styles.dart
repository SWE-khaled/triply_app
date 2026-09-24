import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class AppTextStyles {
  static const TextStyle heroTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    height: 1.2,
  );
  static const TextStyle heroSubtitle = TextStyle(
    fontSize: 12,
    letterSpacing: 1.2,
    color: Colors.white70,
    fontWeight: FontWeight.w500,
  );
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );
  static const TextStyle seeAll = TextStyle(
    fontSize: 13,
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
  static const TextStyle body = TextStyle(fontSize: 14, color: AppColors.textDark);
  static const TextStyle bodyGrey = TextStyle(fontSize: 13, color: AppColors.textGrey);
  static const TextStyle price = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.accentOrange,
  );
}
