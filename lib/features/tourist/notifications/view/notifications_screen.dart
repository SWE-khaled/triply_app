import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/notifications_cubit.dart';
import '../cubit/notifications_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/circle_back_button.dart';
import '../widget/notification_tile.dart';

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

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: controller,
      child: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, _) {
    final unread = controller.unreadCount;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleBackButton(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Notifications',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        Text(
                          unread > 0 ? '$unread new' : 'All caught up',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textGrey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Today',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryTeal)),
                  GestureDetector(
                    onTap: controller.markAllRead,
                    child: const Text('Mark all read',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryTeal)),
                  ),
                ],
              ),
              for (final n in controller.today)
                NotificationTile(
                  item: n,
                  // TODO(Figma): no detail destination in Figma.
                  onTap: () => controller.markOneRead(n.id),
                ),
              const SizedBox(height: 8),
              const Text('Earlier',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryTeal)),
              for (final n in controller.earlier)
                NotificationTile(
                  item: n,
                  // TODO(Figma): no detail destination in Figma.
                  onTap: () {},
                ),
            ],
          ),
        ),
      ),
    );
        },
      ),
    );
  }
}
