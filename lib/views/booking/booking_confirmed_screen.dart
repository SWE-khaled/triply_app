import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triply/core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/price_format.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../models/trip.dart';
import '../../models/trip_details.dart';

class BookingConfirmedScreen extends StatefulWidget {
  final Trip trip;
  final TripDetails details;
  final int seats;
  final double total;

  const BookingConfirmedScreen({
    super.key,
    required this.trip,
    required this.details,
    required this.seats,
    required this.total,
  });

  @override
  State<BookingConfirmedScreen> createState() => _BookingConfirmedScreenState();
}

class _BookingConfirmedScreenState extends State<BookingConfirmedScreen> {
  @override
  void initState() {
    super.initState();
    // Success message right after confirm lands on this screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showAppSnackBar(
        context,
        'Booking confirmed — see you on ${widget.trip.dateLabel}!',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    final details = widget.details;
    final seats = widget.seats;
    final total = widget.total;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
          child: Column(
            children: [
              const SizedBox(height: 50),
              Container(
                width: 80,
                height: 80,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF4DA7A0).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(AppAssets.iconConfirm),
              ),
              const SizedBox(height: 16),
              Text(
                'Booking Confirmed!',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.title,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.subtitle,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: "You've joined "),
                    TextSpan(
                      text: details.title,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dateText,
                        height: 1.5,
                      ),
                    ),
                    TextSpan(
                      text:
                          '. See you on ${trip.dateLabel.replaceAll('·', 'at')}!',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.09),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            details.imageUrl,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              width: 56,
                              height: 56,
                              color: const Color(0xFFE6ECEF),
                              child: const Icon(
                                Icons.image,
                                color: AppColors.subtitle,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                details.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.title,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                trip.dateLabel,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.guideLabel,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _cell(
                            'Seats',
                            '$seats ${seats == 1 ? 'person' : 'persons'}',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _cell('Meeting Point', details.meetingPoint),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _cell('Guide', details.guideName)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _cell(
                            'Total Paid',
                            'EGP ${formatEgp(total)}',
                            valueBold: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  // Back to the trip details (confirmed replaced booking,
                  // so one pop returns to TripDetailsScreen).
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tabSelectedBg,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                    textStyle: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Back to Trip'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cell(String label, String value, {bool valueBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.guideLabel),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.title,
          ),
        ),
      ],
    );
  }
}
