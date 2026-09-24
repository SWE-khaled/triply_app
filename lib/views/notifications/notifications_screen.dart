import 'package:flutter/material.dart';
import '../../controllers/notifications_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/circle_back_button.dart';
import '../../core/widgets/notification_tile.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final NotificationsController controller;

  @override
  void initState() {
    super.initState();
    controller = NotificationsController();
    controller.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    controller.removeListener(_refresh);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
  }
}
