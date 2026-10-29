import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../core/data/repositories/admin_trips_repository.dart';
import '../../../../core/theme/d_app_colors.dart';
import '../../../../core/theme/d_app_text_styles.dart';
import '../../../../core/widgets/d_circle_back_button.dart';
import '../../d_home/view/d_home_view.dart';

/// Row data model for trips in the admin dashboard.
class TripRowData {
  final String tripId;
  final String title;
  final String guide;
  final String date;
  final int travelers;
  final String price;
  final String status;
  final String location;
  final String about;
  final List<String> itinerary;
  final String imageUrl;
  final String rejectionReason;

  const TripRowData({
    required this.tripId,
    required this.title,
    required this.guide,
    required this.date,
    required this.travelers,
    required this.price,
    required this.status,
    this.location = '',
    this.about = '',
    this.itinerary = const [],
    this.imageUrl = '',
    this.rejectionReason = '',
  });
}

/// Trips management screen (connected dynamically to Firestore).
class TripsView extends StatefulWidget {
  const TripsView({super.key});

  @override
  State<TripsView> createState() => _TripsViewState();
}

class _TripsViewState extends State<TripsView> {
  final TextEditingController _search = TextEditingController();
  final AdminTripsRepository _repository = AdminTripsRepository();

  List<TripRowData> _trips = const [];
  StreamSubscription<List<AdminTrip>>? _subscription;
  String _query = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _subscription = _repository.watchTrips().listen(
      (trips) {
        if (!mounted) return;
        setState(() {
          _trips = trips.map(_toTrip).toList();
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

  /// Maps a Firestore trip onto the row the table renders.
  TripRowData _toTrip(AdminTrip trip) => TripRowData(
    tripId: trip.tripId,
    title: trip.title,
    guide: trip.guideName.isNotEmpty ? trip.guideName : 'Tour Guide',
    date: trip.scheduleLabel.isNotEmpty ? trip.scheduleLabel : 'Scheduled',
    travelers: trip.travelers,
    price: trip.priceLabel,
    status: trip.approvalStatus,
    location: trip.location,
    about: trip.about,
    itinerary: trip.itinerary,
    imageUrl: trip.imageUrl,
    rejectionReason: trip.rejectionReason,
  );

  List<TripRowData> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _trips;
    return _trips.where((t) {
      return t.title.toLowerCase().contains(q) ||
          t.guide.toLowerCase().contains(q) ||
          t.date.toLowerCase().contains(q) ||
          t.status.toLowerCase().contains(q);
    }).toList();
  }

  void _showViewDialog(TripRowData trip) {
    showDialog(
      context: context,
      builder: (_) => _ViewTripDialog(trip: trip),
    );
  }

  /// Rejects a trip and tells the guide why.
  Future<void> _cancelTrip(TripRowData trip) async {
    if (trip.tripId.isEmpty) return;
    final reason = await _askRejectionReason();
    if (reason == null || !mounted) return;
    final ok = await _repository.decide(
      tripId: trip.tripId,
      approve: false,
      rejectionReason: reason,
    );
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not reject the trip.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip rejected successfully.')),
      );
    }
  }

  /// Asks the admin why the trip was rejected — the guide sees it.
  Future<String?> _askRejectionReason() async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Reject trip',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Please provide a reason for rejection:'),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'e.g., the meeting point is not specific...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text(
              'Confirm Reject',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    controller.dispose();
    return reason;
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

            // Search
            SearchFilterRow(
              hintText: 'Search trips...',
              controller: _search,
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 20),

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

            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_filtered.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('No trips found.')),
              )
            else
              ..._filtered.map(
                (t) => _TripRow(
                  trip: t,
                  onView: () => _showViewDialog(t),
                  onCancel: () => _cancelTrip(t),
                ),
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

class _TripRow extends StatelessWidget {
  final TripRowData trip;
  final VoidCallback onView;
  final VoidCallback onCancel;
  const _TripRow({
    required this.trip,
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
                  trip.guide,
                  style: AppTextStyles.tableCellMuted,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  trip.date,
                  style: AppTextStyles.tableCellMuted,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '${trip.travelers}',
                  style: AppTextStyles.tableCellMuted,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(trip.price, style: AppTextStyles.tableCellMuted),
              ),
              Expanded(flex: 2, child: StatusChip(status: trip.status)),
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlineActionButton(label: 'View', onTap: onView),
                    const SizedBox(width: 8),
                    if (trip.status != 'cancelled' && trip.status != 'rejected')
                      DangerActionButton(
                        label: 'Cancel & Refund',
                        onTap: onCancel,
                      )
                    else
                      const SizedBox(width: 110),
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
  final TripRowData trip;
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
              _buildDetailRow('Guide:', trip.guide),
              if (trip.location.isNotEmpty)
                _buildDetailRow('Location:', trip.location),
              _buildDetailRow('Date:', trip.date),
              _buildDetailRow('Travelers:', '${trip.travelers}'),
              _buildDetailRow('Price:', trip.price),
              _buildDetailRow('Status:', trip.status.toUpperCase()),
              if (trip.about.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildDetailRow('About:', trip.about),
              ],
              if (trip.rejectionReason.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildDetailRow('Rejection Reason:', trip.rejectionReason),
              ],
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
            width: 110,
            child: Text(label, style: AppTextStyles.fieldLabel),
          ),
          Expanded(child: Text(value, style: AppTextStyles.tableCell)),
        ],
      ),
    );
  }
}
