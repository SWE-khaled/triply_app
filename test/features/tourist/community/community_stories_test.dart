import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:triply/core/data/mock/tourist/mock_community.dart';
import 'package:triply/features/tourist/community/cubit/community_cubit.dart';
import 'package:triply/features/tourist/community/data/community_cloudinary_uploader.dart';
import 'package:triply/features/tourist/community/data/community_posts_repository.dart';
import 'package:triply/features/tourist/community/data/community_stories_repository.dart';
import 'package:triply/features/tourist/community/model/community_post.dart';
import 'package:triply/features/tourist/community/model/community_story.dart';
import 'package:triply/features/tourist/community/view/story_viewer_view.dart';

void main() {
  final base = DateTime.utc(2026, 10, 28, 12);

  CommunityStory story({
    String id = 'story-1',
    String authorId = 'tourist-1',
    String authorName = 'Nour',
    String authorAvatarUrl = '',
    String imageUrl = 'https://res.cloudinary.com/demo/image/upload/story.jpg',
    DateTime? createdAt,
    DateTime? expiresAt,
    bool isMine = false,
    bool isLocalFile = false,
  }) => CommunityStory(
    id: id,
    authorId: authorId,
    authorName: authorName,
    authorAvatarUrl: authorAvatarUrl,
    imageUrl: imageUrl,
    createdAt: createdAt ?? base,
    expiresAt: expiresAt ?? (createdAt ?? base).add(CommunityStory.lifetime),
    isMine: isMine,
    isLocalFile: isLocalFile,
  );

  group('CommunityStory model', () {
    test('parses the Firestore contract and derives ownership', () {
      final createdAt = base.subtract(const Duration(hours: 2));
      final expiresAt = createdAt.add(CommunityStory.lifetime);
      final parsed = CommunityStory.fromDocument(
        {
          'authorId': 'tourist-1',
          'authorName': 'Nour',
          'authorAvatarUrl': 'https://res.cloudinary.com/demo/avatar.jpg',
          'imageUrl': 'https://res.cloudinary.com/demo/story.jpg',
          'createdAt': Timestamp.fromDate(createdAt),
          'expiresAt': Timestamp.fromDate(expiresAt),
        },
        'story-1',
        currentUserId: 'tourist-1',
        now: base,
      );

      expect(parsed, isNotNull);
      expect(parsed!.id, 'story-1');
      expect(parsed.authorId, 'tourist-1');
      expect(parsed.userId, 'tourist-1');
      expect(parsed.authorName, 'Nour');
      expect(
        parsed.authorAvatarUrl,
        'https://res.cloudinary.com/demo/avatar.jpg',
      );
      expect(parsed.imageUrl, 'https://res.cloudinary.com/demo/story.jpg');
      expect(parsed.createdAt!.isAtSameMomentAs(createdAt), isTrue);
      expect(parsed.expiresAt!.isAtSameMomentAs(expiresAt), isTrue);
      expect(parsed.isMine, isTrue);
      expect(parsed.isLocalFile, isFalse);
    });

    test('defaults missing optional avatar data to an empty string', () {
      final parsed = CommunityStory.fromDocument(
        {
          'authorId': 'tourist-2',
          'authorName': 'Mariam',
          'imageUrl': 'https://res.cloudinary.com/demo/story.jpg',
          'createdAt': Timestamp.fromDate(base),
        },
        'story-2',
        now: base,
      );

      expect(parsed, isNotNull);
      expect(parsed!.authorAvatarUrl, '');
      expect(
        parsed.expiresAt!.isAtSameMomentAs(base.add(CommunityStory.lifetime)),
        isTrue,
      );
    });

    test('rejects documents with missing or unresolved timestamps', () {
      final missing = CommunityStory.fromDocument(
        {
          'authorId': 'tourist-1',
          'authorName': 'Nour',
          'imageUrl': 'https://res.cloudinary.com/demo/story.jpg',
        },
        'story-1',
        now: base,
      );
      final unresolved = CommunityStory.fromDocument(
        {
          'authorId': 'tourist-1',
          'authorName': 'Nour',
          'imageUrl': 'https://res.cloudinary.com/demo/story.jpg',
          'createdAt': null,
        },
        'story-2',
        now: base,
      );

      expect(missing, isNull);
      expect(unresolved, isNull);
    });

    test('expires at exactly 24 hours, not before', () {
      final item = story(createdAt: base);

      expect(
        item.isDisplayableAt(base.add(const Duration(hours: 23, minutes: 59))),
        isTrue,
      );
      expect(
        item.isDisplayableAt(base.add(const Duration(hours: 24))),
        isFalse,
      );
      expect(
        item.isDisplayableAt(base.add(const Duration(hours: 24, seconds: 1))),
        isFalse,
      );
    });

    test('keeps the existing mock Story JSON parser compatible', () {
      final mock = CommunityStory.fromJson(mockCommunityStories.first);

      expect(mock.id, 'story_nour_1');
      expect(mock.authorId, 'user_nour');
      expect(mock.authorName, 'Nour');
      expect(mock.imageUrl, contains('unsplash.com'));
      expect(mock.hasUnseen, isTrue);
      // Mocks have no server-created timestamp and must not be displayed.
      expect(mock.createdAt, isNull);
      expect(mock.isDisplayableAt(base), isFalse);
    });

    test('serializes only the approved Firestore fields', () {
      final data = story(
        authorAvatarUrl: 'https://res.cloudinary.com/demo/avatar.jpg',
        createdAt: base,
      ).toFirestore();

      expect(data.keys.toSet(), {
        'authorId',
        'authorName',
        'authorAvatarUrl',
        'imageUrl',
        'createdAt',
        'expiresAt',
      });
      expect(data['authorId'], 'tourist-1');
      expect(data['authorName'], 'Nour');
      expect(data['imageUrl'], contains('res.cloudinary.com'));
      expect(data['createdAt'], isA<FieldValue>());
      expect(
        (data['expiresAt'] as Timestamp).toDate().isAtSameMomentAs(
          base.add(CommunityStory.lifetime),
        ),
        isTrue,
      );
      expect(data.containsKey('caption'), isFalse);
      expect(data.containsKey('storagePaths'), isFalse);
      expect(data.containsKey('isMine'), isFalse);
      expect(data.containsKey('isLocalFile'), isFalse);
    });
  });

  group('FirestoreCommunityStoriesRepository', () {
    late _FakeAuthor author;
    late _FakeUploader uploader;
    late _FakeWriter writer;
    late FirestoreCommunityStoriesRepository repository;

    setUp(() {
      author = _FakeAuthor();
      uploader = _FakeUploader();
      writer = _FakeWriter();
      repository = FirestoreCommunityStoriesRepository(
        author: author,
        imageUploader: uploader,
        writer: writer,
      );
    });

    test('uploads, validates, and writes the exact create payload', () async {
      final created = await repository.createStory(XFile('story.jpg'));

      expect(uploader.calls, 1);
      expect(writer.createdIds, ['story-1']);
      final data = writer.created.single;
      expect(data.keys.toSet(), {
        'authorId',
        'authorName',
        'authorAvatarUrl',
        'imageUrl',
        'createdAt',
        'expiresAt',
      });
      expect(data['authorId'], 'tourist-1');
      expect(data['authorName'], 'Nour');
      expect(
        data['authorAvatarUrl'],
        'https://res.cloudinary.com/demo/avatar.jpg',
      );
      expect(
        data['imageUrl'],
        'https://res.cloudinary.com/demo/image/upload/story.jpg',
      );
      expect(data['createdAt'], isA<FieldValue>());
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();
      expect(
        expiresAt.isAfter(
          DateTime.now().toUtc().add(const Duration(hours: 23, minutes: 59)),
        ),
        isTrue,
      );
      expect(
        expiresAt.isBefore(
          DateTime.now().toUtc().add(const Duration(hours: 24, minutes: 1)),
        ),
        isTrue,
      );

      expect(created.id, 'story-1');
      expect(created.authorId, 'tourist-1');
      expect(created.isMine, isTrue);
      expect(created.isLocalFile, isFalse);
    });

    test('uses the Community Posts display-name fallbacks', () {
      expect(
        FirestoreCommunityStoriesRepository.resolveAuthorName(
          '',
          'nour@example.com',
        ),
        'nour',
      );
      expect(
        FirestoreCommunityStoriesRepository.resolveAuthorName('', ''),
        'Traveler',
      );
      expect(
        FirestoreCommunityStoriesRepository.resolveAuthorName(
          'Nour',
          'other@example.com',
        ),
        'Nour',
      );
    });

    test('uses the authenticated owner identity', () async {
      author.uid = 'authenticated-uid';

      final created = await repository.createStory(XFile('story.jpg'));

      expect(writer.created.single['authorId'], 'authenticated-uid');
      expect(created.authorId, 'authenticated-uid');
    });

    test('rejects an unauthenticated publish before uploading', () async {
      author.uid = null;

      await expectLater(
        repository.createStory(XFile('story.jpg')),
        throwsA(isA<CommunityStoriesException>()),
      );
      expect(uploader.calls, 0);
      expect(writer.created, isEmpty);
    });

    test('rejects non-Cloudinary image URLs', () async {
      uploader.url = 'https://example.com/story.jpg';

      await expectLater(
        repository.createStory(XFile('story.jpg')),
        throwsA(
          isA<CommunityStoriesException>().having(
            (error) => error.message,
            'message',
            contains('invalid'),
          ),
        ),
      );
      expect(writer.created, isEmpty);
    });

    test('reports Cloudinary upload failures and writes nothing', () async {
      uploader.error = const CommunityMediaException('Upload failed: tests');

      await expectLater(
        repository.createStory(XFile('story.jpg')),
        throwsA(
          isA<CommunityStoriesException>().having(
            (error) => error.message,
            'message',
            contains('Upload failed'),
          ),
        ),
      );
      expect(writer.created, isEmpty);
    });

    test('reports Firestore publishing errors', () async {
      writer.createError = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
        message: 'denied',
      );

      await expectLater(
        repository.createStory(XFile('story.jpg')),
        throwsA(
          isA<CommunityStoriesException>().having(
            (error) => error.message,
            'message',
            contains('permission'),
          ),
        ),
      );
    });

    test('deletes only the owner Story', () async {
      final mine = story(authorId: 'tourist-1', isMine: true);
      final someoneElse = story(
        id: 'story-2',
        authorId: 'tourist-2',
        isMine: true,
      );

      await repository.deleteStory(mine);
      expect(writer.deletedIds, ['story-1']);

      await expectLater(
        repository.deleteStory(someoneElse),
        throwsA(isA<CommunityStoriesException>()),
      );
      expect(writer.deletedIds, ['story-1']);
    });

    test('reports Firestore deletion errors', () async {
      writer.deleteError = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
        message: 'denied',
      );

      await expectLater(
        repository.deleteStory(story(isMine: true)),
        throwsA(isA<CommunityStoriesException>()),
      );
    });

    test('accepts only strict Cloudinary HTTPS URLs', () {
      expect(
        FirestoreCommunityStoriesRepository.isCloudinaryStoryUrl(
          'https://res.cloudinary.com/demo/image/upload/story.jpg',
        ),
        isTrue,
      );
      expect(
        FirestoreCommunityStoriesRepository.isCloudinaryStoryUrl(
          'http://res.cloudinary.com/demo/image/upload/story.jpg',
        ),
        isFalse,
      );
      expect(
        FirestoreCommunityStoriesRepository.isCloudinaryStoryUrl(
          'https://example.com/demo/story.jpg',
        ),
        isFalse,
      );
      expect(
        FirestoreCommunityStoriesRepository.isCloudinaryStoryUrl(
          'https://res.cloudinary.com/',
        ),
        isFalse,
      );
    });

    test('filters expired and unresolved Stories from a feed', () {
      final active = story(id: 'active', createdAt: base);
      final expired = story(
        id: 'expired',
        createdAt: base.subtract(const Duration(hours: 24)),
      );
      final unresolved = CommunityStory(
        id: 'unresolved',
        authorId: 'tourist-2',
        authorName: 'Mariam',
        imageUrl: 'https://res.cloudinary.com/demo/story.jpg',
      );

      final filtered = FirestoreCommunityStoriesRepository.activeStories([
        active,
        expired,
        unresolved,
      ], now: base);

      expect(filtered.map((item) => item.id), ['active']);
    });
  });

  group('CommunityCubit Stories', () {
    late _FakePostsRepository postsRepository;
    late _FakeStoriesRepository storiesRepository;
    late CommunityCubit cubit;
    late DateTime now;

    setUp(() {
      now = base;
      postsRepository = _FakePostsRepository();
      storiesRepository = _FakeStoriesRepository();
      cubit = CommunityCubit(
        postsRepository: postsRepository,
        storiesRepository: storiesRepository,
        now: () => now,
      );
    });

    tearDown(() async {
      await cubit.close();
      await postsRepository.dispose();
      await storiesRepository.dispose();
    });

    test('starts with no mock Stories', () {
      expect(cubit.myStories, isEmpty);
      expect(cubit.userRings, isEmpty);
      expect(cubit.state.isLoadingStories, isTrue);
    });

    test('splits remote Stories into mine and other tourists', () async {
      storiesRepository.emit([
        story(id: 'mine', authorId: 'tourist-1', isMine: true),
        story(id: 'other', authorId: 'tourist-2', authorName: 'Mariam'),
      ]);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.myStories.map((item) => item.id), ['mine']);
      expect(cubit.userRings.map((item) => item.id), ['other']);
      expect(cubit.state.stories.map((item) => item.id), ['other']);
      expect(cubit.state.isLoadingStories, isFalse);
    });

    test(
      'keeps one ring per author and orders a viewer chronologically',
      () async {
        storiesRepository.emit([
          story(
            id: 'new',
            authorId: 'tourist-2',
            authorName: 'Mariam',
            createdAt: base.subtract(const Duration(hours: 1)),
          ),
          story(
            id: 'old',
            authorId: 'tourist-2',
            authorName: 'Mariam',
            createdAt: base.subtract(const Duration(hours: 2)),
          ),
          story(
            id: 'other-author',
            authorId: 'tourist-3',
            authorName: 'Youssef',
            createdAt: base.subtract(const Duration(hours: 3)),
          ),
        ]);
        await Future<void>.delayed(Duration.zero);

        expect(cubit.userRings.map((item) => item.id), ['new', 'other-author']);
        expect(cubit.storiesOf('tourist-2').map((item) => item.id), [
          'old',
          'new',
        ]);
      },
    );

    test(
      'publishes through the repository and deduplicates its snapshot',
      () async {
        storiesRepository.nextCreated = story(
          id: 'created',
          authorId: 'tourist-1',
          isMine: true,
        );

        await cubit.publishStory(XFile('story.jpg'));

        expect(storiesRepository.createCalls, 1);
        expect(cubit.myStories.map((item) => item.id), ['created']);

        storiesRepository.emit([
          story(id: 'created', authorId: 'tourist-1', isMine: true),
        ]);
        await Future<void>.delayed(Duration.zero);

        expect(cubit.myStories.map((item) => item.id), ['created']);
        expect(cubit.state.myStories, hasLength(1));
      },
    );

    test('does not leave a false local Story when publishing fails', () async {
      storiesRepository.createError = const CommunityStoriesException(
        'Upload failed',
      );

      await expectLater(
        cubit.publishStory(XFile('story.jpg')),
        throwsA(isA<CommunityStoriesException>()),
      );

      expect(cubit.myStories, isEmpty);
    });

    test('deletes only a Story owned by the current tourist', () async {
      final other = story(id: 'other', authorId: 'tourist-2', isMine: false);
      await expectLater(
        cubit.deleteStory(other),
        throwsA(isA<CommunityStoriesException>()),
      );
      expect(storiesRepository.deletedIds, isEmpty);

      final mine = story(id: 'mine', authorId: 'tourist-1', isMine: true);
      storiesRepository.emit([mine]);
      await Future<void>.delayed(Duration.zero);

      await cubit.deleteStory(mine);

      expect(storiesRepository.deletedIds, ['mine']);
      expect(cubit.myStories, isEmpty);
    });

    test('prunes Stories after the authoritative 24-hour boundary', () async {
      storiesRepository.emit([
        story(id: 'mine', authorId: 'tourist-1', isMine: true),
        story(id: 'other', authorId: 'tourist-2'),
      ]);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.userRings, hasLength(1));

      now = base.add(const Duration(hours: 24, seconds: 1));
      cubit.pruneExpiredStories();

      expect(cubit.myStories, isEmpty);
      expect(cubit.userRings, isEmpty);
    });

    test('drops already-expired Stories from an incoming snapshot', () async {
      storiesRepository.emit([
        story(
          id: 'expired',
          createdAt: base.subtract(const Duration(hours: 25)),
        ),
        story(id: 'active', createdAt: base.subtract(const Duration(hours: 1))),
      ]);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.userRings.map((item) => item.id), ['active']);
    });
  });

  group('StoryViewer expiry', () {
    late Directory tempDirectory;
    late String imagePath;

    setUpAll(() async {
      tempDirectory = await Directory.systemTemp.createTemp(
        'triply_story_viewer_',
      );
      final image = File('${tempDirectory.path}/story.png');
      await image.writeAsBytes(
        base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAANSURBVBhXY/jPwPAfAAUAAf+mXJtdAAAAAElFTkSuQmCC',
        ),
      );
      imagePath = image.path;
    });

    tearDownAll(() async {
      await tempDirectory.delete(recursive: true);
    });

    testWidgets('advances to the next active Story when the current expires', (
      tester,
    ) async {
      var now = base;
      final first = story(
        id: 'first',
        authorName: 'First',
        imageUrl: imagePath,
        isMine: true,
        isLocalFile: true,
        createdAt: base.subtract(const Duration(hours: 23, minutes: 59)),
      );
      final second = story(
        id: 'second',
        authorName: 'Second',
        imageUrl: imagePath,
        isMine: true,
        isLocalFile: true,
        createdAt: base.subtract(const Duration(hours: 1)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: StoryViewerScreen(stories: [first, second], now: () => now),
        ),
      );
      await tester.pump();

      expect(find.text('First'), findsOneWidget);

      now = base.add(const Duration(minutes: 2));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      expect(find.text('Second'), findsOneWidget);
      expect(find.text('First'), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('header uses authorAvatarUrl, never the Story image', (
      tester,
    ) async {
      const avatarUrl = 'https://res.cloudinary.com/demo/avatar.jpg';
      final item = story(
        authorName: 'Nour',
        authorAvatarUrl: avatarUrl,
        imageUrl: imagePath,
        isLocalFile: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: StoryViewerScreen(stories: [item], now: () => base),
        ),
      );
      await tester.pump();

      final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      final image = avatar.foregroundImage;

      expect(avatar.backgroundImage, isNull);
      expect(image, isA<NetworkImage>());
      expect((image! as NetworkImage).url, avatarUrl);
      expect((image as NetworkImage).url, isNot(item.imageUrl));
      expect(find.text('Nour'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('header shows the placeholder when the avatar is empty', (
      tester,
    ) async {
      final item = story(
        authorName: 'Nour',
        authorAvatarUrl: '',
        imageUrl: imagePath,
        isMine: true,
        isLocalFile: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: StoryViewerScreen(stories: [item], now: () => base),
        ),
      );
      await tester.pump();

      final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));

      expect(avatar.foregroundImage, isNull);
      expect(find.byIcon(Icons.person), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('header shows the placeholder when the avatar URL is invalid', (
      tester,
    ) async {
      final item = story(
        authorName: 'Nour',
        authorAvatarUrl: 'not a valid URL',
        imageUrl: imagePath,
        isMine: true,
        isLocalFile: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: StoryViewerScreen(stories: [item], now: () => base),
        ),
      );
      await tester.pump();

      final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));

      expect(avatar.foregroundImage, isNull);
      expect(find.byIcon(Icons.person), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}

class _FakeAuthor implements CommunityStoryAuthor {
  @override
  String? uid = 'tourist-1';

  @override
  String displayName = 'Nour';

  @override
  String email = 'nour@example.com';

  @override
  String photoUrl = 'https://res.cloudinary.com/demo/avatar.jpg';
}

class _FakeUploader extends CommunityCloudinaryUploader {
  String url = 'https://res.cloudinary.com/demo/image/upload/story.jpg';
  Object? error;
  int calls = 0;

  @override
  Future<String> upload(XFile image) async {
    calls++;
    final failure = error;
    if (failure != null) throw failure;
    return url;
  }
}

class _FakeWriter implements CommunityStoriesWriter {
  String nextId = 'story-1';
  final List<String> createdIds = [];
  final List<Map<String, dynamic>> created = [];
  final List<String> deletedIds = [];
  Object? createError;
  Object? deleteError;

  @override
  String newStoryId() => nextId;

  @override
  Future<void> createStory(String storyId, Map<String, dynamic> data) async {
    final failure = createError;
    if (failure != null) throw failure;
    createdIds.add(storyId);
    created.add(data);
  }

  @override
  Future<void> deleteStory(String storyId) async {
    final failure = deleteError;
    if (failure != null) throw failure;
    deletedIds.add(storyId);
  }
}

class _FakePostsRepository implements CommunityPostsRepository {
  final _controller = StreamController<List<CommunityPost>>.broadcast();

  @override
  Stream<List<CommunityPost>> watchPosts() => _controller.stream;

  @override
  Future<CommunityPost> createPost({
    required List<XFile> images,
    required String text,
    String? location,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> deletePost(CommunityPost post) async {}

  @override
  Future<void> toggleLike({
    required String postId,
    required bool liked,
  }) async {}

  Future<void> dispose() => _controller.close();
}

class _FakeStoriesRepository implements CommunityStoriesRepository {
  final _controller = StreamController<List<CommunityStory>>.broadcast();
  CommunityStory? nextCreated;
  Object? createError;
  Object? deleteError;
  int createCalls = 0;
  final List<String> deletedIds = [];

  @override
  Stream<List<CommunityStory>> watchStories() => _controller.stream;

  void emit(List<CommunityStory> stories) => _controller.add(stories);

  @override
  Future<CommunityStory> createStory(XFile image) async {
    createCalls++;
    final failure = createError;
    if (failure != null) throw failure;
    return nextCreated!;
  }

  @override
  Future<void> deleteStory(CommunityStory story) async {
    final failure = deleteError;
    if (failure != null) throw failure;
    deletedIds.add(story.id);
  }

  Future<void> dispose() => _controller.close();
}
