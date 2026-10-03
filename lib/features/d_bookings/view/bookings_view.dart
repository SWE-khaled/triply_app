import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/circle_back_button.dart';
import '../../../data/mock/mock_notifications.dart';
import '../../d_home/view/home_view.dart';

/// Bookings management screen.
class BookingsView extends StatefulWidget {
  const BookingsView({super.key});

  @override
  State<BookingsView> createState() => _BookingsViewState();
}

class _BookingsViewState extends State<BookingsView> {
  final TextEditingController _search = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AdminCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: CardSectionHeader(
                    title: 'Manage Bookings',
                    subtitle: 'Search, review, edit and control all bookings.',
                  ),
                ),

              ],
            ),
            const SizedBox(height: 20),

            SearchFilterRow(
              hintText: 'Search bookings...',
              controller: _search,
            ),
            const SizedBox(height: 24),

            // "Recent Bookings" section
            Row(
              children: [
                Text('Recent Bookings', style: AppTextStyles.sectionTitle),
                const Spacer(),
                Text(
                  'View All',
                  style: AppTextStyles.linkText.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Table header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  _h('User', 3),
                  _h('Trip', 3),
                  _h('Guide', 3),
                  _h('Date', 2),
                  _h('Status', 2),
                  _h('Price', 2),
                  _h('Type', 2),
                ],
              ),
            ),
            const Divider(color: AppColors.divider, height: 1),

            ...mockBookings.map((b) => _BookingRow(booking: b)),
          ],
        ),
      ),
    );
  }

  Widget _h(String label, int flex) => Expanded(
        flex: flex,
        child: Text(label, style: AppTextStyles.tableHeader),
      );
}

class _BookingRow extends StatelessWidget {
  final MockBooking booking;
  const _BookingRow({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(color: AppColors.divider, height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(booking.user, style: AppTextStyles.tableCell),
              ),
              Expanded(
                flex: 3,
                child: Text(booking.trip, style: AppTextStyles.tableCellMuted),
              ),
              Expanded(
                flex: 3,
                child: Text(booking.guide, style: AppTextStyles.tableCellMuted),
              ),
              Expanded(
                flex: 2,
                child: Text(booking.date, style: AppTextStyles.tableCellMuted),
              ),
              Expanded(
                flex: 2,
                child: StatusChip(status: booking.status),
              ),
              Expanded(
                flex: 2,
                child: Text(booking.price, style: AppTextStyles.tableCellMuted),
              ),
              Expanded(
                flex: 2,
                child: Text(booking.type, style: AppTextStyles.linkText),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
