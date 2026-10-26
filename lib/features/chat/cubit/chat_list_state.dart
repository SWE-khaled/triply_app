import 'package:triply/core/data/models/chat.dart';

/// The state of the conversation list.
///
/// Every phase is a distinct class (no `copyWith`): the screen switches on
/// the state and never has to guess which fields are meaningful.
sealed class ChatListState {
  const ChatListState();
}

/// Nothing has been requested yet.
final class ChatListInitial extends ChatListState {
  const ChatListInitial();
}

/// The first snapshot is being read.
final class ChatListLoading extends ChatListState {
  const ChatListLoading();
}

/// The list is live and searchable.
final class ChatListSuccess extends ChatListState {
  final List<Chat> chats;

  /// Sum of `unreadCount[me]` across [chats].
  final int totalUnread;

  final String searchQuery;

  /// When true only conversations with unread messages are listed.
  final bool unreadOnly;

  const ChatListSuccess({
    this.chats = const <Chat>[],
    this.totalUnread = 0,
    this.searchQuery = '',
    this.unreadOnly = false,
  });

  bool get hasAnyUnread => totalUnread > 0;

  /// Chats matching the search and the unread filter.
  List<Chat> visibleChats(String? myUserId) {
    final query = searchQuery.trim().toLowerCase();
    return chats
        .where((chat) {
          if (unreadOnly && chat.unreadFor(myUserId ?? '') == 0) {
            return false;
          }
          if (query.isEmpty || myUserId == null || myUserId.isEmpty) {
            return true;
          }
          final other = chat.otherUserId(myUserId);
          final name = chat.profileOf(other).displayName.toLowerCase();
          final preview = chat.previewText.toLowerCase();
          return name.contains(query) || preview.contains(query);
        })
        .toList(growable: false);
  }
}

/// The list could not be read (signed out, rules, network).
final class ChatListError extends ChatListState {
  final String error;

  const ChatListError(this.error);
}
