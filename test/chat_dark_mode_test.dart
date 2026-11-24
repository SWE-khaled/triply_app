import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/data/models/chat.dart';
import 'package:triply/core/data/models/chat_message.dart';
import 'package:triply/core/data/models/chat_profile.dart';
import 'package:triply/core/data/repositories/chat_repository.dart';
import 'package:triply/core/theme/app_colors.dart';
import 'package:triply/core/theme/app_theme_dark.dart';
import 'package:triply/features/chat/view/chat_list_screen.dart';
import 'package:triply/features/chat/view/chat_room_screen.dart';

void main() {
  testWidgets('Chat list supports dark mode without changing light colors', (
    tester,
  ) async {
    final repository = _FakeChatRepository();

    await tester.pumpWidget(_chatListApp(ThemeMode.dark, repository));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      AppThemeDark.backgroundPrimary,
    );
    expect(
      tester.widget<Text>(find.text('Messages')).style?.color,
      AppThemeDark.homeSectionTitle,
    );
    expect(
      tester.widget<Text>(find.text('No conversations found')).style?.color,
      AppThemeDark.homeSectionTitle,
    );

    await tester.pumpWidget(_chatListApp(ThemeMode.light, repository));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      Colors.white,
    );
    expect(
      tester.widget<Text>(find.text('Messages')).style?.color,
      AppColors.title,
    );
    expect(
      tester.widget<Text>(find.text('No conversations found')).style?.color,
      AppColors.title,
    );
  });

  testWidgets('Chat room bubbles and composer adapt to both themes', (
    tester,
  ) async {
    final repository = _FakeChatRepository();

    await tester.pumpWidget(_chatRoomApp(ThemeMode.dark, repository));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      AppThemeDark.backgroundPrimary,
    );
    expect(
      tester.widget<Text>(find.text('Guide')).style?.color,
      AppThemeDark.homeSectionTitle,
    );
    expect(
      tester.widget<Text>(find.text('A message from the guide')).style?.color,
      AppThemeDark.textPrimary,
    );
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('chat-message-input')))
          .decoration
          ?.fillColor,
      AppThemeDark.backgroundSecondary,
    );

    await tester.pumpWidget(_chatRoomApp(ThemeMode.light, repository));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      AppColors.pageBackground,
    );
    expect(
      tester.widget<Text>(find.text('Guide')).style?.color,
      AppColors.title,
    );
    expect(
      tester.widget<Text>(find.text('A message from the guide')).style?.color,
      AppColors.textDark,
    );
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('chat-message-input')))
          .decoration
          ?.fillColor,
      AppColors.searchBg,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}

Widget _chatListApp(ThemeMode mode, ChatRepository repository) {
  return MaterialApp(
    theme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
    themeMode: mode,
    home: ChatListScreen(repository: repository),
  );
}

Widget _chatRoomApp(ThemeMode mode, ChatRepository repository) {
  return MaterialApp(
    theme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
    themeMode: mode,
    home: ChatRoomScreen(repository: repository, chatId: 'chat-1'),
  );
}

class _FakeChatRepository implements ChatRepository {
  static const _currentUserId = 'tourist-1';
  static final _createdAt = DateTime(2026, 1, 2, 12);

  static const _chat = Chat(
    id: 'chat-1',
    touristId: _currentUserId,
    guideId: 'guide-1',
    participants: [_currentUserId, 'guide-1'],
    profiles: {'guide-1': ChatProfile(displayName: 'Guide')},
  );

  static final _messages = [
    ChatMessage(
      id: 'message-2',
      senderId: _currentUserId,
      text: 'A message from the tourist',
      createdAt: _createdAt,
    ),
    ChatMessage(
      id: 'message-1',
      senderId: 'guide-1',
      text: 'A message from the guide',
      createdAt: _createdAt.subtract(const Duration(minutes: 1)),
    ),
  ];

  @override
  String? get currentUserId => _currentUserId;

  @override
  Stream<List<Chat>> watchChats(String userId) => Stream.value(const []);

  @override
  Stream<Chat?> watchChat(String chatId) => Stream.value(_chat);

  @override
  Stream<List<ChatMessage>> watchMessages(String chatId, {int limit = 30}) =>
      Stream.value(_messages);

  @override
  Stream<Set<String>> watchTyping(String chatId) => Stream.value(const {});

  @override
  Future<void> markRead(String chatId) async {}

  @override
  Future<void> updateMyProfile({
    required String chatId,
    String? displayName,
    String? avatarUrl,
  }) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
