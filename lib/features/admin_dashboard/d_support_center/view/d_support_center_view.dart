import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../support/contact_us/model/contact_message_model.dart';
import '../../d_home/view/d_home_view.dart';
import '../cubit/support_center_cubit.dart';

/// Admin workspace for complaints and inquiries sent from user settings.
class SupportCenterView extends StatelessWidget {
  const SupportCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SupportCenterCubit()..start(),
      child: const _SupportCenterBody(),
    );
  }
}

class _SupportCenterBody extends StatelessWidget {
  const _SupportCenterBody();

  Future<void> _changeStatus(
    BuildContext context,
    ContactMessageModel message,
    String status,
  ) async {
    final error = await context.read<SupportCenterCubit>().updateStatus(
      message,
      status,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error == null
              ? 'Status updated to ${_statusLabel(status)}.'
              : 'Could not update status: $error',
        ),
        backgroundColor: error == null ? null : AppColors.adminDanger,
      ),
    );
  }

  void _showDetails(BuildContext context, ContactMessageModel message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Support message'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailLine('Sender', message.userName),
              _DetailLine('Email', message.userEmail),
              _DetailLine('Role', _roleLabel(message.userRole)),
              _DetailLine('Type', _typeLabel(message.type)),
              _DetailLine('Status', _statusLabel(message.status)),
              _DetailLine('Submitted', _formatDate(message.createdAt)),
              _DetailLine('Message', message.message),
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
    return BlocBuilder<SupportCenterCubit, SupportCenterState>(
      builder: (context, state) {
        if (state is SupportCenterInitial || state is SupportCenterLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is SupportCenterError) {
          return Center(
            child: AppErrorView(
              message: state.message,
              onRetry: context.read<SupportCenterCubit>().retry,
            ),
          );
        }

        final success = state as SupportCenterSuccess;
        final messages = success.filtered;
        final cubit = context.read<SupportCenterCubit>();

        return SingleChildScrollView(
          child: AdminCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardSectionHeader(
                  title: 'Support Center',
                  subtitle:
                      'Review complaints and inquiries from tourists and guides.',
                  trailing: Text(
                    '${success.messages.length} total',
                    style: AppTextStyles.adminLinkText,
                  ),
                ),
                const SizedBox(height: 20),
                SearchFilterRow(
                  hintText: 'Search name, email or message...',
                  onChanged: cubit.search,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _FilterDropdown(
                      label: 'Status',
                      value: success.statusFilter,
                      items: const <DropdownMenuItem<String>>[
                        DropdownMenuItem(
                          value: 'all',
                          child: Text('All statuses'),
                        ),
                        DropdownMenuItem(value: 'pending', child: Text('Pending')),
                        DropdownMenuItem(
                          value: 'inProgress',
                          child: Text('In Progress'),
                        ),
                        DropdownMenuItem(
                          value: 'resolved',
                          child: Text('Resolved'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) cubit.filterByStatus(value);
                      },
                    ),
                    _FilterDropdown(
                      label: 'Role',
                      value: success.roleFilter,
                      items: const <DropdownMenuItem<String>>[
                        DropdownMenuItem(value: 'all', child: Text('All roles')),
                        DropdownMenuItem(
                          value: 'tourist',
                          child: Text('Tourist'),
                        ),
                        DropdownMenuItem(
                          value: 'tourGuide',
                          child: Text('Tour Guide'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) cubit.filterByRole(value);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (messages.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 36),
                    child: Center(child: Text('No support messages found.')),
                  )
                else
                  for (final message in messages)
                    _MessageCard(
                      message: message,
                      busy: success.busyIds.contains(message.id),
                      onView: () => _showDetails(context, message),
                      onStatusChanged: (status) =>
                          _changeStatus(context, message, status),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label:', style: AppTextStyles.adminTableHeader),
        const SizedBox(width: 8),
        DropdownButton<String>(value: value, items: items, onChanged: onChanged),
      ],
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.message,
    required this.busy,
    required this.onView,
    required this.onStatusChanged,
  });

  final ContactMessageModel message;
  final bool busy;
  final VoidCallback onView;
  final ValueChanged<String> onStatusChanged;

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
                  message.userName.isEmpty ? 'Unknown sender' : message.userName,
                  style: AppTextStyles.adminPostCardTitle,
                ),
              ),
              const SizedBox(width: 8),
              _Badge(label: _roleLabel(message.userRole), color: AppColors.adminPrimary),
              const SizedBox(width: 8),
              _Badge(
                label: _statusLabel(message.status),
                color: _statusColor(message.status),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${message.userEmail.isEmpty ? 'No email' : message.userEmail}  ·  '
            '${_typeLabel(message.type)}  ·  ${_formatDate(message.createdAt)}',
            style: AppTextStyles.adminTableCellMuted,
          ),
          const SizedBox(height: 10),
          Text(
            message.message.isEmpty ? 'No message content.' : message.message,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.adminTableCell,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton(
                onPressed: onView,
                child: const Text('View details'),
              ),
              if (busy)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              DropdownButton<String>(
                value: ContactMessageModel.statuses.contains(message.status)
                    ? message.status
                    : 'pending',
                onChanged: busy ? null : (value) {
                  if (value != null) onStatusChanged(value);
                },
                items: ContactMessageModel.statuses
                    .map(
                      (status) => DropdownMenuItem<String>(
                        value: status,
                        child: Text(_statusLabel(status)),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
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

Color _statusColor(String status) => switch (status) {
  'resolved' => AppColors.successTeal,
  'inProgress' => AppColors.adminPrimary,
  _ => AppColors.adminDanger,
};

String _statusLabel(String status) => switch (status) {
  'inProgress' => 'In Progress',
  'pending' => 'Pending',
  'resolved' => 'Resolved',
  _ => status.isEmpty ? 'Unknown' : status,
};

String _typeLabel(String type) => switch (type) {
  'complaint' => 'Complaint',
  'inquiry' => 'Inquiry',
  'general' => 'General',
  _ => type.isEmpty ? 'Unspecified' : type,
};

String _roleLabel(String role) => switch (role) {
  'tourist' => 'Tourist',
  'tourGuide' => 'Tour Guide',
  'guide' => 'Tour Guide',
  _ => role.isEmpty ? 'Unknown role' : role,
};

String _formatDate(DateTime? date) => date == null
    ? 'Date unavailable'
    : '${date.month}/${date.day}/${date.year} '
          '${date.hour.toString().padLeft(2, '0')}:'
          '${date.minute.toString().padLeft(2, '0')}';
