import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/data/repositories/admin_bookings_repository.dart';
import '../../../../core/theme/d_app_colors.dart';
import '../../../../core/theme/d_app_text_styles.dart';
import '../../../../core/widgets/d_circle_back_button.dart';
import '../../d_home/view/d_home_view.dart';

/// Bookings management screen (connected dynamically to Firestore).
class BookingsView extends StatefulWidget {
  const BookingsView({super.key});

  @override
  State<BookingsView> createState() => _BookingsViewState();
}

class _BookingsViewState extends State<BookingsView> {
  final TextEditingController _search = TextEditingController();
  final AdminBookingsRepository _repository = AdminBookingsRepository();

  List<AdminBooking> _bookings = const [];
  StreamSubscription<List<AdminBooking>>? _subscription;
  String _query = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _subscription = _repository.watchBookings().listen(
      (bookings) {
        if (!mounted) return;
        setState(() {
          _bookings = bookings;
          _loading = false;
        });
      },
      onError: (_) {
        if (!mounted) return;
        setState(() => _loading = false);
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _search.dispose();
    super.dispose();
  }

  List<AdminBooking> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _bookings;
    return _bookings.where((b) {
      return b.user.toLowerCase().contains(q) ||
          b.trip.toLowerCase().contains(q) ||
          b.guide.toLowerCase().contains(q) ||
          b.date.toLowerCase().contains(q) ||
          b.status.toLowerCase().contains(q) ||
          b.type.toLowerCase().contains(q);
    }).toList();
  }

  void _showDetails(AdminBooking booking) {
    showDialog(
      context: context,
      builder: (_) => _ViewBookingDialog(
        booking: booking,
        onStatusChange: (status) async {
          final ok = await _repository.updateStatus(booking.id, status);
          if (mounted && ok) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Booking marked as $status.')),
            );
          }
        },
      ),
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
                  '${_bookings.length} Total',
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

            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_filtered.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('No bookings found.')),
              )
            else
              ..._filtered.map(
                (b) => _BookingRow(booking: b, onView: () => _showDetails(b)),
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
  final AdminBooking booking;
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
                child: Text(
                  booking.user,
                  style: AppTextStyles.tableCell,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  booking.trip,
                  style: AppTextStyles.tableCellMuted,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  booking.guide,
                  style: AppTextStyles.tableCellMuted,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  booking.date,
                  style: AppTextStyles.tableCellMuted,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(flex: 2, child: StatusChip(status: booking.status)),
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
                  children: [OutlineActionButton(label: 'View', onTap: onView)],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Booking details dialog.
class _ViewBookingDialog extends StatelessWidget {
  final AdminBooking booking;
  final ValueChanged<String>? onStatusChange;

  const _ViewBookingDialog({
    required this.booking,
    this.onStatusChange,
  });

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
                    child: Text(
                      'Booking Details',
                      style: AppTextStyles.dialogTitle,
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.divider),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Close',
                        style: AppTextStyles.buttonSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _row('Booking Code:', booking.bookingCode),
              _row('Tourist:', booking.user),
              _row('Trip:', booking.trip),
              _row('Tour Guide:', booking.guide),
              _row('Date:', booking.date),
              _row('Travelers:', '${booking.travelers}'),
              if (booking.location.isNotEmpty) _row('Location:', booking.location),
              _row('Price:', booking.price),
              _row('Total:', booking.price),
              _row('Status:', booking.status.toUpperCase()),
              _row('Type:', booking.type),
              const SizedBox(height: 16),
              const Divider(color: AppColors.divider),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (booking.status != 'confirmed')
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onStatusChange?.call('confirmed');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: const Text('Confirm', style: TextStyle(color: Colors.white)),
                    ),
                  if (booking.status != 'confirmed') const SizedBox(width: 8),
                  if (booking.status != 'cancelled')
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onStatusChange?.call('cancelled');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(color: AppColors.danger),
                      ),
                      child: const Text('Cancel Booking'),
                    ),
                ],
              ),
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
            width: 110,
            child: Text(label, style: AppTextStyles.fieldLabel),
          ),
          Expanded(child: Text(value, style: AppTextStyles.tableCell)),
        ],
      ),
    );
  }
}
