import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/data/models/report.dart';
import 'package:triply/core/theme/app_colors.dart';
import 'package:triply/core/theme/app_text_styles.dart';
import 'package:triply/core/widgets/state_views.dart';
import 'package:triply/features/admin_dashboard/d_home/view/d_home_view.dart';

import '../cubit/reports_cubit.dart';

/// Admin workspace for chat reports submitted by tourists and guides.
class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReportsCubit()..start(),
      child: const _ReportsBody(),
    );
  }
}

class _ReportsBody extends StatelessWidget {
  const _ReportsBody();

  Future<void> _review(
    BuildContext context,
    Report report,
    String status,
  ) async {
    final cubit = context.read<ReportsCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final reviewNote = await _askReviewNote(context, status);
    if (reviewNote == null || !context.mounted) return;
    final error = await cubit.review(
      report,
      status: status,
      reviewNote: reviewNote,
    );
    if (!context.mounted) return;
    final ok = error == null;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Report ${status == 'resolved' ? 'resolved' : 'dismissed'}.'
              : 'Could not update this report: $error',
        ),
        backgroundColor: ok ? null : AppColors.adminDanger,
      ),
    );
  }

  Future<String?> _askReviewNote(BuildContext context, String status) async {
    final controller = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(status == 'resolved' ? 'Resolve report' : 'Dismiss report'),
        content: TextField(
          controller: controller,
          maxLength: 500,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Review note (optional)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: Text(status == 'resolved' ? 'Resolve' : 'Dismiss'),
          ),
        ],
      ),
    );
    controller.dispose();
    return note;
  }

  void _showDetails(BuildContext context, Report report) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Chat report'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailLine('Status', _statusLabel(report.status)),
              _DetailLine('Reason', _reasonLabel(report.reasonCode)),
              _DetailLine('Reporter UID', report.reporterId),
              _DetailLine('Reported user UID', report.reportedUserId),
              _DetailLine('Chat ID', report.chatId),
              _DetailLine('Message ID', report.messageId),
              _DetailLine('Reported message', report.text),
              if (report.note.isNotEmpty)
                _DetailLine('Reporter note', report.note),
              if (report.reviewNote?.isNotEmpty ?? false)
                _DetailLine('Admin review note', report.reviewNote!),
              _DetailLine('Submitted', _formatDate(report.createdAt)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (context, state) {
        if (state is ReportsInitial || state is ReportsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ReportsError) {
          return Center(
            child: AppErrorView(
              message: state.message,
              onRetry: context.read<ReportsCubit>().retry,
            ),
          );
        }
        final success = state as ReportsSuccess;
        final reports = success.filtered;
        return SingleChildScrollView(
          child: AdminCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardSectionHeader(
                  title: 'Chat Reports',
                  subtitle:
                      'Review messages reported by tourists and tour guides.',
                  trailing: Text(
                    '${success.reports.length} total',
                    style: AppTextStyles.adminLinkText,
                  ),
                ),
                const SizedBox(height: 20),
                SearchFilterRow(
                  hintText: 'Search reports, users, messages...',
                  onChanged: context.read<ReportsCubit>().search,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: DropdownButton<String>(
                    value: success.statusFilter,
                    onChanged: (value) {
                      if (value != null) {
                        context.read<ReportsCubit>().filterByStatus(value);
                      }
                    },
                    items: const [
                      DropdownMenuItem(
                        value: 'all',
                        child: Text('All reports'),
                      ),
                      DropdownMenuItem(value: 'open', child: Text('Open')),
                      DropdownMenuItem(
                        value: 'resolved',
                        child: Text('Resolved'),
                      ),
                      DropdownMenuItem(
                        value: 'dismissed',
                        child: Text('Dismissed'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (reports.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 36),
                    child: Center(child: Text('No chat reports found.')),
                  )
                else
                  for (final report in reports)
                    _ReportCard(
                      report: report,
                      busy: success.busyReportIds.contains(report.id),
                      onView: () => _showDetails(context, report),
                      onResolve: report.status == 'open'
                          ? () => _review(context, report, 'resolved')
                          : null,
                      onDismiss: report.status == 'open'
                          ? () => _review(context, report, 'dismissed')
                          : null,
                    ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.report,
    required this.busy,
    required this.onView,
    required this.onResolve,
    required this.onDismiss,
  });

  final Report report;
  final bool busy;
  final VoidCallback onView;
  final VoidCallback? onResolve;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.adminDivider),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _reasonLabel(report.reasonCode),
                  style: AppTextStyles.adminPostCardTitle,
                ),
              ),
              _StatusBadge(status: report.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            report.text.isEmpty
                ? 'Reported message is unavailable.'
                : report.text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.adminTableCell,
          ),
          const SizedBox(height: 8),
          Text(
            'Reporter ${_shortId(report.reporterId)}  ·  '
            'Reported ${_shortId(report.reportedUserId)}  ·  '
            '${_formatDate(report.createdAt)}',
            style: AppTextStyles.adminTableCellMuted,
          ),
          if (report.note.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Note: ${report.note}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.adminTableCellMuted,
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: onView,
                child: const Text('View details'),
              ),
              if (onResolve != null)
                ElevatedButton(
                  onPressed: busy ? null : onResolve,
                  child: busy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Resolve'),
                ),
              if (onDismiss != null)
                TextButton(
                  onPressed: busy ? null : onDismiss,
                  child: const Text('Dismiss'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'resolved' => AppColors.successTeal,
      'dismissed' => AppColors.adminTextMuted,
      _ => AppColors.adminDanger,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.adminTableHeader),
          const SizedBox(height: 3),
          SelectableText(value.isEmpty ? '—' : value),
        ],
      ),
    );
  }
}

String _statusLabel(String status) =>
    status.isEmpty ? 'Unknown' : status[0].toUpperCase() + status.substring(1);

String _reasonLabel(String reason) => switch (reason) {
  'inappropriate_content' => 'Inappropriate content',
  'harassment' => 'Harassment',
  'spam' => 'Spam',
  'other' => 'Other',
  _ => reason.isEmpty ? 'Unspecified reason' : reason,
};

String _formatDate(DateTime? date) => date == null
    ? 'Date unavailable'
    : '${date.month}/${date.day}/${date.year} '
          '${date.hour.toString().padLeft(2, '0')}:'
          '${date.minute.toString().padLeft(2, '0')}';

String _shortId(String value) => value.length > 12
    ? '${value.substring(0, 6)}…${value.substring(value.length - 4)}'
    : value;
