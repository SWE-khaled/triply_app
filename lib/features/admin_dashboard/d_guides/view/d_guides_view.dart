import 'package:flutter/material.dart';
import '../../../../core/theme/d_app_colors.dart';
import '../../../../core/theme/d_app_text_styles.dart';
import '../../../../core/widgets/d_circle_back_button.dart';
import '../../../../data/mock/d_mock_guides.dart';
import '../../d_home/view/d_home_view.dart';

/// Guides verification management screen.
class GuidesView extends StatefulWidget {
  const GuidesView({super.key});

  @override
  State<GuidesView> createState() => _GuidesViewState();
}

class _GuidesViewState extends State<GuidesView> {
  late List<MockGuide> _guides;

  @override
  void initState() {
    super.initState();
    _guides = List.from(mockGuides);
  }

  int get _pendingCount =>
      _guides.where((g) => g.status == 'pending').length;

  void _approve(MockGuide guide) {
    setState(() {
      final i = _guides.indexOf(guide);
      _guides[i] = MockGuide(
        name: guide.name,
        email: guide.email,
        document: guide.document,
        city: guide.city,
        status: 'approved',
        phone: guide.phone,
        submitted: guide.submitted,
        docFileName: guide.docFileName,
        uploadedTrips: guide.uploadedTrips,
      );
    });
  }

  void _reject(MockGuide guide) {
    setState(() {
      final i = _guides.indexOf(guide);
      _guides[i] = MockGuide(
        name: guide.name,
        email: guide.email,
        document: guide.document,
        city: guide.city,
        status: 'suspended', // Use suspended to act as rejected/blocked in UI
        phone: guide.phone,
        submitted: guide.submitted,
        docFileName: guide.docFileName,
        uploadedTrips: guide.uploadedTrips,
      );
    });
  }

  void _suspend(MockGuide guide) {
    setState(() {
      final i = _guides.indexOf(guide);
      _guides[i] = MockGuide(
        name: guide.name,
        email: guide.email,
        document: guide.document,
        city: guide.city,
        status: 'suspended',
        phone: guide.phone,
        submitted: guide.submitted,
        docFileName: guide.docFileName,
        uploadedTrips: guide.uploadedTrips,
      );
    });
  }

  void _showDetails(MockGuide guide) {
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
                        horizontal: 14, vertical: 7),
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
  final MockGuide guide;
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
                    Text(guide.name, style: AppTextStyles.tableCell),
                    Text(guide.email, style: AppTextStyles.tableCellMuted),
                  ],
                ),
              ),
              // Document + "View file"
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    Text(guide.document, style: AppTextStyles.tableCellMuted),
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
                child: Text(guide.city, style: AppTextStyles.tableCellMuted),
              ),
              // Status chip
              Expanded(
                flex: 2,
                child: StatusChip(status: guide.status),
              ),
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
  final MockGuide guide;
  const _GuideDetailsDialog({required this.guide});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: 580,
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
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.divider),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Close', style: AppTextStyles.buttonSecondary),
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
                        label: 'Submitted', value: guide.submitted),
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
                              Text(guide.document,
                                  style: AppTextStyles.sectionTitle.copyWith(
                                      fontSize: 15)),
                              Text(guide.docFileName,
                                  style: AppTextStyles.tableCellMuted),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Downloading document...')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                          ),
                          child: Text('Download',
                              style: AppTextStyles.buttonPrimary),
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
                          const Icon(Icons.article_outlined,
                              size: 40, color: AppColors.textMuted),
                          const SizedBox(height: 8),
                          Text('Document preview',
                              style: AppTextStyles.tableCellMuted),
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
                                Text(t.title, style: AppTextStyles.tableCell),
                                Text(t.status,
                                    style: AppTextStyles.tableCellMuted),
                                const SizedBox(height: 8),
                                Text('View full trip',
                                    style: AppTextStyles.linkText),
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
          Text(value, style: AppTextStyles.fieldValue),
        ],
      ),
    );
  }
}
