import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:triply/core/data/repositories/chat_repository.dart';
import 'package:triply/core/data/repositories/firestore_chat_repository.dart';

import '../cubit/chat_list_cubit.dart';
import '../cubit/chat_list_state.dart';

/// Gives a widget the signed-in user's total unread count.
///
/// Owns its own [ChatListCubit] so a bottom navigation badge can show the
/// count (the sum from the chat list) without the screen knowing about
/// chats at all.
class ChatUnreadBuilder extends StatefulWidget {
  final ChatRepository? repository;
  final Widget Function(BuildContext context, int unread) builder;

  const ChatUnreadBuilder({super.key, this.repository, required this.builder});

  @override
  State<ChatUnreadBuilder> createState() => _ChatUnreadBuilderState();
}

class _ChatUnreadBuilderState extends State<ChatUnreadBuilder> {
  late final ChatListCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = ChatListCubit(
      repository: widget.repository ?? FirestoreChatRepository(),
    );
    _cubit.load();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChatListCubit>.value(
      value: _cubit,
      child: BlocBuilder<ChatListCubit, ChatListState>(
        builder: (context, state) => widget.builder(
          context,
          state is ChatListSuccess ? state.totalUnread : 0,
        ),
      ),
    );
  }
}
