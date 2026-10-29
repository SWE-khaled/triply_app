import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/d_app_colors.dart';
import '../../../../core/theme/d_app_text_styles.dart';
import '../../../../core/widgets/d_circle_back_button.dart';
import '../../../../core/data/repositories/admin_guides_repository.dart';
import '../../d_home/view/d_home_view.dart';

/// Guides verification management screen.
class GuidesView extends StatefulWidget {
  const GuidesView({super.key});

  @override
  State<GuidesView> createState() => _GuidesViewState();
}

class _GuidesViewState extends State<GuidesView> {
  final AdminGuidesRepository _repository = AdminGuidesRepository();

  final Set<String> _approvedGuideIdentifiers = {};
  List<AdminGuide> _guides = const [];
  bool _loading = true;
  StreamSubscription<List<AdminGuide>>? _guidesSubscription;

  @override
  void initState() {
    super.initState();
    _guidesSubscription = _repository.watchGuides().listen((guides) {
      if (!mounted) return;
      setState(() {
        _guides = guides.map((g) {
          final isMarkedApproved = _approvedGuideIdentifiers.contains(g.uid) ||
              (g.email.isNotEmpty && _approvedGuideIdentifiers.contains(g.email));
          if (isMarkedApproved) {
            return AdminGuide(
              uid: g.uid,
              name: g.name,
              email: g.email,
              phone: g.phone,
              city: g.city,
              document: g.document,
              status: 'approved',
              submitted: g.submitted,
              docFileName: g.docFileName,
              uploadedTrips: g.uploadedTrips,
            );
          }
          return g;
        }).toList();
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    _guidesSubscription?.cancel();
    super.dispose();
  }

  int get _pendingCount => _guides.where((g) => g.status == 'pending').length;

  void _toast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Approves the guide's documents and writes the decision back.
  Future<void> _approve(AdminGuide guide) async {
    if (guide.uid.isNotEmpty) _approvedGuideIdentifiers.add(guide.uid);
    if (guide.email.isNotEmpty) _approvedGuideIdentifiers.add(guide.email);

    setState(() {
      final i = _guides.indexWhere((g) => g.uid == guide.uid);
      if (i != -1) {
        _guides = [
          for (int idx = 0; idx < _guides.length; idx++)
            if (idx == i)
              AdminGuide(
                uid: _guides[i].uid,
                name: _guides[i].name,
                email: _guides[i].email,
                phone: _guides[i].phone,
                city: _guides[i].city,
                document: _guides[i].document,
                status: 'approved',
                submitted: _guides[i].submitted,
                docFileName: _guides[i].docFileName,
                uploadedTrips: _guides[i].uploadedTrips,
              )
            else
              _guides[idx],
        ];
      }
    });

    final ok = await _repository.decideVerification(
      guideId: guide.uid,
      approve: true,
    );
    if (!mounted) return;
    if (!ok) {
      _toast('Could not approve the guide.');
      return;
    }
  }

  /// Rejects the guide's documents and writes the decision back.
  Future<void> _reject(AdminGuide guide) async {
    final reason = await _askRejectionReason();
    if (reason == null || !mounted) return;
    final ok = await _repository.decideVerification(
      guideId: guide.uid,
      approve: false,
      rejectionReason: reason,
    );
    if (!mounted) return;
    if (!ok) {
      _toast('Could not reject the guide.');
      return;
    }
  }

  /// Asks the admin why the documents were refused.
  Future<String?> _askRejectionReason() async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Reject application',
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
                  hintText: 'e.g., the license is not readable...',
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

  /// Suspends the guide — they can no longer publish or be booked.
  Future<void> _suspend(AdminGuide guide) async {
    final ok = await _repository.suspendGuide(guide.uid);
    if (!mounted) return;
    if (!ok) {
      _toast('Could not suspend the guide.');
      return;
    }
  }

  void _showDetails(AdminGuide guide) {
    showDialog(
      context: context,
      builder: (_) => _GuideDetailsDialog(guide: guide),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AdminCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Row(
              children: [
                Expanded(
                  child: CardSectionHeader(
                    title: 'Tour Guide Verification',
                    subtitle:
                        'Review documents, guide activity and uploaded content',
                  ),
                ),
                if (_pendingCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.statusPendingBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$_pendingCount pending',
                      style: AppTextStyles.tableCellMuted.copyWith(
                        color: AppColors.statusPendingText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Table header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  _h('Guide', 3),
                  _h('Document', 4),
                  _h('City', 2),
                  _h('Status', 2),
                  _h('Actions', 4, end: true),
                ],
              ),
            ),
            const Divider(color: AppColors.divider, height: 1),

            ..._guides.map(
              (g) => _GuideRow(
                guide: g,
                onApprove: () => _approve(g),
                onReject: () => _reject(g),
                onSuspend: () => _suspend(g),
                onDetails: () => _showDetails(g),
              ),
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (!_loading && _guides.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('No guide accounts yet.')),
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

class _GuideRow extends StatelessWidget {
  final AdminGuide guide;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onSuspend;
  final VoidCallback onDetails;

  const _GuideRow({
    required this.guide,
    required this.onApprove,
    required this.onReject,
    required this.onSuspend,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = guide.status == 'pending';

    return Column(
      children: [
        const Divider(color: AppColors.divider, height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(
            children: [
              // Guide name + email
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guide.name,
                      style: AppTextStyles.tableCell,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      guide.email,
                      style: AppTextStyles.tableCellMuted,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              // Document + "View file"
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        guide.document,
                        style: AppTextStyles.tableCellMuted,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () => _showDetails(context),
                      child: Text('View file', style: AppTextStyles.linkText),
                    ),
                  ],
                ),
              ),
              // City
              Expanded(
                flex: 2,
                child: Text(
                  guide.city,
                  style: AppTextStyles.tableCellMuted,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              // Status chip
              Expanded(flex: 2, child: StatusChip(status: guide.status)),
              // Actions
              Expanded(
                flex: 4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlineActionButton(label: 'Details', onTap: onDetails),
                    const SizedBox(width: 6),
                    if (isPending) ...[
                      DangerActionButton(label: 'Reject', onTap: onReject),
                      const SizedBox(width: 6),
                      PrimaryActionButton(label: 'Approve', onTap: onApprove),
                    ] else if (guide.status == 'suspended') ...[
                      OutlineActionButton(label: 'Activate', onTap: onApprove),
                    ] else ...[
                      DangerActionButton(label: 'Suspend', onTap: onSuspend),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _GuideDetailsDialog(guide: guide),
    );
  }
}

/// Guide details modal — shown on "Details" / "View file" tap.
class _GuideDetailsDialog extends StatelessWidget {
  final AdminGuide guide;
  const _GuideDetailsDialog({required this.guide});

  void _showTripDialog(BuildContext context, AdminGuideTrip trip) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          trip.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Status: ${trip.status}'),
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(guide.name, style: AppTextStyles.dialogTitle),
                        const SizedBox(height: 3),
                        Text(
                          'Complete guide application',
                          style: AppTextStyles.dialogSubtitle,
                        ),
                      ],
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
              const SizedBox(height: 20),

              // Info grid
              Row(
                children: [
                  Expanded(
                    child: _InfoField(label: 'Email', value: guide.email),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _InfoField(label: 'Phone', value: guide.phone),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _InfoField(label: 'City', value: guide.city),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _InfoField(
                      label: 'Submitted',
                      value: guide.submitted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Document preview box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                guide.document,
                                style: AppTextStyles.sectionTitle.copyWith(
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                guide.docFileName,
                                style: AppTextStyles.tableCellMuted,
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Downloading document...'),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                          child: Text(
                            'Download',
                            style: AppTextStyles.buttonPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Document preview area
                    Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.documentPreviewBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.article_outlined,
                            size: 40,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Document preview',
                            style: AppTextStyles.tableCellMuted,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Uploaded trips
              if (guide.uploadedTrips.isNotEmpty) ...[
                Text('Uploaded trips', style: AppTextStyles.sectionTitle),
                const SizedBox(height: 12),
                Row(
                  children: guide.uploadedTrips
                      .map(
                        (t) => Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.divider),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.title,
                                  style: AppTextStyles.tableCell,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                Text(
                                  t.status,
                                  style: AppTextStyles.tableCellMuted,
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () => _showTripDialog(context, t),
                                  child: Text(
                                    'View full trip',
                                    style: AppTextStyles.linkText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  final String label;
  final String value;
  const _InfoField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.tableCellMuted),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.fieldValue,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
