import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/circle_back_button.dart';
import '../cubit/guide_notifications_cubit.dart';
import '../cubit/guide_notifications_state.dart';
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
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final n in state.items)
                        GuideNotificationTile(
                          item: n,
                          // TODO(Figma): no detail destination in Figma.
                          onTap: () {},
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
