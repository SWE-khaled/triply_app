import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/d_circle_back_button.dart';
import '../../d_home/view/d_home_view.dart';
import '../cubit/trip_applications_cubit.dart';
import '../model/admin_trip_application.dart';

/// Trip Applications management screen (connected dynamically to Firestore).
class TripApplicationsView extends StatelessWidget {
  const TripApplicationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TripApplicationsCubit()..start(),
      child: const _TripApplicationsBody(),
    );
  }
}

class _TripApplicationsBody extends StatelessWidget {
  const _TripApplicationsBody();

  /// Approves a trip and tells the guide.
  Future<void> _approve(
    BuildContext context,
    AdminTripApplication application,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await context.read<TripApplicationsCubit>().approve(
      application,
    );
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Trip approved.'
              : 'Could not approve the trip. Are you signed in as an admin?',
        ),
        backgroundColor: ok ? null : AppColors.adminDanger,
      ),
    );
  }

  /// Rejects a trip with a reason and tells the guide.
  Future<void> _reject(
    BuildContext context,
    AdminTripApplication application,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final reason = await _askRejectionReason(context);
    if (reason == null || !context.mounted) return;

    final ok = await context.read<TripApplicationsCubit>().reject(
      application,
      reason,
    );
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Trip rejected.'
              : 'Could not reject the trip. Are you signed in as an admin?',
        ),
        backgroundColor: ok ? null : AppColors.adminDanger,
      ),
    );
  }

  Future<String?> _askRejectionReason(BuildContext context) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Reject Application',
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
                hintText: 'e.g., Incomplete details, invalid price...',
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

  void _showReviewDialog(
    BuildContext context,
    AdminTripApplication application,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        scrollable: true,
        title: Text(
          '${application.tripTitle} - ${application.type.toUpperCase()}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (application.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    application.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.image, size: 50, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                'Date: ${application.date}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Travelers: ${application.travelers} travelers'),
              if (application.location.isNotEmpty)
                Text('Location: ${application.location}'),
              Text(
                'Price: ${application.price}',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (application.itinerary.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Itinerary:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...application.itinerary.asMap().entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '${(entry.key + 1).toString().padLeft(2, '0')} '
                      '${entry.value}',
                    ),
                  ),
                ),
              ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
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
                    title: 'Manage Trip Applications',
                    subtitle:
                        'Search, review, edit and control all trip applications.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            SearchFilterRow(
              hintText: 'Search trip applications...',
              onChanged: context.read<TripApplicationsCubit>().search,
            ),
            const SizedBox(height: 20),

            BlocBuilder<TripApplicationsCubit, TripApplicationsState>(
              builder: (context, state) {
                if (state is TripApplicationsInitial ||
                    state is TripApplicationsLoading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (state is TripApplicationsError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text(state.message)),
                  );
                }

                final applications = state is TripApplicationsSuccess
                    ? state.filtered
                    : const <AdminTripApplication>[];
                if (applications.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('No applications found.')),
                  );
                }

                return Column(
                  children: [
                    for (final entry in applications.asMap().entries)
                      _ApplicationItem(
                        app: entry.value,
                        onApprove: () => _approve(context, entry.value),
                        onReject: () => _reject(context, entry.value),
                        onReview: () =>
                            _showReviewDialog(context, entry.value),
                        isFirst: entry.key == 0,
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
}

class _ApplicationItem extends StatelessWidget {
  final AdminTripApplication app;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onReview;
  final bool isFirst;

  const _ApplicationItem({
    required this.app,
    required this.onApprove,
    required this.onReject,
    required this.onReview,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    final isProcessed = app.status == 'approved' || app.status == 'rejected';

    // Trip info block (no Expanded here: it is used both inside a Row and a
    // Column depending on the available width).
    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                app.tripTitle,
                style: AppTextStyles.adminTableCell.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: app.type == 'private'
                    ? Colors.purple.withValues(alpha: 0.1)
                    : Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: app.type == 'private'
                      ? Colors.purple.withValues(alpha: 0.3)
                      : Colors.blue.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                app.type.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: app.type == 'private' ? Colors.purple : Colors.blue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          'By ${app.guide} · ${app.date} · ${app.price}',
          style: AppTextStyles.adminTableCellMuted,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        if (app.status == 'rejected' && app.rejectionReason.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            'Reason for rejection: ${app.rejectionReason}',
            style: const TextStyle(
              color: AppColors.adminDanger,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );

    final actions = isProcessed
        ? StatusChip(status: app.status)
        : Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Text(
                'Pending Review',
                style: AppTextStyles.adminTableCellMuted.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.adminTextSecondary,
                ),
              ),
              OutlineActionButton(label: 'Review', onTap: onReview),
              PrimaryActionButton(label: 'Approve', onTap: onApprove),
              DangerActionButton(label: 'Reject', onTap: onReject),
            ],
          );

    return Column(
      children: [
        if (!isFirst) const Divider(color: AppColors.adminDivider, height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // On narrow windows the actions move under the trip info
              // instead of squeezing it (and overflowing the row).
              if (constraints.maxWidth < 640) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    info,
                    const SizedBox(height: 10),
                    Align(alignment: Alignment.centerRight, child: actions),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: info),
                  const SizedBox(width: 14),
                  actions,
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

