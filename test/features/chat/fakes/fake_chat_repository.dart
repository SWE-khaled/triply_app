import 'dart:async';

import 'package:triply/core/data/models/chat.dart';
import 'package:triply/core/data/models/chat_message.dart';
import 'package:triply/core/data/models/chat_profile.dart';
import 'package:triply/core/data/models/report.dart';
import 'package:triply/core/data/repositories/chat_repository.dart';

/// In-memory [ChatRepository] used by the C2 unit tests.
///
/// It mirrors the rules that matter to the cubits: the canonical id, the
/// tourist-only create, the recipient-only unread increment, the
/// deterministic report id and the 24-hour edit window.
class FakeChatRepository implements ChatRepository {
  FakeChatRepository({
    this.currentUserId,
    Map<String, String>? roles,
    DateTime Function()? clock,
    this.touristName = 'Tourist',
    this.touristAvatar = '',
  }) : roles = roles ?? <String, String>{},
       _clock = clock ?? DateTime.now;

  @override
  String? currentUserId;

  /// uid -> `'tourist'` / `'guide'` / `'admin'`. A missing entry counts
  /// as a tourist.
  final Map<String, String> roles;

  final DateTime Function() _clock;
  final String touristName;
  final String touristAvatar;

  final Map<String, Chat> chats = <String, Chat>{};
  final Map<String, List<ChatMessage>> messages = <String, List<ChatMessage>>{};
  final Map<String, DateTime> typing = <String, DateTime>{};
  final List<Report> reports = <Report>[];

  final StreamController<void> _changes = StreamController<void>.broadcast();

  /// Injected failures for the cubit error-mapping tests.
  Object? openError;
  Object? sendError;
  Object? markReadError;

  int typingWrites = 0;
  int _sequence = 0;

  DateTime get now => _clock();

  void seedChat(Chat chat) {
    chats[chat.id] = chat;
    notify();
  }

  void seedMessages(String chatId, List<ChatMessage> value) {
    messages[chatId] = List<ChatMessage>.of(value);
    notify();
  }

  void notify() {
    if (!_changes.isClosed) _changes.add(null);
  }

  Future<void> dispose() => _changes.close();

  @override
  Future<Chat> openOrCreateChat({
    required String guideId,
    required String guideName,
    required String guideAvatar,
    String? firstMessage,
  }) async {
    if (openError != null) throw openError!;

    final me = currentUserId;
    if (me == null || me.isEmpty) {
      throw const ChatNotAuthenticatedException();
    }
    if (guideId.isEmpty || guideId == me) {
      throw const ChatValidationException('Choose a guide to chat with.');
    }
    if ((roles[me] ?? 'tourist') != 'tourist') {
      throw const ChatPermissionException('Only tourists can start a chat.');
    }

    final chatId = ChatIds.canonical(me, guideId);
    final existing = chats[chatId];
    final first = firstMessage == null || firstMessage.trim().isEmpty
        ? null
        : ChatText.validateMessage(firstMessage);

    if (existing != null) {
      if (first != null) await sendMessage(chatId: chatId, text: first);
      return chats[chatId]!;
    }

    final chat = Chat(
      id: chatId,
      touristId: me,
      guideId: guideId,
      participants: <String>[me, guideId],
      profiles: <String, ChatProfile>{
        me: ChatProfile(displayName: touristName, avatarUrl: touristAvatar),
        guideId: ChatProfile(displayName: guideName, avatarUrl: guideAvatar),
      },
      lastMessage: first == null
          ? null
          : ChatLastMessage(
              text: ChatText.preview(first),
              senderId: me,
              createdAt: now,
            ),
      lastMessageAt: first == null ? null : now,
      unreadCount: <String, int>{me: 0, guideId: first == null ? 0 : 1},
      createdAt: now,
    );
    chats[chatId] = chat;
    messages[chatId] = <ChatMessage>[if (first != null) _newMessage(me, first)];
    notify();
    return chat;
  }

  @override
  Future<ChatMessage> sendMessage({
    required String chatId,
    required String text,
  }) async {
    if (sendError != null) throw sendError!;

    final me = currentUserId;
    if (me == null || me.isEmpty) {
      throw const ChatNotAuthenticatedException();
    }
    final value = ChatText.validateMessage(text);
    final chat = chats[chatId];
    if (chat == null) {
      throw const ChatException('This chat does not exist yet.');
    }

    final other = chat.otherUserId(me);
    final message = _newMessage(me, value);
    messages.putIfAbsent(chatId, () => <ChatMessage>[]).insert(0, message);
    chats[chatId] = chat.copyWith(
      lastMessage: ChatLastMessage(
        text: ChatText.preview(value),
        senderId: me,
        createdAt: now,
      ),
      lastMessageAt: now,
      unreadCount: <String, int>{
        ...chat.unreadCount,
        other: chat.unreadFor(other) + 1,
      },
    );
    notify();
    return message;
  }

  /// A snapshot stream: emits the current value on listen, then a fresh
  /// value on every change. A plain controller (not `async*`) is used so
  /// cancelling a subscription completes promptly — the cubits cancel on
  /// `close()`, and an `async*` generator parked on a broadcast stream
  /// can keep that cancel pending in tests.
  Stream<T> _watch<T>(T Function() snapshot) {
    late final StreamController<T> controller;
    StreamSubscription<void>? subscription;

    void emit() {
      if (!controller.isClosed) controller.add(snapshot());
    }

    controller = StreamController<T>(
      onListen: () {
        emit();
        subscription = _changes.stream.listen((_) => emit());
      },
      onCancel: () async {
        await subscription?.cancel();
        subscription = null;
      },
    );
    return controller.stream;
  }

  @override
  Stream<List<Chat>> watchChats(String userId) =>
      _watch(() => _chatsFor(userId));

  @override
  Stream<Chat?> watchChat(String chatId) => _watch(() => chats[chatId]);

  @override
  Stream<List<ChatMessage>> watchMessages(String chatId, {int limit = 30}) =>
      _watch(() => _page(chatId, limit));

  @override
  Future<List<ChatMessage>> loadMoreMessages({
    required String chatId,
    required DateTime before,
    int limit = 30,
  }) async {
    final all = _sorted(chatId);
    return all
        .where(
          (message) =>
              message.createdAt != null && message.createdAt!.isBefore(before),
        )
        .take(limit)
        .toList(growable: false);
  }

  @override
  Future<void> markRead(String chatId) async {
    if (markReadError != null) throw markReadError!;

    final me = currentUserId;
    if (me == null || me.isEmpty) {
      throw const ChatNotAuthenticatedException();
    }
    final chat = chats[chatId];
    if (chat == null) {
      throw const ChatException('This chat does not exist yet.');
    }
    chats[chatId] = chat.copyWith(
      unreadCount: <String, int>{...chat.unreadCount, me: 0},
      lastReadAt: <String, DateTime>{...chat.lastReadAt, me: now},
    );
    notify();
  }

  @override
  Future<void> editMessage({
    required String chatId,
    required String messageId,
    required String text,
  }) async {
    final me = currentUserId;
    if (me == null || me.isEmpty) {
      throw const ChatNotAuthenticatedException();
    }
    final value = ChatText.validateMessage(text);
    final list = messages[chatId];
    if (list == null) throw const ChatException('This chat does not exist.');

    final index = list.indexWhere((message) => message.id == messageId);
    if (index < 0) throw const ChatException('This message does not exist.');
    final message = list[index];
    if (message.senderId != me) {
      throw const ChatValidationException(
        'You can only edit your own messages.',
      );
    }
    if (!message.canModify(me, now: now)) {
      throw const ChatValidationException(
        'Messages can only be edited within 24 hours.',
      );
    }
    list[index] = message.copyWith(text: value, editedAt: now);
    notify();
  }

  @override
  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  }) async {
    final me = currentUserId;
    if (me == null || me.isEmpty) {
      throw const ChatNotAuthenticatedException();
    }
    final list = messages[chatId];
    if (list == null) return;

    final matches = list.where((item) => item.id == messageId);
    if (matches.isEmpty) return;
    final message = matches.first;
    if (message.senderId != me) {
      throw const ChatValidationException(
        'You can only delete your own messages.',
      );
    }
    if (!message.canModify(me, now: now)) {
      throw const ChatValidationException(
        'Messages can only be deleted within 24 hours.',
      );
    }
    list.removeWhere((item) => item.id == messageId);
    notify();
  }

  @override
  Future<bool> setTyping(String chatId) async {
    final me = currentUserId;
    if (me == null || me.isEmpty) {
      throw const ChatNotAuthenticatedException();
    }
    typingWrites += 1;
    typing[me] = now;
    notify();
    return true;
  }

  @override
  Stream<Set<String>> watchTyping(String chatId) => _watch(_activeTypists);

  @override
  Future<void> reportMessage({
    required String chatId,
    required ChatMessage message,
    required String reasonCode,
    String note = '',
  }) async {
    final me = currentUserId;
    if (me == null || me.isEmpty) {
      throw const ChatNotAuthenticatedException();
    }
    if (!Report.isReasonCode(reasonCode)) {
      throw const ChatValidationException('Choose a report reason.');
    }
    final noteValue = ChatText.validateNote(note);
    final chat = chats[chatId];
    if (chat == null) throw const ChatException('This chat does not exist.');

    final other = chat.otherUserId(me);
    final matches =
        messages[chatId]?.where((item) => item.id == message.id) ??
        const Iterable<ChatMessage>.empty();
    if (matches.isEmpty) {
      throw const ChatException('This message no longer exists.');
    }
    final real = matches.first;
    if (real.senderId != other) {
      throw const ChatValidationException(
        'You can only report the other participant\'s message.',
      );
    }

    reports.add(
      Report(
        id: Report.idFor(me, real.id),
        reporterId: me,
        reportedUserId: other,
        chatId: chatId,
        messageId: real.id,
        text: real.text,
        messageCreatedAt: real.createdAt,
        reasonCode: reasonCode,
        note: noteValue,
        status: 'open',
        createdAt: now,
      ),
    );
  }

  @override
  Future<void> updateMyProfile({
    required String chatId,
    String? displayName,
    String? avatarUrl,
  }) async {
    final me = currentUserId;
    if (me == null || me.isEmpty) {
      throw const ChatNotAuthenticatedException();
    }
    final chat = chats[chatId];
    if (chat == null) throw const ChatException('This chat does not exist.');

    final current = chat.profileOf(me);
    chats[chatId] = chat.copyWith(
      profiles: <String, ChatProfile>{
        ...chat.profiles,
        me: current.copyWith(
          displayName: displayName ?? current.displayName,
          avatarUrl: avatarUrl ?? current.avatarUrl,
        ),
      },
    );
    notify();
  }

  ChatMessage _newMessage(String senderId, String text) {
    _sequence += 1;
    return ChatMessage(
      id: 'm$_sequence',
      senderId: senderId,
      text: text,
      createdAt: now,
    );
  }

  List<Chat> _chatsFor(String userId) {
    final list = chats.values
        .where((chat) => chat.participants.contains(userId))
        .toList(growable: false);
    return List<Chat>.of(list)..sort((a, b) {
      final aAt = a.lastMessageAt;
      final bAt = b.lastMessageAt;
      if (aAt == null && bAt == null) return 0;
      if (aAt == null) return 1;
      if (bAt == null) return -1;
      return bAt.compareTo(aAt);
    });
  }

  List<ChatMessage> _page(String chatId, int limit) =>
      _sorted(chatId).take(limit).toList(growable: false);

  List<ChatMessage> _sorted(String chatId) {
    final list = List<ChatMessage>.of(
      messages[chatId] ?? const <ChatMessage>[],
    );
    list.sort((a, b) {
      final aAt = a.createdAt;
      final bAt = b.createdAt;
      if (aAt == null && bAt == null) return 0;
      if (aAt == null) return 1;
      if (bAt == null) return -1;
      return bAt.compareTo(aAt);
    });
    return list;
  }

  Set<String> _activeTypists() {
    final at = now;
    return <String>{
      for (final entry in typing.entries)
        if (at.difference(entry.value) <= const Duration(seconds: 5)) entry.key,
    };
  }
}
