import 'package:triply/core/data/models/chat.dart';

const Object _unsetChatListError = Object();

/// The chat list and its total unread badge.
class ChatListState {
  final List<Chat> chats;

  /// Sum of `unreadCount[me]` across [chats].
  final int totalUnread;

  final bool isLoading;
  final bool isLoaded;
  final String searchQuery;

  /// A list-level failure (sign-in, rules, network).
  final String? error;

  const ChatListState({
    this.chats = const <Chat>[],
    this.totalUnread = 0,
    this.isLoading = false,
    this.isLoaded = false,
    this.searchQuery = '',
    this.error,
  });

  /// Chats matching [searchQuery] by the other participant's name or the
  /// last-message preview.
  List<Chat> visibleChats(String? myUserId) {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty || myUserId == null || myUserId.isEmpty) {
      return chats;
    }
    return chats
        .where((chat) {
          final other = chat.otherUserId(myUserId);
          final name = chat.profileOf(other).displayName.toLowerCase();
          final preview = chat.previewText.toLowerCase();
          return name.contains(query) || preview.contains(query);
        })
        .toList(growable: false);
  }

  ChatListState copyWith({
    List<Chat>? chats,
    int? totalUnread,
    bool? isLoading,
    bool? isLoaded,
    String? searchQuery,
    Object? error = _unsetChatListError,
  }) {
    return ChatListState(
      chats: chats ?? this.chats,
      totalUnread: totalUnread ?? this.totalUnread,
      isLoading: isLoading ?? this.isLoading,
      isLoaded: isLoaded ?? this.isLoaded,
      searchQuery: searchQuery ?? this.searchQuery,
      error: identical(error, _unsetChatListError)
          ? this.error
          : error as String?,
    );
  }
}
