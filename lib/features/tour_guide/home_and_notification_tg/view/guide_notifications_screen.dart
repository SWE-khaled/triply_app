import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:triply/core/routing/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/circle_back_button.dart';
import '../../../../../core/widgets/state_views.dart';
import '../widget/guide_notifications_skeleton.dart';
import '../cubit/guide_notifications_cubit.dart';
import '../model/guide_notification.dart';
import '../widget/guide_notification_tile.dart';
import 'booking_details_screen.dart';

/// Cream tint from Figma (back button). Local const only — the global
/// theme in `core/theme/` is left untouched.
Color get _cream => AppColors.surfaceElevated;

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
    unawaited(cubit.markAsRead(item.id));
    final relatedId = item.relatedEntityId;
    if (relatedId == null || relatedId.isEmpty) return;
    if (item.relatedCollection == 'bookings') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BookingDetailsScreen(bookingId: relatedId),
        ),
      );
      return;
    }
    if (item.relatedCollection != 'trips') return;
    final trip = await cubit.fetchTrip(relatedId);
    if (trip == null || !context.mounted) return;
    Navigator.of(context).push(AppRoutes.guideTripDetails(trip));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceDefault,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                   CircleBackButton(
                    backgroundColor: _cream,
                    iconColor: AppColors.title,
                  ),
                  const SizedBox(width: 12),
                   Expanded(
                    child: Text(
                      'Notifications',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.title,
                      ),
                    ),
                  ),
                  BlocBuilder<GuideNotificationsCubit, GuideNotificationsState>(
                    builder: (context, _) {
                      // Read the cubit's current rows, like the tourist page:
                      // a source-error rebuild must not hide the unread count.
                      final unread = context
                          .read<GuideNotificationsCubit>()
                          .items
                          .where((n) => n.isUnread)
                          .length;
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
            // skeleton fills the same area the list will occupy.
            Expanded(
              child:
                  BlocBuilder<GuideNotificationsCubit, GuideNotificationsState>(
                    builder: (context, state) {
                      // The rows come from the cubit, not the state snapshot:
                      // a warning/error rebuild must keep showing the live
                      // list (same pattern as the tourist page).
                      final items = context
                          .read<GuideNotificationsCubit>()
                          .items;
                      return switch (state) {
                        GuideNotificationsSuccess(:final warning) => Column(
                          children: [
                            if (warning != null)
                              _SourceWarning(message: warning),
                            Expanded(
                              child: items.isEmpty
                                  ? const _EmptyNotifications()
                                  : ListView.separated(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        0,
                                        16,
                                        24,
                                      ),
                                      itemCount: items.length,
                                      separatorBuilder: (_, _) =>  Divider(
                                        height: 1,
                                        color: AppColors.cardBorder,
                                      ),
                                      itemBuilder: (context, index) {
                                        final item = items[index];
                                        return GuideNotificationTile(
                                          item: item,
                                          onTap: () =>
                                              _openRelated(context, item),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                        GuideNotificationsInitial() ||
                        GuideNotificationsLoading() =>
                          const GuideNotificationsSkeleton(),
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

/// A short, non-blocking note: some sources failed, but the rest of the
/// list is still usable. The exact Firestore error stays in debug logs.
class _SourceWarning extends StatelessWidget {
  const _SourceWarning({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surfaceDefault,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
           Icon(Icons.info_outline, size: 16, color: AppColors.statusError),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style:  TextStyle(fontSize: 11, color: AppColors.statusError),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return  Center(
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
