import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/utils/safe_emit_mixin.dart';

import '../../community/data/community_posts_repository.dart';
import '../../community/model/community_post.dart';
import 'profile_posts_state.dart';

/// Owns the `watchMyPosts()` stream for both the Profile preview and My Posts.
/// Deletions are owned by the per-post action cubit; this cubit only applies
/// the optimistic removal to its own snapshot.
class ProfilePostsCubit extends Cubit<ProfilePostsState>
    with SafeEmitMixin<ProfilePostsState> {
  ProfilePostsCubit({CommunityPostsRepository? postsRepository})
    : _repository = postsRepository ?? FirestoreCommunityPostsRepository(),
      super(const ProfilePostsInitial()) {
    safeEmit(const ProfilePostsLoading());
    _listen();
  }

  final CommunityPostsRepository _repository;

  StreamSubscription<List<CommunityPost>>? _subscription;
  List<CommunityPost> _posts = const [];
  bool _hasLoaded = false;

  /// Authoritative snapshot for derived reads.
  List<CommunityPost> get posts => _posts;

  /// Defensive ownership filter used by the Views; the repository already
  /// scopes the stream to the signed-in tourist.
  List<CommunityPost> myPosts(String? uid) {
    if (uid == null || uid.isEmpty) return const [];
    return _posts
        .where(
          (post) => post.authorId.isNotEmpty && post.authorId == uid,
        )
        .toList(growable: false);
  }

  void _listen() {
    _subscription = _repository.watchMyPosts().listen(
      (posts) {
        if (isClosed) return;
        _posts = List.unmodifiable(posts);
        _hasLoaded = true;
        safeEmit(ProfilePostsSuccess(posts: _posts));
      },
      onError: (Object error, StackTrace stackTrace) {
        if (isClosed) return;
        safeEmit(
          ProfilePostsError(posts: _posts, hasLoaded: _hasLoaded),
        );
      },
    );
  }

  /// Re-subscribes without restarting the shimmer: the error message stays
  /// visible until the stream answers, as before.
  void retry() {
    unawaited(_subscription?.cancel());
    _listen();
  }

  void removePost(CommunityPost post) {
    if (isClosed) return;
    _posts = _posts.where((item) => item.id != post.id).toList(growable: false);
    safeEmit(ProfilePostsSuccess(posts: _posts));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
