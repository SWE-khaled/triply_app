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

  ChatRoomSuccess successOf(ChatRoomCubit value) {
    expect(value.state, isA<ChatRoomSuccess>());
    return value.state as ChatRoomSuccess;
  }

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

      final state = successOf(cubit);
      expect(state.chat!.id, chatId);
      expect(state.messages, hasLength(1));
      expect(state.messages.single.text, 'hello');
      expect(state.isSending, isFalse);
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

      final state = successOf(cubit);
      expect(repository.chats, isEmpty);
      expect(cubit.chatId, isNull);
      expect(state.isReadOnly, isTrue);
      expect(state.actionError, 'Only tourists can start a chat.');
      expect(state.isSending, isFalse);
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

      final state = successOf(cubit);
      expect(state.actionError, 'Write a message first.');
      expect(state.isSending, isFalse);
      expect(state.isReadOnly, isFalse);
    });
  });

  group('sending', () {
    test('bumps only the recipient unread counter', () async {
      await loadExisting();

      await cubit.sendMessage('hi guide');

      final chat = repository.chats[chatId]!;
      expect(chat.unreadFor(guide), 1);
      expect(chat.unreadFor(tourist), 0);
      expect(successOf(cubit).isSending, isFalse);
    });

    test('stores a preview capped at 120 characters', () async {
      await loadExisting();

      await cubit.sendMessage('a' * 150);
      await pumpEventQueue();

      expect(repository.chats[chatId]!.lastMessage!.text, 'a' * 120);
      expect(successOf(cubit).messages.single.text, 'a' * 150);
    });

    test('a permission denial turns the room read-only', () async {
      await loadExisting();
      repository.sendError = const ChatPermissionException();

      await cubit.sendMessage('hi');

      final state = successOf(cubit);
      expect(state.isReadOnly, isTrue);
      expect(state.actionError, isNotNull);
      expect(state.isSending, isFalse);
    });

    test('an ordinary failure does not make the room read-only', () async {
      await loadExisting();
      repository.sendError = const ChatException('Network down.');

      await cubit.sendMessage('hi');

      final state = successOf(cubit);
      expect(state.isReadOnly, isFalse);
      expect(state.actionError, 'Network down.');
    });
  });

  group('load', () {
    test('needs a chat id or a guide id', () async {
      await cubit.load();

      final state = cubit.state;
      expect(state, isA<ChatRoomError>());
      expect((state as ChatRoomError).error, 'This chat is not available.');
      expect(state.isReadOnly, isFalse);
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

      final state = successOf(cubit);
      expect(state.chat!.id, chatId);
      expect(state.messages.single.text, 'one');
      expect(state.isReadOnly, isFalse);
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

      final state = successOf(cubit);
      expect(state.chat, isNull);
      expect(state.messages, isEmpty);
      expect(state.isReadOnly, isFalse);
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

      final state = successOf(cubit);
      expect(state.isReadOnly, isTrue);
      expect(state.actionError, isNotNull);
    });

    test('opening a room with an inbound message clears the badge', () async {
      repository.seedChat(
        baseChat(unread: <String, int>{tourist: 2, guide: 0}),
      );
      repository.seedMessages(chatId, <ChatMessage>[
        message('m1', senderId: guide, text: 'inbound'),
      ]);
      await cubit.close();
      cubit = ChatRoomCubit(
        repository: repository,
        chatId: chatId,
        clock: () => now,
      );

      await cubit.load();
      await pumpEventQueue();

      expect(repository.chats[chatId]!.unreadFor(tourist), 0);
      expect(repository.chats[chatId]!.lastReadOf(tourist), now);
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

      final firstPage = successOf(cubit);
      expect(firstPage.messages, hasLength(30));
      expect(firstPage.messages.first.id, 'm44');
      expect(firstPage.messages.last.id, 'm15');
      expect(firstPage.hasMore, isTrue);

      await cubit.loadMore();

      final loaded = successOf(cubit);
      expect(loaded.messages, hasLength(45));
      expect(loaded.messages.last.id, 'm0');
      expect(loaded.hasMore, isFalse);
      expect(loaded.isLoadingMore, isFalse);
    });

    test('does nothing when the first page is short', () async {
      await loadExisting(
        messages: <ChatMessage>[message('m1', senderId: tourist, text: 'only')],
      );

      await cubit.loadMore();

      final state = successOf(cubit);
      expect(state.messages, hasLength(1));
      expect(state.hasMore, isFalse);
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
        for (final item in successOf(cubit).messages) item.id: item,
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
      final state = successOf(cubit);
      expect(state.isEditing, isFalse);
      expect(state.actionError, isNull);
    });

    test('rejects editing the other participant message', () async {
      await loadExisting(
        messages: <ChatMessage>[message('m1', senderId: guide, text: 'theirs')],
      );

      await cubit.editMessage(messageId: 'm1', text: 'mine now');

      expect(repository.messages[chatId]!.single.text, 'theirs');
      final state = successOf(cubit);
      expect(state.actionError, isNotNull);
      expect(state.isReadOnly, isFalse);
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
      expect(successOf(cubit).actionError, isNotNull);
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
      expect(successOf(cubit).isDeleting, isFalse);
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
        expect(successOf(cubit).isReporting, isFalse);
      },
    );

    test('refuses to report my own message', () async {
      await loadExisting(
        messages: <ChatMessage>[message('m1', senderId: tourist, text: 'mine')],
      );
      final target = repository.messages[chatId]!.single;

      await cubit.reportMessage(message: target, reasonCode: 'spam');

      expect(repository.reports, isEmpty);
      final state = successOf(cubit);
      expect(state.actionError, isNotNull);
      expect(state.isReporting, isFalse);
    });

    test('refuses an unknown reason code', () async {
      await loadExisting(
        messages: <ChatMessage>[message('m1', senderId: guide, text: 'theirs')],
      );
      final target = repository.messages[chatId]!.single;

      await cubit.reportMessage(message: target, reasonCode: 'bogus');

      expect(repository.reports, isEmpty);
      expect(successOf(cubit).actionError, isNotNull);
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
    test('the success state is immutable and carries the flags', () {
      const state = ChatRoomSuccess(
        isReadOnly: true,
        isSending: true,
        actionError: 'boom',
      );

      expect(state.isReadOnly, isTrue);
      expect(state.isSending, isTrue);
      expect(state.isBusy, isTrue);
      expect(state.actionError, 'boom');
      expect(state.messages, isEmpty);
    });

    test('the error state carries the read-only marker', () {
      const state = ChatRoomError('denied', isReadOnly: true);

      expect(state.error, 'denied');
      expect(state.isReadOnly, isTrue);
    });
  });
}
