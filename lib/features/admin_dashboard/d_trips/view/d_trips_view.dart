import 'package:flutter/material.dart';

import '../../../../core/data/repositories/admin_trips_repository.dart';
import '../../../../core/theme/d_app_colors.dart';
import '../../../../core/theme/d_app_text_styles.dart';
import '../../../../core/widgets/d_circle_back_button.dart';
import '../../../../core/data/mock/dashboard/d_mock_trips.dart';
import '../../d_home/view/d_home_view.dart';

/// Trips management screen.
///
/// The trips are read from Firestore — the same documents the guides
/// publish and the tourists book.
class TripsView extends StatefulWidget {
  const TripsView({super.key});

  @override
  State<TripsView> createState() => _TripsViewState();
}

class _TripsViewState extends State<TripsView> {
  final TextEditingController _search = TextEditingController();
  final AdminTripsRepository _repository = AdminTripsRepository();

  late List<MockTrip> _trips;
  String _query = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _trips = List.from(mockTrips);
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// Reads every guide's trips from Firestore.
  Future<void> _load() async {
    final trips = await _repository.fetchTrips();
    if (!mounted) return;
    setState(() {
      _trips = trips.map(_toTrip).toList();
      _loading = false;
    });
  }

  /// Maps a Firestore trip onto the row the table renders.
  MockTrip _toTrip(AdminTrip trip) => MockTrip(
    tripId: trip.tripId,
    title: trip.title,
    guide: trip.guideName,
    date: trip.scheduleLabel,
    travelers: trip.travelers,
    price: trip.priceLabel,
    status: trip.approvalStatus,
  );

  List<MockTrip> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _trips;
    return _trips.where((t) {
      return t.title.toLowerCase().contains(q) ||
          t.guide.toLowerCase().contains(q) ||
          t.date.toLowerCase().contains(q) ||
          t.status.toLowerCase().contains(q);
    }).toList();
  }

  void _showViewDialog(MockTrip trip) {
    showDialog(
      context: context,
      builder: (_) => _ViewTripDialog(trip: trip),
    );
  }

  /// Rejects a trip and tells the guide why.
  Future<void> _cancelTrip(MockTrip trip) async {
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
      return;
    }
    await _load();
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

            // Search + Filter
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

            // Table rows
            ..._filtered.map(
              (t) => _TripRow(
                trip: t,
                onView: () => _showViewDialog(t),
                onCancel: () => _cancelTrip(t),
              ),
            ),
            if (_filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    _loading ? 'Loading trips...' : 'No trips found.',
                  ),
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
  final MockTrip trip;
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
                    if (trip.status != 'cancelled')
                      DangerActionButton(
                        label: 'Cancel & Refund',
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
  final MockTrip trip;
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
              _buildDetailRow('Date:', trip.date),
              _buildDetailRow('Travelers:', '${trip.travelers}'),
              _buildDetailRow('Price:', trip.price),
              _buildDetailRow('Status:', trip.status.toUpperCase()),
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
