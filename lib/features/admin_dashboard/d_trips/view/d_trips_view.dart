import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/d_circle_back_button.dart';
import '../../d_home/view/d_home_view.dart';
import '../cubit/trips_cubit.dart';
import '../model/trip_row_data.dart';

/// Trips management screen (connected dynamically to Firestore).
class TripsView extends StatelessWidget {
  const TripsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TripsCubit()..start(),
      child: const _TripsBody(),
    );
  }
}

class _TripsBody extends StatelessWidget {
  const _TripsBody();

  void _showViewDialog(BuildContext context, TripRowData trip) {
    showDialog(
      context: context,
      builder: (_) => _ViewTripDialog(trip: trip),
    );
  }

  /// Rejects a trip and tells the guide why.
  Future<void> _rejectTrip(BuildContext context, TripRowData trip) async {
    final messenger = ScaffoldMessenger.of(context);
    final reason = await _askRejectionReason(context);
    if (reason == null || !context.mounted) return;

    final ok = await context.read<TripsCubit>().reject(trip, reason);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Trip rejected successfully.'
              : 'Could not reject the trip.',
        ),
        backgroundColor: ok ? null : AppColors.adminDanger,
      ),
    );
  }

  /// Asks the admin why the trip was rejected — the guide sees it.
  Future<String?> _askRejectionReason(BuildContext context) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Reject trip',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.adminDanger,
            ),
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
              onChanged: context.read<TripsCubit>().search,
            ),
            const SizedBox(height: 20),

            BlocBuilder<TripsCubit, TripsState>(
              builder: (context, state) {
                final trips = state is TripsSuccess
                    ? state.filtered
                    : const <TripRowData>[];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    const Divider(color: AppColors.adminDivider, height: 1),

                    if (state is TripsInitial || state is TripsLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (state is TripsError)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: Text(state.message)),
                      )
                    else if (trips.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: Text('No trips found.')),
                      )
                    else
                      ...trips.map(
                        (trip) => _TripRow(
                          trip: trip,
                          onView: () => _showViewDialog(context, trip),
                          onCancel: () => _rejectTrip(context, trip),
                        ),
                      ),
                  ],
                );
              },
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
      style: AppTextStyles.adminTableHeader,
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
        const Divider(color: AppColors.adminDivider, height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  trip.title,
                  style: AppTextStyles.adminTableCell,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  trip.guide,
                  style: AppTextStyles.adminTableCellMuted,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  trip.date,
                  style: AppTextStyles.adminTableCellMuted,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '${trip.travelers}',
                  style: AppTextStyles.adminTableCellMuted,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(trip.price, style: AppTextStyles.adminTableCellMuted),
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
                      style: AppTextStyles.adminDialogTitle,
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
                        border: Border.all(color: AppColors.adminDivider),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Close',
                        style: AppTextStyles.adminButtonSecondary,
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
            child: Text(label, style: AppTextStyles.adminFieldLabel),
          ),
          Expanded(child: Text(value, style: AppTextStyles.adminTableCell)),
        ],
      ),
    );
  }
}

