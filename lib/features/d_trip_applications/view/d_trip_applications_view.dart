import 'package:flutter/material.dart';
import '../../../core/theme/d_app_colors.dart';
import '../../../core/theme/d_app_text_styles.dart';
import '../../../core/widgets/d_circle_back_button.dart';
import '../../../data/mock/d_mock_places.dart';
import '../../d_home/view/d_home_view.dart';

/// Trip Applications management screen.
class TripApplicationsView extends StatefulWidget {
  const TripApplicationsView({super.key});

  @override
  State<TripApplicationsView> createState() => _TripApplicationsViewState();
}

class _TripApplicationsViewState extends State<TripApplicationsView> {
  final TextEditingController _search = TextEditingController();
  late List<MockTripApplication> _apps;

  @override
  void initState() {
    super.initState();
    _apps = List.from(mockTripApplications);
  }

  void _approve(int index) {
    setState(() {
      final a = _apps[index];
      _apps[index] = MockTripApplication(
        tripTitle: a.tripTitle,
        guide: a.guide,
        date: a.date,
        price: a.price,
        status: 'approved',
        type: a.type,
        travelers: a.travelers,
        location: a.location,
        itinerary: a.itinerary,
        participants: a.participants,
        imageUrl: a.imageUrl,
      );
    });
  }

  void _reject(int index) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Reject Application', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Please provide a reason for rejection:'),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'e.g., Incomplete details, invalid price...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final a = _apps[index];
                _apps[index] = MockTripApplication(
                  tripTitle: a.tripTitle,
                  guide: a.guide,
                  date: a.date,
                  price: a.price,
                  status: 'rejected',
                  type: a.type,
                  travelers: a.travelers,
                  location: a.location,
                  itinerary: a.itinerary,
                  participants: a.participants,
                  imageUrl: a.imageUrl,
                  rejectionReason: reasonController.text,
                );
              });
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Confirm Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(MockTripApplication app) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${app.tripTitle} - ${app.type.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    app.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Date: ${app.date}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Travelers: ${app.travelers} travelers'),
                Text('Location: ${app.location}'),
                Text('Price: ${app.price}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text('Itinerary:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                ...app.itinerary.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('${(e.key + 1).toString().padLeft(2, '0')} ${e.value}'),
                )),
                const SizedBox(height: 16),
                const Text('Participants:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: app.participants.map((p) => Chip(
                    label: Text(p),
                    backgroundColor: Colors.blue.withValues(alpha: 0.1),
                    side: BorderSide.none,
                  )).toList(),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
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
              controller: _search,
            ),
            const SizedBox(height: 20),

            // Application rows (no headers — each is a standalone row)
            ..._apps.asMap().entries.map(
                  (entry) => _ApplicationItem(
                    app: entry.value,
                    onApprove: () => _approve(entry.key),
                    onReject: () => _reject(entry.key),
                    onReview: () => _showReviewDialog(entry.value),
                    isFirst: entry.key == 0,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _ApplicationItem extends StatelessWidget {
  final MockTripApplication app;
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
    final isProcessed =
        app.status == 'approved' || app.status == 'rejected';

    return Column(
      children: [
        if (!isFirst) const Divider(color: AppColors.divider, height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Row(
            children: [
              // Trip info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(app.tripTitle, style: AppTextStyles.tableCell.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        )),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: app.type == 'private' ? Colors.purple.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: app.type == 'private' ? Colors.purple.withValues(alpha: 0.3) : Colors.blue.withValues(alpha: 0.3)),
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
                      style: AppTextStyles.tableCellMuted,
                    ),
                    if (app.status == 'rejected' && app.rejectionReason != null && app.rejectionReason!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Reason for rejection: ${app.rejectionReason}',
                        style: const TextStyle(color: AppColors.danger, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ],
                ),
              ),

              // Status or actions
              if (isProcessed) ...[
                StatusChip(status: app.status),
              ] else ...[
                // "Pending Review" text label
                Text(
                  'Pending Review',
                  style: AppTextStyles.tableCellMuted.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 14),
                OutlineActionButton(label: 'Review', onTap: onReview),
                const SizedBox(width: 8),
                PrimaryActionButton(label: 'Approve', onTap: onApprove),
                const SizedBox(width: 8),
                DangerActionButton(label: 'Reject', onTap: onReject),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
