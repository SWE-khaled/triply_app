import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../tourist/guides/model/guide.dart';

/// Cover photo + avatar + identity block (Figma header part).
/// Pure display: values + edit callback in, no controller.
class ProfileHeader extends StatelessWidget {
  final Guide guide;
  final String displayName;
  final String displayAvatar;
  final String? displayLocation;
  final String? displayPhone;
  final VoidCallback? onEdit;

  const ProfileHeader({
    super.key,
    required this.guide,
    required this.displayName,
    required this.displayAvatar,
    this.displayLocation,
    this.displayPhone,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      color: const Color(0xFF0E5261),
      padding: EdgeInsets.fromLTRB(16, topInset + 16, 16, 20),
      child: Stack(
        children: [
          // Content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      displayAvatar,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: const Color(0xFFE6ECEF),
                        child: const Icon(
                          Icons.person,
                          color: AppColors.subtitle,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: onEdit,
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        displayName,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (guide.isVerified)
                      Container(
                        width: 20,
                        height: 20,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4DA7A0),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 13,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  guide.specialty,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 13, color: AppColors.starGold),
                    const SizedBox(width: 3),
                    Text(
                      '${guide.rating} (${guide.reviewCount})',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.location_on,
                        size: 13, color: Colors.white),
                    const SizedBox(width: 2),
                    Text(
                      displayLocation ?? guide.location,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                if (displayPhone != null && displayPhone!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.phone, size: 13, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        displayPhone!,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Edit button
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: onEdit,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}