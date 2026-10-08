import 'package:flutter/material.dart';

import '../../../../core/theme/d_app_colors.dart';
import '../../../../core/theme/d_app_text_styles.dart';
import '../../../../core/widgets/d_circle_back_button.dart';
import '../../../../data/mock/d_mock_trips.dart';
import '../../d_home/view/d_home_view.dart';

/// Trips management screen.
class TripsView extends StatefulWidget {
  const TripsView({super.key});

  @override
  State<TripsView> createState() => _TripsViewState();
}

class _TripsViewState extends State<TripsView> {
  final TextEditingController _search = TextEditingController();
  late List<MockTrip> _trips;

  @override
  void initState() {
    super.initState();
    _trips = List.from(mockTrips);
  }



  void _showViewDialog(MockTrip trip) {
    showDialog(
      context: context,
      builder: (_) => _ViewTripDialog(trip: trip),
    );
  }

  void _cancelTrip(MockTrip trip) {
    setState(() {
      final index = _trips.indexOf(trip);
      if (index != -1) {
        _trips[index] = MockTrip(
          title: trip.title,
          guide: trip.guide,
          date: trip.date,
          travelers: trip.travelers,
          price: trip.price,
          status: 'cancelled',
        );
      }
    });
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
            SearchFilterRow(hintText: 'Search trips...', controller: _search),
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
            ..._trips.map(
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
                child: Text(trip.title, style: AppTextStyles.tableCell),
              ),
              Expanded(
                flex: 3,
                child: Text(trip.guide, style: AppTextStyles.tableCellMuted),
              ),
              Expanded(
                flex: 2,
                child: Text(trip.date, style: AppTextStyles.tableCellMuted),
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
      child: SizedBox(
        width: 520,
        child: Padding(
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
