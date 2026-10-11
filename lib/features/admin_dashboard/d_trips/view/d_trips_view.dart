import 'package:flutter/material.dart';

import '../../../../core/theme/d_app_colors.dart';
import '../../../../core/theme/d_app_text_styles.dart';
import '../../../../core/widgets/d_circle_back_button.dart';
import '../../../../data/firestore/models/trip_doc.dart';
import '../../../../data/firestore/repositories/admin_repository.dart';
import '../../d_home/view/d_home_view.dart';

/// Trips management screen (server-backed).
///
/// Rows come from the admin trip list; cancellation goes through the
/// admin-only `decideTripStatus` callable. Cancelling a trip does NOT
/// refund its bookings (those keep their own lifecycle) — the UI never
/// claims otherwise.
class TripsView extends StatefulWidget {
  const TripsView({super.key});

  @override
  State<TripsView> createState() => _TripsViewState();
}

class _TripsViewState extends State<TripsView> {
  final TextEditingController _search = TextEditingController();
  final AdminRepository _repo = AdminRepository();
  List<TripDoc> _trips = [];
  String _query = '';
  bool _loading = true;
  String? _error;
  final Set<String> _busy = {};

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

  /// Reloads the list. Returns false (with [error] set) when the display
  /// may be stale — mutating callers surface a notice instead of a
  /// misleading success.
  Future<bool> _load() async {
    if (!mounted) return false;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final trips = await _repo.allTrips();
      if (!mounted) return false;
      setState(() {
        _trips = trips;
        _loading = false;
      });
      return true;
    } catch (e) {
      if (!mounted) return false;
      setState(() {
        _loading = false;
        _error = _message(e);
      });
      return false;
    }
  }

  static String _message(Object e) {
    const prefix = 'Exception: ';
    final text = e.toString();
    final msg = text.startsWith(prefix) ? text.substring(prefix.length) : text;
    return msg.isEmpty ? 'Operation failed. Please try again.' : msg;
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  List<TripDoc> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _trips;
    return _trips.where((t) {
      return t.title.toLowerCase().contains(q) ||
          t.guideName.toLowerCase().contains(q) ||
          t.dateLabel.toLowerCase().contains(q) ||
          t.approvalStatus.toLowerCase().contains(q);
    }).toList();
  }

  void _showViewDialog(TripDoc trip) {
    showDialog(
      context: context,
      builder: (_) => _ViewTripDialog(trip: trip),
    );
  }

  Future<void> _cancelTrip(TripDoc trip) async {
    if (_busy.contains(trip.id)) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Cancel trip'),
        content: const Text(
          'Are you sure you want to cancel this trip? '
          'Existing bookings keep their own status and refunds, if any, '
          'are handled separately.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep trip'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Cancel trip',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy.add(trip.id));
    try {
      await _repo.decideTripStatus(tripId: trip.id, decision: 'cancelled');
      final fresh = await _load();
      _snack(
        fresh
            ? 'Trip cancelled.'
            : 'Trip cancelled, but the list could not refresh.',
      );
    } catch (e) {
      _snack(_message(e));
    } finally {
      if (mounted) setState(() => _busy.remove(trip.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AdminCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: CardSectionHeader(
                    title: 'Manage Trips',
                    subtitle: 'Search, review, edit and control all trips.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Search + Filter
            SearchFilterRow(
              hintText: 'Search trips...',
              controller: _search,
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 20),

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
                    _h('Trip', 4),
                    _h('Guide', 3),
                    _h('Date', 2),
                    _h('Travelers', 2),
                    _h('Price', 2),
                    _h('Status', 2),
                    _h('Actions', 3, end: true),
                  ],
                ),
              ),
              const Divider(color: AppColors.divider, height: 1),

              // Table rows
              ..._filtered.map(
                (t) => _TripRow(
                  trip: t,
                  busy: _busy.contains(t.id),
                  onView: () => _showViewDialog(t),
                  onCancel: () => _cancelTrip(t),
                ),
              ),
              if (_filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('No trips found.')),
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

class _TripRow extends StatelessWidget {
  final TripDoc trip;
  final bool busy;
  final VoidCallback onView;
  final VoidCallback onCancel;
  const _TripRow({
    required this.trip,
    required this.busy,
    required this.onView,
    required this.onCancel,
  });

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
                flex: 4,
                child: Text(
                  trip.title,
                  style: AppTextStyles.tableCell,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  trip.guideName.isNotEmpty ? trip.guideName : '—',
                  style: AppTextStyles.tableCellMuted,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  trip.dateLabel.isNotEmpty ? trip.dateLabel : '—',
                  style: AppTextStyles.tableCellMuted,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '${trip.bookedSeats}/${trip.capacity}',
                  style: AppTextStyles.tableCellMuted,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '${trip.currency} ${trip.priceEgp.toStringAsFixed(0)}',
                  style: AppTextStyles.tableCellMuted,
                ),
              ),
              Expanded(flex: 2, child: StatusChip(status: trip.approvalStatus)),
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlineActionButton(label: 'View', onTap: onView),
                    const SizedBox(width: 8),
                    if (trip.approvalStatus != 'cancelled')
                      busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : DangerActionButton(
                              label: 'Cancel trip',
                              onTap: onCancel,
                            )
                    else
                      const SizedBox(
                        width: 110,
                      ), // Placeholder to maintain alignment
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

/// View Trip Details Dialog
class _ViewTripDialog extends StatelessWidget {
  final TripDoc trip;
  const _ViewTripDialog({required this.trip});

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
                      'Trip Details',
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
              _buildDetailRow('Title:', trip.title),
              _buildDetailRow(
                'Guide:',
                trip.guideName.isNotEmpty ? trip.guideName : '—',
              ),
              _buildDetailRow(
                'Date:',
                trip.dateLabel.isNotEmpty ? trip.dateLabel : '—',
              ),
              _buildDetailRow(
                'Travelers:',
                '${trip.bookedSeats}/${trip.capacity}',
              ),
              _buildDetailRow(
                'Price:',
                '${trip.currency} ${trip.priceEgp.toStringAsFixed(0)}',
              ),
              _buildDetailRow('Status:', trip.approvalStatus.toUpperCase()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
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
