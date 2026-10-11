import 'package:flutter/material.dart';
import '../../../../core/theme/d_app_colors.dart';
import '../../../../core/theme/d_app_text_styles.dart';
import '../../../../data/firestore/repositories/admin_repository.dart';
import '../../d_home/view/d_home_view.dart';

/// Overview / Dashboard page (server-backed).
///
/// Stat cards show live server aggregates (counts + commission earnings);
/// the guide applications card drives the same admin-only verification
/// decisions as the Guides screen.
class OverviewView extends StatefulWidget {
  const OverviewView({super.key});

  @override
  State<OverviewView> createState() => _OverviewViewState();
}

class _OverviewViewState extends State<OverviewView> {
  final AdminRepository _repo = AdminRepository();
  AdminOverview? _overview;
  List<AdminGuideRow> _guides = [];
  bool _loading = true;
  String? _error;
  final Set<String> _busy = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Reloads stats + queue. Returns false (with [error] set) when the
  /// display may be stale — mutating callers surface a notice instead of
  /// a misleading success.
  Future<bool> _load() async {
    if (!mounted) return false;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final overview = await _repo.overviewCounts();
      final guides = await _repo.pendingVerifications(limit: 10);
      if (!mounted) return false;
      setState(() {
        _overview = overview;
        _guides = guides;
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

  /// Thousands separator for stat values (no new dependencies).
  static String _fmt(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    var count = 0;
    for (var i = digits.length - 1; i >= 0; i--) {
      buffer.write(digits[i]);
      count++;
      if (count % 3 == 0 && i != 0) buffer.write(',');
    }
    return buffer.toString().split('').reversed.join();
  }

  Future<void> _decide(AdminGuideRow row, bool approved) async {
    if (_busy.contains(row.guideId)) return;
    setState(() => _busy.add(row.guideId));
    try {
      await _repo.decideVerification(guideId: row.guideId, approved: approved);
      final fresh = await _load();
      _snack(
        fresh
            ? (approved ? 'Guide approved.' : 'Verification rejected.')
            : 'Saved, but the list could not refresh.',
      );
    } catch (e) {
      _snack(_message(e));
    } finally {
      if (mounted) setState(() => _busy.remove(row.guideId));
    }
  }

  Future<void> _toggleActive(AdminGuideRow row) async {
    if (_busy.contains(row.guideId)) return;
    setState(() => _busy.add(row.guideId));
    try {
      await _repo.setUserActive(row.guideId, !row.userActive);
      final fresh = await _load();
      if (!fresh) {
        _snack('Saved, but the list could not refresh.');
      } else {
        _snack(row.userActive ? 'Guide suspended.' : 'Guide reactivated.');
      }
    } catch (e) {
      _snack(_message(e));
    } finally {
      if (mounted) setState(() => _busy.remove(row.guideId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final overview = _overview;
    final pendingGuidesCount = overview?.pendingGuides ?? 0;
    final pendingTripsCount = overview?.pendingTrips ?? 0;
    final totalPending = overview?.totalPending ?? 0;

    if (_loading && overview == null) {
      return const SingleChildScrollView(
        child: AdminCard(
          padding: EdgeInsets.all(24),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 64),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      );
    }
    if (_error != null && overview == null) {
      return SingleChildScrollView(
        child: AdminCard(
          padding: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
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
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: AdminCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 6-stat grid ─────────────────────────────
            LayoutBuilder(
              builder: (context, constraints) {
                final w = (constraints.maxWidth - 32) / 3;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: w,
                      child: _StatCard(
                        index: 1,
                        value: _fmt(overview?.usersTotal ?? 0),
                        label: 'Total Users',
                        badge: '',
                        badgeDanger: false,
                        badgeIsText: true,
                      ),
                    ),
                    SizedBox(
                      width: w,
                      child: _StatCard(
                        index: 2,
                        value: _fmt(overview?.guidesTotal ?? 0),
                        label: 'Tour Guides',
                        badge: '',
                        badgeDanger: false,
                        badgeIsText: true,
                      ),
                    ),
                    SizedBox(
                      width: w,
                      child: _StatCard(
                        index: 3,
                        value: _fmt(overview?.tripsTotal ?? 0),
                        label: 'Total Trips',
                        badge: '',
                        badgeDanger: false,
                        badgeIsText: true,
                      ),
                    ),
                    SizedBox(
                      width: w,
                      child: _StatCard(
                        index: 4,
                        value: _fmt(overview?.bookingsTotal ?? 0),
                        label: 'Total Bookings',
                        badge: '',
                        badgeDanger: false,
                        badgeIsText: true,
                      ),
                    ),
                    SizedBox(
                      width: w,
                      child: _StatCard(
                        index: 5,
                        value:
                            'EGP ${(overview?.earnings ?? 0).toStringAsFixed(0)}',
                        label: 'Our Earnings',
                        badge: 'from commissions',
                        badgeDanger: false,
                        badgeIsText: true,
                      ),
                    ),
                    SizedBox(
                      width: w,
                      child: _StatCard(
                        index: 6,
                        value: '$totalPending',
                        label: 'Pending Requests',
                        badge: 'Needs review',
                        badgeDanger: true,
                        badgeIsText: true,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // ── Bottom row: Pending Actions + Guide Applications ──
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 700) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PendingActionsCard(
                        guidesCount: pendingGuidesCount,
                        tripsCount: pendingTripsCount,
                      ),
                      const SizedBox(height: 16),
                      _GuideApplicationsCard(
                        guides: _guides,
                        busy: _busy,
                        onApprove: _decide,
                        onToggleActive: _toggleActive,
                      ),
                    ],
                  );
                }
                final leftW = (constraints.maxWidth - 16) * 0.4;
                final rightW = (constraints.maxWidth - 16) * 0.6;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: leftW,
                      child: _PendingActionsCard(
                        guidesCount: pendingGuidesCount,
                        tripsCount: pendingTripsCount,
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: rightW,
                      child: _GuideApplicationsCard(
                        guides: _guides,
                        busy: _busy,
                        onApprove: _decide,
                        onToggleActive: _toggleActive,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stat Card ────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final int index;
  final String value;
  final String label;
  final String badge;
  final bool badgeDanger;
  final bool badgeIsText;

  const _StatCard({
    required this.index,
    required this.value,
    required this.label,
    required this.badge,
    required this.badgeDanger,
    this.badgeIsText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Number badge
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.statBadgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.statBadgeText,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                badge,
                style: badgeDanger
                    ? AppTextStyles.statPercentDanger
                    : (badgeIsText
                          ? AppTextStyles.sectionSubtitle.copyWith(
                              color: AppColors.positiveGreen,
                            )
                          : AppTextStyles.statPercent),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: AppTextStyles.statValue,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.statLabel,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

// ── Pending Actions Card ─────────────────────────────────────
class _PendingActionsCard extends StatelessWidget {
  final int guidesCount;
  final int tripsCount;

  const _PendingActionsCard({
    required this.guidesCount,
    required this.tripsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Pending Actions', style: AppTextStyles.sectionTitle),
              const Spacer(),
              Text(
                'Manage all',
                style: AppTextStyles.linkText.copyWith(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _PendingActionItem(
            title: 'Guides waiting for approval',
            subtitle: 'Review verification documents',
            count: '$guidesCount',
          ),
          const SizedBox(height: 10),
          _PendingActionItem(
            title: 'Trip applications',
            subtitle: 'Waiting for approval',
            count: '$tripsCount',
          ),
        ],
      ),
    );
  }
}

class _PendingActionItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String count;

  const _PendingActionItem({
    required this.title,
    required this.subtitle,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.tableCell),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.tableCellMuted),
              ],
            ),
          ),
          Text(count, style: AppTextStyles.pendingActionsCount),
        ],
      ),
    );
  }
}

// ── Guide Applications Card (mini table) ─────────────────────
class _GuideApplicationsCard extends StatelessWidget {
  final List<AdminGuideRow> guides;
  final Set<String> busy;
  final Future<void> Function(AdminGuideRow, bool) onApprove;
  final Future<void> Function(AdminGuideRow) onToggleActive;

  const _GuideApplicationsCard({
    required this.guides,
    required this.busy,
    required this.onApprove,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    final pendingGuides = guides.where((g) => g.status == 'pending').toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Guide Applications', style: AppTextStyles.sectionTitle),
                  const SizedBox(height: 2),
                  Text(
                    'Review documents, guide activity and uploaded content',
                    style: AppTextStyles.sectionSubtitle,
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.statusPendingBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${pendingGuides.length} pending',
                  style: AppTextStyles.tableCellMuted.copyWith(
                    color: AppColors.statusPendingText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MiniGuideTableHeader(),
          const Divider(color: AppColors.divider, height: 1),
          ...guides.map(
            (g) => _MiniGuideRow(
              row: g,
              busy: busy.contains(g.guideId),
              onApprove: () => onApprove(g, true),
              onReject: () => onApprove(g, false),
              onToggleActive: () => onToggleActive(g),
            ),
          ),
          if (guides.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: Text('No pending applications.')),
            ),
        ],
      ),
    );
  }
}

class _MiniGuideTableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text('Guide', style: AppTextStyles.tableHeader),
          ),
          Expanded(
            flex: 3,
            child: Text('Document', style: AppTextStyles.tableHeader),
          ),
          Expanded(
            flex: 2,
            child: Text('City', style: AppTextStyles.tableHeader),
          ),
          Expanded(
            flex: 2,
            child: Text('Status', style: AppTextStyles.tableHeader),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Actions',
              style: AppTextStyles.tableHeader,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniGuideRow extends StatelessWidget {
  final AdminGuideRow row;
  final bool busy;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onToggleActive;

  const _MiniGuideRow({
    required this.row,
    required this.busy,
    required this.onApprove,
    required this.onReject,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(color: AppColors.divider, height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.displayName,
                      style: AppTextStyles.tableCell,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      row.email,
                      style: AppTextStyles.tableCellMuted,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _docLabel(row),
                        style: AppTextStyles.tableCellMuted,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('View file', style: AppTextStyles.linkText),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  row.city.isNotEmpty ? row.city : '—',
                  style: AppTextStyles.tableCellMuted,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(
                flex: 2,
                child: _buildStatusChip(
                  row.userActive ? row.status : 'suspended',
                ),
              ),
              Expanded(flex: 3, child: _buildActions(row, context)),
            ],
          ),
        ),
      ],
    );
  }

  static String _docLabel(AdminGuideRow row) {
    final hasId = row.verification.idDocumentUrl.isNotEmpty;
    final hasLicense = row.verification.licenseDocumentUrl.isNotEmpty;
    if (hasId && hasLicense) return '2 files';
    if (hasId || hasLicense) return '1 file';
    return 'No files';
  }

  Widget _buildStatusChip(String status) {
    Color bg;
    Color textColor;
    String label;
    if (status == 'pending') {
      bg = AppColors.statusPendingBg;
      textColor = AppColors.statusPendingText;
      label = 'Pending';
    } else if (status == 'approved') {
      bg = AppColors.statusActiveBg;
      textColor = AppColors.statusActiveText;
      label = 'Approved';
    } else {
      bg = AppColors.statusSuspendedBg;
      textColor = AppColors.statusSuspendedText;
      label = 'Suspended';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildActions(AdminGuideRow row, BuildContext context) {
    if (busy) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      );
    }
    if (row.status == 'pending') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InkWell(
            onTap: onReject,
            child: const _SmallBtn(label: 'Reject', danger: true),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: onApprove,
            child: const _SmallFilledBtn(label: 'Approve'),
          ),
        ],
      );
    }
    if (row.userActive) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InkWell(
            onTap: onToggleActive,
            child: const _SmallBtn(label: 'Suspend', danger: true),
          ),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        InkWell(
          onTap: onToggleActive,
          child: const _SmallBtn(label: 'Activate', danger: false),
        ),
      ],
    );
  }
}

class _SmallBtn extends StatelessWidget {
  final String label;
  final bool danger;
  const _SmallBtn({required this.label, required this.danger});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: danger ? AppColors.dangerLight : Colors.white,
        border: danger ? null : Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: danger ? AppColors.danger : AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _SmallFilledBtn extends StatelessWidget {
  final String label;
  const _SmallFilledBtn({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
