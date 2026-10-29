import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../core/data/repositories/admin_guides_repository.dart';
import '../../../../core/theme/d_app_colors.dart';
import '../../../../core/theme/d_app_text_styles.dart';
import '../../d_home/view/d_home_view.dart';

/// Overview / Dashboard page (all stats and lists stream live from Firestore).
class OverviewView extends StatefulWidget {
  const OverviewView({super.key});

  @override
  State<OverviewView> createState() => _OverviewViewState();
}

class _OverviewViewState extends State<OverviewView> {
  List<AdminGuide> _guides = const [];
  final AdminGuidesRepository _guidesRepo = AdminGuidesRepository();

  StreamSubscription? _usersSub;
  StreamSubscription? _guidesSub;
  StreamSubscription? _tripsSub;
  StreamSubscription? _bookingsSub;
  StreamSubscription<List<AdminGuide>>? _guidesListSub;

  int _totalUsersCount = 0;
  int _tourGuidesCount = 0;
  int _totalTripsCount = 0;
  int _totalBookingsCount = 0;
  double _totalEarnings = 0;
  int _pendingTripsCount = 0;

  int get _pendingGuidesCount =>
      _guides.where((g) => g.status == 'pending').length;

  int get _totalPending => _pendingGuidesCount + _pendingTripsCount;

  @override
  void initState() {
    super.initState();
    _initKpiStreams();
  }

  void _initKpiStreams() {
    try {
      // 1. Total Users (real-time from Firestore)
      _usersSub = FirebaseFirestore.instance
          .collection('users')
          .snapshots()
          .listen((snap) {
        if (!mounted) return;
        setState(() {
          _totalUsersCount = snap.docs.length;
        });
      }, onError: (_) {});

      // 2. Tour Guides (users with role 'guide')
      _guidesSub = FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'guide')
          .snapshots()
          .listen((snap) {
        if (!mounted) return;
        setState(() {
          _tourGuidesCount = snap.docs.length;
        });
      }, onError: (_) {});

      // 3. Total Trips and Pending Trips
      _tripsSub = FirebaseFirestore.instance
          .collection('trips')
          .snapshots()
          .listen((snap) {
        if (!mounted) return;
        int pending = 0;
        for (final doc in snap.docs) {
          final data = doc.data();
          final status = (data['approvalStatus'] as String?) ??
              (data['status'] as String?) ??
              'pending';
          if (status == 'pending' || status == 'pending_review') pending++;
        }
        setState(() {
          _totalTripsCount = snap.docs.length;
          _pendingTripsCount = pending;
        });
      }, onError: (_) {});

      // 4. Total Bookings and Earnings from database
      _bookingsSub = FirebaseFirestore.instance
          .collection('bookings')
          .snapshots()
          .listen((snap) {
        if (!mounted) return;
        double earnings = 0;
        for (final doc in snap.docs) {
          final data = doc.data();
          final price = (data['totalPrice'] as num?) ??
              (data['price'] as num?) ??
              (data['amount'] as num?) ??
              0;
          earnings += (price * 0.1); // 10% commission
        }
        setState(() {
          _totalBookingsCount = snap.docs.length;
          _totalEarnings = earnings;
        });
      }, onError: (_) {});

      // 5. Watch Guides from Firestore
      _guidesListSub = _guidesRepo.watchGuides().listen((guides) {
        if (!mounted) return;
        setState(() {
          _guides = guides;
        });
      }, onError: (_) {});
    } catch (_) {}
  }

  @override
  void dispose() {
    _usersSub?.cancel();
    _guidesSub?.cancel();
    _tripsSub?.cancel();
    _bookingsSub?.cancel();
    _guidesListSub?.cancel();
    super.dispose();
  }

  String _formatNumber(int n) {
    if (n <= 0) return '0';
    final s = n.toString();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return s.replaceAllMapped(reg, (Match m) => '${m[1]},');
  }

  String get _earningsLabel {
    if (_totalEarnings <= 0) return 'EGP 0';
    final s = _totalEarnings.toStringAsFixed(0);
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return 'EGP ${s.replaceAllMapped(reg, (Match m) => '${m[1]},')}';
  }

  Future<void> _updateGuideStatus(AdminGuide guide, String status) async {
    if (guide.uid.isEmpty) return;

    final previousGuides = _guides;
    setState(() {
      _guides = _guides.map((g) {
        if (g.uid == guide.uid) {
          return AdminGuide(
            uid: g.uid,
            name: g.name,
            email: g.email,
            document: g.document,
            city: g.city,
            status: status,
            phone: g.phone,
            submitted: g.submitted,
            docFileName: g.docFileName,
            uploadedTrips: g.uploadedTrips,
          );
        }
        return g;
      }).toList();
    });

    final ok = await _guidesRepo.decideVerification(
      guideId: guide.uid,
      approve: status == 'approved',
    );

    if (!mounted) return;

    if (!ok) {
      setState(() {
        _guides = previousGuides;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status for ${guide.name}.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AdminCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 6-stat dynamic KPI grid ─────────────────────────────
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
                        value: _formatNumber(_totalUsersCount),
                        label: 'Total Users',
                        badge: _totalUsersCount > 0 ? '+$_totalUsersCount' : '0',
                        badgeDanger: false,
                        badgeIsText: true,
                      ),
                    ),
                    SizedBox(
                      width: w,
                      child: _StatCard(
                        index: 2,
                        value: _formatNumber(_tourGuidesCount),
                        label: 'Tour Guides',
                        badge: _tourGuidesCount > 0 ? '+$_tourGuidesCount' : '0',
                        badgeDanger: false,
                        badgeIsText: true,
                      ),
                    ),
                    SizedBox(
                      width: w,
                      child: _StatCard(
                        index: 3,
                        value: _formatNumber(_totalTripsCount),
                        label: 'Total Trips',
                        badge: _totalTripsCount > 0 ? '+$_totalTripsCount' : '0',
                        badgeDanger: false,
                        badgeIsText: true,
                      ),
                    ),
                    SizedBox(
                      width: w,
                      child: _StatCard(
                        index: 4,
                        value: _formatNumber(_totalBookingsCount),
                        label: 'Total Bookings',
                        badge: _totalBookingsCount > 0 ? '+$_totalBookingsCount' : '0',
                        badgeDanger: false,
                        badgeIsText: true,
                      ),
                    ),
                    SizedBox(
                      width: w,
                      child: _StatCard(
                        index: 5,
                        value: _earningsLabel,
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
                        value: '$_totalPending',
                        label: 'Pending Requests',
                        badge: _totalPending > 0 ? 'Needs review' : 'All clear',
                        badgeDanger: _totalPending > 0,
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
                        guidesCount: _pendingGuidesCount,
                        tripsCount: _pendingTripsCount,
                      ),
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
                    SizedBox(
                      width: leftW,
                      child: _PendingActionsCard(
                        guidesCount: _pendingGuidesCount,
                        tripsCount: _pendingTripsCount,
                      ),
                    ),
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
                              color: badgeDanger ? AppColors.danger : AppColors.positiveGreen,
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
                      guide.name,
                      style: AppTextStyles.tableCell,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      guide.email,
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
                        guide.document.isNotEmpty ? guide.document : 'National ID',
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
                  guide.city.isNotEmpty ? guide.city : 'Egypt',
                  style: AppTextStyles.tableCellMuted,
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
