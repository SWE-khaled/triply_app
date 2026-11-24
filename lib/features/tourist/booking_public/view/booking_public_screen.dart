import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triply/core/routing/app_routes.dart';
import '../../../../core/helper/price_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/app_theme_dark.dart';
import '../../../../core/widgets/circle_back_button.dart';
import '../../checkout/view/payment_view.dart';
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
  final TextEditingController requestsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Trip → details mapping and the seats/availability link belong to the
    // cubit; the View only supplies the trip it was opened with.
    context.read<BookingPublicCubit>().prepareTrip(widget.trip);
  }

  @override
  void dispose() {
    requestsController.dispose();
    super.dispose();
  }

  /// UI-only dispatch: the booking is created as `pending`/`pending` with its
  /// seats reserved first; only a successful Paymob payment confirms it.
  void _confirm() {
    final cubit = context.read<BookingPublicCubit>();
    cubit.createBooking(
      tripId: widget.trip.id,
      unitPrice: cubit.details.priceEgp,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingPublicCubit, BookingPublicState>(
      listener: (context, state) {
        final request = state.request;
        if (request is BookingPublicRequestFailed) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(request.message)));
          return;
        }
        final cubit = context.read<BookingPublicCubit>();
        final details = cubit.details;
        if (request is BookingPublicRequestCreated) {
          final navigator = Navigator.of(context);
          final messenger = ScaffoldMessenger.of(context);
          final bookingId = request.bookingId;
          navigator.push(
            MaterialPageRoute(
              builder: (_) => PaymentView(
                price: cubit.total(details.priceEgp),
                flow: PaymentFlow.publicBooking,
                onPaymentSuccess: () => cubit.confirmPayment(
                  bookingId: bookingId,
                  // The Paymob callback has no transaction id, so the
                  // booking id doubles as the payment id (test-only demo).
                  paymentId: bookingId,
                ),
                onPaymentError: () => messenger.showSnackBar(
                  const SnackBar(
                    content: Text('The payment failed. Please try again.'),
                  ),
                ),
              ),
            ),
          );
          return;
        }
        if (request is BookingPublicRequestConfirmed) {
          Navigator.of(context).pushAndRemoveUntil(
            AppRoutes.bookingConfirmed(
              trip: widget.trip,
              details: details,
              seats: cubit.state.seats,
              total: cubit.total(details.priceEgp),
            ),
            (route) => route.isFirst,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppThemeColors.resolve(
          context,
          light: AppColors.background,
          dark: AppThemeDark.backgroundPrimary,
        ),
        appBar: AppBar(
          backgroundColor: AppThemeColors.resolve(
            context,
            light: AppColors.background,
            dark: AppThemeDark.backgroundPrimary,
          ),
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: CircleBackButton(
              backgroundColor: AppThemeColors.resolve(
                context,
                light: Colors.white,
                dark: AppThemeDark.surfaceDefault,
              ),
              iconColor: AppThemeColors.resolve(
                context,
                light: Colors.black,
                dark: AppThemeDark.iconPrimary,
              ),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Join Trip',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppThemeColors.resolve(
                    context,
                    light: AppColors.title,
                    dark: AppThemeDark.homeSectionTitle,
                  ),
                ),
              ),
              Text(
                widget.trip.title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppThemeColors.resolve(
                    context,
                    light: AppColors.subtitle,
                    dark: AppThemeDark.homeGuideSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: BlocBuilder<BookingPublicCubit, BookingPublicState>(
          builder: (context, state) {
            final cubit = context.read<BookingPublicCubit>();
            final details = cubit.details;
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
                      border: Border.all(
                        color: AppThemeColors.resolve(
                          context,
                          light: AppColors.cardBorder,
                          dark: AppThemeDark.homeGuideBorder,
                        ),
                      ),
                      color: AppThemeColors.resolve(
                        context,
                        light: Colors.transparent,
                        dark: AppThemeDark.homeGuideSurface,
                      ),
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
                                  color: AppThemeColors.resolve(
                                    context,
                                    light: AppColors.title,
                                    dark: AppThemeDark.homeGuideName,
                                  ),
                                ),
                              ),
                              TextSpan(
                                text: '(optional)',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppThemeColors.resolve(
                                    context,
                                    light: AppColors.subtitle,
                                    dark: AppThemeDark.homeGuideSecondary,
                                  ),
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
                              color: AppThemeColors.resolve(
                                context,
                                light: AppColors.subtitle,
                                dark: AppThemeDark.textDisabled,
                              ),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.only(top: 8),
                          ),
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppThemeColors.resolve(
                              context,
                              light: AppColors.title,
                              dark: AppThemeDark.textPrimary,
                            ),
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
                final cubit = context.read<BookingPublicCubit>();
                final total = cubit.total(cubit.details.priceEgp);
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.request is BookingPublicRequestLoading
                        ? null
                        : _confirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppThemeColors.resolve(
                        context,
                        light: AppColors.tabSelectedBg,
                        dark: AppThemeDark.homeSeeAll,
                      ),
                      foregroundColor: AppThemeColors.resolve(
                        context,
                        light: Colors.white,
                        dark: AppThemeDark.backgroundPrimary,
                      ),
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
      ),
    );
  }
}
