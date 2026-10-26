import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:triply/core/data/models/chat.dart';
import 'package:triply/core/data/models/chat_message.dart';
import 'package:triply/core/data/repositories/chat_repository.dart';
import 'package:triply/core/utils/safe_emit_mixin.dart';

import 'chat_room_state.dart';

/// One conversation.
///
/// The cubit can be built for an existing [chatId] (the list was opened)
/// or with the guide's data when the tourist starts a new chat. In the
/// second case no document is created until the first message is sent —
/// the repository writes the chat and that first message together.
class ChatRoomCubit extends Cubit<ChatRoomState>
    with SafeEmitMixin<ChatRoomState> {
  static const int pageSize = 30;

  ChatRoomCubit({
    required this.repository,
    String? chatId,
    this.guideId,
    this.guideName,
    this.guideAvatar,
    DateTime Function()? clock,
    Duration typingInterval = const Duration(seconds: 3),
  }) : _chatId = chatId, // ignore: prefer_initializing_formals
       _clock = clock ?? DateTime.now,
       _typingThrottle = ChatTypingThrottle(
         clock: clock,
         interval: typingInterval,
       ),
       super(const ChatRoomState());

  final ChatRepository repository;
  final String? guideId;
  final String? guideName;
  final String? guideAvatar;
  final DateTime Function() _clock;
  final ChatTypingThrottle _typingThrottle;

  String? _chatId;
  StreamSubscription<Chat?>? _chatSubscription;
  StreamSubscription<List<ChatMessage>>? _messageSubscription;
  StreamSubscription<Set<String>>? _typingSubscription;

  String? get chatId => _chatId;

  String? get myUserId => repository.currentUserId;

  String? get otherUserId {
    final chat = state.chat;
    final me = myUserId;
    if (chat == null || me == null) return null;
    return chat.otherUserId(me);
  }

  /// The other participant's `lastReadAt`, when the chat is loaded.
  DateTime? get otherLastReadAt {
    final chat = state.chat;
    final other = otherUserId;
    if (chat == null || other == null) return null;
    return chat.lastReadOf(other);
  }

  bool get isOtherTyping {
    final other = otherUserId;
    return other != null && state.typingUids.contains(other);
  }

  /// True when the other participant's read marker is at or after the
  /// message's creation time.
  bool isReadByOther(ChatMessage message) {
    final me = myUserId;
    final readAt = otherLastReadAt;
    final createdAt = message.createdAt;
    if (me == null || readAt == null || createdAt == null) return false;
    if (message.senderId != me) return false;
    return !createdAt.isAfter(readAt);
  }

  /// Subscribes to an existing chat.
  Future<void> load() async {
    if (_chatId == null) {
      if (guideId == null) {
        safeEmit(
          state.copyWith(
            isLoading: false,
            error: 'This chat is not available.',
          ),
        );
      }
      return;
    }
    safeEmit(state.copyWith(isLoading: true, error: null));
    await _listen();
  }

  Future<void> _listen() async {
    final chatId = _chatId;
    if (chatId == null) return;

    await _cancelSubscriptions();

    final firstChat = Completer<void>();
    final firstMessages = Completer<void>();
    final firstTyping = Completer<void>();
    _chatSubscription = repository
        .watchChat(chatId)
        .listen(
          (chat) {
            if (chat != null) safeEmit(state.copyWith(chat: chat));
            if (!firstChat.isCompleted) firstChat.complete();
          },
          onError: (Object error) {
            _onStreamError(error);
            if (!firstChat.isCompleted) firstChat.complete();
          },
        );
    _messageSubscription = repository
        .watchMessages(chatId, limit: pageSize)
        .listen(
          (messages) {
            safeEmit(
              state.copyWith(
                messages: messages,
                isLoading: false,
                hasMore: messages.length >= pageSize,
                error: null,
              ),
            );
            if (!firstMessages.isCompleted) firstMessages.complete();
          },
          onError: (Object error) {
            _onStreamError(error);
            if (!firstMessages.isCompleted) firstMessages.complete();
          },
        );
    _typingSubscription = repository
        .watchTyping(chatId)
        .listen(
          (uids) {
            safeEmit(state.copyWith(typingUids: uids));
            if (!firstTyping.isCompleted) firstTyping.complete();
          },
          onError: (Object error) {
            _onStreamError(error);
            if (!firstTyping.isCompleted) firstTyping.complete();
          },
        );
    await Future.wait(<Future<void>>[
      firstChat.future,
      firstMessages.future,
      firstTyping.future,
    ]);
  }

  void _onStreamError(Object error) {
    final mapped = ChatErrors.map(error);
    safeEmit(
      state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: mapped.toString(),
        isReadOnly: mapped is ChatPermissionException ? true : state.isReadOnly,
      ),
    );
  }

  /// Sends a message. With no chat yet, this creates the canonical chat
  /// and the message atomically through the repository.
  Future<void> sendMessage(String text) async {
    if (state.isSending || state.isReadOnly) return;
    safeEmit(state.copyWith(isSending: true, actionError: null));
    try {
      final chatId = _chatId;
      if (chatId == null) {
        final targetGuideId = guideId;
        if (targetGuideId == null) {
          throw const ChatValidationException('Choose a guide first.');
        }
        final chat = await repository.openOrCreateChat(
          guideId: targetGuideId,
          guideName: guideName ?? '',
          guideAvatar: guideAvatar ?? '',
          firstMessage: text,
        );
        _chatId = chat.id;
        safeEmit(state.copyWith(chat: chat));
        await _listen();
        safeEmit(state.copyWith(isSending: false));
      } else {
        await repository.sendMessage(chatId: chatId, text: text);
        safeEmit(state.copyWith(isSending: false));
      }
    } catch (error) {
      _fail(error);
    }
  }

  /// Loads the next page of older messages.
  Future<void> loadMore() async {
    final chatId = _chatId;
    if (chatId == null || state.isLoadingMore || !state.hasMore) return;
    final oldest = state.messages.isEmpty
        ? null
        : state.messages.last.createdAt;
    if (oldest == null) return;

    safeEmit(state.copyWith(isLoadingMore: true, actionError: null));
    try {
      final older = await repository.loadMoreMessages(
        chatId: chatId,
        before: oldest,
        limit: pageSize,
      );
      final known = state.messages.map((message) => message.id).toSet();
      final merged = <ChatMessage>[
        ...state.messages,
        ...older.where((message) => !known.contains(message.id)),
      ];
      safeEmit(
        state.copyWith(
          messages: merged,
          isLoadingMore: false,
          hasMore: older.length >= pageSize,
        ),
      );
    } catch (error) {
      _fail(error);
    }
  }

  /// Resets the caller's unread counter on the chat document.
  Future<void> markRead() async {
    final chatId = _chatId;
    if (chatId == null) return;
    try {
      await repository.markRead(chatId);
    } catch (error) {
      _fail(error);
    }
  }

  Future<void> editMessage({
    required String messageId,
    required String text,
  }) async {
    if (state.isEditing) return;
    safeEmit(state.copyWith(isEditing: true, actionError: null));
    try {
      await repository.editMessage(
        chatId: _requireChatId(),
        messageId: messageId,
        text: text,
      );
      safeEmit(state.copyWith(isEditing: false));
    } catch (error) {
      _fail(error);
    }
  }

  Future<void> deleteMessage(String messageId) async {
    if (state.isDeleting) return;
    safeEmit(state.copyWith(isDeleting: true, actionError: null));
    try {
      await repository.deleteMessage(
        chatId: _requireChatId(),
        messageId: messageId,
      );
      safeEmit(state.copyWith(isDeleting: false));
    } catch (error) {
      _fail(error);
    }
  }

  Future<void> reportMessage({
    required ChatMessage message,
    required String reasonCode,
    String note = '',
  }) async {
    if (state.isReporting) return;
    safeEmit(state.copyWith(isReporting: true, actionError: null));
    try {
      await repository.reportMessage(
        chatId: _requireChatId(),
        message: message,
        reasonCode: reasonCode,
        note: note,
      );
      safeEmit(state.copyWith(isReporting: false));
    } catch (error) {
      _fail(error);
    }
  }

  /// Writes the typing marker at most once per three seconds.
  Future<void> notifyTyping() async {
    final chatId = _chatId;
    if (chatId == null) return;
    if (!_typingThrottle.shouldSend(_clock())) return;
    try {
      await repository.setTyping(chatId);
    } catch (_) {
      // Typing is best-effort: a failure must not interrupt the room.
    }
  }

  Future<void> updateMyProfile({String? displayName, String? avatarUrl}) async {
    final chatId = _chatId;
    if (chatId == null) return;
    try {
      await repository.updateMyProfile(
        chatId: chatId,
        displayName: displayName,
        avatarUrl: avatarUrl,
      );
    } catch (error) {
      _fail(error);
    }
  }

  String _requireChatId() {
    final chatId = _chatId;
    if (chatId == null) {
      throw const ChatValidationException('This chat does not exist yet.');
    }
    return chatId;
  }

  void _fail(Object error) {
    final mapped = ChatErrors.map(error);
    safeEmit(
      state.copyWith(
        actionError: mapped.toString(),
        isReadOnly: mapped is ChatPermissionException ? true : state.isReadOnly,
        isSending: false,
        isEditing: false,
        isDeleting: false,
        isReporting: false,
        isLoadingMore: false,
        isLoading: false,
      ),
    );
  }

  Future<void> _cancelSubscriptions() async {
    await _chatSubscription?.cancel();
    await _messageSubscription?.cancel();
    await _typingSubscription?.cancel();
    _chatSubscription = null;
    _messageSubscription = null;
    _typingSubscription = null;
  }

  @override
  Future<void> close() async {
    await _cancelSubscriptions();
    await super.close();
  }
}
