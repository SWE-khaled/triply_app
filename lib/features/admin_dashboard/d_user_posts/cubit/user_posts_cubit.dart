import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/features/tourist/community/data/community_posts_repository.dart';
import 'package:triply/features/tourist/community/model/community_post.dart';

part 'user_posts_state.dart';

/// Owns the User Posts tab: the live community feed, the search query and
/// the admin delete action.
class UserPostsCubit extends Cubit<UserPostsState> {
  UserPostsCubit({
    FirestoreCommunityPostsRepository? repository,
    FirebaseFirestore? firestore,
  }) : _repository = repository ?? FirestoreCommunityPostsRepository(),
       _firestore = firestore ?? FirebaseFirestore.instance,
       super(const UserPostsInitial());

  final FirestoreCommunityPostsRepository _repository;
  final FirebaseFirestore _firestore;

  StreamSubscription<List<CommunityPost>>? _subscription;
  List<CommunityPost> _posts = const [];
  String _query = '';

  /// Subscribes to the community feed. Calling it twice is a no-op.
  void start() {
    emit(const UserPostsLoading());
    _subscription?.cancel();
    _subscription = _repository.watchPosts().listen(
      (posts) {
        _posts = posts;
        _emitSuccess();
      },
      onError: (_) {
        if (!isClosed) emit(const UserPostsError('Could not load user posts.'));
      },
    );
  }

  /// Applies the search box content to the loaded list.
  void search(String query) {
    _query = query;
    final current = state;
    if (current is UserPostsSuccess) {
      emit(current.copyWith(query: query));
    }
  }

  /// Deletes a post as the admin.
  ///
  /// The card disappears immediately and comes back when Firestore refuses
  /// the delete. Returns `null` on success, or the message to show when the
  /// delete failed.
  Future<String?> removePost(CommunityPost post) async {
    final current = state;
    if (current is! UserPostsSuccess) return 'Posts are still loading.';

    final index = current.posts.indexWhere((item) => item.id == post.id);
    emit(
      current.copyWith(
        posts: current.posts.where((item) => item.id != post.id).toList(),
      ),
    );

    try {
      await _firestore
          .collection('communityPosts')
          .doc(post.id)
          .delete();

      // Older documents also live in the legacy `posts` collection. That
      // cleanup is best-effort only and must not fail the deletion above.
      try {
        await _firestore.collection('posts').doc(post.id).delete();
      } catch (_) {}

      return null;
    } catch (error) {
      if (!isClosed) {
        final latest = state;
        if (latest is UserPostsSuccess &&
            !latest.posts.any((item) => item.id == post.id)) {
          final restored = [...latest.posts];
          final at = index < 0
              ? 0
              : (index > restored.length ? restored.length : index);
          restored.insert(at, post);
          emit(latest.copyWith(posts: restored));
        }
      }

      final isPermissionError = error.toString().contains('permission-denied');
      return isPermissionError
          ? 'Permission denied: firestore.rules must allow an admin to '
                'delete community posts.'
          : 'Could not delete post: $error';
    }
  }

  void _emitSuccess() {
    if (isClosed) return;
    emit(UserPostsSuccess(posts: List.unmodifiable(_posts), query: _query));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
