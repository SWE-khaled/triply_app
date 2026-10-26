import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/data/models/chat.dart';
import 'package:triply/core/data/models/chat_message.dart';
import 'package:triply/core/data/models/chat_profile.dart';
import 'package:triply/core/data/repositories/chat_repository.dart';
import 'package:triply/features/chat/cubit/chat_room_cubit.dart';
import 'package:triply/features/chat/cubit/chat_room_state.dart';

import '../fakes/fake_chat_repository.dart';

/// The room cubit drives the deployed chat contract: the first message
/// creates the canonical chat atomically, every send bumps only the
/// recipient's unread counter, the preview stops at 120 characters, and
/// a denied write turns the room read-only.
void main() {
  const tourist = 't1';
  const guide = 'g1';
  final chatId = ChatIds.canonical(tourist, guide);

  late FakeChatRepository repository;
  late ChatRoomCubit cubit;
  late DateTime now;

  setUp(() {
    now = DateTime.utc(2026, 10, 9, 12);
    repository = FakeChatRepository(currentUserId: tourist, clock: () => now);
    cubit = ChatRoomCubit(repository: repository);
  });

  tearDown(() async {
    await cubit.close();
    await repository.dispose();
  });

  Chat baseChat({Map<String, int>? unread, Map<String, DateTime>? lastReadAt}) {
    return Chat(
      id: chatId,
      touristId: tourist,
      guideId: guide,
      participants: <String>[tourist, guide],
      profiles: <String, ChatProfile>{
        tourist: const ChatProfile(displayName: 'Tourist'),
        guide: const ChatProfile(displayName: 'Guide'),
      },
      unreadCount: unread ?? <String, int>{tourist: 0, guide: 0},
      lastReadAt: lastReadAt ?? const <String, DateTime>{},
      createdAt: now.subtract(const Duration(days: 1)),
    );
  }

  ChatMessage message(
    String id, {
    required String senderId,
    required String text,
    DateTime? createdAt,
  }) {
    return ChatMessage(
      id: id,
      senderId: senderId,
      text: text,
      createdAt: createdAt ?? now,
    );
  }

  Future<void> loadExisting({List<ChatMessage>? messages}) async {
    repository.seedChat(baseChat());
    repository.seedMessages(chatId, messages ?? <ChatMessage>[]);
    await cubit.close();
    cubit = ChatRoomCubit(
      repository: repository,
      chatId: chatId,
      clock: () => now,
    );
    await cubit.load();
  }

  group('starting a chat', () {
    test('the first message creates the canonical chat atomically', () async {
      await cubit.close();
      cubit = ChatRoomCubit(
        repository: repository,
        guideId: guide,
        guideName: 'Guide',
        guideAvatar: 'https://avatar',
        clock: () => now,
      );

      await cubit.sendMessage('hello');

      expect(chatId, 'g1_t1');
      expect(cubit.chatId, chatId);
      expect(repository.chats.keys, [chatId]);

      final chat = repository.chats[chatId]!;
      expect(chat.touristId, tourist);
      expect(chat.guideId, guide);
      expect(chat.participants, <String>[tourist, guide]);
      expect(chat.profileOf(tourist).displayName, 'Tourist');
      expect(chat.profileOf(guide).displayName, 'Guide');
      expect(chat.unreadFor(tourist), 0);
      expect(chat.unreadFor(guide), 1);
      expect(chat.lastMessage!.text, 'hello');
      expect(chat.lastMessage!.senderId, tourist);

      expect(cubit.state.chat!.id, chatId);
      expect(cubit.state.messages, hasLength(1));
      expect(cubit.state.messages.single.text, 'hello');
      expect(cubit.state.isSending, isFalse);
    });

    test('a guide cannot start a chat', () async {
      await cubit.close();
      repository = FakeChatRepository(
        currentUserId: guide,
        roles: <String, String>{guide: 'guide'},
        clock: () => now,
      );
      cubit = ChatRoomCubit(
        repository: repository,
        guideId: tourist,
        guideName: 'Tourist',
        clock: () => now,
      );

      await cubit.sendMessage('hello');

      expect(repository.chats, isEmpty);
      expect(cubit.chatId, isNull);
      expect(cubit.state.isReadOnly, isTrue);
      expect(cubit.state.actionError, 'Only tourists can start a chat.');
      expect(cubit.state.isSending, isFalse);
    });

    test('reuses an existing chat instead of creating a duplicate', () async {
      repository.seedChat(baseChat());
      repository.seedMessages(chatId, <ChatMessage>[
        message('m1', senderId: tourist, text: 'first'),
      ]);

      await cubit.close();
      cubit = ChatRoomCubit(
        repository: repository,
        guideId: guide,
        guideName: 'Guide',
        clock: () => now,
      );

      await cubit.sendMessage('second');

      expect(repository.chats, hasLength(1));
      expect(repository.messages[chatId], hasLength(2));
      expect(cubit.chatId, chatId);
    });

    test('empty text is rejected by the repository contract', () async {
      await loadExisting();

      await cubit.sendMessage('   ');

      expect(cubit.state.actionError, 'Write a message first.');
      expect(cubit.state.isSending, isFalse);
      expect(cubit.state.isReadOnly, isFalse);
    });
  });

  group('sending', () {
    test('bumps only the recipient unread counter', () async {
      await loadExisting();

      await cubit.sendMessage('hi guide');

      final chat = repository.chats[chatId]!;
      expect(chat.unreadFor(guide), 1);
      expect(chat.unreadFor(tourist), 0);
      expect(cubit.state.isSending, isFalse);
    });

    test('stores a preview capped at 120 characters', () async {
      await loadExisting();

      await cubit.sendMessage('a' * 150);
      await pumpEventQueue();

      expect(repository.chats[chatId]!.lastMessage!.text, 'a' * 120);
      expect(cubit.state.messages.single.text, 'a' * 150);
    });

    test('a permission denial turns the room read-only', () async {
      await loadExisting();
      repository.sendError = const ChatPermissionException();

      await cubit.sendMessage('hi');

      expect(cubit.state.isReadOnly, isTrue);
      expect(cubit.state.actionError, isNotNull);
      expect(cubit.state.isSending, isFalse);
    });

    test('an ordinary failure does not make the room read-only', () async {
      await loadExisting();
      repository.sendError = const ChatException('Network down.');

      await cubit.sendMessage('hi');

      expect(cubit.state.isReadOnly, isFalse);
      expect(cubit.state.actionError, 'Network down.');
    });
  });

  group('load', () {
    test('needs a chat id or a guide id', () async {
      await cubit.load();

      expect(cubit.state.error, 'This chat is not available.');
      expect(cubit.state.isLoading, isFalse);
    });

    test('reads the chat, its messages and the typing markers', () async {
      final created = now.subtract(const Duration(minutes: 5));
      await loadExisting(
        messages: <ChatMessage>[
          message('m1', senderId: tourist, text: 'one', createdAt: created),
        ],
      );
      repository.typing[guide] = now;
      repository.notify();
      await pumpEventQueue();

      expect(cubit.state.chat!.id, chatId);
      expect(cubit.state.messages.single.text, 'one');
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.isReadOnly, isFalse);
      expect(cubit.isOtherTyping, isTrue);
    });

    test('does not mark the room read-only for a missing chat', () async {
      await cubit.close();
      cubit = ChatRoomCubit(
        repository: repository,
        chatId: 'missing_chat',
        clock: () => now,
      );

      await cubit.load();

      expect(cubit.state.chat, isNull);
      expect(cubit.state.messages, isEmpty);
      expect(cubit.state.isReadOnly, isFalse);
    });
  });

  group('markRead', () {
    test('clears only my unread counter and moves my read marker', () async {
      repository.seedChat(
        baseChat(unread: <String, int>{tourist: 2, guide: 5}),
      );
      repository.seedMessages(chatId, <ChatMessage>[]);
      await cubit.close();
      cubit = ChatRoomCubit(
        repository: repository,
        chatId: chatId,
        clock: () => now,
      );
      await cubit.load();

      await cubit.markRead();

      final chat = repository.chats[chatId]!;
      expect(chat.unreadFor(tourist), 0);
      expect(chat.unreadFor(guide), 5);
      expect(chat.lastReadOf(tourist), now);
      expect(chat.lastReadOf(guide), isNull);
    });

    test('a failure is surfaced as an action error', () async {
      await loadExisting();
      repository.markReadError = const ChatPermissionException();

      await cubit.markRead();

      expect(cubit.state.isReadOnly, isTrue);
      expect(cubit.state.actionError, isNotNull);
    });
  });

  group('typing', () {
    test('writes at most once per three seconds', () async {
      await loadExisting();

      await cubit.notifyTyping();
      await cubit.notifyTyping();
      expect(repository.typingWrites, 1);

      now = now.add(const Duration(seconds: 3));
      await cubit.notifyTyping();
      expect(repository.typingWrites, 2);
    });

    test('does nothing before the chat exists', () async {
      await cubit.close();
      cubit = ChatRoomCubit(
        repository: repository,
        guideId: guide,
        clock: () => now,
      );

      await cubit.notifyTyping();

      expect(repository.typingWrites, 0);
    });
  });

  group('pagination', () {
    test('loads 30 messages, then the older page', () async {
      final base = now.subtract(const Duration(hours: 2));
      final all = <ChatMessage>[
        for (var i = 0; i < 45; i++)
          message(
            'm$i',
            senderId: tourist,
            text: 'message $i',
            createdAt: base.add(Duration(minutes: i)),
          ),
      ];
      await loadExisting(messages: all);

      expect(cubit.state.messages, hasLength(30));
      expect(cubit.state.messages.first.id, 'm44');
      expect(cubit.state.messages.last.id, 'm15');
      expect(cubit.state.hasMore, isTrue);

      await cubit.loadMore();

      expect(cubit.state.messages, hasLength(45));
      expect(cubit.state.messages.last.id, 'm0');
      expect(cubit.state.hasMore, isFalse);
      expect(cubit.state.isLoadingMore, isFalse);
    });

    test('does nothing when the first page is short', () async {
      await loadExisting(
        messages: <ChatMessage>[message('m1', senderId: tourist, text: 'only')],
      );

      await cubit.loadMore();

      expect(cubit.state.messages, hasLength(1));
      expect(cubit.state.hasMore, isFalse);
    });
  });

  group('read receipts', () {
    test('uses the other participant read marker', () async {
      final readAt = now.subtract(const Duration(minutes: 10));
      repository.seedChat(
        baseChat(lastReadAt: <String, DateTime>{guide: readAt}),
      );
      repository.seedMessages(chatId, <ChatMessage>[
        message(
          'read',
          senderId: tourist,
          text: 'read',
          createdAt: readAt.subtract(const Duration(minutes: 1)),
        ),
        message(
          'unread',
          senderId: tourist,
          text: 'unread',
          createdAt: readAt.add(const Duration(minutes: 1)),
        ),
        message(
          'theirs',
          senderId: guide,
          text: 'theirs',
          createdAt: readAt.subtract(const Duration(minutes: 2)),
        ),
      ]);
      await cubit.close();
      cubit = ChatRoomCubit(
        repository: repository,
        chatId: chatId,
        clock: () => now,
      );
      await cubit.load();

      expect(cubit.otherLastReadAt, readAt);
      final byId = <String, ChatMessage>{
        for (final item in cubit.state.messages) item.id: item,
      };
      expect(cubit.isReadByOther(byId['read']!), isTrue);
      expect(cubit.isReadByOther(byId['unread']!), isFalse);
      expect(cubit.isReadByOther(byId['theirs']!), isFalse);
    });
  });

  group('edit and delete', () {
    test('edits my own message inside the window', () async {
      await loadExisting(
        messages: <ChatMessage>[message('m1', senderId: tourist, text: 'old')],
      );

      await cubit.editMessage(messageId: 'm1', text: 'new');

      final edited = repository.messages[chatId]!.single;
      expect(edited.text, 'new');
      expect(edited.isEdited, isTrue);
      expect(cubit.state.isEditing, isFalse);
      expect(cubit.state.actionError, isNull);
    });

    test('rejects editing the other participant message', () async {
      await loadExisting(
        messages: <ChatMessage>[message('m1', senderId: guide, text: 'theirs')],
      );

      await cubit.editMessage(messageId: 'm1', text: 'mine now');

      expect(repository.messages[chatId]!.single.text, 'theirs');
      expect(cubit.state.actionError, isNotNull);
      expect(cubit.state.isReadOnly, isFalse);
    });

    test('rejects editing after 24 hours', () async {
      await loadExisting(
        messages: <ChatMessage>[
          message(
            'm1',
            senderId: tourist,
            text: 'old',
            createdAt: now.subtract(const Duration(hours: 25)),
          ),
        ],
      );

      await cubit.editMessage(messageId: 'm1', text: 'new');

      expect(repository.messages[chatId]!.single.text, 'old');
      expect(cubit.state.actionError, isNotNull);
    });

    test('deletes my own message', () async {
      await loadExisting(
        messages: <ChatMessage>[
          message('m1', senderId: tourist, text: 'gone soon'),
          message('m2', senderId: guide, text: 'keep'),
        ],
      );

      await cubit.deleteMessage('m1');

      expect(repository.messages[chatId]!.map((item) => item.id), <String>[
        'm2',
      ]);
      expect(cubit.state.isDeleting, isFalse);
    });
  });

  group('report', () {
    test(
      'reports the other participant message with copied evidence',
      () async {
        final sentAt = now.subtract(const Duration(minutes: 3));
        await loadExisting(
          messages: <ChatMessage>[
            message(
              'm1',
              senderId: guide,
              text: 'bad words',
              createdAt: sentAt,
            ),
          ],
        );
        final target = repository.messages[chatId]!.single;

        await cubit.reportMessage(
          message: target,
          reasonCode: 'harassment',
          note: '  please review  ',
        );

        final report = repository.reports.single;
        expect(report.id, 't1_m1');
        expect(report.reporterId, tourist);
        expect(report.reportedUserId, guide);
        expect(report.chatId, chatId);
        expect(report.messageId, 'm1');
        expect(report.text, 'bad words');
        expect(report.messageCreatedAt, sentAt);
        expect(report.reasonCode, 'harassment');
        expect(report.note, 'please review');
        expect(report.status, 'open');
        expect(cubit.state.isReporting, isFalse);
      },
    );

    test('refuses to report my own message', () async {
      await loadExisting(
        messages: <ChatMessage>[message('m1', senderId: tourist, text: 'mine')],
      );
      final target = repository.messages[chatId]!.single;

      await cubit.reportMessage(message: target, reasonCode: 'spam');

      expect(repository.reports, isEmpty);
      expect(cubit.state.actionError, isNotNull);
      expect(cubit.state.isReporting, isFalse);
    });

    test('refuses an unknown reason code', () async {
      await loadExisting(
        messages: <ChatMessage>[message('m1', senderId: guide, text: 'theirs')],
      );
      final target = repository.messages[chatId]!.single;

      await cubit.reportMessage(message: target, reasonCode: 'bogus');

      expect(repository.reports, isEmpty);
      expect(cubit.state.actionError, isNotNull);
    });
  });

  group('profile', () {
    test('writes only my own profile entry', () async {
      await loadExisting();

      await cubit.updateMyProfile(
        displayName: 'New Name',
        avatarUrl: 'https://new',
      );

      final chat = repository.chats[chatId]!;
      expect(chat.profileOf(tourist).displayName, 'New Name');
      expect(chat.profileOf(tourist).avatarUrl, 'https://new');
      expect(chat.profileOf(guide).displayName, 'Guide');
    });
  });

  group('state', () {
    test('copyWith keeps the unset fields and clears errors on demand', () {
      const state = ChatRoomState();
      final failed = state.copyWith(actionError: 'boom', isSending: true);
      final cleared = failed.copyWith(isSending: false, actionError: null);

      expect(failed.actionError, 'boom');
      expect(cleared.actionError, isNull);
      expect(cleared.isSending, isFalse);
      expect(cleared.messages, isEmpty);
    });
  });
}
