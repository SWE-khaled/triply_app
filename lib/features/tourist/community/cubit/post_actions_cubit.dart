import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/utils/safe_emit_mixin.dart';

import '../data/community_posts_repository.dart';
import '../model/community_post.dart';
import 'community_action_error.dart';
import 'post_actions_state.dart';

/// Owns like/delete for exactly one post. Each card gets its own instance, so
/// a slow request on one post never changes another card's state.
class PostActionsCubit extends Cubit<PostActionsState>
    with SafeEmitMixin<PostActionsState> {
  PostActionsCubit({
    required this.post,
    CommunityPostsRepository? postsRepository,
    this.onDeleted,
  }) : _repository = postsRepository ?? FirestoreCommunityPostsRepository(),
       super(const PostActionsInitial());

  static const likeAction = 'like';
  static const deleteAction = 'delete';

  final CommunityPost post;
  final CommunityPostsRepository _repository;

  /// Lets the feed perform its optimistic removal after a confirmed delete.
  final void Function()? onDeleted;

  bool _busy = false;

  /// Extra taps while this post's transaction is in flight are ignored. The
  /// repository transaction also makes a repeated target a no-op.
  Future<void> toggleLike() async {
    if (_busy) return;
    _busy = true;
    safeEmit(const PostActionInProgress(action: likeAction));
    try {
      await _repository.toggleLike(postId: post.id, liked: !post.isLiked);
      // The Firestore snapshot updates the count and isLiked state.
      safeEmit(const PostActionSucceeded(action: likeAction));
    } catch (error) {
      safeEmit(
        PostActionFailed(
          action: likeAction,
          message: communityActionErrorMessage(error),
        ),
      );
    } finally {
      _busy = false;
    }
  }

  /// Ownership is enforced here as well as in the repository.
  Future<void> delete() async {
    if (_busy) return;
    if (!post.isMine) {
      safeEmit(
        const PostActionFailed(
          action: deleteAction,
          message: 'You can only delete your own posts.',
        ),
      );
      return;
    }
    _busy = true;
    safeEmit(const PostActionInProgress(action: deleteAction));
    try {
      await _repository.deletePost(post);
      onDeleted?.call();
      safeEmit(const PostActionSucceeded(action: deleteAction));
    } catch (error) {
      safeEmit(
        PostActionFailed(
          action: deleteAction,
          message: communityActionErrorMessage(error),
        ),
      );
    } finally {
      _busy = false;
    }
  }
}
