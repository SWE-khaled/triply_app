import 'package:flutter/material.dart';
import '../../../../core/theme/d_app_colors.dart';
import '../../../../core/theme/d_app_text_styles.dart';
import '../../../../core/widgets/d_circle_back_button.dart';
import '../../../../data/firestore/repositories/admin_repository.dart';
import '../../d_home/view/d_home_view.dart';

/// Users management screen (server-backed).
///
/// Rows come from the admin-only `users` list (tourists + guides);
/// suspend/activate writes `isActive` through the admin-only rules path.
/// Per-user activity counts are not aggregated server-side, so the
/// Activity column shows a placeholder instead of an invented number.
class UsersView extends StatefulWidget {
  const UsersView({super.key});

  @override
  State<UsersView> createState() => _UsersViewState();
}

class _UsersViewState extends State<UsersView> {
  final TextEditingController _search = TextEditingController();
  final AdminRepository _repo = AdminRepository();
  List<AdminUserRow> _users = [];
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

  /// Reloads the list. Returns false (with [error] set) when the display
  /// may be stale — mutating callers surface a notice instead of a
  /// misleading success.
  Future<bool> _load() async {
    if (!mounted) return false;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final users = await _repo.listUsers();
      if (!mounted) return false;
      setState(() {
        _users = users;
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

  List<AdminUserRow> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _users;
    return _users.where((u) {
      return u.name.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q) ||
          u.phone.toLowerCase().contains(q) ||
          u.typeLabel.toLowerCase().contains(q);
    }).toList();
  }

  void _showViewDialog(AdminUserRow user) {
    showDialog(
      context: context,
      builder: (_) => _ViewUserDialog(user: user),
    );
  }

  Future<void> _toggleUserStatus(AdminUserRow user) async {
    if (_busy.contains(user.uid)) return;
    setState(() => _busy.add(user.uid));
    try {
      await _repo.setUserActive(user.uid, !user.isActive);
      final fresh = await _load();
      if (!fresh) {
        _snack('Saved, but the list could not refresh.');
      } else {
        _snack(user.isActive ? 'User suspended.' : 'User reactivated.');
      }
    } catch (e) {
      _snack(_message(e));
    } finally {
      if (mounted) setState(() => _busy.remove(user.uid));
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
              ..._filtered.map(
                (u) => _UserRow(
                  user: u,
                  busy: _busy.contains(u.uid),
                  onView: () => _showViewDialog(u),
                  onToggleStatus: () => _toggleUserStatus(u),
                ),
              ),
              if (_filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('No users found.')),
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
    ),
  );
}

class _UserRow extends StatelessWidget {
  final AdminUserRow user;
  final bool busy;
  final VoidCallback onView;
  final VoidCallback onToggleStatus;

  const _UserRow({
    required this.user,
    required this.busy,
    required this.onView,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final isSuspended = !user.isActive;
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
                  user.name,
                  style: AppTextStyles.tableCell,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  user.email.isNotEmpty ? user.email : '—',
                  style: AppTextStyles.tableCellMuted,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  user.phone.isNotEmpty ? user.phone : '—',
                  style: AppTextStyles.tableCellMuted,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  user.typeLabel,
                  style: AppTextStyles.tableCellMuted,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '—',
                  style: AppTextStyles.tableCellMuted,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(flex: 2, child: StatusChip(status: user.status)),
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlineActionButton(label: 'View', onTap: onView),
                    const SizedBox(width: 6),
                    if (busy)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else if (isSuspended)
                      OutlineActionButton(
                        label: 'Activate',
                        onTap: onToggleStatus,
                      )
                    else
                      DangerActionButton(
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

/// View User Details Dialog
class _ViewUserDialog extends StatelessWidget {
  final AdminUserRow user;
  const _ViewUserDialog({required this.user});

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
                      'User Details',
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
              _buildDetailRow('Name:', user.name),
              _buildDetailRow(
                'Email:',
                user.email.isNotEmpty ? user.email : '—',
              ),
              _buildDetailRow(
                'Phone:',
                user.phone.isNotEmpty ? user.phone : '—',
              ),
              _buildDetailRow('Type:', user.typeLabel),
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
          Expanded(child: Text(value, style: AppTextStyles.tableCell)),
        ],
      ),
    );
  }
}
