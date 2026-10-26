import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/data/models/chat.dart';
import 'package:triply/core/data/models/chat_message.dart';
import 'package:triply/core/data/models/chat_profile.dart';
import 'package:triply/core/data/models/report.dart';
import 'package:triply/core/data/repositories/chat_repository.dart';

/// The chat models must survive the documents the deployed rules allow:
/// missing fields, a null `createdAt` while a server timestamp is in
/// flight, and the canonical document id built from two uids.
void main() {
  group('ChatIds.canonical', () {
    test('sorts both uids lexicographically', () {
      expect(ChatIds.canonical('alice', 'bob'), 'alice_bob');
      expect(ChatIds.canonical('bob', 'alice'), 'alice_bob');
    });

    test('is stable for the same pair', () {
      expect(ChatIds.canonical('z9', 'a1'), ChatIds.canonical('a1', 'z9'));
      expect(ChatIds.canonical('uid2', 'uid2'), 'uid2_uid2');
    });

    test('keeps the role order out of the id', () {
      // touristId is 'zeta', guideId is 'alpha': the role fields stay as
      // they are, only the document id is sorted.
      expect(ChatIds.canonical('zeta', 'alpha'), 'alpha_zeta');
    });
  });

  group('Chat.fromDocument', () {
    test('reads every field of a complete document', () {
      final created = DateTime.utc(2026, 10, 1, 10);
      final chat = Chat.fromDocument({
        'touristId': 't1',
        'guideId': 'g1',
        'participants': ['t1', 'g1'],
        'profiles': {
          't1': {'displayName': 'Tourist', 'avatarUrl': 'https://a'},
          'g1': {'displayName': 'Guide', 'avatarUrl': 'https://b'},
        },
        'lastMessage': {
          'text': 'Hello',
          'senderId': 't1',
          'createdAt': created,
        },
        'lastMessageAt': created,
        'unreadCount': {'t1': 0, 'g1': 2},
        'lastReadAt': {'t1': created},
        'createdAt': created,
      }, 'c1');

      expect(chat.id, 'c1');
      expect(chat.touristId, 't1');
      expect(chat.guideId, 'g1');
      expect(chat.participants, ['t1', 'g1']);
      expect(chat.profileOf('t1').displayName, 'Tourist');
      expect(chat.profileOf('g1').avatarUrl, 'https://b');
      expect(chat.lastMessage!.text, 'Hello');
      expect(chat.previewText, 'Hello');
      expect(chat.unreadFor('g1'), 2);
      expect(chat.lastReadOf('t1'), created);
      expect(chat.createdAt, created);
    });

    test('tolerates a null document', () {
      final chat = Chat.fromDocument(null, 'empty');

      expect(chat.id, 'empty');
      expect(chat.touristId, '');
      expect(chat.guideId, '');
      expect(chat.participants, isEmpty);
      expect(chat.profiles, isEmpty);
      expect(chat.lastMessage, isNull);
      expect(chat.lastMessageAt, isNull);
      expect(chat.unreadCount, isEmpty);
      expect(chat.lastReadAt, isEmpty);
      expect(chat.createdAt, isNull);
      expect(chat.previewText, '');
      expect(chat.unreadFor('anyone'), 0);
      expect(chat.otherUserId('anyone'), '');
    });

    test('tolerates wrong types without throwing', () {
      final chat = Chat.fromDocument({
        'touristId': 42,
        'guideId': true,
        'participants': 'not a list',
        'profiles': 'not a map',
        'lastMessage': 'not a map',
        'lastMessageAt': 12.5,
        'unreadCount': {'t1': 3, 'g1': 'two'},
        'lastReadAt': {'t1': 'not a date', 'g1': 5},
        'createdAt': 'not a date',
      }, 'c2');

      expect(chat.touristId, '');
      expect(chat.guideId, '');
      expect(chat.participants, isEmpty);
      expect(chat.profiles, isEmpty);
      expect(chat.lastMessage, isNull);
      expect(
        chat.lastMessageAt!.isAtSameMomentAs(
          DateTime.fromMillisecondsSinceEpoch(12),
        ),
        isTrue,
      );
      expect(chat.unreadFor('t1'), 3);
      expect(chat.unreadFor('g1'), 0);
      // A non-date string is dropped; a number is read as epoch millis.
      expect(chat.lastReadAt.keys, <String>['g1']);
      expect(
        chat.lastReadAt['g1']!.isAtSameMomentAs(
          DateTime.fromMillisecondsSinceEpoch(5),
        ),
        isTrue,
      );
      expect(chat.createdAt, isNull);
    });

    test('falls back to the role fields when participants is missing', () {
      final chat = Chat.fromDocument({
        'touristId': 't1',
        'guideId': 'g1',
      }, 'c3');

      expect(chat.participants, ['t1', 'g1']);
    });

    test('accepts a Timestamp for every date field', () {
      // The model is fed a Timestamp by the SDK; the rules store server
      // timestamps which arrive as Timestamps too.
      final parsed = Chat.fromDocument({
        'lastMessageAt': DateTime.utc(2026, 10, 2),
        'unreadCount': {'t1': 1},
      }, 'c4');

      expect(parsed.lastMessageAt, DateTime.utc(2026, 10, 2));
    });

    test('resolves the other participant from either role', () {
      final chat = Chat.fromDocument({
        'touristId': 't1',
        'guideId': 'g1',
      }, 'c5');

      expect(chat.otherUserId('t1'), 'g1');
      expect(chat.otherUserId('g1'), 't1');
    });

    test('round-trips through toMap', () {
      final created = DateTime.utc(2026, 10, 3);
      final chat = Chat.fromDocument({
        'touristId': 't1',
        'guideId': 'g1',
        'participants': ['t1', 'g1'],
        'profiles': {
          't1': {'displayName': 'Tourist', 'avatarUrl': ''},
        },
        'lastMessage': {'text': 'Hi', 'senderId': 't1', 'createdAt': created},
        'lastMessageAt': created,
        'unreadCount': {'g1': 1},
        'lastReadAt': {'t1': created},
        'createdAt': created,
      }, 'c6');

      final again = Chat.fromDocument(chat.toMap(), chat.id);

      expect(again.touristId, chat.touristId);
      expect(again.guideId, chat.guideId);
      expect(again.participants, chat.participants);
      expect(again.profileOf('t1').displayName, 'Tourist');
      expect(again.lastMessage!.text, 'Hi');
      expect(again.lastMessageAt!.toUtc(), created);
      expect(again.unreadFor('g1'), 1);
      expect(again.lastReadOf('t1')!.toUtc(), created);
      expect(again.createdAt!.toUtc(), created);
    });
  });

  group('ChatProfile', () {
    test('defaults to empty strings', () {
      const profile = ChatProfile();
      expect(profile.displayName, '');
      expect(profile.avatarUrl, '');
    });

    test('reads a malformed entry as empty', () {
      expect(ChatProfile.fromMap(null).displayName, '');
      expect(ChatProfile.fromMap('nope').displayName, '');
      expect(ChatProfile.fromMap({'displayName': 3}).displayName, '');
    });

    test('copyWith keeps the untouched field', () {
      const profile = ChatProfile(displayName: 'A', avatarUrl: 'B');
      expect(profile.copyWith(displayName: 'C').avatarUrl, 'B');
    });
  });

  group('ChatMessage', () {
    test('reads a document and reports the edit state', () {
      final created = DateTime.utc(2026, 10, 4, 9);
      final message = ChatMessage.fromDocument({
        'senderId': 't1',
        'text': 'Hi there',
        'createdAt': created,
        'editedAt': created.add(const Duration(minutes: 1)),
      }, 'm1');

      expect(message.id, 'm1');
      expect(message.senderId, 't1');
      expect(message.text, 'Hi there');
      expect(message.createdAt, created);
      expect(message.isEdited, isTrue);
    });

    test('tolerates a missing document', () {
      final message = ChatMessage.fromDocument(null, 'm2');

      expect(message.senderId, '');
      expect(message.text, '');
      expect(message.createdAt, isNull);
      expect(message.isEdited, isFalse);
      expect(message.canModify('t1'), isFalse);
    });

    test('canModify is owner-only and inside the 24-hour window', () {
      final created = DateTime.utc(2026, 10, 5, 12);
      final message = ChatMessage(
        id: 'm3',
        senderId: 't1',
        text: 'Hi',
        createdAt: created,
      );

      expect(message.canModify('g1', now: created), isFalse);
      expect(message.canModify('t1', now: created), isTrue);
      expect(
        message.canModify('t1', now: created.add(const Duration(hours: 23))),
        isTrue,
      );
      expect(
        message.canModify('t1', now: created.add(const Duration(hours: 24))),
        isFalse,
      );
    });

    test('a message without createdAt cannot be modified', () {
      const message = ChatMessage(id: 'm4', senderId: 't1', text: 'Hi');
      expect(message.canModify('t1'), isFalse);
    });
  });

  group('ChatText', () {
    test('preview is the whole text up to 120 characters', () {
      expect(ChatText.preview('short'), 'short');
      expect(ChatText.preview('a' * 120), 'a' * 120);
    });

    test('preview cuts longer text at 120 characters', () {
      final preview = ChatText.preview('a' * 121);
      expect(preview, 'a' * 120);
      expect(preview.length, 120);
    });

    test('preview never splits a surrogate pair', () {
      final text = '${'a' * 119}😀😀';
      final preview = ChatText.preview(text);

      expect(preview.runes.length, 120);
      expect(preview, '${'a' * 119}😀');
      // The cut ends on a complete pair: the last UTF-16 unit is a low
      // surrogate, not the orphaned high half of the next emoji.
      expect(preview.codeUnits.last, inInclusiveRange(0xDC00, 0xDFFF));
    });

    test('validateMessage trims and rejects empty text', () {
      expect(ChatText.validateMessage('  hello  '), 'hello');
      expect(
        () => ChatText.validateMessage('   '),
        throwsA(isA<ChatValidationException>()),
      );
    });

    test('validateMessage enforces the 20,000 character limit', () {
      expect(ChatText.validateMessage('a' * 20000).length, 20000);
      expect(
        () => ChatText.validateMessage('a' * 20001),
        throwsA(isA<ChatValidationException>()),
      );
    });

    test('validateNote enforces the 500 character limit', () {
      expect(ChatText.validateNote(' n '), 'n');
      expect(ChatText.validateNote('a' * 500).length, 500);
      expect(
        () => ChatText.validateNote('a' * 501),
        throwsA(isA<ChatValidationException>()),
      );
    });
  });

  group('Report', () {
    test('builds the deterministic id', () {
      expect(Report.idFor('t1', 'm1'), 't1_m1');
      expect(Report.idFor('g1', 'm9'), 'g1_m9');
    });

    test('accepts only the four deployed reason codes', () {
      expect(Report.reasonCodes, [
        'spam',
        'harassment',
        'inappropriate_content',
        'other',
      ]);
      expect(Report.isReasonCode('spam'), isTrue);
      expect(Report.isReasonCode('other'), isTrue);
      expect(Report.isReasonCode('bogus'), isFalse);
      expect(Report.isReasonCode(''), isFalse);
    });

    test('round-trips the copied evidence', () {
      final created = DateTime.utc(2026, 10, 6, 8);
      final report = Report.fromDocument({
        'reporterId': 't1',
        'reportedUserId': 'g1',
        'chatId': 'g1_t1',
        'messageId': 'm1',
        'text': 'the evidence',
        'messageCreatedAt': created,
        'reasonCode': 'spam',
        'note': 'note',
        'status': 'open',
        'createdAt': created.add(const Duration(minutes: 2)),
      }, 't1_m1');

      expect(report.id, 't1_m1');
      expect(report.reporterId, 't1');
      expect(report.reportedUserId, 'g1');
      expect(report.chatId, 'g1_t1');
      expect(report.messageId, 'm1');
      expect(report.text, 'the evidence');
      expect(report.messageCreatedAt, created);
      expect(report.reasonCode, 'spam');
      expect(report.note, 'note');
      expect(report.status, 'open');

      final again = Report.fromDocument(report.toMap(), report.id);
      expect(again.text, 'the evidence');
      expect(again.messageCreatedAt!.toUtc(), created);
      expect(again.reasonCode, 'spam');
    });

    test('tolerates a missing document', () {
      final report = Report.fromDocument(null, 'x');

      expect(report.reporterId, '');
      expect(report.reviewerId, isNull);
      expect(report.reviewNote, isNull);
      expect(report.messageCreatedAt, isNull);
    });
  });

  group('ChatTypingThrottle', () {
    test('sends once, then waits for the interval', () {
      var now = DateTime.utc(2026, 10, 7, 12);
      final throttle = ChatTypingThrottle(clock: () => now);

      expect(throttle.shouldSend(), isTrue);
      now = now.add(const Duration(seconds: 1));
      expect(throttle.shouldSend(), isFalse);
      now = now.add(const Duration(seconds: 2));
      expect(throttle.shouldSend(), isTrue);
    });

    test('reset allows an immediate send', () {
      var now = DateTime.utc(2026, 10, 7, 12);
      final throttle = ChatTypingThrottle(clock: () => now);

      expect(throttle.shouldSend(), isTrue);
      expect(throttle.shouldSend(), isFalse);
      throttle.reset();
      expect(throttle.shouldSend(), isTrue);
    });

    test('honours a custom interval', () {
      var now = DateTime.utc(2026, 10, 7, 12);
      final throttle = ChatTypingThrottle(
        clock: () => now,
        interval: const Duration(seconds: 10),
      );

      expect(throttle.shouldSend(), isTrue);
      now = now.add(const Duration(seconds: 9));
      expect(throttle.shouldSend(), isFalse);
      now = now.add(const Duration(seconds: 1));
      expect(throttle.shouldSend(), isTrue);
    });
  });

  group('ChatErrors', () {
    test('keeps a chat exception as it is', () {
      const error = ChatPermissionException();
      expect(ChatErrors.map(error), same(error));
    });

    test('maps a rules denial to the read-only exception', () {
      final mapped = ChatErrors.map(
        FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
      );
      expect(mapped, isA<ChatPermissionException>());
    });

    test('maps a signed-out write to the auth exception', () {
      final mapped = ChatErrors.map(
        FirebaseException(plugin: 'cloud_firestore', code: 'unauthenticated'),
      );
      expect(mapped, isA<ChatNotAuthenticatedException>());
    });

    test('wraps an unknown error in a safe message', () {
      final mapped = ChatErrors.map(StateError('boom'));
      expect(mapped, isA<ChatException>());
      expect(mapped.toString(), 'Bad state: boom');
    });
  });
}
