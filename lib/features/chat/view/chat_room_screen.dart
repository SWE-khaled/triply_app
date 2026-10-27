import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:triply/core/data/models/chat_message.dart';
import 'package:triply/core/data/repositories/chat_repository.dart';
import 'package:triply/core/data/repositories/firestore_chat_repository.dart';
import 'package:triply/core/theme/app_colors.dart';
import 'package:triply/core/widgets/app_snackbar.dart';
import 'package:triply/core/widgets/circle_back_button.dart';

import '../cubit/chat_room_cubit.dart';
import '../cubit/chat_room_state.dart';
import '../model/chat_audience.dart';
import '../util/chat_time.dart';
import '../widgets/chat_avatar.dart';

/// One conversation with live messages, typing, seen marks and message
/// actions.
///
/// Opening an existing chat subscribes to it. Opening the screen for a
/// guide with no chat id yet only prepares the composer: the chat and its
/// first message are written together when the tourist sends.
class ChatRoomScreen extends StatefulWidget {
  final ChatRepository? repository;
  final String? chatId;
  final String? guideId;
  final String guideName;
  final String guideAvatar;
  final String fallbackName;
  final String fallbackAvatar;
  final ChatAudience audience;

  const ChatRoomScreen({
    super.key,
    this.repository,
    this.chatId,
    this.guideId,
    this.guideName = '',
    this.guideAvatar = '',
    this.fallbackName = '',
    this.fallbackAvatar = '',
    this.audience = ChatAudience.tourist,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  late final ChatRepository _repository;
  late final ChatRoomCubit _cubit;
  late final TextEditingController _composer;
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? FirestoreChatRepository();
    _cubit = ChatRoomCubit(
      repository: _repository,
      chatId: widget.chatId,
      guideId: widget.guideId,
      guideName: widget.guideName,
      guideAvatar: widget.guideAvatar,
    );
    _composer = TextEditingController();
    _scroll = ScrollController()..addListener(_onScroll);
    unawaited(_load());
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    _composer.dispose();
    _cubit.close();
    super.dispose();
  }

  Future<void> _load() async {
    await _cubit.load();
    if (!mounted) return;
    // Opening a room clears its badge even when the newest message is the
    // caller's own (the cubit also marks inbound snapshots read).
    await _cubit.markRead();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 240) {
      unawaited(_cubit.loadMore());
    }
  }

  String _otherName(ChatRoomSuccess? state) {
    final chat = state?.chat;
    final me = _cubit.myUserId;
    if (chat != null && me != null) {
      final name = chat.profileOf(chat.otherUserId(me)).displayName.trim();
      if (name.isNotEmpty) return name;
    }
    if (widget.fallbackName.trim().isNotEmpty) {
      return widget.fallbackName.trim();
    }
    if (widget.guideName.trim().isNotEmpty) return widget.guideName.trim();
    return widget.audience.otherFallbackName;
  }

  String _otherAvatar(ChatRoomSuccess? state) {
    final chat = state?.chat;
    final me = _cubit.myUserId;
    if (chat != null && me != null) {
      final avatar = chat.profileOf(chat.otherUserId(me)).avatarUrl.trim();
      if (avatar.isNotEmpty) return avatar;
    }
    if (widget.fallbackAvatar.trim().isNotEmpty) {
      return widget.fallbackAvatar.trim();
    }
    return widget.guideAvatar.trim();
  }

  Future<void> _send() async {
    final state = _cubit.state;
    if (state is! ChatRoomSuccess || state.isReadOnly || state.isSending) {
      return;
    }
    final text = _composer.text.trim();
    if (text.isEmpty) return;
    _composer.clear();
    await _cubit.sendMessage(text);
  }

  Future<void> _openMessageActions(ChatMessage message) async {
    final state = _cubit.state;
    if (state is! ChatRoomSuccess || state.isReadOnly) return;

    final me = _cubit.myUserId;
    final mine = me != null && message.senderId == me;
    final canModify = mine && message.canModify(me);

    if (!mine) {
      final reason = await _askReport(message);
      if (reason == null || !mounted) return;
      await _cubit.reportMessage(
        message: message,
        reasonCode: reason.reasonCode,
        note: reason.note,
      );
      if (!mounted) return;
      final after = _cubit.state;
      if (after is ChatRoomSuccess && after.actionError == null) {
        showAppSnackBar(context, 'Report sent');
      }
      return;
    }

    if (!canModify) {
      showAppSnackBar(
        context,
        'Messages can only be edited within 24 hours.',
        icon: Icons.info_outline,
      );
      return;
    }

    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              key: const Key('chat-action-edit'),
              leading: const Icon(
                Icons.edit_outlined,
                color: AppColors.primary,
              ),
              title: const Text('Edit message'),
              onTap: () => Navigator.of(sheetContext).pop('edit'),
            ),
            ListTile(
              key: const Key('chat-action-delete'),
              leading: const Icon(
                Icons.delete_outline,
                color: AppColors.accentOrange,
              ),
              title: const Text(
                'Delete message',
                style: TextStyle(color: AppColors.accentOrange),
              ),
              onTap: () => Navigator.of(sheetContext).pop('delete'),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (action == 'edit') {
      await _editMessage(message);
    } else if (action == 'delete') {
      await _deleteMessage(message);
    }
  }

  Future<void> _editMessage(ChatMessage message) async {
    // The dialog owns (and disposes) its own controller, so it is never
    // disposed while the closing animation still uses it.
    final result = await showDialog<String>(
      context: context,
      builder: (_) => _EditMessageDialog(initialText: message.text),
    );
    if (!mounted || result == null) return;
    if (result.trim().isEmpty) {
      showAppSnackBar(
        context,
        'Write a message first.',
        icon: Icons.info_outline,
      );
      return;
    }
    await _cubit.editMessage(messageId: message.id, text: result);
    if (!mounted) return;
    final after = _cubit.state;
    if (after is ChatRoomSuccess && after.actionError == null) {
      showAppSnackBar(context, 'Message updated');
    }
  }

  Future<void> _deleteMessage(ChatMessage message) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete message?'),
        content: const Text('This message will be removed for both of you.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            key: const Key('chat-delete-confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.accentOrange),
            ),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    await _cubit.deleteMessage(message.id);
    if (!mounted) return;
    final after = _cubit.state;
    if (after is ChatRoomSuccess && after.actionError == null) {
      showAppSnackBar(context, 'Message deleted');
    }
  }

  Future<({String reasonCode, String note})?> _askReport(ChatMessage message) {
    return showDialog<({String reasonCode, String note})>(
      context: context,
      builder: (_) => const _ReportDialog(reasons: _reportReasons),
    );
  }

  static const Map<String, String> _reportReasons = <String, String>{
    'spam': 'Spam',
    'harassment': 'Harassment',
    'inappropriate_content': 'Inappropriate content',
    'other': 'Other',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: BlocBuilder<ChatRoomCubit, ChatRoomState>(
          bloc: _cubit,
          builder: (context, state) {
            final success = state is ChatRoomSuccess ? state : null;
            final readOnly =
                success?.isReadOnly ??
                (state is ChatRoomError && state.isReadOnly);
            return Column(
              children: [
                _header(success),
                if (readOnly) _readOnlyBanner(),
                Expanded(child: _body(state)),
                if (success != null) ...[
                  if (success.actionError != null)
                    _actionError(success.actionError!),
                  if (!success.isReadOnly) _composerBar(success),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _header(ChatRoomSuccess? state) {
    final name = _otherName(state);
    final typing = state != null && _cubit.isOtherTyping;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        children: [
          CircleBackButton(onTap: () => Navigator.maybePop(context)),
          const SizedBox(width: 10),
          ChatAvatar(name: name, avatarUrl: _otherAvatar(state), size: 44),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.title,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  typing ? 'typing...' : widget.audience.otherRoleLabel,
                  key: typing ? const Key('chat-header-typing') : null,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: typing ? FontWeight.w600 : FontWeight.w400,
                    color: typing ? AppColors.primaryTeal : AppColors.subtitle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _readOnlyBanner() {
    return Container(
      key: const Key('chat-read-only-banner'),
      width: double.infinity,
      color: const Color(0xFFFAF5EC),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: const Row(
        children: [
          Icon(Icons.lock_outline, size: 17, color: AppColors.primary),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'This conversation is read-only because this account is inactive.',
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(ChatRoomState state) {
    return switch (state) {
      ChatRoomInitial() || ChatRoomLoading() => const Center(
        child: CircularProgressIndicator(
          color: AppColors.priceTeal,
          strokeWidth: 2.5,
        ),
      ),
      ChatRoomError(:final error) => _error(error),
      ChatRoomSuccess() => _room(state),
    };
  }

  Widget _error(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 42,
              color: AppColors.subtitle,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.subtitle,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _load,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.tabSelectedBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _room(ChatRoomSuccess state) {
    if (state.messages.isEmpty) {
      return Column(
        children: [
          Expanded(
            child: Center(
              key: const Key('chat-empty-room'),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 82,
                      height: 82,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.waving_hand_outlined,
                        size: 34,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Start the conversation with ${_otherName(state)}.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors.subtitle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_cubit.isOtherTyping) _typingRow(),
        ],
      );
    }

    final entries = _entries(state.messages);
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            reverse: true,
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final message = entry.message;
              if (message == null) {
                return _daySeparator(entry.day!);
              }
              return _messageBubble(state, message);
            },
          ),
        ),
        if (_cubit.isOtherTyping) _typingRow(),
        if (state.isLoadingMore)
          const Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryTeal,
              ),
            ),
          ),
      ],
    );
  }

  List<_RoomEntry> _entries(List<ChatMessage> messages) {
    // The repository streams newest-first; the visible list is
    // chronological with a day separator before each new day.
    final chronological = messages.reversed.toList(growable: false);
    final entries = <_RoomEntry>[];
    DateTime? lastDay;
    for (final message in chronological) {
      final at = message.createdAt;
      if (at != null) {
        final local = at.toLocal();
        final day = DateTime(local.year, local.month, local.day);
        if (lastDay == null || day != lastDay) {
          entries.add(_RoomEntry.day(at));
          lastDay = day;
        }
      }
      entries.add(_RoomEntry.message(message));
    }
    return entries.reversed.toList(growable: false);
  }

  Widget _daySeparator(DateTime at) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Text(
          chatDayLabel(at),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.subtitle,
          ),
        ),
      ),
    );
  }

  Widget _messageBubble(ChatRoomSuccess state, ChatMessage message) {
    final me = _cubit.myUserId;
    final mine = me != null && message.senderId == me;
    final seen = mine && _cubit.isReadByOther(message);
    final createdAt = message.createdAt;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        key: ValueKey<String>('chat-message-${message.id}'),
        onLongPress: () => _openMessageActions(message),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.fromLTRB(13, 9, 13, 7),
          decoration: BoxDecoration(
            color: mine ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(mine ? 18 : 4),
              bottomRight: Radius.circular(mine ? 4 : 18),
            ),
            border: mine ? null : Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.text,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: mine ? Colors.white : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (createdAt != null) ...[
                    Text(
                      chatClockLabel(createdAt),
                      style: TextStyle(
                        fontSize: 10,
                        color: mine ? Colors.white70 : AppColors.guideLabel,
                      ),
                    ),
                    const SizedBox(width: 5),
                  ],
                  if (message.isEdited) ...[
                    Text(
                      'edited',
                      style: TextStyle(
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                        color: mine ? Colors.white70 : AppColors.guideLabel,
                      ),
                    ),
                    const SizedBox(width: 5),
                  ],
                  if (mine) ...[
                    Icon(
                      seen ? Icons.done_all : Icons.done,
                      size: 13,
                      color: seen ? Colors.white : Colors.white70,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      seen ? 'Seen' : 'Sent',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: seen ? FontWeight.w600 : FontWeight.w400,
                        color: seen ? Colors.white : Colors.white70,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typingRow() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        key: const Key('chat-typing-indicator'),
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TypingDot(opacity: 1),
            SizedBox(width: 4),
            _TypingDot(opacity: 0.6),
            SizedBox(width: 4),
            _TypingDot(opacity: 0.3),
          ],
        ),
      ),
    );
  }

  Widget _actionError(String error) {
    return Container(
      key: const Key('chat-action-error'),
      width: double.infinity,
      color: const Color(0xFFFDECEC),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      child: Text(
        error,
        style: const TextStyle(fontSize: 12, color: AppColors.accentOrange),
      ),
    );
  }

  Widget _composerBar(ChatRoomSuccess state) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              key: const Key('chat-message-input'),
              controller: _composer,
              minLines: 1,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              onChanged: (_) => unawaited(_cubit.notifyTyping()),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.hint),
                filled: true,
                fillColor: AppColors.searchBg,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _composer,
            builder: (context, value, _) {
              final canSend =
                  value.text.trim().isNotEmpty &&
                  !state.isSending &&
                  !state.isReadOnly;
              return FilledButton(
                key: const Key('chat-send-button'),
                onPressed: canSend ? _send : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.cardBorder,
                  minimumSize: const Size(46, 46),
                  padding: EdgeInsets.zero,
                  shape: const CircleBorder(),
                ),
                child: state.isSending
                    ? const SizedBox(
                        width: 17,
                        height: 17,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        Icons.send_rounded,
                        size: 20,
                        color: canSend ? Colors.white : AppColors.subtitle,
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RoomEntry {
  final ChatMessage? message;
  final DateTime? day;

  const _RoomEntry.message(ChatMessage this.message) : day = null;
  const _RoomEntry.day(DateTime this.day) : message = null;
}

class _TypingDot extends StatelessWidget {
  final double opacity;

  const _TypingDot({required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: AppColors.guideLabel.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Edit dialog that owns its [TextEditingController], so the controller is
/// disposed only after the dialog has left the widget tree.
class _EditMessageDialog extends StatefulWidget {
  final String initialText;

  const _EditMessageDialog({required this.initialText});

  @override
  State<_EditMessageDialog> createState() => _EditMessageDialogState();
}

class _EditMessageDialogState extends State<_EditMessageDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit message'),
      content: TextField(
        key: const Key('chat-edit-input'),
        controller: _controller,
        autofocus: true,
        minLines: 1,
        maxLines: 4,
        maxLength: ChatText.maxMessageLength,
        decoration: const InputDecoration(
          hintText: 'Message',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          key: const Key('chat-edit-save'),
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

/// Report dialog that owns its note controller (same reason as above).
class _ReportDialog extends StatefulWidget {
  final Map<String, String> reasons;

  const _ReportDialog({required this.reasons});

  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  final TextEditingController _note = TextEditingController();
  String? _reasonCode;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Report message'),
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Why are you reporting this message?',
                style: TextStyle(fontSize: 13, color: AppColors.subtitle),
              ),
              const SizedBox(height: 8),
              RadioGroup<String>(
                groupValue: _reasonCode,
                onChanged: (value) => setState(() => _reasonCode = value),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final entry in widget.reasons.entries)
                      RadioListTile<String>(
                        value: entry.key,
                        title: Text(
                          entry.value,
                          style: const TextStyle(fontSize: 14),
                        ),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.primary,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                key: const Key('chat-report-note'),
                controller: _note,
                maxLines: 3,
                maxLength: ChatText.maxReportNoteLength,
                decoration: const InputDecoration(
                  hintText: 'Add a note (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          key: const Key('chat-report-submit'),
          onPressed: _reasonCode == null
              ? null
              : () => Navigator.of(
                  context,
                ).pop((reasonCode: _reasonCode!, note: _note.text)),
          child: const Text('Submit'),
        ),
      ],
    );
  }
}