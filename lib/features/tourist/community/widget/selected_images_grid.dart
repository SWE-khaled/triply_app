import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:triply/core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/app_theme_dark.dart';

/// Multi-photo grid extracted from `_SelectedImagesGrid`.
class SelectedImagesGrid extends StatelessWidget {
  final List<XFile> images;
  final void Function(int index) onRemove;
  final VoidCallback onAddMore;

  const SelectedImagesGrid({
    super.key,
    required this.images,
    required this.onRemove,
    required this.onAddMore,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: images.length + 1,
      itemBuilder: (context, index) {
        if (index == images.length) {
          return GestureDetector(
            onTap: onAddMore,
            child: Container(
              decoration: BoxDecoration(
                color: AppThemeColors.resolve(
                  context,
                  light: AppColors.chipGrey,
                  dark: AppThemeDark.surfaceElevated,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.add_photo_alternate_outlined,
                color: AppThemeColors.resolve(
                  context,
                  light: AppColors.primaryTeal,
                  dark: AppThemeDark.actionSecondary,
                ),
              ),
            ),
          );
        }
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(images[index].path),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => onRemove(index),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
