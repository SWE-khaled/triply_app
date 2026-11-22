import 'dart:io';
import 'package:triply/core/theme/app_colors.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Single story-photo preview extracted from `_SelectedImagePreview`.
class SelectedImagePreview extends StatelessWidget {
  final XFile image;
  final VoidCallback onRemove;
  final VoidCallback onReplace;

  const SelectedImagePreview({
    super.key,
    required this.image,
    required this.onRemove,
    required this.onReplace,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onReplace,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(image.path),
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.overlayScrim.withValues(alpha: 0.54),
                  shape: BoxShape.circle,
                ),
                child:  Icon(Icons.close, size: 18, color: AppColors.surfaceDefault),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
