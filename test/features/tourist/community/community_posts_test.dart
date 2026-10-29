import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:triply/features/tourist/community/cubit/community_cubit.dart';
import 'package:triply/features/tourist/community/cubit/community_state.dart';
import 'package:triply/features/tourist/community/data/community_cloudinary_uploader.dart';
import 'package:triply/features/tourist/community/data/community_posts_repository.dart';
import 'package:triply/features/tourist/community/data/community_stories_repository.dart';
import 'package:triply/features/tourist/community/model/community_post.dart';
import 'package:triply/features/tourist/community/model/community_story.dart';
import 'package:triply/features/tourist/community/widget/community_posts_empty_state.dart';

void main() {
  CommunityPost post({
    String id = 'post-1',
    String authorId = 'tourist-1',
    bool isMine = true,
    int likesCount = 0,
    bool isLiked = false,
    Map<String, bool> likedBy = const <String, bool>{},
  }) => CommunityPost(
    id: id,
    authorId: authorId,
    authorName: 'Nour',
    authorAvatarUrl: '',
    createdAt: DateTime.utc(2026, 10, 27, 10),
    location: 'Giza',
    text: 'A wonderful morning.',
    imageUrls: const [],
    likesCount: likesCount,
    commentsCount: 0,
    likedBy: likedBy,
    isLiked: isLiked,
    isMine: isMine,
  );

  group('CommunityPost', () {
    test('parses the Firestore contract and derives ownership', () {
      final createdAt = DateTime.utc(2026, 10, 27, 10);
      final parsed = CommunityPost.fromDocument(
        {
          'authorId': 'tourist-1',
          'authorName': 'Nour',
          'authorAvatarUrl': 'https://example.com/avatar.jpg',
          'createdAt': Timestamp.fromDate(createdAt),
          'location': 'Giza',
          'imageUrls': ['https://example.com/one.jpg'],
          'storagePaths': ['communityPosts/tourist-1/post-1/0-one.jpg'],
          'text': 'A wonderful morning.',
          'likesCount': 7,
          'commentsCount': 2,
        },
        'post-1',
        currentUserId: 'tourist-1',
      );

      expect(parsed.id, 'post-1');
      expect(parsed.isMine, isTrue);
      expect(parsed.imageUrls, ['https://example.com/one.jpg']);
      expect(parsed.storagePaths, hasLength(1));
      expect(parsed.createdAt!.isAtSameMomentAs(createdAt), isTrue);
      expect(parsed.likedBy, isEmpty);
      expect(parsed.isLiked, isFalse);
      expect(parsed.toFirestore()['authorId'], 'tourist-1');
    });

    test('restores isLiked from likedBy for the signed-in user', () {
      final parsed = CommunityPost.fromDocument(
        {
          'authorId': 'another-user',
          'authorName': 'Nour',
          'authorAvatarUrl': '',
          'location': '',
          'imageUrls': const <String>[],
          'storagePaths': const <String>[],
          'text': 'Hello',
          'likesCount': 2,
          'commentsCount': 0,
          'likedBy': {'tourist-1': true, 'tourist-2': true},
        },
        'post-1',
        currentUserId: 'tourist-1',
      );

      expect(parsed.likedBy.keys, containsAll(['tourist-1', 'tourist-2']));
      expect(parsed.isLiked, isTrue);
      expect(parsed.likesCount, 2);
    });

    test('serializes likedBy only when it has entries', () {
      expect(post().toFirestore().containsKey('likedBy'), isFalse);
      expect(post(likedBy: {'tourist-1': true}).toFirestore()['likedBy'], {
        'tourist-1': true,
      });
    });

    test('writes the fields required to create a post', () {
      final data = post().toFirestore();

      expect(
        data.keys,
        containsAll([
          'authorId',
          'authorName',
          'authorAvatarUrl',
          'location',
          'imageUrls',
          'storagePaths',
          'text',
          'likesCount',
          'commentsCount',
        ]),
      );
      expect(data['storagePaths'], isEmpty);
      expect(data['imageUrls'], isEmpty);
    });

    test('formats relative timestamps without negative values', () {
      final now = DateTime.utc(2026, 10, 27, 12);
      expect(
        CommunityPostTime.format(
          now.subtract(const Duration(minutes: 2)),
          now: now,
        ),
        '2 min ago',
      );
      expect(
        CommunityPostTime.format(now.add(const Duration(minutes: 2)), now: now),
        'Just now',
      );
    });
  });

  group('Community like state', () {
    test('a first like records the uid and increments the count', () {
      final next = FirestoreCommunityPostsRepository.nextLikeState(
        data: {'likesCount': 0},
        uid: 'user-1',
        liked: true,
      );

      expect(next.changed, isTrue);
      expect(next.likesCount, 1);
      expect(next.likedBy, {'user-1': true});
    });

    test('an unlike removes the uid and decrements the count', () {
      final next = FirestoreCommunityPostsRepository.nextLikeState(
        data: {
          'likesCount': 2,
          'likedBy': {'user-1': true, 'user-2': true},
        },
        uid: 'user-1',
        liked: false,
      );

      expect(next.changed, isTrue);
      expect(next.likesCount, 1);
      expect(next.likedBy, {'user-2': true});
    });

    test('a repeated like is a no-op', () {
      final next = FirestoreCommunityPostsRepository.nextLikeState(
        data: {
          'likesCount': 1,
          'likedBy': {'user-1': true},
        },
        uid: 'user-1',
        liked: true,
      );

      expect(next.changed, isFalse);
      expect(next.likesCount, 1);
      expect(next.likedBy, {'user-1': true});
    });

    test('the count never becomes negative', () {
      final next = FirestoreCommunityPostsRepository.nextLikeState(
        data: {
          'likesCount': 0,
          'likedBy': {'user-1': true},
        },
        uid: 'user-1',
        liked: false,
      );

      expect(next.likesCount, 0);
    });
  });

  group('CommunityCloudinaryUploader', () {
    test('uses the same Cloudinary account and preset as profiles', () {
      expect(CommunityCloudinaryUploader.cloudName, 'yl49wcys');
      expect(CommunityCloudinaryUploader.uploadPreset, 'djowcnxm');
      expect(
        CommunityCloudinaryUploader.uploadEndpoint,
        'https://api.cloudinary.com/v1_1/yl49wcys/image/upload',
      );
    });
  });

  group('CommunityCubit', () {
    late _FakeCommunityPostsRepository repository;
    late _FakeCommunityStoriesRepository storiesRepository;
    late CommunityCubit cubit;

    setUp(() {
      repository = _FakeCommunityPostsRepository();
      storiesRepository = _FakeCommunityStoriesRepository();
      cubit = CommunityCubit(
        postsRepository: repository,
        storiesRepository: storiesRepository,
      );
    });

    tearDown(() async {
      await cubit.close();
      await repository.dispose();
      await storiesRepository.dispose();
    });

    test('starts empty and uses the realtime Firestore feed', () async {
      expect(cubit.posts, isEmpty);

      repository.emit([post(id: 'remote-post')]);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.posts.map((item) => item.id), ['remote-post']);
      expect(cubit.state.isLoadingPosts, isFalse);
      expect(cubit.state.postsError, isNull);
    });

    test('persists a like and syncs the Firestore snapshot', () async {
      repository.emit([post(id: 'post-1')]);
      await Future<void>.delayed(Duration.zero);

      await cubit.toggleLike(cubit.posts.single);

      expect(repository.likeCalls.single.postId, 'post-1');
      expect(repository.likeCalls.single.liked, isTrue);

      repository.emit([
        post(
          id: 'post-1',
          likesCount: 1,
          isLiked: true,
          likedBy: {'tourist-1': true},
        ),
      ]);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.posts.single.likesCount, 1);
      expect(cubit.posts.single.isLiked, isTrue);
    });

    test('persists an unlike without going below zero', () async {
      repository.emit([
        post(
          id: 'post-1',
          likesCount: 1,
          isLiked: true,
          likedBy: {'tourist-1': true},
        ),
      ]);
      await Future<void>.delayed(Duration.zero);

      await cubit.toggleLike(cubit.posts.single);

      expect(repository.likeCalls.single.liked, isFalse);

      repository.emit([post(id: 'post-1')]);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.posts.single.likesCount, 0);
      expect(cubit.posts.single.isLiked, isFalse);
    });

    test('ignores repeated taps while a like request is in flight', () async {
      repository.emit([post(id: 'post-1')]);
      await Future<void>.delayed(Duration.zero);

      final pending = Completer<void>();
      repository.likeCompleter = pending;
      final first = cubit.toggleLike(cubit.posts.single);
      final second = cubit.toggleLike(cubit.posts.single);

      expect(repository.likeCalls, hasLength(1));

      pending.complete();
      await Future.wait([first, second]);
    });

    test('leaves the visible state unchanged when the write fails', () async {
      repository.emit([post(id: 'post-1')]);
      await Future<void>.delayed(Duration.zero);
      repository.failNextLike = true;

      await expectLater(
        cubit.toggleLike(cubit.posts.single),
        throwsA(isA<CommunityPostsException>()),
      );

      expect(cubit.posts.single.likesCount, 0);
      expect(cubit.posts.single.isLiked, isFalse);
    });

    test('restores the current user like state from Firestore', () async {
      repository.emit([
        CommunityPost.fromDocument(
          {
            'authorId': 'another-user',
            'authorName': 'Nour',
            'authorAvatarUrl': '',
            'location': '',
            'imageUrls': const <String>[],
            'storagePaths': const <String>[],
            'text': 'Hello',
            'likesCount': 2,
            'commentsCount': 0,
            'likedBy': {'tourist-1': true},
          },
          'post-1',
          currentUserId: 'tourist-1',
        ),
      ]);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.posts.single.likesCount, 2);
      expect(cubit.posts.single.isLiked, isTrue);
    });

    test(
      'publishes only through the repository and removes own posts',
      () async {
        repository.nextCreatedPost = post(id: 'created-post');

        await cubit.publishPost(images: const <XFile>[], text: 'Hello Cairo');

        expect(repository.createCalls, 1);
        expect(cubit.posts.first.id, 'created-post');

        await cubit.deletePost(cubit.posts.first);

        expect(repository.deletedIds, ['created-post']);
        expect(cubit.posts.any((item) => item.id == 'created-post'), isFalse);
      },
    );

    test('does not send a delete request for somebody else\'s post', () async {
      await expectLater(
        cubit.deletePost(post(authorId: 'another-user', isMine: false)),
        throwsA(isA<CommunityPostsException>()),
      );

      expect(repository.deletedIds, isEmpty);
    });
  });

  group('Community posts empty state', () {
    CommunityState state({
      bool loading = false,
      String? error,
      List<CommunityPost> posts = const [],
    }) => CommunityState(
      stories: const [],
      myStories: const [],
      posts: posts,
      isLoadingPosts: loading,
      postsError: error,
    );

    test('is shown only after loading without posts or an error', () {
      expect(state().showPostsEmptyState, isTrue);
      expect(state(loading: true).showPostsEmptyState, isFalse);
      expect(state(error: 'Could not load posts').showPostsEmptyState, isFalse);
      expect(state(posts: [post()]).showPostsEmptyState, isFalse);
    });

    testWidgets('renders the title and subtitle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: CommunityPostsEmptyState())),
      );

      expect(find.text('No posts yet'), findsOneWidget);
      expect(find.text('Be the first to share something!'), findsOneWidget);
    });
  });
}

class _FakeCommunityPostsRepository implements CommunityPostsRepository {
  final _controller = StreamController<List<CommunityPost>>.broadcast();
  int createCalls = 0;
  final List<String> deletedIds = [];
  final List<({String postId, bool liked})> likeCalls = [];
  CommunityPost? nextCreatedPost;
  bool failNextLike = false;
  Completer<void>? likeCompleter;

  @override
  Stream<List<CommunityPost>> watchPosts() => _controller.stream;

  void emit(List<CommunityPost> posts) => _controller.add(posts);

  @override
  Future<CommunityPost> createPost({
    required List<XFile> images,
    required String text,
    String? location,
  }) async {
    createCalls++;
    return nextCreatedPost ??
        (throw StateError('Set nextCreatedPost before publishing.'));
  }

  @override
  Future<void> deletePost(CommunityPost post) async {
    deletedIds.add(post.id);
  }

  @override
  Future<void> toggleLike({required String postId, required bool liked}) async {
    likeCalls.add((postId: postId, liked: liked));
    final pending = likeCompleter;
    if (pending != null) await pending.future;
    if (failNextLike) {
      failNextLike = false;
      throw const CommunityPostsException('Write failed.');
    }
  }

  Future<void> dispose() => _controller.close();
}

/// Community Posts tests only need Story dependencies to stay inert.
class _FakeCommunityStoriesRepository implements CommunityStoriesRepository {
  final _controller = StreamController<List<CommunityStory>>.broadcast();

  @override
  Stream<List<CommunityStory>> watchStories() => _controller.stream;

  @override
  Future<CommunityStory> createStory(XFile image) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteStory(CommunityStory story) async {}

  Future<void> dispose() => _controller.close();
}
