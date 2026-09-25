import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/booking_controller.dart';
import '../../controllers/trip_details_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/price_format.dart';
import '../../models/trip.dart';
import '../../models/trip_details.dart';
import 'booking_confirmed_screen.dart';
import 'widgets/booking_summary_card.dart';
import 'widgets/price_breakdown.dart';
import 'widgets/seats_stepper.dart';

class BookingScreen extends StatefulWidget {
  final Trip trip;

  const BookingScreen({super.key, required this.trip});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final BookingController bookingController = BookingController();
  final TripDetailsController detailsController =
      TripDetailsController();
  late final TripDetails details;
  int seats = 1;
  final TextEditingController requestsController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    details = detailsController.getByTripId(
      widget.trip.id,
      title: widget.trip.title,
      imageUrl: widget.trip.imageUrl,
      priceEgp: widget.trip.priceEgp,
      guideName: widget.trip.guideName,
    );
  }

  @override
  void dispose() {
    requestsController.dispose();
    super.dispose();
  }

  void _confirm() {
    final booking = bookingController.buildBooking(
      tripId: widget.trip.id,
      seats: seats,
      specialRequests: requestsController.text,
      unitPrice: details.priceEgp,
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => BookingConfirmedScreen(
          trip: widget.trip,
          details: details,
          seats: booking.seats,
          total: booking.total,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = bookingController.total(details.priceEgp, seats);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left,
              color: AppColors.title, size: 26),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Join Trip',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.title,
              ),
            ),
            Text(
              widget.trip.title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.subtitle,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BookingSummaryCard(
                details: details, dateLabel: widget.trip.dateLabel),
            const SizedBox(height: 12),
            SeatsStepper(
              seats: seats,
              onDecrement: () => setState(() => seats =
                  bookingController.clampSeats(seats - 1)),
              onIncrement: () => setState(() => seats =
                  bookingController.clampSeats(seats + 1)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border:
                    Border.all(color: AppColors.cardBorder),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Special Requests ',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.title,
                          ),
                        ),
                        TextSpan(
                          text: '(optional)',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.subtitle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextField(
                    controller: requestsController,
                    maxLines: 3,
                    minLines: 2,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText:
                          'Any dietary needs, accessibility requirements, or special requests...',
                      hintStyle: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.subtitle),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.only(top: 8),
                    ),
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: AppColors.title),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            PriceBreakdown(
              unitPrice: details.priceEgp,
              seats: seats,
              fee: bookingController.fee(details.priceEgp, seats),
              total: total,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _confirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tabSelectedBg,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
                textStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child:
                  Text('Confirm & Pay — EGP ${formatEgp(total)}'),
            ),
          ),
        ),
      ),
    );
  }
}
