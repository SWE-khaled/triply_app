import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/notification_toruist/notification_target.dart';

import '../cubit/notifications_cubit.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/app_theme_dark.dart';
import '../../../../core/widgets/circle_back_button.dart';
import '../../../../core/widgets/state_views.dart';
import '../model/notification_item.dart';
import '../widget/notification_tile.dart';

Color _notificationColor(BuildContext context, Color light, Color dark) =>
    AppThemeColors.resolve(context, light: light, dark: dark);

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final NotificationsCubit controller;

  @override
  void initState() {
    super.initState();
    // Owned here (like the old controller) so the body below keeps working
    // unchanged; provided below for BlocBuilder rebuilds.
    controller = NotificationsCubit();
  }

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }

  /// Marks the tapped row only, then opens its target when it has one.
  void _open(NotificationItem item) {
    unawaited(controller.markOneRead(item.id));
    final type = switch (item.routeType) {
      'post' => NotificationTargetType.post,
      'trip' => NotificationTargetType.trip,
      'chat' => NotificationTargetType.chat,
      _ => null,
    };
    final targetId = item.targetId.isNotEmpty ? item.targetId : item.id;
    if (type == null || targetId.isEmpty) return;
    NotificationNavigator.open(NotificationTarget(type: type, id: targetId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: controller,
      child: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          final unread = controller.unreadCount;
          final warning = state is NotificationsSuccess ? state.warning : null;
          return Scaffold(
            backgroundColor: _notificationColor(
              context,
              AppColors.background,
              AppThemeDark.backgroundPrimary,
            ),
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        CircleBackButton(
                          backgroundColor: _notificationColor(
                            context,
                            Colors.white,
                            AppThemeDark.surfaceElevated,
                          ),
                          iconColor: _notificationColor(
                            context,
                            Colors.black,
                            AppThemeDark.iconPrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notifications',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: _notificationColor(
                                    context,
                                    Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.color ??
                                        Colors.black87,
                                    AppThemeDark.homeSectionTitle,
                                  ),
                                ),
                              ),
                              Text(
                                unread > 0 ? '$unread new' : 'All caught up',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _notificationColor(
                                    context,
                                    AppColors.textGrey,
                                    AppThemeDark.homeGuideSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: switch (state) {
                      NotificationsError(:final error) => AppErrorView(
                        message: error,
                        onRetry: controller.load,
                      ),
                      NotificationsInitial() ||
                      NotificationsLoading() => Center(
                        child: CircularProgressIndicator(
                          color: _notificationColor(
                            context,
                            AppColors.primaryTeal,
                            AppThemeDark.iconPrimary,
                          ),
                        ),
                      ),
                      _ => SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (warning != null)
                              _SourceWarning(message: warning),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Today',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: _notificationColor(
                                      context,
                                      AppColors.primaryTeal,
                                      AppThemeDark.homeSectionTitle,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: controller.markAllRead,
                                  child: Text(
                                    'Mark all read',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _notificationColor(
                                        context,
                                        AppColors.primaryTeal,
                                        AppThemeDark.homeSeeAll,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            for (final n in controller.today)
                              NotificationTile(item: n, onTap: () => _open(n)),
                            const SizedBox(height: 8),
                            Text(
                              'Earlier',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: _notificationColor(
                                  context,
                                  AppColors.primaryTeal,
                                  AppThemeDark.homeSectionTitle,
                                ),
                              ),
                            ),
                            for (final n in controller.earlier)
                              NotificationTile(item: n, onTap: () => _open(n)),
                          ],
                        ),
                      ),
                    },
                  ),
                ],
              ),
            ),
          );
        },
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: _notificationColor(
          context,
          const Color(0xFFFDECEC),
          AppThemeDark.surfaceDefault,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: _notificationColor(
              context,
              Colors.redAccent,
              AppThemeDark.statusError,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 11,
                color: _notificationColor(
                  context,
                  Colors.redAccent,
                  AppThemeDark.statusError,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
