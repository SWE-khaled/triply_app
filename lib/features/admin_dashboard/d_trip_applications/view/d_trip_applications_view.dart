import 'package:flutter/material.dart';
import '../../../../core/theme/d_app_colors.dart';
import '../../../../core/theme/d_app_text_styles.dart';
import '../../../../core/widgets/d_circle_back_button.dart';
import '../../../../data/firestore/models/trip_doc.dart';
import '../../../../data/firestore/repositories/admin_repository.dart';
import '../../d_home/view/d_home_view.dart';

/// Trip Applications management screen (server-backed).
///
/// Rows come from the pending-trip review queue; approve/reject go through
/// the admin-only `decideTripStatus` callable (rejection reasons preserved).
class TripApplicationsView extends StatefulWidget {
  const TripApplicationsView({super.key});

  @override
  State<TripApplicationsView> createState() => _TripApplicationsViewState();
}

class _TripApplicationsViewState extends State<TripApplicationsView> {
  final TextEditingController _search = TextEditingController();
  final AdminRepository _repo = AdminRepository();
  List<TripDoc> _apps = [];
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

  /// Reloads the queue. Returns false (with [error] set) when the display
  /// may be stale — mutating callers surface a notice instead of a
  /// misleading success.
  Future<bool> _load() async {
    if (!mounted) return false;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final apps = await _repo.pendingTrips();
      if (!mounted) return false;
      setState(() {
        _apps = apps;
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
    if (q.isEmpty) return _apps;
    return _apps.where((a) {
      return a.title.toLowerCase().contains(q) ||
          a.guideName.toLowerCase().contains(q) ||
          a.location.toLowerCase().contains(q) ||
          a.approvalStatus.toLowerCase().contains(q) ||
          a.category.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _approve(TripDoc trip) async {
    if (_busy.contains(trip.id)) return;
    setState(() => _busy.add(trip.id));
    try {
      await _repo.decideTripStatus(tripId: trip.id, decision: 'approved');
      final fresh = await _load();
      _snack(
        fresh
            ? 'Trip approved.'
            : 'Trip approved, but the list could not refresh.',
      );
    } catch (e) {
      _snack(_message(e));
    } finally {
      if (mounted) setState(() => _busy.remove(trip.id));
    }
  }

  Future<void> _reject(TripDoc trip) async {
    if (_busy.contains(trip.id)) return;
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Reject Application',
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
            onPressed: () => Navigator.pop(ctx, reasonController.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text(
              'Confirm Reject',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    if (reason == null || !mounted) return;
    setState(() => _busy.add(trip.id));
    try {
      await _repo.decideTripStatus(
        tripId: trip.id,
        decision: 'rejected',
        rejectionReason: reason,
      );
      final fresh = await _load();
      _snack(
        fresh
            ? 'Application rejected.'
            : 'Rejected, but the list could not refresh.',
      );
    } catch (e) {
      _snack(_message(e));
    } finally {
      if (mounted) setState(() => _busy.remove(trip.id));
    }
  }

  void _showReviewDialog(TripDoc app) {
    final itinerary = app.itinerary
        .map((e) => (e['title'] ?? e['activity'] ?? '').toString())
        .where((t) => t.isNotEmpty)
        .toList();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          '${app.title} - ${app.category.toUpperCase()}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (app.coverImageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      app.coverImageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  'Date: ${app.dateLabel}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Travelers: ${app.bookedSeats}/${app.capacity} booked'),
                Text('Location: ${app.location}'),
                Text(
                  'Price: ${app.currency} ${app.priceEgp.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Itinerary:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                if (itinerary.isEmpty) const Text('No itinerary provided.'),
                ...itinerary.asMap().entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '${(e.key + 1).toString().padLeft(2, '0')} ${e.value}',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Languages:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: app.languages.isEmpty
                      ? [const Chip(label: Text('—'))]
                      : app.languages
                            .map(
                              (p) => Chip(
                                label: Text(p),
                                backgroundColor: Colors.blue.withValues(
                                  alpha: 0.1,
                                ),
                                side: BorderSide.none,
                              ),
                            )
                            .toList(),
                ),
              ],
            ),
          ),
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
              // Application rows (no headers — each is a standalone row)
              ..._filtered.map(
                (app) => _ApplicationItem(
                  app: app,
                  onApprove: () => _approve(app),
                  onReject: () => _reject(app),
                  onReview: () => _showReviewDialog(app),
                  isFirst: _filtered.first == app,
                ),
              ),
              if (_filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('No applications found.')),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ApplicationItem extends StatelessWidget {
  final TripDoc app;
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
    final isPending = app.approvalStatus == 'pending';

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
                        Expanded(
                          child: Text(
                            app.title,
                            style: AppTextStyles.tableCell.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blue.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            app.category.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'By ${app.guideName} · ${app.dateLabel} · ${app.currency} ${app.priceEgp.toStringAsFixed(0)}',
                      style: AppTextStyles.tableCellMuted,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    if (app.approvalStatus == 'rejected' &&
                        app.rejectionReason.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Reason for rejection: ${app.rejectionReason}',
                        style: const TextStyle(
                          color: AppColors.danger,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Status or actions
              if (!isPending) ...[
                StatusChip(status: app.approvalStatus),
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
