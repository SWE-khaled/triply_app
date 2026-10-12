import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/data/my_bookings_public.dart';
import '../../../../core/helper/price_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/circle_back_button.dart';
import '../../../../core/data/trip_details_source.dart';
import '../../../../data/firestore/models/booking_doc.dart';
import '../../../../data/firestore/repositories/bookings_repository.dart';
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

  /// Confirm & Pay: creates the authoritative server booking FIRST
  /// (`createBooking`: atomic capacity check + server pricing), records a
  /// `pending` payment reconciliation entry, then runs the existing
  /// checkout flow with the SERVER totals. The trip is only recorded
  /// locally after server-side verification reports `succeeded` — a
  /// WebView redirect alone never confirms anything, and a backend
  /// failure records nothing and shows an error instead.
  Future<void> _confirm(BuildContext context) async {
    final cubit = context.read<BookingPublicCubit>();
    if (cubit.state.isSubmitting) return;
    final trip = widget.trip;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final repository = BookingsRepository();
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
    BookingDoc? booking;
    try {
      booking = await cubit.submitBooking(
        repository: repository,
        uid: uid,
        trip: trip,
      );
    } catch (e) {
      if (!mounted) return;
      navigator.pop(); // Dismiss the loading dialog.
      messenger.showSnackBar(SnackBar(content: Text(_bookingError(e))));
      return;
    }
    if (!mounted) return;
    navigator.pop(); // Dismiss the loading dialog.
    if (booking == null) return; // Duplicate tap while submitting.
    final doc = booking;
    final summary = CheckoutBookingSummary(
      guideId: doc.guideId,
      guideName: trip.guideName,
      guideSpecialty: '',
      guideAvatarUrl: '',
      dateLabel: trip.dateLabel,
      timeSlot: '',
      durationLabel: details.duration,
      travelers: doc.seats,
      meetingPoint: doc.meetingPoint.isNotEmpty
          ? doc.meetingPoint
          : details.meetingPoint,
      pricePerHour: doc.unitPrice,
      currency: doc.currency,
      serviceFee: doc.serviceFee,
      total: doc.totalAmount,
    );
    final checkout = CheckoutController(summary: summary);
    final token = await checkout.startPayment();
    if (!mounted) return;
    if (token == null) {
      final message = checkout.payError ?? 'Payment failed. Please try again.';
      checkout.dispose();
      messenger.showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    final orderId = checkout.lastOrderId;
    checkout.dispose(); // WebView only needs the strings below.
    // Pending reconciliation record (server amounts + Paymob order id)
    // BEFORE the iframe, so verification has something to reconcile.
    // Fails closed: without it there is nothing to verify against.
    String paymentId;
    try {
      paymentId = await repository.createPendingPayment(
        bookingId: doc.id,
        touristId: uid!,
        amount: doc.totalAmount,
        providerReference: orderId != null ? orderId.toString() : '',
      );
    } catch (e) {
      if (!mounted) return;
      // Fail closed with the actual cause (never a false success, never a
      // swallowed backend message). _bookingError maps scrubbed INTERNAL to
      // a friendly retry message via the repository.
      messenger.showSnackBar(SnackBar(content: Text(_bookingError(e))));
      return;
    }
    if (!mounted) return;
    navigator.push(
      MaterialPageRoute(
        builder: (_) => PaymobWebviewScreen(
          paymentToken: token,
          guideName: trip.guideName,
          onSuccess: () async {
            await _verifyAndConfirm(
              navigator,
              messenger,
              repository: repository,
              trip: trip,
              doc: doc,
              paymentId: paymentId,
            );
          },
        ),
      ),
    );
  }

  /// Verifies the payment server-side and only then records + confirms.
  /// Anything but `succeeded` leaves the booking unpaid: the user lands on
  /// My Trips (where the pending booking is visible) with an honest
  /// message — never a false confirmation.
  Future<void> _verifyAndConfirm(
    NavigatorState navigator,
    ScaffoldMessengerState messenger, {
    required BookingsRepository repository,
    required Trip trip,
    required BookingDoc doc,
    required String paymentId,
  }) async {
    messenger.showSnackBar(const SnackBar(content: Text('Verifying payment…')));
    try {
      final verdict = await repository.verifyPayment(paymentId);
      if (!mounted) return;
      if (verdict.status == 'succeeded') {
        // Verified paid: values are server-authoritative.
        MyBookingsPublic.record(trip.id, doc.seats, totalPaid: doc.totalAmount);
        navigator.pushReplacement(
          AppRoutes.bookingConfirmed(
            trip: trip,
            details: details,
            seats: doc.seats,
            total: doc.totalAmount,
          ),
        );
        return;
      }
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Payment received and is awaiting confirmation. '
            'You can check My Trips for updates.',
          ),
        ),
      );
      AppRoutes.goToMyTrips(navigator.context);
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(_bookingError(e))));
      AppRoutes.goToMyTrips(navigator.context);
    }
  }

  /// Repository errors already carry user-facing messages behind an
  /// `Exception:` prefix; anything else becomes a generic failure.
  /// Never logs tokens, payment data, or user identifiers.
  String _bookingError(Object e) {
    final text = e.toString();
    const prefix = 'Exception: ';
    final msg = text.startsWith(prefix) ? text.substring(prefix.length) : text;
    return msg.isEmpty ? 'Booking failed. Please try again.' : msg;
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
                  onPressed: state.isSubmitting
                      ? null
                      : () => _confirm(context),
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
