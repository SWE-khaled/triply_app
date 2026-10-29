import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/data/repositories/admin_tourists_repository.dart';
import '../../../../core/theme/d_app_colors.dart';
import '../../../../core/theme/d_app_text_styles.dart';
import '../../../../core/widgets/d_circle_back_button.dart';
import '../../d_home/view/d_home_view.dart';

/// Tourists management screen (for Tourists only, connected to Firestore database).
class UsersView extends StatefulWidget {
  const UsersView({super.key});

  @override
  State<UsersView> createState() => _UsersViewState();
}

class _UsersViewState extends State<UsersView> {
  final TextEditingController _search = TextEditingController();
  final AdminTouristsRepository _repository = AdminTouristsRepository();

  List<AdminTourist> _tourists = const [];
  StreamSubscription<List<AdminTourist>>? _subscription;
  String _query = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _subscription = _repository.watchTourists().listen(
      (tourists) {
        if (!mounted) return;
        setState(() {
          _tourists = tourists;
          _loading = false;
        });
      },
      onError: (_) {
        if (!mounted) return;
        setState(() {
          _loading = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _search.dispose();
    super.dispose();
  }

  List<AdminTourist> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _tourists;
    return _tourists.where((u) {
      return u.name.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q) ||
          u.phone.toLowerCase().contains(q);
    }).toList();
  }

  void _showViewDialog(AdminTourist tourist) {
    showDialog(
      context: context,
      builder: (_) => _ViewUserDialog(tourist: tourist),
    );
  }

  Future<void> _toggleUserStatus(AdminTourist tourist) async {
    final newStatus = tourist.status == 'active' ? 'suspended' : 'active';
    final ok = await _repository.updateStatus(tourist.uid, newStatus);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update tourist status.')),
      );
    }
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
              controller: _search,
              onChanged: (v) => setState(() => _query = v),
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

            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              ..._filtered.map(
                (u) => _UserRow(
                  tourist: u,
                  onView: () => _showViewDialog(u),
                  onToggleStatus: () => _toggleUserStatus(u),
                ),
              ),
              if (_filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('No tourists found.')),
                ),
            ],
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
        const Divider(color: AppColors.divider, height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  tourist.name,
                  style: AppTextStyles.tableCell,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  tourist.email,
                  style: AppTextStyles.tableCellMuted,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  tourist.phone.isNotEmpty ? tourist.phone : '—',
                  style: AppTextStyles.tableCellMuted,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  tourist.type,
                  style: AppTextStyles.tableCellMuted,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  tourist.activity,
                  style: AppTextStyles.tableCellMuted,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(flex: 2, child: StatusChip(status: tourist.status)),
              Expanded(
                flex: 2,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                        ),
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
                    );
                  },
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
                      style: AppTextStyles.dialogTitle,
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
            child: Text(label, style: AppTextStyles.fieldLabel),
          ),
          Expanded(child: Text(value, style: AppTextStyles.tableCell)),
        ],
      ),
    );
  }
}
