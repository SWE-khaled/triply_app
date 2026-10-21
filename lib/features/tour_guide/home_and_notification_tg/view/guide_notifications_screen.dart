import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/circle_back_button.dart';
import '../../../../../core/widgets/state_views.dart';
import '../cubit/guide_notifications_cubit.dart';
import '../model/guide_notification.dart';
import '../widget/guide_notification_tile.dart';

/// Cream tint from Figma (back button). Local const only — the global
/// theme in `core/theme/` is left untouched.
const Color _cream = Color(0xFFFAF5EA);

/// Tour-guide notifications list.
class GuideNotificationsScreen extends StatelessWidget {
  const GuideNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GuideNotificationsCubit(),
      child: const _GuideNotificationsView(),
    );
  }
}

class _GuideNotificationsView extends StatelessWidget {
  const _GuideNotificationsView();

  /// Opens the trip or the booking the notification is about, and marks
  /// the notification as read.
  Future<void> _openRelated(
    BuildContext context,
    GuideNotification item,
  ) async {
    final cubit = context.read<GuideNotificationsCubit>();
    cubit.markAsRead(item.id);
    final relatedId = item.relatedEntityId;
    if (relatedId == null || relatedId.isEmpty) return;
    if (item.relatedCollection != 'trips') return;
    final trip = await cubit.fetchTrip(relatedId);
    if (trip == null || !context.mounted) return;
    Navigator.of(context).push(AppRoutes.guideTripDetails(trip));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  const CircleBackButton(
                    backgroundColor: _cream,
                    iconColor: AppColors.title,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.title,
                      ),
                    ),
                  ),
                  BlocBuilder<GuideNotificationsCubit, GuideNotificationsState>(
                    builder: (context, state) {
                      final unread = state is GuideNotificationsSuccess
                          ? state.items.where((n) => n.isUnread).length
                          : 0;
                      if (unread == 0) return const SizedBox.shrink();
                      return TextButton(
                        onPressed: () => context
                            .read<GuideNotificationsCubit>()
                            .markAllAsRead(),
                        child: const Text(
                          'Mark all as read',
                          style: TextStyle(fontSize: 12),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // The builder sits outside the scroll view, so the loading
            // spinner is centered in the screen.
            Expanded(
              child:
                  BlocBuilder<GuideNotificationsCubit, GuideNotificationsState>(
                    builder: (context, state) {
                      return switch (state) {
                        GuideNotificationsSuccess(:final items) =>
                          items.isEmpty
                              ? const _EmptyNotifications()
                              : ListView.separated(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    24,
                                  ),
                                  itemCount: items.length,
                                  separatorBuilder: (_, _) => const Divider(
                                    height: 1,
                                    color: AppColors.cardBorder,
                                  ),
                                  itemBuilder: (context, index) {
                                    final item = items[index];
                                    return GuideNotificationTile(
                                      item: item,
                                      onTap: () => _openRelated(context, item),
                                    );
                                  },
                                ),
                        GuideNotificationsInitial() ||
                        GuideNotificationsLoading() => const AppLoadingView(),
                        GuideNotificationsError(:final error) => AppErrorView(
                          message: error,
                          onRetry: () =>
                              context.read<GuideNotificationsCubit>().load(),
                        ),
                      };
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none, size: 44, color: AppColors.subtitle),
          SizedBox(height: 12),
          Text(
            'No notifications yet.',
            style: TextStyle(fontSize: 13, color: AppColors.subtitle),
          ),
        ],
      ),
    );
  }
}
