import 'package:flutter/material.dart';

/// Resolves a screen color without changing its existing light-mode value.
class AppThemeColors {
  AppThemeColors._();

  static Color resolve(
    BuildContext context, {
    required Color light,
    required Color dark,
  }) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }
}
