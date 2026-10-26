import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:triply/core/data/models/chat.dart';
import 'package:triply/core/data/repositories/chat_repository.dart';
import 'package:triply/core/utils/safe_emit_mixin.dart';

import 'chat_list_state.dart';

/// Watches the signed-in user's chats and keeps the total unread badge.
class ChatListCubit extends Cubit<ChatListState>
    with SafeEmitMixin<ChatListState> {
  ChatListCubit({required ChatRepository repository, String? userId})
    : _repository = repository,
      _userId = userId ?? repository.currentUserId,
      super(const ChatListInitial());

  final ChatRepository _repository;
  final String? _userId;

  StreamSubscription<List<Chat>>? _subscription;

  String? get userId => _userId;

  ChatListSuccess? get _success =>
      state is ChatListSuccess ? state as ChatListSuccess : null;

  /// The chats after the search and unread filters, ready for the list.
  List<Chat> get visibleChats =>
      _success?.visibleChats(_userId) ?? const <Chat>[];

  /// The badge value (sum of the caller's unread counters).
  int get totalUnread => _success?.totalUnread ?? 0;

  /// Subscribes to the chats. Awaiting the first snapshot keeps tests
  /// deterministic and gives the screen a loaded/error state.
  Future<void> load() async {
    if (state is ChatListLoading) return;

    final uid = _userId;
    if (uid == null || uid.isEmpty) {
      safeEmit(const ChatListError('Sign in to see your chats.'));
      return;
    }

    safeEmit(const ChatListLoading());
    await _subscription?.cancel();

    final first = Completer<void>();
    _subscription = _repository
        .watchChats(uid)
        .listen(
          (chats) {
            _onChats(uid, chats);
            if (!first.isCompleted) first.complete();
          },
          onError: (Object error) {
            _onError(error);
            if (!first.isCompleted) first.complete();
          },
        );
    await first.future;
  }

  void _onChats(String uid, List<Chat> chats) {
    final totalUnread = chats.fold<int>(
      0,
      (sum, chat) => sum + chat.unreadFor(uid),
    );
    final current = _success;
    safeEmit(
      ChatListSuccess(
        chats: chats,
        totalUnread: totalUnread,
        searchQuery: current?.searchQuery ?? '',
        unreadOnly: current?.unreadOnly ?? false,
      ),
    );
  }

  void _onError(Object error) {
    safeEmit(ChatListError(ChatErrors.map(error).toString()));
  }

  void setSearchQuery(String query) {
    final current = _success;
    if (current == null) return;
    safeEmit(
      ChatListSuccess(
        chats: current.chats,
        totalUnread: current.totalUnread,
        searchQuery: query,
        unreadOnly: current.unreadOnly,
      ),
    );
  }

  /// Switches between "All" and "Unread only".
  void setUnreadOnly(bool value) {
    final current = _success;
    if (current == null) return;
    safeEmit(
      ChatListSuccess(
        chats: current.chats,
        totalUnread: current.totalUnread,
        searchQuery: current.searchQuery,
        unreadOnly: value,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}
