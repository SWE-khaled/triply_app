import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/data/models/chat.dart';
import 'package:triply/core/data/models/chat_profile.dart';
import 'package:triply/features/chat/cubit/chat_list_cubit.dart';
import 'package:triply/features/chat/cubit/chat_list_state.dart';

import '../fakes/fake_chat_repository.dart';

/// The list cubit turns the chat documents into the list the screen
/// shows: newest first, the sum of the signed-in user's unread counters
/// as the badge, and a search over the other participant's name and the
/// last-message preview.
void main() {
  const tourist = 't1';
  const guideOne = 'g1';
  const guideTwo = 'g2';

  late FakeChatRepository repository;
  late ChatListCubit cubit;

  final newer = DateTime.utc(2026, 10, 8, 12);
  final older = DateTime.utc(2026, 10, 7, 12);

  Chat chatFor({
    required String guideId,
    required String guideName,
    required String lastText,
    required DateTime lastAt,
    int unread = 0,
  }) {
    return Chat(
      id: ChatIds.canonical(tourist, guideId),
      touristId: tourist,
      guideId: guideId,
      participants: <String>[tourist, guideId],
      profiles: <String, ChatProfile>{
        tourist: const ChatProfile(displayName: 'Tourist'),
        guideId: ChatProfile(displayName: guideName),
      },
      lastMessage: ChatLastMessage(
        text: lastText,
        senderId: guideId,
        createdAt: lastAt,
      ),
      lastMessageAt: lastAt,
      unreadCount: <String, int>{tourist: unread},
    );
  }

  setUp(() {
    repository = FakeChatRepository(currentUserId: tourist, clock: () => newer);
    cubit = ChatListCubit(repository: repository);
  });

  tearDown(() async {
    await cubit.close();
    await repository.dispose();
  });

  group('load', () {
    test('exposes the chats and the total unread badge', () async {
      repository.seedChat(
        chatFor(
          guideId: guideOne,
          guideName: 'Guide One',
          lastText: 'Hello from one',
          lastAt: newer,
          unread: 2,
        ),
      );
      repository.seedChat(
        chatFor(
          guideId: guideTwo,
          guideName: 'Guide Two',
          lastText: 'Hello from two',
          lastAt: older,
          unread: 3,
        ),
      );

      await cubit.load();

      expect(cubit.state.isLoaded, isTrue);
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.chats, hasLength(2));
      expect(cubit.state.totalUnread, 5);
    });

    test('sorts by the newest activity, not by creation', () async {
      repository.seedChat(
        chatFor(
          guideId: guideOne,
          guideName: 'Guide One',
          lastText: 'Older',
          lastAt: older,
        ),
      );
      repository.seedChat(
        chatFor(
          guideId: guideTwo,
          guideName: 'Guide Two',
          lastText: 'Newer',
          lastAt: newer,
        ),
      );

      await cubit.load();

      expect(cubit.state.chats.map((chat) => chat.guideId).toList(), [
        guideTwo,
        guideOne,
      ]);
    });

    test('leaves out chats the user does not participate in', () async {
      repository.seedChat(
        chatFor(
          guideId: guideOne,
          guideName: 'Guide One',
          lastText: 'Mine',
          lastAt: newer,
        ),
      );
      // Another pair, nothing to do with the signed-in tourist.
      repository.seedChat(
        const Chat(
          id: 'g2_t2',
          touristId: 't2',
          guideId: guideTwo,
          participants: <String>['t2', guideTwo],
        ),
      );

      await cubit.load();

      expect(cubit.state.chats, hasLength(1));
      expect(cubit.state.chats.single.guideId, guideOne);
      expect(cubit.state.totalUnread, 0);
    });

    test('reports a signed-out user instead of watching chats', () async {
      final signedOut = FakeChatRepository(currentUserId: null);
      final signedOutCubit = ChatListCubit(repository: signedOut);

      await signedOutCubit.load();

      expect(signedOutCubit.state.isLoaded, isTrue);
      expect(signedOutCubit.state.chats, isEmpty);
      expect(signedOutCubit.state.error, 'Sign in to see your chats.');

      await signedOutCubit.close();
      await signedOut.dispose();
    });

    test('recomputes the badge when a chat changes', () async {
      repository.seedChat(
        chatFor(
          guideId: guideOne,
          guideName: 'Guide One',
          lastText: 'One',
          lastAt: newer,
          unread: 1,
        ),
      );

      await cubit.load();
      expect(cubit.state.totalUnread, 1);

      repository.seedChat(
        chatFor(
          guideId: guideOne,
          guideName: 'Guide One',
          lastText: 'One more',
          lastAt: newer,
          unread: 4,
        ),
      );
      await pumpEventQueue();

      expect(cubit.state.totalUnread, 4);
    });
  });

  group('search', () {
    setUp(() async {
      repository.seedChat(
        chatFor(
          guideId: guideOne,
          guideName: 'Guide One',
          lastText: 'The pyramids tour',
          lastAt: newer,
        ),
      );
      repository.seedChat(
        chatFor(
          guideId: guideTwo,
          guideName: 'Guide Two',
          lastText: 'Nile dinner',
          lastAt: older,
        ),
      );
      await cubit.load();
    });

    test('matches the other participant name, case-insensitively', () {
      cubit.setSearchQuery('guide TWO');

      expect(cubit.visibleChats.map((chat) => chat.guideId), [guideTwo]);
    });

    test('matches the last-message preview', () {
      cubit.setSearchQuery('pyramids');

      expect(cubit.visibleChats.map((chat) => chat.guideId), [guideOne]);
    });

    test('returns everything for an empty query', () {
      cubit.setSearchQuery('   ');

      expect(cubit.visibleChats, hasLength(2));
    });

    test('returns nothing for an unmatched query', () {
      cubit.setSearchQuery('nothing like this');

      expect(cubit.visibleChats, isEmpty);
    });
  });

  group('state', () {
    test('copyWith keeps the unset fields', () {
      const state = ChatListState(searchQuery: 'x', totalUnread: 2);
      final next = state.copyWith(isLoading: true);

      expect(next.searchQuery, 'x');
      expect(next.totalUnread, 2);
      expect(next.isLoading, isTrue);
    });

    test('copyWith clears the error explicitly', () {
      const state = ChatListState(error: 'boom');
      expect(state.copyWith(error: null).error, isNull);
    });
  });
}
