import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/helper/price_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/circle_back_button.dart';
import '../../../../core/data/trip_details_source.dart';
import '../../checkout/controller/checkout_controller.dart';
import '../../checkout/model/booking_model.dart';
import '../../checkout/view/paymob_webview_screen.dart';
import '../../trip_details/model/trip_details.dart';
import '../../trips/models/trip.dart';
import '../cubit/booking_public_cubit.dart';
import '../cubit/booking_public_state.dart';
import '../widgets/booking_summary_card.dart';
import '../widgets/price_breakdown.dart';
import '../widgets/seats_stepper.dart';

class BookingPublicScreen extends StatefulWidget {
  final Trip trip;

  const BookingPublicScreen({super.key, required this.trip});

  @override
  State<BookingPublicScreen> createState() => _BookingPublicScreenState();
}

class _BookingPublicScreenState extends State<BookingPublicScreen> {
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
      context.read<BookingPublicCubit>().setMaxSpots(
        widget.trip.capacity - widget.trip.peopleCount,
      );
    });
  }

  @override
  void dispose() {
    requestsController.dispose();
    super.dispose();
  }

  /// Confirm & Pay: runs checkout + Paymob first; the trip is only
  /// recorded (added to My Trips) after a successful payment.
  Future<void> _confirm(BuildContext context) async {
    final cubit = context.read<BookingPublicCubit>();
    final trip = widget.trip;
    final seats = cubit.state.seats;
    final summary = CheckoutBookingSummary(
      guideId: '',
      guideName: trip.guideName,
      guideSpecialty: '',
      guideAvatarUrl: '',
      dateLabel: trip.dateLabel,
      timeSlot: '',
      durationLabel: details.duration,
      travelers: seats,
      meetingPoint: details.meetingPoint,
      pricePerHour: details.priceEgp,
      currency: 'EGP',
      serviceFee: cubit.fee(details.priceEgp),
      total: cubit.total(details.priceEgp),
    );
    final checkout = CheckoutController(summary: summary);
    // Captured before the async gap (avoids BuildContext across awaits).
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
    final token = await checkout.startPayment();
    if (!mounted) return;
    navigator.pop(); // Dismiss the loading dialog.
    if (token == null) {
      final message =
          checkout.payError ?? 'Payment failed. Please try again.';
      checkout.dispose();
      messenger.showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    checkout.dispose(); // WebView only needs the token strings below.
    navigator.push(
      MaterialPageRoute(
        builder: (_) => PaymobWebviewScreen(
          paymentToken: token,
          guideName: trip.guideName,
          onSuccess: () {
            final booking = cubit.confirm(
              tripId: trip.id,
              unitPrice: details.priceEgp,
            );
            navigator.pushReplacement(
              AppRoutes.bookingConfirmed(
                trip: trip,
                details: details,
                seats: booking.seats,
                total: booking.total,
              ),
            );
          },
        ),
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
        leading: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: CircleBackButton(),
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
      body: BlocBuilder<BookingPublicCubit, BookingPublicState>(
        builder: (context, state) {
          final cubit = context.read<BookingPublicCubit>();
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
          child: BlocBuilder<BookingPublicCubit, BookingPublicState>(
            builder: (context, state) {
              final total = context.read<BookingPublicCubit>().total(
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
