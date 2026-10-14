import 'package:triply/core/firebase/firestore_result.dart';
import 'package:triply/data/firestore/datasources/firestore_query_helper.dart';
import 'package:triply/data/firestore/datasources/posts_datasource.dart';
import 'package:triply/data/firestore/datasources/stories_datasource.dart';
import 'package:triply/data/firestore/mappers/firestore_mappers.dart';
import 'package:triply/data/firestore/models/post_doc.dart';
import 'package:triply/data/firestore/models/story_doc.dart';
import 'package:triply/features/tourist/community/model/community_post.dart';
import 'package:triply/features/tourist/community/model/community_story.dart';

/// Community reads/writes. Failures are explicit ([FirestoreFailure]) —
///
/// the repository never disguises a failure as mock data; cubits keep
/// their own baseline and report the failure (offline notice), so mock
/// content is never presented as a successful Firestore read.
///
/// Likes are persistent (`posts/{id}/likes/{uid}`); the UI keeps its
/// optimistic +/-1 on top of the server aggregate.
class CommunityRepository {
  PostsDatasource? _postsDS;
  StoriesDatasource? _storiesDS;
  CommunityRepository({PostsDatasource? posts, StoriesDatasource? stories})
    : _postsDS = posts,
      _storiesDS = stories;

  // Lazy: constructing the repository must not touch Firebase (keeps
  // widget/unit tests and offline startup free of Firebase initialization).
  PostsDatasource get _posts => _postsDS ??= PostsDatasource();
  StoriesDatasource get _stories => _storiesDS ??= StoriesDatasource();

  Future<FirestoreResult<List<CommunityPost>>> feed(
    String currentUid, {
    int limit = 20,
    Object? startAfter,
  }) async {
    try {
      final page = await _posts.feed(limit: limit, startAfter: startAfter);
      // Per-user like state lives in `posts/{id}/likes/{uid}`, which the
      // mapper can't see — enrich here so rebuilt feeds keep hearts lit.
      // Skipped for signed-out previews (CommunityCubit uid 'me'): those
      // like docs can never exist. Likes written before this fix are
      // already in the subcollection, so they light up with no migration.
      final liked = currentUid == 'me' || currentUid.isEmpty
          ? <String>{}
          : await _posts.likedIds(
              page.items.map((d) => d.id).toList(), currentUid);
      // True totals come from the live `likes` subcollection, NOT the
      // stored `likesCount` field (only refreshed by the
      // `onPostLikeWritten` Function when deployed). Parallel counts;
      // a failure keeps the stored aggregate instead of failing the feed.
      Map<String, int> counts = const {};
      try {
        final entries = await Future.wait(
          page.items.map((d) async => MapEntry(d.id, await _posts.countLikes(d.id))),
        );
        counts = Map.fromEntries(entries);
      } catch (_) {}
      final items = page.items
          .map((d) {
            final post = FirestoreMappers.postDocToPost(
              d,
              currentUid: currentUid,
              isLiked: liked.contains(d.id),
            );
            if (counts.containsKey(d.id)) post.likesCount = counts[d.id]!;
            return post;
          })
          .toList();
      if (items.isEmpty) return const FirestoreEmpty();
      return FirestoreOk(items);
    } catch (e) {
      return FirestoreFailure(FirestoreQueryHelper.friendlyError(e), e);
    }
  }

  Future<FirestoreResult<List<CommunityStory>>> activeStories(
    String currentUid,
  ) async {
    try {
      final docs = await _stories.listActive();
      final items = docs
          .map(
            (d) => FirestoreMappers.storyDocToStory(d, currentUid: currentUid),
          )
          .toList();
      if (items.isEmpty) return const FirestoreEmpty();
      return FirestoreOk(items);
    } catch (e) {
      return FirestoreFailure(FirestoreQueryHelper.friendlyError(e), e);
    }
  }

  Future<String> addPost({
    required String authorId,
    String authorName = '',
    String authorAvatarUrl = '',
    String text = '',
    List<String> imageUrls = const [],
    String location = '',
  }) {
    return _posts.create(
      PostDoc(
        id: '',
        authorId: authorId,
        authorName: authorName,
        authorAvatarUrl: authorAvatarUrl,
        text: text,
        imageUrls: imageUrls,
        location: location,
      ),
    );
  }

  Future<void> deletePost(String postId) => _posts.delete(postId);

  Future<void> toggleLike({
    required String postId,
    required String uid,
    required bool currentlyLiked,
  }) {
    return currentlyLiked
        ? _posts.unlike(postId, uid)
        : _posts.like(postId, uid);
  }

  Future<String> addStory({
    required String userId,
    String userName = '',
    required String mediaUrl,
  }) {
    return _stories.create(
      StoryDoc(id: '', userId: userId, userName: userName, mediaUrl: mediaUrl),
    );
  }

  Future<void> deleteStory(String storyId) => _stories.delete(storyId);
}
