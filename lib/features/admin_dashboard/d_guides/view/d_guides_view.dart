import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/data/repositories/admin_guides_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/d_circle_back_button.dart';
import '../../d_home/view/d_home_view.dart';
import '../cubit/guides_cubit.dart';

/// Guides verification management screen.
class GuidesView extends StatelessWidget {
  const GuidesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GuidesCubit()..start(),
      child: const _GuidesBody(),
    );
  }
}

class _GuidesBody extends StatelessWidget {
  const _GuidesBody();

  /// Approves the guide's documents and writes the decision back.
  Future<void> _approve(BuildContext context, AdminGuide guide) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await context.read<GuidesCubit>().approve(guide);
    if (ok) return;
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Could not approve the guide.'),
        backgroundColor: AppColors.adminDanger,
      ),
    );
  }

  /// Rejects the guide's documents and writes the decision back.
  Future<void> _reject(BuildContext context, AdminGuide guide) async {
    final messenger = ScaffoldMessenger.of(context);
    final reason = await _askRejectionReason(context);
    if (reason == null || !context.mounted) return;

    final ok = await context.read<GuidesCubit>().reject(guide, reason);
    if (ok) return;
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Could not reject the guide.'),
        backgroundColor: AppColors.adminDanger,
      ),
    );
  }

  /// Suspends the guide — they can no longer publish or be booked.
  Future<void> _suspend(BuildContext context, AdminGuide guide) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await context.read<GuidesCubit>().suspend(guide);
    if (ok) return;
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Could not suspend the guide.'),
        backgroundColor: AppColors.adminDanger,
      ),
    );
  }

  /// Asks the admin why the documents were refused.
  Future<String?> _askRejectionReason(BuildContext context) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Reject application',
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
                hintText: 'e.g., the license is not readable...',
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

  void _showDetails(BuildContext context, AdminGuide guide) {
    showDialog(
      context: context,
      builder: (_) => _GuideDetailsDialog(guide: guide),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AdminCard(
        child: BlocBuilder<GuidesCubit, GuidesState>(
          builder: (context, state) {
            final guides = state is GuidesSuccess
                ? state.guides
                : const <AdminGuide>[];
            final pendingCount = state is GuidesSuccess
                ? state.pendingCount
                : 0;

            return Column(
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
                    if (pendingCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.adminStatusPendingBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$pendingCount pending',
                          style: AppTextStyles.adminTableCellMuted.copyWith(
                            color: AppColors.adminStatusPendingText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                _buildTable(context, state, guides),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTable(
    BuildContext context,
    GuidesState state,
    List<AdminGuide> guides,
  ) {
    final header = Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              _h('Guide', 3),
              _h('Document', 4),
              _h('City', 2),
              _h('Status', 2),
              _h('Actions', 5, end: true),
            ],
          ),
        ),
        const Divider(color: AppColors.adminDivider, height: 1),
      ],
    );

    if (state is GuidesInitial || state is GuidesLoading) {
      return Column(
        children: [
          header,
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }
    if (state is GuidesError) {
      return Column(
        children: [
          header,
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text(state.message)),
          ),
        ],
      );
    }
    if (guides.isEmpty) {
      return Column(
        children: [
          header,
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text('No guide accounts yet.')),
          ),
        ],
      );
    }

    return AdminTableArea(
      minWidth: 900,
      child: Column(
        children: [
          header,
          for (final guide in guides)
            _GuideRow(
              guide: guide,
              onApprove: () => _approve(context, guide),
              onReject: () => _reject(context, guide),
              onSuspend: () => _suspend(context, guide),
              onDetails: () => _showDetails(context, guide),
            ),
        ],
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
        const Divider(color: AppColors.adminDivider, height: 1),
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
                      style: AppTextStyles.adminTableCell,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      guide.email,
                      style: AppTextStyles.adminTableCellMuted,
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
                        style: AppTextStyles.adminTableCellMuted,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () => _showDetails(context),
                      child: Text(
                        'View file',
                        style: AppTextStyles.adminLinkText,
                      ),
                    ),
                  ],
                ),
              ),
              // City
              Expanded(
                flex: 2,
                child: Text(
                  guide.city,
                  style: AppTextStyles.adminTableCellMuted,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              // Status chip
              Expanded(flex: 2, child: StatusChip(status: guide.status)),
              // Actions
              Expanded(
                flex: 5,
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

  Future<void> _handleDownload(
    BuildContext context,
    String url,
    String defaultName,
  ) async {
    final cleanUrl = url.trim();
    if (cleanUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No file URL available for this document.'),
        ),
      );
      return;
    }

    try {
      // If it's a Cloudinary URL, convert to direct attachment download
      String downloadUrl = cleanUrl;
      if (cleanUrl.contains('cloudinary.com') &&
          cleanUrl.contains('/upload/')) {
        if (!cleanUrl.contains('/upload/fl_attachment')) {
          downloadUrl = cleanUrl.replaceFirst(
            '/upload/',
            '/upload/fl_attachment/',
          );
        }
      }

      final uri = Uri.parse(downloadUrl);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        await launchUrl(
          Uri.parse(cleanUrl),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not download document: $e')),
        );
      }
    }
  }

  Future<void> _handleView(BuildContext context, String url) async {
    final cleanUrl = url.trim();
    if (cleanUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No file URL available for this document.'),
        ),
      );
      return;
    }

    try {
      final uri = Uri.parse(cleanUrl);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open document viewer.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open document: $e')));
      }
    }
  }

  Widget _buildDocSection(
    BuildContext context, {
    required String title,
    required String fileName,
    required String url,
  }) {
    final hasUrl = url.trim().isNotEmpty;
    final lower = url.toLowerCase();
    final isImage =
        hasUrl &&
        (lower.contains('.jpg') ||
            lower.contains('.jpeg') ||
            lower.contains('.png') ||
            lower.contains('.webp') ||
            (lower.contains('cloudinary.com') && !lower.contains('.pdf')));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.adminDivider),
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
                      title,
                      style: AppTextStyles.adminSectionTitle.copyWith(
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      fileName.isNotEmpty
                          ? fileName
                          : (hasUrl ? 'Document uploaded' : 'No file uploaded'),
                      style: AppTextStyles.adminTableCellMuted,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (hasUrl) ...[
                OutlinedButton.icon(
                  onPressed: () => _handleView(context, url),
                  icon: const Icon(Icons.open_in_new, size: 14),
                  label: const Text('View'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.adminPrimary,
                    side: const BorderSide(color: AppColors.adminPrimary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              ElevatedButton.icon(
                onPressed: () => _handleDownload(context, url, fileName),
                icon: const Icon(
                  Icons.download_rounded,
                  size: 16,
                  color: Colors.white,
                ),
                label: const Text(
                  'Download',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.adminPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Document preview area
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.adminDocumentPreviewBg,
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: isImage
                ? InkWell(
                    onTap: () => _handleView(context, url),
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          _previewPlaceholder(hasUrl, fileName),
                    ),
                  )
                : _previewPlaceholder(hasUrl, fileName),
          ),
        ],
      ),
    );
  }

  Widget _previewPlaceholder(bool hasUrl, String fileName) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          hasUrl ? Icons.description_outlined : Icons.article_outlined,
          size: 44,
          color: hasUrl ? AppColors.adminPrimary : AppColors.adminTextMuted,
        ),
        const SizedBox(height: 8),
        Text(
          hasUrl
              ? (fileName.toLowerCase().endsWith('.pdf')
                    ? 'PDF Document (Click View to open)'
                    : 'Document uploaded (Click View to open)')
              : 'Document preview not available',
          style: AppTextStyles.adminTableCellMuted,
        ),
      ],
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
                        Text(guide.name, style: AppTextStyles.adminDialogTitle),
                        const SizedBox(height: 3),
                        Text(
                          'Complete guide application',
                          style: AppTextStyles.adminDialogSubtitle,
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
              const SizedBox(height: 20),

              // Verification Documents
              Text(
                'Verification Documents',
                style: AppTextStyles.adminSectionTitle,
              ),
              const SizedBox(height: 12),

              if (guide.idDocumentUrl.isNotEmpty ||
                  guide.licenseDocumentUrl.isNotEmpty) ...[
                if (guide.idDocumentUrl.isNotEmpty)
                  _buildDocSection(
                    context,
                    title: 'Tour Guide ID',
                    fileName: guide.idDocumentUrl
                        .split('/')
                        .last
                        .split('?')
                        .first,
                    url: guide.idDocumentUrl,
                  ),
                if (guide.licenseDocumentUrl.isNotEmpty)
                  _buildDocSection(
                    context,
                    title: 'Syndicate Membership / License',
                    fileName: guide.licenseDocumentUrl
                        .split('/')
                        .last
                        .split('?')
                        .first,
                    url: guide.licenseDocumentUrl,
                  ),
              ] else
                _buildDocSection(
                  context,
                  title: guide.document.isNotEmpty
                      ? guide.document
                      : 'Verification Document',
                  fileName: guide.docFileName,
                  url: guide.documentUrl,
                ),

              const SizedBox(height: 10),

              // Uploaded trips
              if (guide.uploadedTrips.isNotEmpty) ...[
                Text('Uploaded trips', style: AppTextStyles.adminSectionTitle),
                const SizedBox(height: 12),
                Row(
                  children: guide.uploadedTrips
                      .map(
                        (t) => Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.adminDivider),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.title,
                                  style: AppTextStyles.adminTableCell,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                Text(
                                  t.status,
                                  style: AppTextStyles.adminTableCellMuted,
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () => _showTripDialog(context, t),
                                  child: Text(
                                    'View full trip',
                                    style: AppTextStyles.adminLinkText,
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
        color: AppColors.adminInputBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.adminTableCellMuted),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.adminFieldValue,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
