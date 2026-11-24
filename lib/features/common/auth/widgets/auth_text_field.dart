import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:triply/core/theme/app_colors.dart';
import 'package:triply/core/theme/app_theme_colors.dart';
import 'package:triply/core/theme/app_theme_dark.dart';

class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  /// Optional leading widget (e.g. a country-code prefix). Rendered inside
  /// the field next to [icon] without changing the existing design.
  final Widget? prefix;
  final List<TextInputFormatter>? inputFormatters;
  final bool themeAware;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefix,
    this.inputFormatters,
    this.themeAware = false,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    Color fieldColor(Color light, Color dark) => widget.themeAware
        ? AppThemeColors.resolve(context, light: light, dark: dark)
        : light;

    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscureText : false,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      validator: widget.validator,
      style: TextStyle(
        color: fieldColor(AppColors.textDark, AppThemeDark.textPrimary),
        fontSize: 15,
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: fieldColor(AppColors.textGrey, AppThemeDark.textDisabled),
        ),
        prefixIcon: Icon(
          widget.icon,
          color: fieldColor(AppColors.iconGrey, AppThemeDark.iconSecondary),
        ),
        prefix: widget.prefix,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: fieldColor(
                    AppColors.iconGrey,
                    AppThemeDark.iconSecondary,
                  ),
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : null,
        filled: true,
        fillColor: fieldColor(
          AppColors.fieldBackground,
          AppThemeDark.backgroundSecondary,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: fieldColor(
              AppColors.fieldBorder,
              AppThemeDark.borderDefault,
            ),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: fieldColor(
              AppColors.fieldBorder,
              AppThemeDark.borderDefault,
            ),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: fieldColor(
              AppColors.signInDark,
              AppThemeDark.actionSecondary,
            ),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
