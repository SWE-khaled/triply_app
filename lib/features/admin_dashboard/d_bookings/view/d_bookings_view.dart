import 'package:flutter/material.dart';
import '../../../../core/theme/d_app_colors.dart';
import '../../../../core/theme/d_app_text_styles.dart';
import '../../../../core/widgets/d_circle_back_button.dart';
import '../../../../data/mock/d_mock_notifications.dart';
import '../../d_home/view/d_home_view.dart';

/// Bookings management screen.
class BookingsView extends StatefulWidget {
  const BookingsView({super.key});

  @override
  State<BookingsView> createState() => _BookingsViewState();
}

class _BookingsViewState extends State<BookingsView> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  List<MockBooking> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return mockBookings;
    return mockBookings.where((b) {
      return b.user.toLowerCase().contains(q) ||
          b.trip.toLowerCase().contains(q) ||
          b.guide.toLowerCase().contains(q) ||
          b.date.toLowerCase().contains(q) ||
          b.status.toLowerCase().contains(q) ||
          b.type.toLowerCase().contains(q);
    }).toList();
  }

  void _showDetails(MockBooking booking) {
    showDialog(
      context: context,
      builder: (_) => _ViewBookingDialog(booking: booking),
    );
  }

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
              onChanged: (v) => setState(() => _query = v),
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
                  _h('Actions', 2, end: true),
                ],
              ),
            ),
            const Divider(color: AppColors.divider, height: 1),

            ..._filtered.map((b) => _BookingRow(
                  booking: b,
                  onView: () => _showDetails(b),
                )),
            if (_filtered.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('No bookings found.')),
              ),
          ],
        ),
      ),
    );
  }

  Widget _h(String label, int flex, {bool end = false}) => Expanded(
        flex: flex,
        child: Text(
          label,
          style: AppTextStyles.tableHeader,
          textAlign: end ? TextAlign.end : TextAlign.start,
        ),
      );
}

class _BookingRow extends StatelessWidget {
  final MockBooking booking;
  final VoidCallback onView;
  const _BookingRow({required this.booking, required this.onView});

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
                child: Text(booking.user,
                    style: AppTextStyles.tableCell,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1),
              ),
              Expanded(
                flex: 3,
                child: Text(booking.trip,
                    style: AppTextStyles.tableCellMuted,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1),
              ),
              Expanded(
                flex: 3,
                child: Text(booking.guide,
                    style: AppTextStyles.tableCellMuted,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1),
              ),
              Expanded(
                flex: 2,
                child: Text(booking.date,
                    style: AppTextStyles.tableCellMuted,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1),
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
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlineActionButton(label: 'View', onTap: onView),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Booking details dialog (all fields the current model supports).
class _ViewBookingDialog extends StatelessWidget {
  final MockBooking booking;
  const _ViewBookingDialog({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Booking Details',
                        style: AppTextStyles.dialogTitle),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.divider),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Close',
                          style: AppTextStyles.buttonSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _row('Tourist:', booking.user),
              _row('Trip:', booking.trip),
              _row('Tour Guide:', booking.guide),
              _row('Date:', booking.date),
              _row('Price:', booking.price),
              _row('Total:', booking.price),
              _row('Status:', booking.status.toUpperCase()),
              _row('Type:', booking.type),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: AppTextStyles.fieldLabel),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.tableCell),
          ),
        ],
      ),
    );
  }
}
