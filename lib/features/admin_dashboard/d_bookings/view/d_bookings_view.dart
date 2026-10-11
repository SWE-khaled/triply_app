import 'package:flutter/material.dart';
import '../../../../core/theme/d_app_colors.dart';
import '../../../../core/theme/d_app_text_styles.dart';
import '../../../../core/widgets/d_circle_back_button.dart';
import '../../../../data/firestore/repositories/admin_repository.dart';
import '../../d_home/view/d_home_view.dart';

/// Bookings management screen (server-backed, read-only).
///
/// Rows come from the admin-only bookings list with resolved display
/// names. Payment/refund states are informational only: nothing here
/// marks paid or processes refunds.
class BookingsView extends StatefulWidget {
  const BookingsView({super.key});

  @override
  State<BookingsView> createState() => _BookingsViewState();
}

class _BookingsViewState extends State<BookingsView> {
  final TextEditingController _search = TextEditingController();
  final AdminRepository _repo = AdminRepository();
  List<AdminBookingRow> _rows = [];
  String _query = '';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await _repo.recentBookingRows();
      if (!mounted) return;
      setState(() {
        _rows = rows;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _message(e);
      });
    }
  }

  static String _message(Object e) {
    const prefix = 'Exception: ';
    final text = e.toString();
    final msg = text.startsWith(prefix) ? text.substring(prefix.length) : text;
    return msg.isEmpty ? 'Operation failed. Please try again.' : msg;
  }

  static String _dateLabel(AdminBookingRow row) {
    final b = row.booking;
    final date = b.tripDate ?? b.appointmentAt ?? b.createdAt;
    if (date == null) return '—';
    final d = date.toLocal();
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  List<AdminBookingRow> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _rows;
    return _rows.where((r) {
      final b = r.booking;
      return r.touristName.toLowerCase().contains(q) ||
          r.tripTitle.toLowerCase().contains(q) ||
          r.guideName.toLowerCase().contains(q) ||
          _dateLabel(r).toLowerCase().contains(q) ||
          b.status.toLowerCase().contains(q) ||
          b.bookingType.toLowerCase().contains(q);
    }).toList();
  }

  void _showDetails(AdminBookingRow row) {
    showDialog(
      context: context,
      builder: (_) => _ViewBookingDialog(row: row),
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

            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null && _filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Column(
                    children: [
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _load,
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
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

              ..._filtered.map(
                (b) => _BookingRow(
                  row: b,
                  dateLabel: _dateLabel(b),
                  onView: () => _showDetails(b),
                ),
              ),
              if (_filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('No bookings found.')),
                ),
            ],
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
  final AdminBookingRow row;
  final String dateLabel;
  final VoidCallback onView;
  const _BookingRow({
    required this.row,
    required this.dateLabel,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final b = row.booking;
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
                  row.touristName,
                  style: AppTextStyles.tableCell,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  row.tripTitle,
                  style: AppTextStyles.tableCellMuted,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  row.guideName,
                  style: AppTextStyles.tableCellMuted,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  dateLabel,
                  style: AppTextStyles.tableCellMuted,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(flex: 2, child: StatusChip(status: b.status)),
              Expanded(
                flex: 2,
                child: Text(
                  '${b.currency} ${b.totalAmount.toStringAsFixed(0)}',
                  style: AppTextStyles.tableCellMuted,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(b.bookingType, style: AppTextStyles.linkText),
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

/// Booking details dialog (all fields the current model supports).
class _ViewBookingDialog extends StatelessWidget {
  final AdminBookingRow row;
  const _ViewBookingDialog({required this.row});

  static String _dateLabel(AdminBookingRow row) {
    final b = row.booking;
    final date = b.tripDate ?? b.appointmentAt ?? b.createdAt;
    if (date == null) return '—';
    final d = date.toLocal();
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final b = row.booking;
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
              _row('Tourist:', row.touristName),
              _row('Trip:', row.tripTitle),
              _row('Tour Guide:', row.guideName),
              _row('Date:', _dateLabel(row)),
              _row(
                'Price:',
                '${b.currency} ${b.unitPrice.toStringAsFixed(0)} × ${b.seats}',
              ),
              _row(
                'Total:',
                '${b.currency} ${b.totalAmount.toStringAsFixed(0)}',
              ),
              _row('Status:', b.status.toUpperCase()),
              _row('Payment:', b.paymentStatus.toUpperCase()),
              _row('Type:', b.bookingType),
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
          Expanded(child: Text(value, style: AppTextStyles.tableCell)),
        ],
      ),
    );
  }
}
