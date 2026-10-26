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
      super(const ChatListState());

  final ChatRepository _repository;
  final String? _userId;

  StreamSubscription<List<Chat>>? _subscription;

  String? get userId => _userId;

  /// The chats after the search filter, ready for the list.
  List<Chat> get visibleChats => state.visibleChats(_userId);

  /// Subscribes to the chats. Awaiting the first snapshot keeps tests
  /// deterministic and gives the screen a loaded/error state.
  Future<void> load() async {
    final uid = _userId;
    if (uid == null || uid.isEmpty) {
      safeEmit(
        state.copyWith(
          isLoading: false,
          isLoaded: true,
          error: 'Sign in to see your chats.',
        ),
      );
      return;
    }

    safeEmit(state.copyWith(isLoading: true, error: null));
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
    safeEmit(
      state.copyWith(
        chats: chats,
        totalUnread: totalUnread,
        isLoading: false,
        isLoaded: true,
        error: null,
      ),
    );
  }

  void _onError(Object error) {
    final mapped = ChatErrors.map(error);
    safeEmit(
      state.copyWith(
        isLoading: false,
        isLoaded: true,
        error: mapped.toString(),
      ),
    );
  }

  void setSearchQuery(String query) {
    safeEmit(state.copyWith(searchQuery: query));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}
