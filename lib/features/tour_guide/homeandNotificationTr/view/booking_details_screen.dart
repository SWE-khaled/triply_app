import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/circle_back_button.dart';
import '../../../../../core/widgets/network_image_fallback.dart';
import '../controller/booking_details_controller.dart';
import '../widget/booking_type_pill.dart';

/// Cream tint from Figma (back button). Local const only — the global
/// theme in `core/theme/` is left untouched.
const Color _cream = Color(0xFFFAF5EA);

/// Traveler profile + trip booking details for one New Booking.
/// Opened from [DashboardScreen] with a booking id.
class BookingDetailsScreen extends StatefulWidget {
  final String bookingId;

  const BookingDetailsScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  late final BookingDetailsController controller;

  @override
  void initState() {
    super.initState();
    controller = BookingDetailsController(bookingId: widget.bookingId);
    controller.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    controller.removeListener(_refresh);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final details = controller.details;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  CircleBackButton(
                    backgroundColor: _cream,
                    iconColor: AppColors.title,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Booking Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.title,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (details == null)
                const Text(
                  'Booking not found.',
                  style: TextStyle(fontSize: 13, color: AppColors.subtitle),
                )
              else ...[
                _guestCard(),
                const SizedBox(height: 16),
                _tripCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _guestCard() {
    final details = controller.details!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          ClipOval(
            child: NetworkImageFallback(
              imageUrl: details.avatarUrl,
              width: 72,
              height: 72,
              fallbackIcon: Icons.person_outline,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            details.guestName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.title,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${details.country} · ${details.travelerLabel}',
            style: const TextStyle(fontSize: 13, color: AppColors.subtitle),
          ),
          const SizedBox(height: 12),
          BookingTypePill(isPrivate: details.isPrivate),
        ],
      ),
    );
  }

  Widget _tripCard() {
    final details = controller.details!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            details.tourTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.title,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            details.datetimeLabel,
            style: const TextStyle(fontSize: 13, color: AppColors.subtitle),
          ),
          const SizedBox(height: 6),
          Text(
            details.location,
            style: const TextStyle(fontSize: 13, color: AppColors.subtitle),
          ),
          const SizedBox(height: 6),
          Text(
            'Booking #${details.bookingCode} · ${details.priceLabel}',
            style: const TextStyle(fontSize: 13, color: AppColors.subtitle),
          ),
        ],
      ),
    );
  }
}
