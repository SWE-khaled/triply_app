import 'package:flutter/material.dart';

import 'package:triply/core/constants/app_routes.dart';
import 'package:triply/core/theme/app_colors.dart';

import '../data/chat_roles.dart';

/// Opens the chat with a guide without creating it until the first
/// message is sent.
///
/// Only a tourist sees it. [isTourist] is injectable for widget tests and
/// previews; when it is null the role is read from `users/{uid}`.
class MessageGuideButton extends StatelessWidget {
  static const Key buttonKey = Key('chat-message-guide-button');

  final String guideId;
  final String guideName;
  final String guideAvatar;

  /// A full-width outlined button instead of the round profile-bar icon.
  final bool expanded;

  /// Test/preview override. Null reads the signed-in account's role.
  final bool? isTourist;

  const MessageGuideButton({
    super.key,
    required this.guideId,
    required this.guideName,
    this.guideAvatar = '',
    this.expanded = false,
    this.isTourist,
  });

  @override
  Widget build(BuildContext context) {
    if (guideId.trim().isEmpty) return const SizedBox.shrink();
    if (isTourist == false) return const SizedBox.shrink();
    if (isTourist == true) return _button(context);

    return FutureBuilder<String?>(
      future: ChatRoles.currentUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }
        if (!ChatRoles.canStartChat(snapshot.data)) {
          return const SizedBox.shrink();
        }
        return _button(context);
      },
    );
  }

  Widget _button(BuildContext context) {
    void open() {
      Navigator.of(context).push(
        AppRoutes.chatWithGuide(
          guideId: guideId,
          guideName: guideName,
          guideAvatar: guideAvatar,
        ),
      );
    }

    if (expanded) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          key: buttonKey,
          onPressed: open,
          icon: const Icon(Icons.chat_bubble_outline, size: 19),
          label: const Text(
            'Message',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: const Size(0, 52),
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Semantics(
        button: true,
        label: 'Message',
        child: InkWell(
          key: buttonKey,
          onTap: open,
          customBorder: const CircleBorder(),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFFAF5EC),
              border: Border.all(color: AppColors.guideLabel),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
