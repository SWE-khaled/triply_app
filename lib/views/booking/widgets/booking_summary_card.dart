import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/trip_details.dart';

class BookingSummaryCard extends StatelessWidget {
  final TripDetails details;
  final String dateLabel;

  const BookingSummaryCard(
      {super.key, required this.details, required this.dateLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Stack(
            children: [
              SizedBox(
                height: 190,
                width: double.infinity,
                child: Image.network(
                  details.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: const Color(0xFFE6ECEF),
                    child: const Icon(Icons.image,
                        color: AppColors.subtitle, size: 36),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.55),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 14,
                child: Text(
                  details.title,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _row(
                  icon: Icons.location_on,
                  iconColor: AppColors.pin,
                  label: 'Date & Time',
                  value: dateLabel,
                ),
                const SizedBox(height: 14),
                _peopleRow(),
                const SizedBox(height: 14),
                _row(
                  icon: Icons.schedule,
                  iconColor: AppColors.starGold,
                  label: 'Duration',
                  value: details.duration,
                ),
                const SizedBox(height: 14),
                _row(
                  icon: Icons.location_on,
                  iconColor: AppColors.dateText,
                  label: 'Meeting Point',
                  value: details.meetingPoint,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(Widget child) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _row({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tile(Icon(icon, size: 16, color: iconColor)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.guideLabel,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.title,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _peopleRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tile(SvgPicture.asset(
          AppAssets.iconPeople,
          width: 14,
          height: 14,
          colorFilter: const ColorFilter.mode(
            AppColors.guidedTourText,
            BlendMode.srcIn,
          ),
        )),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Guide',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.guideLabel,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                details.guideName,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.title,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
