import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/data/repositories/admin_tourists_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/d_circle_back_button.dart';
import '../../d_home/view/d_home_view.dart';
import '../cubit/users_cubit.dart';

/// Tourists management screen (connected to Firestore).
class UsersView extends StatelessWidget {
  const UsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UsersCubit()..start(),
      child: const _UsersBody(),
    );
  }
}

class _UsersBody extends StatelessWidget {
  const _UsersBody();

  void _showViewDialog(BuildContext context, AdminTourist tourist) {
    showDialog(
      context: context,
      builder: (_) => _ViewUserDialog(tourist: tourist),
    );
  }

  Future<void> _toggleUserStatus(
    BuildContext context,
    AdminTourist tourist,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await context.read<UsersCubit>().toggleStatus(tourist);
    if (ok) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('Failed to update tourist status.')),
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
                    title: 'Manage Tourists',
                    subtitle: 'Search, review and control all tourist accounts.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            SearchFilterRow(
              hintText: 'Search tourists...',
              onChanged: context.read<UsersCubit>().search,
            ),
            const SizedBox(height: 20),

            BlocBuilder<UsersCubit, UsersState>(
              builder: (context, state) {
                final header = Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          _h('Name', 3),
                          _h('Email', 3),
                          _h('Phone', 3),
                          _h('Type', 2),
                          _h('Activity', 2),
                          _h('Status', 2),
                          _h('Actions', 4, end: true),
                        ],
                      ),
                    ),
                    const Divider(color: AppColors.adminDivider, height: 1),
                  ],
                );

                if (state is UsersInitial || state is UsersLoading) {
                  return Column(
                    children: [
                      header,
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  );
                }
                if (state is UsersError) {
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

                final data = state as UsersSuccess;
                final tourists = data.filtered;
                if (tourists.isEmpty) {
                  return Column(
                    children: [
                      header,
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: Text('No tourists found.')),
                      ),
                    ],
                  );
                }

                return AdminTableArea(
                  minWidth: 900,
                  child: Column(
                    children: [
                      header,
                      for (final tourist in tourists)
                        _UserRow(
                          tourist: tourist,
                          onView: () => _showViewDialog(context, tourist),
                          onToggleStatus: () =>
                              _toggleUserStatus(context, tourist),
                        ),
                    ],
                  ),
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
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    ),
  );
}

class _UserRow extends StatelessWidget {
  final AdminTourist tourist;
  final VoidCallback onView;
  final VoidCallback onToggleStatus;

  const _UserRow({
    required this.tourist,
    required this.onView,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final isSuspended = tourist.status == 'suspended';
    return Column(
      children: [
        const Divider(color: AppColors.adminDivider, height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  tourist.name,
                  style: AppTextStyles.adminTableCell,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  tourist.email,
                  style: AppTextStyles.adminTableCellMuted,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  tourist.phone.isNotEmpty ? tourist.phone : 'â€”',
                  style: AppTextStyles.adminTableCellMuted,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  tourist.type,
                  style: AppTextStyles.adminTableCellMuted,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  tourist.activity,
                  style: AppTextStyles.adminTableCellMuted,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(flex: 2, child: StatusChip(status: tourist.status)),
              Expanded(
                flex: 4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlineActionButton(label: 'View', onTap: onView),
                    const SizedBox(width: 6),
                    isSuspended
                        ? OutlineActionButton(
                            label: 'Activate',
                            onTap: onToggleStatus,
                          )
                        : DangerActionButton(
                            label: 'Suspend',
                            onTap: onToggleStatus,
                          ),
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

/// View Tourist Details Dialog
class _ViewUserDialog extends StatelessWidget {
  final AdminTourist tourist;
  const _ViewUserDialog({required this.tourist});

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
                      'Tourist Details',
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
              _buildDetailRow('Name:', tourist.name),
              _buildDetailRow('Email:', tourist.email),
              _buildDetailRow('Phone:', tourist.phone.isNotEmpty ? tourist.phone : 'Not provided'),
              _buildDetailRow('Type:', tourist.type),
              _buildDetailRow('Activity:', tourist.activity),
              _buildDetailRow('Status:', tourist.status.toUpperCase()),
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
            child: Text(label, style: AppTextStyles.adminFieldLabel),
          ),
          Expanded(child: Text(value, style: AppTextStyles.adminTableCell)),
        ],
      ),
    );
  }
}

