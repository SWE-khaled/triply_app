import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../model/guide_trip_details.dart';

class GuideDetailsInfo extends StatelessWidget {
  final GuideTripDetails details;

  const GuideDetailsInfo({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.guidedTourBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            details.tag,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.guidedTourText,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          details.title,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.titleDetails,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 2,
          children: [
            ...List.generate(
              5,
              (_) =>
                  const Icon(Icons.star, size: 13, color: AppColors.starGold),
            ),
            const SizedBox(width: 4),
            Text(
              details.rating.toString(),
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.title,
              ),
            ),
            Text(
              ' (${details.reviewsCount} reviews)',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.subtitle,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.location_on, size: 13, color: AppColors.pin),
            Text(
              details.location,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.subtitle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _meta(Icons.access_time, details.duration),
            const SizedBox(width: 14),
            _meta(Icons.group_outlined, details.groupType),
            const SizedBox(width: 14),
            Expanded(child: _meta(Icons.translate, details.languages)),
          ],
        ),
      ],
    );
  }

  Widget _meta(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.subtitle),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.dateText),
          ),
        ),
      ],
    );
  }
}
