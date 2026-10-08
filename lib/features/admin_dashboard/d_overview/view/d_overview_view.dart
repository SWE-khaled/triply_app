import 'package:flutter/material.dart';
import '../../../../core/theme/d_app_colors.dart';
import '../../../../core/theme/d_app_text_styles.dart';
import '../../../../data/mock/d_mock_guides.dart';
import '../../d_home/view/d_home_view.dart';

/// Overview / Dashboard page.
class OverviewView extends StatefulWidget {
  const OverviewView({super.key});

  @override
  State<OverviewView> createState() => _OverviewViewState();
}

class _OverviewViewState extends State<OverviewView> {
  late List<MockGuide> _guides;

  @override
  void initState() {
    super.initState();
    _guides = List.from(mockGuides);
  }

  void _updateGuideStatus(MockGuide guide, String status) {
    setState(() {
      final i = _guides.indexOf(guide);
      if (i != -1) {
        _guides[i] = MockGuide(
          name: guide.name, email: guide.email, document: guide.document, city: guide.city, status: status,
          phone: guide.phone, submitted: guide.submitted, docFileName: guide.docFileName, uploadedTrips: guide.uploadedTrips,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pendingGuidesCount = _guides.where((g) => g.status == 'pending').length;
    // Trip applications hardcoded to 3 for now, since this view only edits guides
    final pendingTripsCount = 3;
    final totalPending = pendingGuidesCount + pendingTripsCount;

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
                      child: const _StatCard(
                        index: 1,
                        value: '12,480',
                        label: 'Total Users',
                        badge: '+4.2%',
                        badgeDanger: false,
                      ),
                    ),
                    SizedBox(
                      width: w,
                      child: const _StatCard(
                        index: 2,
                        value: '326',
                        label: 'Tour Guides',
                        badge: '+1.8%',
                        badgeDanger: false,
                      ),
                    ),
                    SizedBox(
                      width: w,
                      child: const _StatCard(
                        index: 3,
                        value: '1,204',
                        label: 'Total Trips',
                        badge: '+3.1%',
                        badgeDanger: false,
                      ),
                    ),
                    SizedBox(
                      width: w,
                      child: const _StatCard(
                        index: 4,
                        value: '8,930',
                        label: 'Total Bookings',
                        badge: '+6.5%',
                        badgeDanger: false,
                      ),
                    ),
                    SizedBox(
                      width: w,
                      child: const _StatCard(
                        index: 5,
                        value: 'EGP 2,838',
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
                      _PendingActionsCard(guidesCount: pendingGuidesCount, tripsCount: pendingTripsCount),
                      const SizedBox(height: 16),
                      _GuideApplicationsCard(
                        guides: _guides,
                        onUpdateStatus: _updateGuideStatus,
                      ),
                    ],
                  );
                }
                final leftW = (constraints.maxWidth - 16) * 0.4;
                final rightW = (constraints.maxWidth - 16) * 0.6;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: leftW, child: _PendingActionsCard(guidesCount: pendingGuidesCount, tripsCount: pendingTripsCount)),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: rightW,
                      child: _GuideApplicationsCard(
                        guides: _guides,
                        onUpdateStatus: _updateGuideStatus,
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
          Text(value,
              style: AppTextStyles.statValue,
              overflow: TextOverflow.ellipsis,
              maxLines: 1),
          const SizedBox(height: 4),
          Text(label,
              style: AppTextStyles.statLabel,
              overflow: TextOverflow.ellipsis,
              maxLines: 1),
        ],
      ),
    );
  }
}

// ── Pending Actions Card ─────────────────────────────────────
class _PendingActionsCard extends StatelessWidget {
  final int guidesCount;
  final int tripsCount;
  
  const _PendingActionsCard({required this.guidesCount, required this.tripsCount});

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
  final List<MockGuide> guides;
  final void Function(MockGuide, String) onUpdateStatus;

  const _GuideApplicationsCard({required this.guides, required this.onUpdateStatus});

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
                  Text('Review documents, guide activity and uploaded content', style: AppTextStyles.sectionSubtitle),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(color: AppColors.statusPendingBg, borderRadius: BorderRadius.circular(20)),
                child: Text('${pendingGuides.length} pending', style: AppTextStyles.tableCellMuted.copyWith(color: AppColors.statusPendingText, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MiniGuideTableHeader(),
          const Divider(color: AppColors.divider, height: 1),
          ...guides.map((g) => _MiniGuideRow(
            guide: g,
            onApprove: () => onUpdateStatus(g, 'approved'),
            onReject: () => onUpdateStatus(g, 'suspended'),
            onSuspend: () => onUpdateStatus(g, 'suspended'),
            onActivate: () => onUpdateStatus(g, 'approved'),
          )),
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
  final MockGuide guide;
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
                    Text(guide.name,
                        style: AppTextStyles.tableCell,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1),
                    Text(guide.email,
                        style: AppTextStyles.tableCellMuted,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(guide.document,
                          style: AppTextStyles.tableCellMuted,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1),
                    ),
                    const SizedBox(width: 6),
                    Text('View file', style: AppTextStyles.linkText),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(guide.city,
                    style: AppTextStyles.tableCellMuted,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1),
              ),
              Expanded(
                flex: 2,
                child: _buildStatusChip(guide.status),
              ),
              Expanded(
                flex: 3,
                child: _buildActions(guide, context),
              ),
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

  Widget _buildActions(MockGuide guide, BuildContext context) {
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
