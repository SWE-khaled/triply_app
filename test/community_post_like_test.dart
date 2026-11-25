import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:triply/features/tourist/community/cubit/post_actions_cubit.dart';
import 'package:triply/features/tourist/community/cubit/post_actions_state.dart';
import 'package:triply/features/tourist/community/data/community_posts_repository.dart';
import 'package:triply/features/tourist/community/model/community_post.dart';

void main() {
  test(
    'updates like state immediately and confirms it after the request',
    () async {
      final repository = _FakeCommunityPostsRepository();
      final cubit = PostActionsCubit(
        post: _post(),
        postsRepository: repository,
      );

      final request = cubit.toggleLike();

      expect(cubit.state, isA<PostActionInProgress>());
      expect(cubit.state.isLiked, isTrue);
      expect(cubit.state.likesCount, 1);
      expect(repository.requestedLike, isTrue);

      repository.completer.complete();
      await request;

      expect(cubit.state, isA<PostActionSucceeded>());
      expect(cubit.state.isLiked, isTrue);
      expect(cubit.state.likesCount, 1);
      await cubit.close();
    },
  );

  test('reverts the optimistic like when the request fails', () async {
    final repository = _FakeCommunityPostsRepository();
    final cubit = PostActionsCubit(post: _post(), postsRepository: repository);

    final request = cubit.toggleLike();
    repository.completer.completeError(Exception('offline'));
    await request;

    expect(cubit.state, isA<PostActionFailed>());
    expect(cubit.state.isLiked, isFalse);
    expect(cubit.state.likesCount, 0);
    await cubit.close();
  });
}

CommunityPost _post() => CommunityPost(
  id: 'post-1',
  authorName: 'Traveler',
  authorAvatarUrl: '',
  location: '',
  text: 'A trip',
  likesCount: 0,
  commentsCount: 0,
);

class _FakeCommunityPostsRepository implements CommunityPostsRepository {
  final Completer<void> completer = Completer<void>();
  bool? requestedLike;

  @override
  Future<void> toggleLike({required String postId, required bool liked}) {
    requestedLike = liked;
    return completer.future;
  }

  @override
  Stream<List<CommunityPost>> watchPosts() => const Stream.empty();

  @override
  Stream<List<CommunityPost>> watchMyPosts() => const Stream.empty();

  @override
  Future<CommunityPost> createPost({
    required List<XFile> images,
    required String text,
    String? location,
  }) => throw UnimplementedError();

  @override
  Future<void> deletePost(CommunityPost post) => throw UnimplementedError();
}
