import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:triply/core/data/models/chat.dart';
import 'package:triply/core/data/models/chat_message.dart';
import 'package:triply/core/data/models/chat_profile.dart';
import 'package:triply/core/data/repositories/chat_repository.dart';
import 'package:triply/features/chat/model/chat_audience.dart';
import 'package:triply/features/chat/view/chat_list_screen.dart';
import 'package:triply/features/chat/view/chat_room_screen.dart';
import 'package:triply/features/chat/widgets/message_guide_button.dart';

import '../fakes/fake_chat_repository.dart';

const String touristId = 'tourist-1';
const String guideId = 'guide-1';

DateTime get _now => DateTime(2026, 10, 27, 18, 30);

Chat _chat({
  int unreadForTourist = 0,
  DateTime? guideReadAt,
  String lastText = 'Welcome to Cairo',
  String lastSenderId = guideId,
  DateTime? lastAt,
}) {
  final at = lastAt ?? _now.subtract(const Duration(minutes: 5));
  return Chat(
    id: ChatIds.canonical(touristId, guideId),
    touristId: touristId,
    guideId: guideId,
    participants: const <String>[touristId, guideId],
    profiles: const <String, ChatProfile>{
      touristId: ChatProfile(displayName: 'Sara Tourist'),
      guideId: ChatProfile(displayName: 'Omar Guide'),
    },
    lastMessage: ChatLastMessage(
      text: lastText,
      senderId: lastSenderId,
      createdAt: at,
    ),
    lastMessageAt: at,
    unreadCount: <String, int>{touristId: unreadForTourist, guideId: 0},
    lastReadAt: <String, DateTime>{guideId: ?guideReadAt},
    createdAt: _now.subtract(const Duration(days: 1)),
  );
}

FakeChatRepository _repository() => FakeChatRepository(
  currentUserId: touristId,
  clock: () => _now,
  touristName: 'Sara Tourist',
);

Future<void> _pumpList(
  WidgetTester tester,
  FakeChatRepository repository, {
  ChatAudience audience = ChatAudience.tourist,
  bool showGuideNav = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ChatListScreen(
        repository: repository,
        audience: audience,
        showGuideNav: showGuideNav,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpRoom(
  WidgetTester tester,
  FakeChatRepository repository, {
  String? chatId,
  String? guideIdValue,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ChatRoomScreen(
        repository: repository,
        chatId: chatId,
        guideId: guideIdValue,
        guideName: 'Omar Guide',
        fallbackName: 'Omar Guide',
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('chat list', () {
    testWidgets('shows the empty state and no invented conversations', (
      tester,
    ) async {
      final repository = _repository();
      addTearDown(repository.dispose);

      await _pumpList(tester, repository);

      expect(find.byKey(const Key('chat-empty-state')), findsOneWidget);
      expect(find.text('No conversations found'), findsOneWidget);
      expect(
        find.text('Open a guide profile and send the first message.'),
        findsOneWidget,
      );
      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('renders a real repository chat with its unread count', (
      tester,
    ) async {
      final repository = _repository();
      addTearDown(repository.dispose);
      repository.seedChat(_chat(unreadForTourist: 2));

      await _pumpList(tester, repository);

      expect(
        find.byKey(ValueKey<String>('chat-tile-${_chat().id}')),
        findsOneWidget,
      );
      expect(find.text('Omar Guide'), findsOneWidget);
      expect(find.text('Welcome to Cairo'), findsOneWidget);
      expect(find.text('Unread (2)'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('guide list keeps its four tabs and unread badge', (
      tester,
    ) async {
      final repository = _repository();
      addTearDown(repository.dispose);
      repository.seedChat(_chat(unreadForTourist: 1));

      await _pumpList(
        tester,
        repository,
        audience: ChatAudience.guide,
        showGuideNav: true,
      );

      expect(find.text('Chats'), findsNWidgets(2)); // header + tab
      expect(find.text('My Trips'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.byKey(const Key('guide-nav-chat-badge')), findsOneWidget);

      final chatIcon = tester.getRect(find.byIcon(Icons.chat_bubble_outline));
      final navItem = tester.getRect(
        find.ancestor(
          of: find.byIcon(Icons.chat_bubble_outline),
          matching: find.byType(AnimatedContainer),
        ),
      );
      expect(chatIcon.center.dx, closeTo(navItem.center.dx, 0.1));
      expect(chatIcon.center.dy, closeTo(navItem.center.dy, 0.1));
    });

    testWidgets('searching without a match shows the no-result copy', (
      tester,
    ) async {
      final repository = _repository();
      addTearDown(repository.dispose);
      repository.seedChat(_chat());

      await _pumpList(tester, repository);
      await tester.enterText(
        find.byKey(const Key('chat-list-search')),
        'nothing matches this',
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('chat-empty-state')), findsOneWidget);
      expect(find.text('No conversations found'), findsOneWidget);
      expect(find.text('Try another guide or trip name.'), findsOneWidget);
    });
  });

  group('chat room', () {
    testWidgets('shows live messages, edited label and seen receipt', (
      tester,
    ) async {
      final repository = _repository();
      addTearDown(repository.dispose);
      final chat = _chat(guideReadAt: _now);
      repository.seedChat(chat);
      repository.seedMessages(chat.id, <ChatMessage>[
        ChatMessage(
          id: 'm1',
          senderId: touristId,
          text: 'Hello Omar',
          createdAt: _now.subtract(const Duration(minutes: 10)),
          editedAt: _now.subtract(const Duration(minutes: 9)),
        ),
        ChatMessage(
          id: 'm2',
          senderId: guideId,
          text: 'Welcome to Cairo',
          createdAt: _now.subtract(const Duration(minutes: 5)),
        ),
      ]);

      await _pumpRoom(tester, repository, chatId: chat.id);

      expect(find.text('Hello Omar'), findsOneWidget);
      expect(find.text('Welcome to Cairo'), findsOneWidget);
      expect(find.text('edited'), findsOneWidget);
      expect(find.text('Seen'), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('chat-message-m1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('chat-message-m2')),
        findsOneWidget,
      );
    });

    testWidgets('a denied write turns the room read-only', (tester) async {
      final repository = _repository();
      addTearDown(repository.dispose);
      final chat = _chat();
      repository.seedChat(chat);
      repository.seedMessages(chat.id, <ChatMessage>[
        ChatMessage(
          id: 'm1',
          senderId: guideId,
          text: 'Are you still interested?',
          createdAt: _now.subtract(const Duration(minutes: 5)),
        ),
      ]);
      repository.sendError = const ChatPermissionException();

      await _pumpRoom(tester, repository, chatId: chat.id);
      await tester.enterText(
        find.byKey(const Key('chat-message-input')),
        'Yes, I am',
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('chat-send-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('chat-read-only-banner')), findsOneWidget);
      expect(find.byKey(const Key('chat-action-error')), findsOneWidget);
      expect(find.byKey(const Key('chat-message-input')), findsNothing);
    });

    testWidgets('opens an empty new-chat room without creating a document', (
      tester,
    ) async {
      final repository = _repository();
      addTearDown(repository.dispose);

      await _pumpRoom(tester, repository, guideIdValue: guideId);

      expect(find.byKey(const Key('chat-empty-room')), findsOneWidget);
      expect(repository.chats, isEmpty);
      expect(find.byKey(const Key('chat-message-input')), findsOneWidget);
    });
  });

  group('message entry point', () {
    testWidgets('is visible to tourists only', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MessageGuideButton(
              guideId: guideId,
              guideName: 'Omar Guide',
              isTourist: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(MessageGuideButton.buttonKey), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MessageGuideButton(
              guideId: guideId,
              guideName: 'Omar Guide',
              isTourist: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(MessageGuideButton.buttonKey), findsNothing);
    });
  });
}
