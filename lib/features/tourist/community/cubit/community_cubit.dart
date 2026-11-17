import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/utils/page_load_error.dart';
import 'package:triply/core/utils/safe_emit_mixin.dart';

import '../data/community_posts_repository.dart';
import '../model/community_post.dart';
import 'community_state.dart';

/// Owns only the Community posts feed.
///
/// This file was the old aggregate Community cubit. Stories, publishing and
/// per-post actions now live in their own cubits so one failing operation
/// cannot replace another feed's state.
class CommunityPostsCubit extends Cubit<CommunityPostsState>
    with SafeEmitMixin<CommunityPostsState> {
  CommunityPostsCubit({CommunityPostsRepository? postsRepository})
    : _repository = postsRepository ?? FirestoreCommunityPostsRepository(),
      super(const CommunityPostsInitial()) {
    safeEmit(const CommunityPostsLoading());
    _listen();
  }

  final CommunityPostsRepository _repository;

  StreamSubscription<List<CommunityPost>>? _subscription;
  List<CommunityPost> _posts = const [];
  bool _hasLoaded = false;

  /// Authoritative feed snapshot for derived reads.
  List<CommunityPost> get posts => _posts;

  void _listen() {
    _subscription = _repository.watchPosts().listen(
      _onPosts,
      onError: _onPostsError,
    );
  }

  void _onPosts(List<CommunityPost> posts) {
    if (isClosed) return;
    _posts = List.unmodifiable(posts);
    _hasLoaded = true;
    safeEmit(CommunityPostsSuccess(posts: _posts));
  }

  void _onPostsError(Object error, StackTrace stackTrace) {
    if (isClosed) return;
    // Keep the last successful feed on screen, as the aggregate cubit did.
    safeEmit(
      CommunityPostsError(
        message: pageLoadErrorMessage(error),
        posts: _posts,
        hasLoaded: _hasLoaded,
      ),
    );
  }

  /// Re-subscribes without restarting the shimmer: the error view stays until
  /// the feed answers.
  void retry() {
    unawaited(_subscription?.cancel());
    _listen();
  }

  /// Immediate optimistic insertion after a successful publish.
  void addPost(CommunityPost post) {
    if (isClosed) return;
    final posts = _posts.where((item) => item.id != post.id).toList();
    _posts = List.unmodifiable([post, ...posts]);
    _hasLoaded = true;
    safeEmit(CommunityPostsSuccess(posts: _posts));
  }

  /// Immediate optimistic removal after the owning cubit deleted a post.
  void removePost(CommunityPost post) {
    if (isClosed) return;
    _posts = _posts.where((item) => item.id != post.id).toList(growable: false);
    safeEmit(CommunityPostsSuccess(posts: _posts));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
