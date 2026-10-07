import 'package:flutter/material.dart';
import '../../../../core/theme/d_app_colors.dart';
import '../../../../core/theme/d_app_text_styles.dart';
import '../../../../core/widgets/d_circle_back_button.dart';
import '../../../../data/mock/d_mock_search.dart';
import '../../d_home/view/d_home_view.dart';

/// Users management screen.
class UsersView extends StatefulWidget {
  const UsersView({super.key});

  @override
  State<UsersView> createState() => _UsersViewState();
}

class _UsersViewState extends State<UsersView> {
  final TextEditingController _search = TextEditingController();
  late List<MockUser> _users;

  @override
  void initState() {
    super.initState();
    _users = List.from(mockUsers);
  }

  void _showViewDialog(MockUser user) {
    showDialog(
      context: context,
      builder: (_) => _ViewUserDialog(user: user),
    );
  }

  void _toggleUserStatus(MockUser user) {
    setState(() {
      final index = _users.indexOf(user);
      if (index != -1) {
        final newStatus = user.status == 'active' ? 'suspended' : 'active';
        _users[index] = MockUser(
          name: user.name,
          email: user.email,
          phone: user.phone,
          type: user.type,
          activity: user.activity,
          status: newStatus,
        );
      }
    });
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
                    title: 'Manage Users',
                    subtitle: 'Search, review, edit and control all users.',
                  ),
                ),

              ],
            ),
            const SizedBox(height: 20),

            SearchFilterRow(
              hintText: 'Search users...',
              controller: _search,
            ),
            const SizedBox(height: 20),

            // Table header
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
                  _h('Actions', 2, end: true),
                ],
              ),
            ),
            const Divider(color: AppColors.divider, height: 1),

            ..._users.map((u) => _UserRow(
              user: u,
              onView: () => _showViewDialog(u),
              onToggleStatus: () => _toggleUserStatus(u),
            )),
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

class _UserRow extends StatelessWidget {
  final MockUser user;
  final VoidCallback onView;
  final VoidCallback onToggleStatus;

  const _UserRow({required this.user, required this.onView, required this.onToggleStatus});

  @override
  Widget build(BuildContext context) {
    final isSuspended = user.status == 'suspended';
    return Column(
      children: [
        const Divider(color: AppColors.divider, height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(user.name, style: AppTextStyles.tableCell),
              ),
              Expanded(
                flex: 3,
                child: Text(user.email, style: AppTextStyles.tableCellMuted),
              ),
              Expanded(
                flex: 3,
                child: Text(user.phone, style: AppTextStyles.tableCellMuted),
              ),
              Expanded(
                flex: 2,
                child: Text(user.type, style: AppTextStyles.tableCellMuted),
              ),
              Expanded(
                flex: 2,
                child: Text(user.activity, style: AppTextStyles.tableCellMuted),
              ),
              Expanded(
                flex: 2,
                child: StatusChip(status: user.status),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlineActionButton(label: 'View', onTap: onView),
                    const SizedBox(width: 6),
                    isSuspended
                        ? OutlineActionButton(label: 'Activate', onTap: onToggleStatus)
                        : DangerActionButton(label: 'Suspend', onTap: onToggleStatus),
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


/// View User Details Dialog
class _ViewUserDialog extends StatelessWidget {
  final MockUser user;
  const _ViewUserDialog({required this.user});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: 520,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('User Details', style: AppTextStyles.dialogTitle),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.divider),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Close', style: AppTextStyles.buttonSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Name:', user.name),
              _buildDetailRow('Email:', user.email),
              _buildDetailRow('Phone:', user.phone),
              _buildDetailRow('Type:', user.type),
              _buildDetailRow('Activity:', user.activity),
              _buildDetailRow('Status:', user.status.toUpperCase()),
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
            child: Text(label, style: AppTextStyles.fieldLabel),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.tableCell),
          ),
        ],
      ),
    );
  }
}

