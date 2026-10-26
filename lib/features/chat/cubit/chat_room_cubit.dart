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
       super(const ChatRoomInitial());

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

  /// The newest inbound message whose read marker was already written, so
  /// the live snapshot does not write the same read marker twice.
  String? _lastMarkedReadMessageId;

  String? get chatId => _chatId;

  String? get myUserId => repository.currentUserId;

  ChatRoomSuccess? get _success =>
      state is ChatRoomSuccess ? state as ChatRoomSuccess : null;

  String? get otherUserId {
    final chat = _success?.chat;
    final me = myUserId;
    if (chat == null || me == null) return null;
    return chat.otherUserId(me);
  }

  /// The other participant's `lastReadAt`, when the chat is loaded.
  DateTime? get otherLastReadAt {
    final chat = _success?.chat;
    final other = otherUserId;
    if (chat == null || other == null) return null;
    return chat.lastReadOf(other);
  }

  bool get isOtherTyping {
    final other = otherUserId;
    final typing = _success?.typingUids ?? const <String>{};
    return other != null && typing.contains(other);
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

  /// Subscribes to an existing chat, or opens the empty composer for a
  /// chat that will be created by its first message.
  Future<void> load() async {
    if (_chatId == null) {
      if (guideId == null) {
        safeEmit(const ChatRoomError('This chat is not available.'));
        return;
      }
      safeEmit(const ChatRoomSuccess());
      return;
    }
    safeEmit(const ChatRoomLoading());
    await _listen();
    if (state is ChatRoomSuccess) {
      unawaited(_refreshMyProfile());
    }
  }

  Future<void> _listen() async {
    final chatId = _chatId;
    if (chatId == null) return;

    await _cancelSubscriptions();
    _lastMarkedReadMessageId = null;

    final firstChat = Completer<void>();
    final firstMessages = Completer<void>();
    final firstTyping = Completer<void>();
    _chatSubscription = repository
        .watchChat(chatId)
        .listen(
          (chat) {
            _onChat(chat);
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
            _onMessages(chatId, messages);
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
            _onTyping(uids);
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

  void _onChat(Chat? chat) {
    final current = _success;
    safeEmit(
      ChatRoomSuccess(
        chat: chat ?? current?.chat,
        messages: current?.messages ?? const <ChatMessage>[],
        typingUids: current?.typingUids ?? const <String>{},
        isLoadingMore: current?.isLoadingMore ?? false,
        hasMore: current?.hasMore ?? false,
        isReadOnly: current?.isReadOnly ?? false,
        isSending: current?.isSending ?? false,
        isEditing: current?.isEditing ?? false,
        isDeleting: current?.isDeleting ?? false,
        isReporting: current?.isReporting ?? false,
        actionError: current?.actionError,
      ),
    );
  }

  void _onMessages(String chatId, List<ChatMessage> messages) {
    final current = _success;
    safeEmit(
      ChatRoomSuccess(
        chat: current?.chat,
        messages: messages,
        typingUids: current?.typingUids ?? const <String>{},
        isLoadingMore: false,
        hasMore: messages.length >= pageSize,
        isReadOnly: current?.isReadOnly ?? false,
        isSending: current?.isSending ?? false,
        isEditing: current?.isEditing ?? false,
        isDeleting: current?.isDeleting ?? false,
        isReporting: current?.isReporting ?? false,
        actionError: current?.actionError,
      ),
    );

    // Reading the room clears the badge: do it once per inbound message
    // (the first snapshot and every later one), not on every rebuild.
    final me = myUserId;
    final newest = messages.isEmpty ? null : messages.first;
    if (newest != null &&
        me != null &&
        newest.senderId != me &&
        !(current?.isReadOnly ?? false) &&
        _lastMarkedReadMessageId != newest.id) {
      _lastMarkedReadMessageId = newest.id;
      unawaited(markRead());
    }
  }

  void _onTyping(Set<String> uids) {
    final current = _success;
    safeEmit(
      ChatRoomSuccess(
        chat: current?.chat,
        messages: current?.messages ?? const <ChatMessage>[],
        typingUids: uids,
        isLoadingMore: current?.isLoadingMore ?? false,
        hasMore: current?.hasMore ?? false,
        isReadOnly: current?.isReadOnly ?? false,
        isSending: current?.isSending ?? false,
        isEditing: current?.isEditing ?? false,
        isDeleting: current?.isDeleting ?? false,
        isReporting: current?.isReporting ?? false,
        actionError: current?.actionError,
      ),
    );
  }

  void _onStreamError(Object error) {
    final mapped = ChatErrors.map(error);
    final current = _success;
    if (current == null) {
      safeEmit(
        ChatRoomError(
          mapped.toString(),
          isReadOnly: mapped is ChatPermissionException,
        ),
      );
      return;
    }
    safeEmit(
      ChatRoomSuccess(
        chat: current.chat,
        messages: current.messages,
        typingUids: current.typingUids,
        isLoadingMore: false,
        hasMore: current.hasMore,
        isReadOnly: current.isReadOnly || mapped is ChatPermissionException,
        isSending: false,
        isEditing: false,
        isDeleting: false,
        isReporting: false,
        actionError: mapped.toString(),
      ),
    );
  }

  /// Sends a message. With no chat yet, this creates the canonical chat
  /// and the message atomically through the repository.
  Future<void> sendMessage(String text) async {
    // A new chat can be sent before `load()` is called; treat the initial
    // state as the empty room. An existing chat id still needs its load.
    final current =
        _success ??
        (state is ChatRoomInitial && _chatId == null && guideId != null
            ? const ChatRoomSuccess()
            : null);
    if (current == null || current.isSending || current.isReadOnly) return;
    safeEmit(
      ChatRoomSuccess(
        chat: current.chat,
        messages: current.messages,
        typingUids: current.typingUids,
        isLoadingMore: current.isLoadingMore,
        hasMore: current.hasMore,
        isReadOnly: current.isReadOnly,
        isSending: true,
        isEditing: current.isEditing,
        isDeleting: current.isDeleting,
        isReporting: current.isReporting,
        actionError: null,
      ),
    );
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
        final sent = _success;
        safeEmit(
          ChatRoomSuccess(
            chat: chat,
            messages: sent?.messages ?? const <ChatMessage>[],
            typingUids: sent?.typingUids ?? const <String>{},
            isLoadingMore: sent?.isLoadingMore ?? false,
            hasMore: sent?.hasMore ?? false,
            isReadOnly: sent?.isReadOnly ?? false,
            isSending: false,
            isEditing: sent?.isEditing ?? false,
            isDeleting: sent?.isDeleting ?? false,
            isReporting: sent?.isReporting ?? false,
            actionError: null,
          ),
        );
        await _listen();
        unawaited(_refreshMyProfile());
      } else {
        await repository.sendMessage(chatId: chatId, text: text);
        final sent = _success;
        if (sent != null) {
          safeEmit(
            ChatRoomSuccess(
              chat: sent.chat,
              messages: sent.messages,
              typingUids: sent.typingUids,
              isLoadingMore: sent.isLoadingMore,
              hasMore: sent.hasMore,
              isReadOnly: sent.isReadOnly,
              isSending: false,
              isEditing: sent.isEditing,
              isDeleting: sent.isDeleting,
              isReporting: sent.isReporting,
              actionError: null,
            ),
          );
        }
      }
    } catch (error) {
      _fail(error);
    }
  }

  /// Loads the next page of older messages.
  Future<void> loadMore() async {
    final current = _success;
    final chatId = _chatId;
    if (current == null ||
        chatId == null ||
        current.isLoadingMore ||
        !current.hasMore) {
      return;
    }
    final oldest = current.messages.isEmpty
        ? null
        : current.messages.last.createdAt;
    if (oldest == null) return;

    safeEmit(
      ChatRoomSuccess(
        chat: current.chat,
        messages: current.messages,
        typingUids: current.typingUids,
        isLoadingMore: true,
        hasMore: current.hasMore,
        isReadOnly: current.isReadOnly,
        isSending: current.isSending,
        isEditing: current.isEditing,
        isDeleting: current.isDeleting,
        isReporting: current.isReporting,
        actionError: null,
      ),
    );
    try {
      final older = await repository.loadMoreMessages(
        chatId: chatId,
        before: oldest,
        limit: pageSize,
      );
      final known = current.messages.map((message) => message.id).toSet();
      final merged = <ChatMessage>[
        ...current.messages,
        ...older.where((message) => !known.contains(message.id)),
      ];
      final loaded = _success;
      safeEmit(
        ChatRoomSuccess(
          chat: loaded?.chat ?? current.chat,
          messages: merged,
          typingUids: loaded?.typingUids ?? current.typingUids,
          isLoadingMore: false,
          hasMore: older.length >= pageSize,
          isReadOnly: loaded?.isReadOnly ?? current.isReadOnly,
          isSending: loaded?.isSending ?? current.isSending,
          isEditing: loaded?.isEditing ?? current.isEditing,
          isDeleting: loaded?.isDeleting ?? current.isDeleting,
          isReporting: loaded?.isReporting ?? current.isReporting,
          actionError: loaded?.actionError,
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
    final current = _success;
    if (current == null || current.isEditing || current.isReadOnly) return;
    safeEmit(
      ChatRoomSuccess(
        chat: current.chat,
        messages: current.messages,
        typingUids: current.typingUids,
        isLoadingMore: current.isLoadingMore,
        hasMore: current.hasMore,
        isReadOnly: current.isReadOnly,
        isSending: current.isSending,
        isEditing: true,
        isDeleting: current.isDeleting,
        isReporting: current.isReporting,
        actionError: null,
      ),
    );
    try {
      await repository.editMessage(
        chatId: _requireChatId(),
        messageId: messageId,
        text: text,
      );
      final done = _success;
      if (done != null) {
        safeEmit(
          ChatRoomSuccess(
            chat: done.chat,
            messages: done.messages,
            typingUids: done.typingUids,
            isLoadingMore: done.isLoadingMore,
            hasMore: done.hasMore,
            isReadOnly: done.isReadOnly,
            isSending: done.isSending,
            isEditing: false,
            isDeleting: done.isDeleting,
            isReporting: done.isReporting,
            actionError: null,
          ),
        );
      }
    } catch (error) {
      _fail(error);
    }
  }

  Future<void> deleteMessage(String messageId) async {
    final current = _success;
    if (current == null || current.isDeleting || current.isReadOnly) return;
    safeEmit(
      ChatRoomSuccess(
        chat: current.chat,
        messages: current.messages,
        typingUids: current.typingUids,
        isLoadingMore: current.isLoadingMore,
        hasMore: current.hasMore,
        isReadOnly: current.isReadOnly,
        isSending: current.isSending,
        isEditing: current.isEditing,
        isDeleting: true,
        isReporting: current.isReporting,
        actionError: null,
      ),
    );
    try {
      await repository.deleteMessage(
        chatId: _requireChatId(),
        messageId: messageId,
      );
      final done = _success;
      if (done != null) {
        safeEmit(
          ChatRoomSuccess(
            chat: done.chat,
            messages: done.messages,
            typingUids: done.typingUids,
            isLoadingMore: done.isLoadingMore,
            hasMore: done.hasMore,
            isReadOnly: done.isReadOnly,
            isSending: done.isSending,
            isEditing: done.isEditing,
            isDeleting: false,
            isReporting: done.isReporting,
            actionError: null,
          ),
        );
      }
    } catch (error) {
      _fail(error);
    }
  }

  Future<void> reportMessage({
    required ChatMessage message,
    required String reasonCode,
    String note = '',
  }) async {
    final current = _success;
    if (current == null || current.isReporting) return;
    safeEmit(
      ChatRoomSuccess(
        chat: current.chat,
        messages: current.messages,
        typingUids: current.typingUids,
        isLoadingMore: current.isLoadingMore,
        hasMore: current.hasMore,
        isReadOnly: current.isReadOnly,
        isSending: current.isSending,
        isEditing: current.isEditing,
        isDeleting: current.isDeleting,
        isReporting: true,
        actionError: null,
      ),
    );
    try {
      await repository.reportMessage(
        chatId: _requireChatId(),
        message: message,
        reasonCode: reasonCode,
        note: note,
      );
      final done = _success;
      if (done != null) {
        safeEmit(
          ChatRoomSuccess(
            chat: done.chat,
            messages: done.messages,
            typingUids: done.typingUids,
            isLoadingMore: done.isLoadingMore,
            hasMore: done.hasMore,
            isReadOnly: done.isReadOnly,
            isSending: done.isSending,
            isEditing: done.isEditing,
            isDeleting: done.isDeleting,
            isReporting: false,
            actionError: null,
          ),
        );
      }
    } catch (error) {
      _fail(error);
    }
  }

  /// Writes the typing marker at most once per three seconds.
  Future<void> notifyTyping() async {
    final chatId = _chatId;
    if (chatId == null) return;
    if (_success?.isReadOnly ?? false) return;
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

  /// Keeps the caller's name/avatar current in every room they open.
  ///
  /// Silent by design: a profile refresh must never interrupt the chat.
  Future<void> _refreshMyProfile() async {
    final chatId = _chatId;
    if (chatId == null) return;
    try {
      await repository.updateMyProfile(chatId: chatId);
    } catch (_) {
      // Best effort.
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
    final current = _success;
    if (current == null) {
      safeEmit(
        ChatRoomError(
          mapped.toString(),
          isReadOnly: mapped is ChatPermissionException,
        ),
      );
      return;
    }
    safeEmit(
      ChatRoomSuccess(
        chat: current.chat,
        messages: current.messages,
        typingUids: current.typingUids,
        isLoadingMore: false,
        hasMore: current.hasMore,
        isReadOnly: current.isReadOnly || mapped is ChatPermissionException,
        isSending: false,
        isEditing: false,
        isDeleting: false,
        isReporting: false,
        actionError: mapped.toString(),
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
