import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SearchInput extends StatelessWidget {
  final String hint;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;

  const SearchInput({
    super.key,
    required this.hint,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: readOnly ? onTap : null,
      child: AbsorbPointer(
        absorbing: readOnly,
        child: TextField(
          readOnly: readOnly,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 14, color: AppColors.textGrey),
            prefixIcon: const Icon(Icons.search, color: AppColors.textDark),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}
