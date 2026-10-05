import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/circle_back_button.dart';
import '../controller/guide_notifications_controller.dart';
import '../widget/guide_notification_tile.dart';

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

class _GuideNotificationsScreenState
    extends State<GuideNotificationsScreen> {
  late final GuideNotificationsController controller;

  @override
  void initState() {
    super.initState();
    controller = GuideNotificationsController();
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
              for (final n in controller.items)
                GuideNotificationTile(
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
