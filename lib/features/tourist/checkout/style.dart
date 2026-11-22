import 'package:flutter/material.dart';
import 'package:triply/core/theme/app_colors.dart';

class Style {
  final Color? primaryColor,
      appBarBackgroundColor,
      appBarForegroundColor,
      unselectedColor,
      scaffoldColor,
      circleProgressColor;
  final TextStyle? textStyle;
  ButtonStyle? buttonStyle;
  // final bool? showMobileWalletIcons;

  Style({
    this.circleProgressColor,
    this.primaryColor,
    this.appBarBackgroundColor,
    this.appBarForegroundColor,
    this.unselectedColor,
    this.scaffoldColor,
    this.textStyle,
    this.buttonStyle,
    // this.showMobileWalletIcons = true,
  }) {
    buttonStyle =
        buttonStyle ??
        ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              10,
            ), // Moved here to prevent constant expression error
          ),
          backgroundColor: primaryColor,
          foregroundColor: AppColors.textPrimary,
        );
  }
}
