import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat.dart';
import '../models/chat_message.dart';

/// The chat data layer, behind an interface so the cubits can be tested
/// with an in-memory fake.
abstract class ChatRepository {
  /// The signed-in user's uid, or null when signed out.
  String? get currentUserId;

  /// Opens the canonical chat with [guideId], creating it when needed.
  ///
  /// Only a tourist may start a chat. When [firstMessage] is supplied the
  /// chat document, both profiles, the counters and the first message are
  /// written atomically, so a new chat never exists without its first
  /// message.
  Future<Chat> openOrCreateChat({
    required String guideId,
    required String guideName,
    required String guideAvatar,
    String? firstMessage,
  });

  /// Sends [text] to an existing chat.
  ///
  /// One batch writes the message, the 120-character preview, the
  /// timestamp and the recipient's unread counter.
  Future<ChatMessage> sendMessage({
    required String chatId,
    required String text,
  });

  /// The chats of [userId], newest activity first.
  Stream<List<Chat>> watchChats(String userId);

  /// The chat document, or null when it does not exist.
  Stream<Chat?> watchChat(String chatId);

  /// The most recent [limit] messages, newest first.
  Stream<List<ChatMessage>> watchMessages(String chatId, {int limit = 30});

  /// The page of messages older than [before], newest first.
  Future<List<ChatMessage>> loadMoreMessages({
    required String chatId,
    required DateTime before,
    int limit = 30,
  });

  /// Resets the caller's unread counter and moves their read marker.
  Future<void> markRead(String chatId);

  Future<void> editMessage({
    required String chatId,
    required String messageId,
    required String text,
  });

  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  });

  /// Writes the caller's typing marker, at most once every three seconds.
  ///
  /// Returns true when a write actually happened.
  Future<bool> setTyping(String chatId);

  /// The uids that wrote a typing marker in the last five seconds.
  Stream<Set<String>> watchTyping(String chatId);

  /// Reports [message]. The document id is deterministic.
  Future<void> reportMessage({
    required String chatId,
    required ChatMessage message,
    required String reasonCode,
    String note = '',
  });

  /// Writes only the caller's own `profiles.<uid>` entry.
  Future<void> updateMyProfile({
    required String chatId,
    String? displayName,
    String? avatarUrl,
  });
}

/// Base class for chat failures with a message safe to show in the UI.
class ChatException implements Exception {
  final String message;

  const ChatException(this.message);

  @override
  String toString() => message;
}

/// The request was denied by the rules.
///
/// The cubits turn this into a read-only chat: the account is inactive,
/// the chat is not the caller's, or the guide is no longer approved.
class ChatPermissionException extends ChatException {
  const ChatPermissionException([
    super.message = 'You do not have permission to do that.',
  ]);
}

/// The caller is not signed in.
class ChatNotAuthenticatedException extends ChatException {
  const ChatNotAuthenticatedException([super.message = 'Sign in to use chat.']);
}

/// The input does not satisfy the chat contract.
class ChatValidationException extends ChatException {
  const ChatValidationException(super.message);
}

/// Maps SDK and stream errors to the chat exception types.
class ChatErrors {
  const ChatErrors._();

  static Object map(Object error) {
    if (error is ChatException) return error;
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return const ChatPermissionException();
        case 'unauthenticated':
          return const ChatNotAuthenticatedException();
        default:
          return ChatException(error.message ?? 'The chat request failed.');
      }
    }
    return ChatException(error.toString());
  }
}

/// Text rules shared by the Firestore implementation and the fake.
class ChatText {
  /// Technical ceiling enforced by the deployed message rule.
  static const int maxMessageLength = 20000;

  /// The `lastMessage.text` ceiling enforced by the deployed chat rule.
  static const int previewLength = 120;

  /// The report note ceiling enforced by the deployed report rule.
  static const int maxReportNoteLength = 500;

  const ChatText._();

  /// Validates and normalises a message body.
  static String validateMessage(String text) {
    final value = text.trim();
    if (value.isEmpty) {
      throw const ChatValidationException('Write a message first.');
    }
    if (value.runes.length > maxMessageLength) {
      throw const ChatValidationException(
        'This message is longer than the 20,000 character limit.',
      );
    }
    return value;
  }

  /// Validates and normalises a report note.
  static String validateNote(String note) {
    final value = note.trim();
    if (value.runes.length > maxReportNoteLength) {
      throw const ChatValidationException(
        'A report note can be at most 500 characters.',
      );
    }
    return value;
  }

  /// The value stored in `lastMessage.text`.
  ///
  /// Truncated to [previewLength] characters without splitting a
  /// surrogate pair, so the deployed 120-character rule always accepts
  /// the preview.
  static String preview(String text) {
    final runes = text.runes;
    if (runes.length <= previewLength) return text;
    return String.fromCharCodes(runes.take(previewLength));
  }
}

/// At most one typing write per [interval].
///
/// The clock is injectable so the throttle can be tested without
/// waiting three real seconds.
class ChatTypingThrottle {
  ChatTypingThrottle({
    DateTime Function()? clock,
    this.interval = const Duration(seconds: 3),
  }) : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  final Duration interval;
  DateTime? _lastSent;

  bool shouldSend([DateTime? now]) {
    final at = now ?? _clock();
    final last = _lastSent;
    if (last == null || at.difference(last) >= interval) {
      _lastSent = at;
      return true;
    }
    return false;
  }

  void reset() => _lastSent = null;
}
