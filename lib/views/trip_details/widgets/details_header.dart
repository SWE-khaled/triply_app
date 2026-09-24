import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class DetailsHeader extends StatelessWidget {
  final String imageUrl;
  final bool isFavorite;
  final VoidCallback onBack;
  final VoidCallback onFavorite;
  final VoidCallback onShare;

  const DetailsHeader({
    super.key,
    required this.imageUrl,
    required this.isFavorite,
    required this.onBack,
    required this.onFavorite,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 300,
          width: double.infinity,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              color: const Color(0xFFE6ECEF),
              child: const Icon(Icons.image,
                  color: AppColors.subtitle, size: 40),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _circleBtn(
                    icon: Icons.arrow_back_ios_new, onTap: onBack),
                const Spacer(),
                _circleBtn(
                  icon: isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  iconColor: isFavorite
                      ? AppColors.accentOrange
                      : Colors.white,
                  onTap: onFavorite,
                ),
                const SizedBox(width: 8),
                _circleBtn(
                    icon: Icons.share_outlined, onTap: onShare),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _circleBtn({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.25),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 17, color: iconColor),
      ),
    );
  }
}
