import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/data/repositories/admin_guides_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../d_home/view/d_home_view.dart';
import '../cubit/admin_dashboard_cubit.dart';

/// Overview / Dashboard page (all stats and lists stream live from Firestore).
class OverviewView extends StatelessWidget {
  const OverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminDashboardCubit()..start(),
      child: const _OverviewBody(),
    );
  }
}

class _OverviewBody extends StatelessWidget {
  const _OverviewBody();

  Future<void> _updateGuideStatus(
    BuildContext context,
    AdminGuide guide,
    String status,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await context.read<AdminDashboardCubit>().updateGuideStatus(
      guide,
      status,
    );
    if (ok) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text('Failed to update status for ${guide.name}.'),
        backgroundColor: AppColors.adminDanger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminDashboardCubit, AdminDashboardState>(
      builder: (context, state) {
        if (state is AdminDashboardInitial || state is AdminDashboardLoading) {
          return const _OverviewStatus(child: CircularProgressIndicator());
        }
        if (state is AdminDashboardError) {
          return _OverviewStatus(child: _buildError(context, state));
        }

        final data = state as AdminDashboardSuccess;
        return SingleChildScrollView(
          child: AdminCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 6-stat dynamic KPI grid ───────────────────────────────
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
                            value: _formatNumber(data.totalUsersCount),
                            label: 'Total Users',
                            badge: data.totalUsersCount > 0
                                ? '+${data.totalUsersCount}'
                                : '0',
                            badgeDanger: false,
                            badgeIsText: true,
                          ),
                        ),
                        SizedBox(
                          width: w,
                          child: _StatCard(
                            index: 2,
                            value: _formatNumber(data.tourGuidesCount),
                            label: 'Tour Guides',
                            badge: data.tourGuidesCount > 0
                                ? '+${data.tourGuidesCount}'
                                : '0',
                            badgeDanger: false,
                            badgeIsText: true,
                          ),
                        ),
                        SizedBox(
                          width: w,
                          child: _StatCard(
                            index: 3,
                            value: _formatNumber(data.totalTripsCount),
                            label: 'Total Trips',
                            badge: data.totalTripsCount > 0
                                ? '+${data.totalTripsCount}'
                                : '0',
                            badgeDanger: false,
                            badgeIsText: true,
                          ),
                        ),
                        SizedBox(
                          width: w,
                          child: _StatCard(
                            index: 4,
                            value: _formatNumber(data.totalBookingsCount),
                            label: 'Total Bookings',
                            badge: data.totalBookingsCount > 0
                                ? '+${data.totalBookingsCount}'
                                : '0',
                            badgeDanger: false,
                            badgeIsText: true,
                          ),
                        ),
                        SizedBox(
                          width: w,
                          child: _StatCard(
                            index: 5,
                            value: data.earningsLabel,
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
                            value: '${data.totalPending}',
                            label: 'Pending Requests',
                            badge: data.totalPending > 0
                                ? 'Needs review'
                                : 'All clear',
                            badgeDanger: data.totalPending > 0,
                            badgeIsText: true,
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),

                // ── Bottom row: Pending Actions + Guide Applications ──────
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 700) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _PendingActionsCard(
                            guidesCount: data.pendingGuidesCount,
                            tripsCount: data.pendingTripsCount,
                          ),
                          const SizedBox(height: 16),
                          _GuideApplicationsCard(
                            guides: data.guides,
                            onUpdateStatus: (guide, status) =>
                                _updateGuideStatus(context, guide, status),
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
                            guidesCount: data.pendingGuidesCount,
                            tripsCount: data.pendingTripsCount,
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: rightW,
                          child: _GuideApplicationsCard(
                            guides: data.guides,
                            onUpdateStatus: (guide, status) =>
                                _updateGuideStatus(context, guide, status),
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
      },
    );
  }

  Widget _buildError(BuildContext context, AdminDashboardError state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          state.message,
          textAlign: TextAlign.center,
          style: AppTextStyles.adminTableCellMuted,
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => context.read<AdminDashboardCubit>().retry(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.adminPrimary,
          ),
          child: const Text('Retry', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

/// Centered white card used by the loading and error states.
class _OverviewStatus extends StatelessWidget {
  final Widget child;

  const _OverviewStatus({required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AdminCard(
        padding: const EdgeInsets.all(48),
        child: Center(child: child),
      ),
    );
  }
}

String _formatNumber(int n) {
  if (n <= 0) return '0';
  final s = n.toString();
  final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  return s.replaceAllMapped(reg, (Match m) => '${m[1]},');
}

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
        border: Border.all(color: AppColors.adminBorderLight),
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
                  color: AppColors.adminStatBadgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.adminStatBadgeText,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                badge,
                style: badgeDanger
                    ? AppTextStyles.adminStatPercentDanger
                    : (badgeIsText
                          ? AppTextStyles.adminSectionSubtitle.copyWith(
                              color: badgeDanger ? AppColors.adminDanger : AppColors.adminPositiveGreen,
                            )
                          : AppTextStyles.adminStatPercent),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: AppTextStyles.adminStatValue,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.adminStatLabel,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

// â”€â”€ Pending Actions Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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
        border: Border.all(color: AppColors.adminBorderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Pending Actions', style: AppTextStyles.adminSectionTitle),
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
        color: AppColors.adminBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.adminTableCell),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.adminTableCellMuted),
              ],
            ),
          ),
          Text(count, style: AppTextStyles.adminPendingActionsCount),
        ],
      ),
    );
  }
}

// â”€â”€ Guide Applications Card (mini table) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _GuideApplicationsCard extends StatelessWidget {
  final List<AdminGuide> guides;
  final Future<void> Function(AdminGuide, String) onUpdateStatus;

  const _GuideApplicationsCard({
    required this.guides,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    final pendingGuides = guides.where((g) => g.status == 'pending').toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.adminBorderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Guide Applications', style: AppTextStyles.adminSectionTitle),
                  const SizedBox(height: 2),
                  Text(
                    'Review documents, guide activity and uploaded content',
                    style: AppTextStyles.adminSectionSubtitle,
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
                  color: AppColors.adminStatusPendingBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${pendingGuides.length} pending',
                  style: AppTextStyles.adminTableCellMuted.copyWith(
                    color: AppColors.adminStatusPendingText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MiniGuideTableHeader(),
          const Divider(color: AppColors.adminDivider, height: 1),
          if (guides.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('No guide applications found.')),
            )
          else
            ...guides.map(
              (g) => _MiniGuideRow(
                guide: g,
                onApprove: () => onUpdateStatus(g, 'approved'),
                onReject: () => onUpdateStatus(g, 'suspended'),
                onSuspend: () => onUpdateStatus(g, 'suspended'),
                onActivate: () => onUpdateStatus(g, 'approved'),
              ),
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
            child: Text('Guide', style: AppTextStyles.adminTableHeader),
          ),
          Expanded(
            flex: 3,
            child: Text('Document', style: AppTextStyles.adminTableHeader),
          ),
          Expanded(
            flex: 2,
            child: Text('City', style: AppTextStyles.adminTableHeader),
          ),
          Expanded(
            flex: 2,
            child: Text('Status', style: AppTextStyles.adminTableHeader),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Actions',
              style: AppTextStyles.adminTableHeader,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniGuideRow extends StatelessWidget {
  final AdminGuide guide;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onSuspend;
  final VoidCallback onActivate;

  const _MiniGuideRow({
    required this.guide,
    required this.onApprove,
    required this.onReject,
    required this.onSuspend,
    required this.onActivate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(color: AppColors.adminDivider, height: 1),
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
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        guide.document.isNotEmpty ? guide.document : 'National ID',
                        style: AppTextStyles.adminTableCellMuted,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('View file', style: AppTextStyles.adminLinkText),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  guide.city.isNotEmpty ? guide.city : 'Egypt',
                  style: AppTextStyles.adminTableCellMuted,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(flex: 2, child: _buildStatusChip(guide.status)),
              Expanded(flex: 3, child: _buildActions(guide, context)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color bg;
    Color textColor;
    String label;
    if (status == 'pending') {
      bg = AppColors.adminStatusPendingBg;
      textColor = AppColors.adminStatusPendingText;
      label = 'Pending';
    } else if (status == 'approved') {
      bg = AppColors.adminStatusActiveBg;
      textColor = AppColors.adminStatusActiveText;
      label = 'Approved';
    } else {
      bg = AppColors.adminStatusSuspendedBg;
      textColor = AppColors.adminStatusSuspendedText;
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

  Widget _buildActions(AdminGuide guide, BuildContext context) {
    if (guide.status == 'pending') {
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
    } else if (guide.status == 'suspended') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InkWell(
            onTap: onActivate,
            child: const _SmallBtn(label: 'Activate', danger: false),
          ),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        InkWell(
          onTap: onSuspend,
          child: const _SmallBtn(label: 'Suspend', danger: true),
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
        color: danger ? AppColors.adminDangerLight : Colors.white,
        border: danger ? null : Border.all(color: AppColors.adminDivider),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: danger ? AppColors.adminDanger : AppColors.adminTextPrimary,
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
        color: AppColors.adminPrimary,
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

