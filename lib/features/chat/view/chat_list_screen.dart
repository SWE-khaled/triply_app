import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:triply/core/constants/app_routes.dart';
import 'package:triply/core/data/models/chat.dart';
import 'package:triply/core/data/repositories/chat_repository.dart';
import 'package:triply/core/data/repositories/firestore_chat_repository.dart';
import 'package:triply/core/theme/app_colors.dart';
import 'package:triply/core/widgets/app_snackbar.dart';
import 'package:triply/core/widgets/circle_back_button.dart';
import 'package:triply/features/common/AuthTourist/cubit/auth_cubit.dart';
import 'package:triply/features/tour_guide/home_and_notification_tg/widget/guide_bottom_nav.dart';

import '../cubit/chat_list_cubit.dart';
import '../cubit/chat_list_state.dart';
import '../model/chat_audience.dart';
import '../util/chat_time.dart';
import '../widgets/chat_avatar.dart';

/// The conversation list of both roles.
///
/// A tourist opens it from the messages button on Home; a guide opens it
/// from the Chats tab. The list is live, searchable and filterable, and it
/// never creates a chat — only the room's first message does that.
class ChatListScreen extends StatefulWidget {
  final ChatRepository? repository;
  final ChatAudience audience;

  /// Shows the four-tab guide navigation (the guide list is a tab).
  final bool showGuideNav;

  const ChatListScreen({
    super.key,
    this.repository,
    this.audience = ChatAudience.tourist,
    this.showGuideNav = false,
  });

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late final ChatRepository _repository;
  late final ChatListCubit _cubit;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? FirestoreChatRepository();
    _cubit = ChatListCubit(repository: _repository);
    _searchController = TextEditingController();
    _cubit.load();
  }

  @override
  void dispose() {
    _cubit.close();
    _searchController.dispose();
    super.dispose();
  }

  void _openChat(Chat chat) {
    final me = _cubit.userId ?? '';
    final otherId = chat.otherUserId(me);
    final profile = chat.profileOf(otherId);
    Navigator.of(context).push(
      AppRoutes.chatRoom(
        chatId: chat.id,
        audience: widget.audience,
        fallbackName: profile.displayName,
        fallbackAvatar: profile.avatarUrl,
      ),
    );
  }

  void _onGuideTab(int index) {
    if (index == 2) return;
    if (index == 0) {
      Navigator.of(context).pushAndRemoveUntil(
        AppRoutes.guideDashboard(),
        (route) => route.isFirst,
      );
      return;
    }
    if (index == 1) {
      Navigator.of(
        context,
      ).pushAndRemoveUntil(AppRoutes.guideTrips(), (route) => route.isFirst);
      return;
    }
    if (index == 3) {
      final uid = context.read<AuthCubit>().user?.uid;
      if (uid == null) {
        showAppSnackBar(
          context,
          'Sign in to see your profile',
          icon: Icons.info_outline,
        );
        return;
      }
      Navigator.of(context).push(AppRoutes.guideProfile(uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChatListCubit>.value(
      value: _cubit,
      child: BlocBuilder<ChatListCubit, ChatListState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  _search(state),
                  _filters(state),
                  const SizedBox(height: 6),
                  Expanded(child: _body(state)),
                ],
              ),
            ),
            bottomNavigationBar: widget.showGuideNav
                ? GuideBottomNav(
                    currentIndex: 2,
                    chatUnread: state is ChatListSuccess
                        ? state.totalUnread
                        : 0,
                    onTap: _onGuideTab,
                  )
                : null,
          );
        },
      ),
    );
  }

  Widget _header() {
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.audience.listTitle,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.title,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          widget.audience.listSubtitle,
          style: const TextStyle(fontSize: 13, color: AppColors.subtitle),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: widget.showGuideNav
          ? title
          : Row(
              children: [
                CircleBackButton(onTap: () => Navigator.maybePop(context)),
                const SizedBox(width: 12),
                Expanded(child: title),
              ],
            ),
    );
  }

  Widget _search(ChatListState state) {
    final query = state is ChatListSuccess ? state.searchQuery : '';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: TextField(
        key: const Key('chat-list-search'),
        controller: _searchController,
        onChanged: _cubit.setSearchQuery,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search by name or message...',
          hintStyle: const TextStyle(fontSize: 13, color: AppColors.hint),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.guideLabel,
            size: 21,
          ),
          suffixIcon: query.trim().isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.guideLabel,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _cubit.setSearchQuery('');
                  },
                ),
          filled: true,
          fillColor: AppColors.searchBg,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _filters(ChatListState state) {
    final success = state is ChatListSuccess ? state : null;
    final unreadOnly = success?.unreadOnly ?? false;
    final unread = success?.totalUnread ?? 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          _filterChip(
            key: const Key('chat-filter-all'),
            label: 'All',
            selected: !unreadOnly,
            onTap: () => _cubit.setUnreadOnly(false),
          ),
          const SizedBox(width: 8),
          _filterChip(
            key: const Key('chat-filter-unread'),
            label: unread > 0 ? 'Unread ($unread)' : 'Unread',
            selected: unreadOnly,
            onTap: () => _cubit.setUnreadOnly(true),
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required Key key,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      key: key,
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.tabSelectedBg : AppColors.tabUnselected,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.tabSelectedBg : AppColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _body(ChatListState state) {
    return switch (state) {
      ChatListInitial() || ChatListLoading() => const Center(
        child: CircularProgressIndicator(
          color: AppColors.priceTeal,
          strokeWidth: 2.5,
        ),
      ),
      ChatListError(:final error) => _error(error),
      ChatListSuccess() => _list(state),
    };
  }

  Widget _error(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 42,
              color: AppColors.subtitle,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.subtitle,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _cubit.load,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.tabSelectedBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _list(ChatListSuccess state) {
    final chats = state.visibleChats(_cubit.userId);
    if (chats.isEmpty) return _empty(state);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
      itemCount: chats.length,
      separatorBuilder: (_, _) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final chat = chats[index];
        return _ChatTile(
          key: ValueKey<String>('chat-tile-${chat.id}'),
          chat: chat,
          audience: widget.audience,
          myUserId: _cubit.userId ?? '',
          onTap: () => _openChat(chat),
        );
      },
    );
  }

  Widget _empty(ChatListSuccess state) {
    final searching = state.searchQuery.trim().isNotEmpty;
    final unreadOnly = state.unreadOnly;
    final subtitle = searching
        ? 'Try another guide or trip name.'
        : unreadOnly
        ? 'You have no unread messages.'
        : widget.audience.isTourist
        ? 'Open a guide profile and send the first message.'
        : 'Chats started by travelers will appear here.';

    return Center(
      key: const Key('chat-empty-state'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.forum_outlined,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No conversations found',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.title,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.subtitle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final Chat chat;
  final ChatAudience audience;
  final String myUserId;
  final VoidCallback onTap;

  const _ChatTile({
    super.key,
    required this.chat,
    required this.audience,
    required this.myUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final otherId = chat.otherUserId(myUserId);
    final profile = chat.profileOf(otherId);
    final name = profile.displayName.trim().isEmpty
        ? audience.otherFallbackName
        : profile.displayName.trim();
    final unread = chat.unreadFor(myUserId);
    final last = chat.lastMessage;
    final preview = last == null
        ? 'No messages yet'
        : last.senderId == myUserId
        ? 'You: ${last.text}'
        : last.text;
    final at = chat.lastMessageAt ?? last?.createdAt;

    return Material(
      color: unread > 0 ? AppColors.primaryLight.withValues(alpha: 0.45) : null,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
          child: Row(
            children: [
              ChatAvatar(name: name, avatarUrl: profile.avatarUrl, size: 54),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: unread > 0
                                  ? FontWeight.w800
                                  : FontWeight.w700,
                              color: AppColors.title,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          chatTimeLabel(at),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: unread > 0
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: unread > 0
                                ? AppColors.primary
                                : AppColors.guideLabel,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            preview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: unread > 0
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: unread > 0
                                  ? AppColors.textDark
                                  : AppColors.subtitle,
                            ),
                          ),
                        ),
                        if (unread > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            constraints: const BoxConstraints(minWidth: 20),
                            height: 20,
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              unread > 99 ? '99+' : '$unread',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
