import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/firebase/firestore_result.dart';
import 'package:triply/data/firestore/mappers/firestore_mappers.dart';
import 'package:triply/data/firestore/models/notification_doc.dart';
import 'package:triply/data/firestore/models/post_doc.dart';
import 'package:triply/data/firestore/repositories/community_repository.dart';
import 'package:triply/data/firestore/repositories/notifications_repository.dart';
import 'package:triply/features/tour_guide/homeandNotificationTr/cubit/guide_notifications_cubit.dart';
import 'package:triply/features/tour_guide/homeandNotificationTr/model/guide_notification.dart';
import 'package:triply/features/tourist/community/cubit/community_cubit.dart';
import 'package:triply/features/tourist/community/model/community_post.dart';
import 'package:triply/features/tourist/community/model/community_story.dart';
import 'package:triply/features/tourist/notifications/cubit/notifications_cubit.dart';
import 'package:triply/features/tourist/notifications/model/notification_item.dart';

/// Focused Phase 6 unit tests: community feed/create/likes/delete and
/// tourist/guide notification listing + read state. Fakes override the
/// repository boundary (possible because constructors are lazy — building
/// them never touches Firebase). These are UNIT tests, not emulator
/// integration tests.
class _FakeCommunityRepository extends CommunityRepository {
  FirestoreResult<List<CommunityPost>> feedResult =
      const FirestoreOk<List<CommunityPost>>([]);
  FirestoreResult<List<CommunityStory>> storiesResult =
      const FirestoreOk<List<CommunityStory>>([]);
  int feedCalls = 0;
  int addCalls = 0;
  int deleteCalls = 0;
  int likeCalls = 0;
  String? lastLikePost;
  String? lastLikeUid;
  bool? lastLikeWasLiked;
  Object? likeError;
  Object? deleteError;
  String createdId = 'server-post-1';
  Map<String, dynamic>? lastCreate;

  @override
  Future<FirestoreResult<List<CommunityPost>>> feed(
    String currentUid, {
    int limit = 20,
    Object? startAfter,
  }) async {
    feedCalls++;
    return feedResult;
  }

  @override
  Future<FirestoreResult<List<CommunityStory>>> activeStories(
    String currentUid,
  ) async {
    return storiesResult;
  }

  @override
  Future<String> addPost({
    required String authorId,
    String authorName = '',
    String authorAvatarUrl = '',
    String text = '',
    List<String> imageUrls = const [],
    String location = '',
  }) async {
    addCalls++;
    lastCreate = {
      'authorId': authorId,
      'authorName': authorName,
      'text': text,
      'location': location,
    };
    return createdId;
  }

  @override
  Future<void> deletePost(String postId) async {
    deleteCalls++;
    if (deleteError != null) throw deleteError!;
  }

  @override
  Future<void> toggleLike({
    required String postId,
    required String uid,
    required bool currentlyLiked,
  }) async {
    likeCalls++;
    lastLikePost = postId;
    lastLikeUid = uid;
    lastLikeWasLiked = currentlyLiked;
    if (likeError != null) throw likeError!;
  }

  @override
  Future<void> deleteStory(String storyId) async {
    deleteCalls++;
    if (deleteError != null) throw deleteError!;
  }
}

class _FakeNotificationsRepository extends NotificationsRepository {
  FirestoreResult<List<NotificationItem>> listResult =
      const FirestoreOk<List<NotificationItem>>([]);
  FirestoreResult<List<GuideNotification>> guideResult =
      const FirestoreOk<List<GuideNotification>>([]);
  int markOneCalls = 0;
  int markAllCalls = 0;
  Object? markError;

  @override
  Future<FirestoreResult<List<NotificationItem>>> myNotifications(
    String userId, {
    int limit = 20,
    Object? startAfter,
  }) async => listResult;

  @override
  Future<FirestoreResult<List<GuideNotification>>> guideNotifications(
    String userId, {
    int limit = 20,
    Object? startAfter,
  }) async => guideResult;

  @override
  Future<void> markOneRead(String id) async {
    markOneCalls++;
    if (markError != null) throw markError!;
  }

  @override
  Future<void> markAllRead(String userId) async {
    markAllCalls++;
    if (markError != null) throw markError!;
  }
}

CommunityPost _post({
  String id = 'p1',
  bool isMine = false,
  int likes = 3,
  bool liked = false,
}) => CommunityPost(
  id: id,
  authorName: isMine ? 'You' : 'Sam',
  authorAvatarUrl: '',
  timeAgo: '2h ago',
  location: 'Cairo',
  imageUrl: '',
  text: 'hi',
  likesCount: likes,
  commentsCount: 0,
  isLiked: liked,
  isMine: isMine,
);

CommunityStory _serverStory({String id = 's1', bool mine = false}) =>
    CommunityStory(
      id: id,
      userId: mine ? 'u1' : 'other',
      userName: mine ? 'You' : 'O',
      imageUrl: 'http://img',
      isMine: mine,
    );

NotificationItem _item({
  String id = 'n1',
  String section = 'today',
  bool read = false,
}) => NotificationItem(
  id: id,
  type: 'general',
  title: 'T',
  body: 'B',
  timeLabel: 'now',
  isRead: read,
  section: section,
);

void main() {
  group('CommunityCubit remote feed', () {
    test('remote mode is enabled (Phase 6 activation)', () {
      expect(CommunityCubit.useRemote, isTrue);
    });

    test('refresh replaces mocks and resolves isMine by uid', () async {
      final repo = _FakeCommunityRepository()
        ..feedResult = FirestoreOk<List<CommunityPost>>([
          _post(id: 'r1'),
          _post(id: 'r2', isMine: true),
        ])
        ..storiesResult = FirestoreOk<List<CommunityStory>>([
          _serverStory(id: 's9'),
        ]);
      final cubit = CommunityCubit(repository: repo, uid: 'u9');
      final ok = await cubit.refreshRemote();
      expect(ok, isTrue);
      expect(cubit.posts.map((p) => p.id), ['r1', 'r2']);
      // No mock ids survive a successful refresh.
      expect(cubit.posts.any((p) => p.id.startsWith('post_')), isFalse);
      // Local-only stories merge with server ones.
      cubit.addMyStory('/tmp/local.jpg');
      await cubit.refreshRemote();
      expect(cubit.myStories.any((s) => s.isLocalFile), isTrue);
      expect(cubit.storiesOf('u9').length, cubit.myStories.length);
      await cubit.close();
    });

    test('empty server keeps mocks and reports false', () async {
      final repo = _FakeCommunityRepository()
        ..feedResult = const FirestoreEmpty()
        ..storiesResult = const FirestoreEmpty();
      final cubit = CommunityCubit(repository: repo, uid: 'u1');
      final before = cubit.posts.map((p) => p.id).toList();
      final ok = await cubit.refreshRemote();
      expect(ok, isFalse);
      expect(cubit.posts.map((p) => p.id).toList(), before);
      await cubit.close();
    });

    test('failure keeps mocks and reports false', () async {
      final repo = _FakeCommunityRepository()
        ..feedResult = const FirestoreFailure<List<CommunityPost>>('offline')
        ..storiesResult = const FirestoreFailure<List<CommunityStory>>(
          'offline',
        );
      final cubit = CommunityCubit(repository: repo, uid: 'u1');
      final ok = await cubit.refreshRemote();
      expect(ok, isFalse);
      expect(cubit.posts, isNotEmpty);
      await cubit.close();
    });
  });

  group('CommunityCubit create/delete/like', () {
    test('text post persists with author identity, prepended', () async {
      final repo = _FakeCommunityRepository();
      final cubit = CommunityCubit(repository: repo, uid: 'u1');
      final id = await cubit.createPost(
        text: 'Hello Nile',
        imagePaths: const [],
        location: 'Cairo',
        authorName: 'Ada',
        authorAvatarUrl: 'http://av',
      );
      expect(id, 'server-post-1');
      expect(repo.addCalls, 1);
      expect(repo.lastCreate!['authorId'], 'u1');
      expect(repo.lastCreate!['authorName'], 'Ada');
      expect(repo.lastCreate!['text'], 'Hello Nile');
      expect(cubit.posts.first.id, 'server-post-1');
      expect(cubit.posts.first.isMine, isTrue);
      await cubit.close();
    });

    test('image post is refused without touching the backend', () async {
      final repo = _FakeCommunityRepository();
      final cubit = CommunityCubit(repository: repo, uid: 'u1');
      final before = cubit.posts.length;
      await expectLater(
        cubit.createPost(
          text: 'pics',
          imagePaths: const ['/tmp/a.jpg'],
          authorName: 'Ada',
          authorAvatarUrl: '',
        ),
        throwsA(
          predicate((e) => e.toString().contains('uploads are not available')),
        ),
      );
      expect(repo.addCalls, 0);
      expect(cubit.posts.length, before);
      await cubit.close();
    });

    test('empty post is refused', () async {
      final repo = _FakeCommunityRepository();
      final cubit = CommunityCubit(repository: repo, uid: 'u1');
      await expectLater(
        cubit.createPost(
          imagePaths: const [],
          authorName: 'Ada',
          authorAvatarUrl: '',
        ),
        throwsA(predicate((e) => e.toString().contains('Write something'))),
      );
      expect(repo.addCalls, 0);
      await cubit.close();
    });

    test('own post deletes via backend; others rejected first', () async {
      final repo = _FakeCommunityRepository()
        ..feedResult = FirestoreOk<List<CommunityPost>>([
          _post(id: 'mine', isMine: true),
          _post(id: 'theirs'),
        ]);
      final cubit = CommunityCubit(repository: repo, uid: 'u1');
      await cubit.refreshRemote();
      await expectLater(
        cubit.deletePostRemote(cubit.posts.firstWhere((p) => p.id == 'theirs')),
        throwsA(predicate((e) => e.toString().contains('others'))),
      );
      expect(repo.deleteCalls, 0);
      final ok = await cubit.deletePostRemote(
        cubit.posts.firstWhere((p) => p.id == 'mine'),
      );
      expect(ok, isTrue);
      expect(repo.deleteCalls, 1);
      expect(cubit.posts.any((p) => p.id == 'mine'), isFalse);
      await cubit.close();
    });

    test('like persists with prior state; reverts + false on error', () async {
      final repo = _FakeCommunityRepository()
        ..feedResult = FirestoreOk<List<CommunityPost>>([_post()]);
      final cubit = CommunityCubit(repository: repo, uid: 'u1');
      await cubit.refreshRemote();
      final post = cubit.posts.single;
      final ok = await cubit.toggleLikePersistent(post);
      expect(ok, isTrue);
      expect(post.isLiked, isTrue);
      expect(post.likesCount, 4);
      expect(repo.lastLikePost, 'p1');
      expect(repo.lastLikeUid, 'u1');
      expect(repo.lastLikeWasLiked, isFalse);
      repo.likeError = Exception('offline');
      final ok2 = await cubit.toggleLikePersistent(post);
      expect(ok2, isFalse);
      // Reverted to the pre-toggle state (liked, 4) — never a wrong count.
      expect(post.isLiked, isTrue);
      expect(post.likesCount, 4);
      await cubit.close();
    });

    test('server story delete persists; local story skips backend', () async {
      final repo = _FakeCommunityRepository()
        ..storiesResult = FirestoreOk<List<CommunityStory>>([
          _serverStory(id: 's9', mine: true),
        ]);
      final cubit = CommunityCubit(repository: repo, uid: 'u1');
      await cubit.refreshRemote();
      cubit.addMyStory('/tmp/local.jpg');
      final ok = await cubit.deleteStoryRemote(
        cubit.myStories.firstWhere((s) => s.id == 's9'),
      );
      expect(ok, isTrue);
      expect(repo.deleteCalls, 1);
      final localOk = await cubit.deleteStoryRemote(
        cubit.myStories.firstWhere((s) => s.isLocalFile),
      );
      expect(localOk, isTrue);
      expect(repo.deleteCalls, 1);
      await cubit.close();
    });
  });

  group('Tourist NotificationsCubit', () {
    test('remote mode is enabled (Phase 6 activation)', () {
      expect(NotificationsCubit.useRemote, isTrue);
    });

    test('load replaces mocks; sections + unread from server', () async {
      final repo = _FakeNotificationsRepository()
        ..listResult = FirestoreOk<List<NotificationItem>>([
          _item(id: 'a', section: 'today'),
          _item(id: 'b', section: 'earlier'),
        ]);
      final cubit = NotificationsCubit(repo);
      final ok = await cubit.loadRemote('u1');
      expect(ok, isTrue);
      expect(cubit.today.map((n) => n.id), ['a']);
      expect(cubit.earlier.map((n) => n.id), ['b']);
      expect(cubit.unreadCount, 2);
      await cubit.close();
    });

    test('empty keeps mocks and reports false', () async {
      final repo = _FakeNotificationsRepository()
        ..listResult = const FirestoreEmpty();
      final cubit = NotificationsCubit(repo);
      final before = cubit.unreadCount;
      final ok = await cubit.loadRemote('u1');
      expect(ok, isFalse);
      expect(cubit.unreadCount, before);
      await cubit.close();
    });

    test('mark one/all persist via the repository', () async {
      final repo = _FakeNotificationsRepository()
        ..listResult = FirestoreOk<List<NotificationItem>>([_item()]);
      final cubit = NotificationsCubit(repo);
      await cubit.loadRemote('u1');
      expect(await cubit.markOneReadRemote('u1', 'n1'), isTrue);
      expect(repo.markOneCalls, 1);
      expect(cubit.unreadCount, 0);
      expect(await cubit.markAllReadRemote('u1'), isTrue);
      expect(repo.markAllCalls, 1);
      await cubit.close();
    });

    test('failed mark returns false (local flip stays optimistic)', () async {
      final repo = _FakeNotificationsRepository()
        ..listResult = FirestoreOk<List<NotificationItem>>([_item()])
        ..markError = Exception('offline');
      final cubit = NotificationsCubit(repo);
      await cubit.loadRemote('u1');
      expect(await cubit.markOneReadRemote('u1', 'n1'), isFalse);
      await cubit.close();
    });
  });

  group('Guide notifications', () {
    test('remote mode is enabled (Phase 6 activation)', () {
      expect(GuideNotificationsCubit.useRemote, isTrue);
    });

    test('load replaces mocks; read state + unread count', () async {
      final repo = _FakeNotificationsRepository()
        ..guideResult = FirestoreOk<List<GuideNotification>>([
          const GuideNotification(
            id: 'g1',
            type: 'booking',
            title: 'T',
            body: 'B',
            isRead: false,
            timeLabel: '2h ago',
          ),
        ]);
      final cubit = GuideNotificationsCubit(repo);
      final ok = await cubit.loadRemote('guide1');
      expect(ok, isTrue);
      expect(cubit.state.items.map((n) => n.id), ['g1']);
      expect(cubit.unreadCount, 1);
      expect(await cubit.markOneReadRemote('g1'), isTrue);
      expect(repo.markOneCalls, 1);
      expect(cubit.unreadCount, 0);
      expect(await cubit.markAllReadRemote('guide1'), isTrue);
      expect(repo.markAllCalls, 1);
      await cubit.close();
    });

    test('empty keeps mocks and reports false', () async {
      final repo = _FakeNotificationsRepository()
        ..guideResult = const FirestoreEmpty();
      final cubit = GuideNotificationsCubit(repo);
      final before = cubit.state.items.map((n) => n.id).toList();
      final ok = await cubit.loadRemote('guide1');
      expect(ok, isFalse);
      expect(cubit.state.items.map((n) => n.id).toList(), before);
      await cubit.close();
    });

    test('model defaults keep legacy mocks compiling', () {
      const n = GuideNotification(id: 'x', type: 't', title: 'a', body: 'b');
      expect(n.isRead, isTrue);
      expect(n.timeLabel, isEmpty);
      expect(n.copyWith(isRead: false).isRead, isFalse);
    });
  });

  group('firestore mappers (community/notifications)', () {
    test('post maps author + mine flag', () {
      const doc = PostDoc(
        id: 'p',
        authorId: 'u1',
        authorName: 'Ada',
        text: 'hi',
        likesCount: 5,
      );
      final mine = FirestoreMappers.postDocToPost(doc, currentUid: 'u1');
      expect(mine.isMine, isTrue);
      expect(mine.likesCount, 5);
      final other = FirestoreMappers.postDocToPost(doc, currentUid: 'u2');
      expect(other.isMine, isFalse);
    });

    test('notification section splits today vs earlier', () {
      final now = NotificationDoc.fromMap({
        'userId': 'u',
        'title': 't',
        'createdAt': DateTime.now(),
      }, 'n1');
      expect(FirestoreMappers.notificationDocToItem(now).section, 'today');
      final old = NotificationDoc.fromMap({
        'userId': 'u',
        'title': 't',
        'createdAt': DateTime.now().subtract(const Duration(days: 2)),
      }, 'n2');
      expect(FirestoreMappers.notificationDocToItem(old).section, 'earlier');
      final missing = NotificationDoc.fromMap({'userId': 'u'}, 'n3');
      expect(
        FirestoreMappers.notificationDocToItem(missing).section,
        'earlier',
      );
    });

    test('guide notification carries read state + time', () {
      final doc = NotificationDoc.fromMap({
        'userId': 'g',
        'title': 't',
        'message': 'm',
        'isRead': true,
        'createdAt': DateTime.now(),
      }, 'n9');
      final item = FirestoreMappers.notificationDocToGuideNotification(doc);
      expect(item.isRead, isTrue);
      expect(item.timeLabel, isNotEmpty);
      expect(item.body, 'm');
    });
  });
}
