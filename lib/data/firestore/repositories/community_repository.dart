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
      final items = page.items
          .map((d) => FirestoreMappers.postDocToPost(d, currentUid: currentUid))
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
