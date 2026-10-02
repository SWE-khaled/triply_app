import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../model/community_post.dart';

/// Single image provider: local device file (composer posts) vs network URL.
Widget postImage(String path, bool isLocal, double height) {
  if (isLocal) {
    return Image.file(
      File(path),
      width: double.infinity,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        height: height,
        color: AppColors.chipGrey,
        child: const Icon(Icons.broken_image, color: Colors.grey),
      ),
    );
  }
  return Image.network(
    path,
    width: double.infinity,
    height: height,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) => Container(
      height: height,
      color: AppColors.chipGrey,
      child: const Icon(Icons.image, color: Colors.grey),
    ),
  );
}

/// Adaptive multi-image layout extracted from `_PostImages`.
class PostImages extends StatelessWidget {
  final CommunityPost post;

  const PostImages({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final paths = post.imageUrls;
    final isLocal = post.isLocalImage;

    if (paths.length <= 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: postImage(paths.first, isLocal, 200),
      );
    }
    if (paths.length == 2) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Expanded(child: postImage(paths[0], isLocal, 170)),
            const SizedBox(width: 4),
            Expanded(child: postImage(paths[1], isLocal, 170)),
          ],
        ),
      );
    }
    final rest = paths.sublist(1);
    final displayCount = rest.length > 4 ? 4 : rest.length;
    final overflow = rest.length - displayCount;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: postImage(paths.first, isLocal, 180),
        ),
        const SizedBox(height: 4),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
            childAspectRatio: 16 / 10,
          ),
          itemCount: displayCount,
          itemBuilder: (context, i) {
            if (i == displayCount - 1 && overflow > 0) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    postImage(rest[i], isLocal, double.infinity),
                    Container(
                      color: Colors.black54,
                      alignment: Alignment.center,
                      child: Text(
                        '+$overflow',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: postImage(rest[i], isLocal, double.infinity),
            );
          },
        ),
      ],
    );
  }
}
