import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/profile_avatar.dart';

/// Cover photo + avatar + identity block (Figma header part).
/// Pure display: values + edit callback in, no controller.
///
/// Every value comes from the signed-in guide's own account — the
/// tourist-facing listing of the mock guides is never used here.
class ProfileHeader extends StatelessWidget {
  /// The guide's name.
  final String displayName;

  /// The guide's photo URL, or the bundled default.
  final String displayAvatar;

  /// The location the guide set, or empty.
  final String? displayLocation;

  /// The phone number the guide set, or null.
  final String? displayPhone;

  /// Whether the admin approved this guide.
  final bool isVerified;

  /// The guide's specialty, or empty when they have not set one.
  final String specialty;

  /// The guide's average rating (0 when there are no reviews yet).
  final double rating;

  /// How many reviews the guide has (0 when there are none yet).
  final int reviewCount;

  final VoidCallback? onEdit;

  const ProfileHeader({
    super.key,
    required this.displayName,
    required this.displayAvatar,
    this.displayLocation,
    this.displayPhone,
    this.isVerified = false,
    this.specialty = '',
    this.rating = 0,
    this.reviewCount = 0,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      color: AppColors.actionPrimary,
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
                    border: Border.all(color: AppColors.borderStrong, width: 3),
                  ),
                  child: ClipOval(
                    child: ProfileAvatar(
                      imageUrl: displayAvatar,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // Long Firestore display names must shrink instead of
                    // pushing the verified badge off the card.
                    Expanded(
                      child: GestureDetector(
                        onTap: onEdit,
                        behavior: HitTestBehavior.opaque,
                        child: Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (isVerified)
                      Container(
                        width: 20,
                        height: 20,
                        alignment: Alignment.center,
                        decoration:  BoxDecoration(
                          color: AppColors.actionSecondary,
                          shape: BoxShape.circle,
                        ),
                        child:  Icon(
                          Icons.check,
                          size: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                  ],
                ),
                if (specialty.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    specialty,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textPrimary.withValues(alpha: 0.85),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (reviewCount > 0) ...[
                       Icon(
                        Icons.star,
                        size: 13,
                        color: AppColors.starGold,
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          '$rating ($reviewCount)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (displayLocation != null &&
                        displayLocation!.isNotEmpty) ...[
                       Icon(
                        Icons.location_on,
                        size: 13,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          displayLocation!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (displayPhone != null && displayPhone!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                       Icon(Icons.phone, size: 13, color: AppColors.textPrimary),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          displayPhone!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.textPrimary,
                          ),
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
                  color: AppColors.overlayScrim.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child:  Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
