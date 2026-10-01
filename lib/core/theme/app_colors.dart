import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ---- Primary ----
  static const Color primary = Color(0xFF0C4A56);
  static const Color primaryLight = Color(0xFFEAF3F4);
  static const Color primaryText = Color(0xFF0C4A56);
  static const Color primaryTeal = Color.fromARGB(255, 61, 139, 134);
  static const Color guidesName = Color.fromARGB(255, 35, 93, 89);

  // ---- Backgrounds ----
  static const Color background = Colors.white;
  static const Color pageBackground = Color(0xFFF7F8F8);
  static const Color searchBg = Color(0xFFF2F4F4);
  static const Color chatIconBg = Color(0xFFF2F4F4);
  static const Color inputFill = Color(0xFFF2F2F2);

  // ---- Borders & Shadows ----
  static const Color cardBorder = Color(0xFFE5EAEA);
  static const Color cardShadow = Color(0x1A000000);

  // ---- Text ----
  static const Color title = Color(0xFF0E5261);
  static const Color titleDark = Color(0xFF111111); // كان title في trips
  static const Color titleDetails = Color(0xFF0E5261);
  static const Color subtitle = Color(0xFF7A8A8E);
  static const Color hint = Color(0xFF9AA9AD);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGrey = Color(0xFF8A8A8A);
  static const Color dateText = Color(0xFF526B72);
  static const Color guideLabel = Color(0xFF8A9EA3);

  // ---- Accent ----
  static const Color price = Color(0xFFE07B39);
  static const Color priceTeal = Color(0xFF0E5261); // كان price في trips
  static const Color accentOrange = Color(0xFFE86A2C);
  static const Color pin = Color(0xFFE2703A);
  static const Color star = Color(0xFFF5A623);
  static const Color starGold = Color(0xFFD8B66A);
  static const Color iconDetails = Color(0xFF86A8B0);

  // ---- Tabs ----
  static const Color tabSelectedBg = Color(0xFF0E5261);
  static final Color tabUnselectedBg = Colors.black.withValues(alpha: 0.06);

  // ---- Bottom nav ----
  static const Color bottomNavSelected = Color(0xFF0E4B4A);
  static const Color bottomNavUnselected = Color(0xFFB0BEC5);

  // ---- Guided tour ----
  static const Color guidedTourText = Color(0xFF4DA7A0);
  static final Color guidedTourBg =
      const Color(0xFF4DA7A0).withValues(alpha: 0.15);
}
