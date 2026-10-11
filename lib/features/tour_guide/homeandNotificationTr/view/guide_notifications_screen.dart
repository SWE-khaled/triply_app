import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/theme/app_colors.dart';
import 'package:triply/core/widgets/circle_back_button.dart';
import 'package:triply/features/tour_guide/homeandNotificationTr/cubit/guide_notifications_cubit.dart';
import 'package:triply/features/tour_guide/homeandNotificationTr/cubit/guide_notifications_state.dart';
import 'package:triply/features/tour_guide/homeandNotificationTr/widget/guide_notification_tile.dart';

/// Cream tint from Figma (back button). Local const only — the global
/// theme in `core/theme/` is left untouched.
const Color _cream = Color(0xFFFAF5EA);

/// Tour-guide notifications list.
class GuideNotificationsScreen extends StatefulWidget {
  const GuideNotificationsScreen({super.key});

  @override
  State<GuideNotificationsScreen> createState() =>
      _GuideNotificationsScreenState();
}

class _GuideNotificationsScreenState extends State<GuideNotificationsScreen> {
  late final GuideNotificationsCubit _cubit;
  String? _uid;
  bool _loadRequested = false;

  @override
  void initState() {
    super.initState();
    // Owned here so the Firebase uid is bound once; provided below for
    // BlocBuilder rebuilds. Server list is primary
    // ([GuideNotificationsCubit.useRemote]); mocks render meanwhile with
    // an explicit notice on failure.
    _cubit = GuideNotificationsCubit();
    _uid = FirebaseAuth.instance.currentUser?.uid;
    if (GuideNotificationsCubit.useRemote) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  /// Best-effort server refresh, guarded so rebuilds never duplicate it.
  Future<void> _refresh() async {
    if (!mounted || _loadRequested) return;
    _loadRequested = true;
    try {
      final ok = await _cubit.loadRemote(_uid ?? '');
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Couldn't refresh notifications — showing saved ones.",
            ),
          ),
        );
      }
    } finally {
      _loadRequested = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: const _GuideNotificationsView(),
    );
  }
}

class _GuideNotificationsView extends StatelessWidget {
  const _GuideNotificationsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  CircleBackButton(
                    backgroundColor: _cream,
                    iconColor: AppColors.title,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.title,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              BlocBuilder<GuideNotificationsCubit, GuideNotificationsState>(
                builder: (context, state) {
                  final cubit = context.read<GuideNotificationsCubit>();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => cubit.markAllReadRemote(
                            FirebaseAuth.instance.currentUser?.uid ?? '',
                          ),
                          child: const Text(
                            'Mark all read',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryTeal,
                            ),
                          ),
                        ),
                      ),
                      for (final n in state.items)
                        GuideNotificationTile(
                          item: n,
                          // TODO(Figma): no detail destination in Figma.
                          onTap: () => cubit.markOneReadRemote(n.id),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
