import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/helper/price_format.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/trip_details_source.dart';
import '../../trip_details/model/trip_details.dart';
import '../../trips/models/trip.dart';
import '../cubit/booking_cubit.dart';
import '../cubit/booking_state.dart';
import '../widgets/booking_summary_card.dart';
import '../widgets/price_breakdown.dart';
import '../widgets/seats_stepper.dart';

class BookingScreen extends StatefulWidget {
  final Trip trip;

  const BookingScreen({super.key, required this.trip});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late final TripDetails details;
  final TextEditingController requestsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    details = const TripDetailsSource().getByTripId(
      widget.trip.id,
      title: widget.trip.title,
      imageUrl: widget.trip.imageUrl,
      priceEgp: widget.trip.priceEgp,
      guideName: widget.trip.guideName,
    );
    // Seats left = capacity - people already on the trip (card number).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<BookingCubit>().setMaxSpots(
        widget.trip.capacity - widget.trip.peopleCount,
      );
    });
  }

  @override
  void dispose() {
    requestsController.dispose();
    super.dispose();
  }

  void _confirm(BuildContext context) {
    final cubit = context.read<BookingCubit>();
    final booking = cubit.confirm(
      tripId: widget.trip.id,
      unitPrice: details.priceEgp,
    );
    Navigator.of(context).pushReplacement(
      AppRoutes.bookingConfirmed(
        trip: widget.trip,
        details: details,
        seats: booking.seats,
        total: booking.total,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            color: AppColors.title,
            size: 26,
          ),
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
      body: BlocBuilder<BookingCubit, BookingState>(
        builder: (context, state) {
          final cubit = context.read<BookingCubit>();
          final total = cubit.total(details.priceEgp);
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BookingSummaryCard(
                  details: details,
                  dateLabel: widget.trip.dateLabel,
                ),
                const SizedBox(height: 12),
                SeatsStepper(
                  seats: state.seats,
                  spotsAvailable: state.maxSpots,
                  onDecrement: () => cubit.changeSeats(state.seats - 1),
                  onIncrement: () => cubit.changeSeats(state.seats + 1),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.cardBorder),
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
                        onChanged: cubit.changeRequests,
                        decoration: InputDecoration(
                          hintText:
                              'Any dietary needs, accessibility requirements, or special requests...',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.subtitle,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.only(top: 8),
                        ),
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.title,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                PriceBreakdown(
                  unitPrice: details.priceEgp,
                  seats: state.seats,
                  fee: cubit.fee(details.priceEgp),
                  total: total,
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: BlocBuilder<BookingCubit, BookingState>(
            builder: (context, state) {
              final total = context.read<BookingCubit>().total(
                details.priceEgp,
              );
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _confirm(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tabSelectedBg,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                    textStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Text('Confirm & Pay — EGP ${formatEgp(total)}'),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
