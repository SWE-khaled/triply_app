import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/firebase/firestore_result.dart';
import 'package:triply/data/firestore/datasources/cloudinary_uploader.dart';
import 'package:triply/data/firestore/datasources/community_media_storage.dart';
import 'package:triply/data/firestore/datasources/firestore_query_helper.dart';
import 'package:triply/data/firestore/repositories/community_repository.dart';
import '../../../../core/data/mock/tourist/mock_community.dart';
import '../model/community_post.dart';
import '../model/community_story.dart';
import 'community_state.dart';

class CommunityCubit extends Cubit<CommunityState> {
  /// Kill-switch: gates every remote call in the View. Phase 6 (community)
  /// is activated; flipping back to `false` is instant rollback to the
  /// mock baseline.
  static const bool useRemote = true;

  final CommunityRepository _repository;

  /// Firebase uid of the viewer. Defaults to the legacy local id so unit
  /// tests and signed-out previews keep working; the View passes the real
  /// uid, which drives `isMine` and all ownership checks below.
  final String uid;

  CommunityCubit({CommunityRepository? repository, String? uid})
    : _repository = repository ?? CommunityRepository(),
      uid = uid ?? 'me',
      super(
        CommunityState(
          stories: mockCommunityStories
              .map((e) => CommunityStory.fromJson(e))
              .toList(),
          myStories: [],
          posts: mockCommunityPosts
              .map((e) => CommunityPost.fromJson(e))
              .toList(),
        ),
      );

  /// Stories of a single user only — the viewer must never mix users.
  List<CommunityStory> storiesOf(String userId) {
    if (userId == uid) return state.myStories;
    return state.stories.where((s) => s.userId == userId).toList();
  }

  /// One ring per user (first story is the cover), "mine" excluded.
  List<CommunityStory> get userRings {
    final seen = <String>{};
    final rings = <CommunityStory>[];
    for (final s in state.stories) {
      if (seen.add(s.userId)) rings.add(s);
    }
    return rings;
  }

  List<CommunityStory> get myStories => state.myStories;

  List<CommunityPost> get posts => state.posts;

  void _emitCopy() {
    emit(
      state.copyWith(
        stories: [...state.stories],
        myStories: [...state.myStories],
        posts: [...state.posts],
      ),
    );
  }

  void toggleLike(CommunityPost post) {
    post.isLiked = !post.isLiked;
    post.likesCount += post.isLiked ? 1 : -1;
    _emitCopy();
  }

  /// Appends a gallery image to MY stories (session-local: there is no
  /// media-upload backend in this phase, so stories cannot persist).
  /// Returns the created story.
  CommunityStory addMyStory(String imagePath) {
    final story = CommunityStory(
      id: 'my_story_${DateTime.now().millisecondsSinceEpoch}',
      userId: uid,
      userName: 'You',
      imageUrl: imagePath,
      isMine: true,
      isLocalFile: true,
    );
    final myStories = [...state.myStories, story];
    emit(state.copyWith(myStories: myStories));
    return story;
  }

  /// Deletes a session-local story. Server stories go through
  /// [deleteStoryRemote]; returns true when something was removed.
  bool deleteStory(CommunityStory story) {
    if (!story.isMine || story.userId != uid) return false;
    final before = state.myStories.length;
    final myStories = state.myStories.where((s) => s.id != story.id).toList();
    final removed = myStories.length < before;
    if (removed) emit(state.copyWith(myStories: myStories));
    return removed;
  }

  /// Deletes a story, persisting server stories via the backend.
  /// Ownership is enforced here AND by rules; throws with a user-facing
  /// message otherwise. Local-only stories just drop from the session.
  Future<bool> deleteStoryRemote(CommunityStory story) async {
    if (!story.isMine || story.userId != uid) {
      throw Exception("You can only delete your own stories.");
    }
    if (!story.isLocalFile) {
      await _repository.deleteStory(story.id);
    }
    return deleteStory(story);
  }

  /// Uploads a gallery photo and persists it as a `stories/` document
  /// (24h expiry), then prepends the real record to MY stories. Unlike
  /// [addMyStory] (session-local preview), the story survives tab switches
  /// and restarts via [refreshRemote]. Throws with a user-facing message
  /// on any failure, in which case nothing is added locally.
  Future<String> createStoryRemote({
    required String imagePath,
    required String userName,
  }) async {
    if (uid.isEmpty || uid == 'me') {
      throw Exception('Please sign in to share a story.');
    }
    final path = imagePath.trim();
    if (path.isEmpty) {
      throw Exception('Select a photo first.');
    }
    final String mediaUrl;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      mediaUrl = path;
    } else {
      final file = File(path);
      if (!await file.exists()) {
        throw Exception('Photo could not be read.');
      }
      mediaUrl = await CloudinaryUploader().uploadImageFile(file);
    }
    try {
      final id = await _repository.addStory(
        userId: uid,
        userName: userName,
        mediaUrl: mediaUrl,
      );
      emit(
        state.copyWith(
          myStories: [
            CommunityStory(
              id: id,
              userId: uid,
              userName: 'You',
              imageUrl: mediaUrl,
              isMine: true,
            ),
            ...state.myStories,
          ],
        ),
      );
      return id;
    } catch (e) {
      throw Exception(FirestoreQueryHelper.friendlyError(e));
    }
  }

  /// Creates a text/location/photo post on the backend and prepends the
  /// real record. Gallery photos are uploaded (Cloudinary) first; their
  /// download URLs persist in `posts/{id}.imageUrls` so every viewer sees
  /// the same images. Throws with a user-facing message on any failure,
  /// in which case nothing is added locally.
  Future<String> createPost({
    String? text,
    required List<String> imagePaths,
    String? location,
    required String authorName,
    required String authorAvatarUrl,
  }) async {
    List<String> imageUrls = const [];
    if (imagePaths.isNotEmpty) {
      imageUrls = await CommunityMediaStorage().uploadPostImages(
        uid,
        imagePaths,
      );
    }
    if (text == null || text.trim().isEmpty) {
      if (imageUrls.isEmpty) {
        throw Exception('Write something or select at least one image.');
      }
    }
    final id = await _repository.addPost(
      authorId: uid,
      authorName: authorName,
      authorAvatarUrl: authorAvatarUrl,
      text: (text ?? '').trim(),
      imageUrls: imageUrls,
      location: location ?? '',
    );
    emit(
      state.copyWith(
        posts: [
          CommunityPost(
            id: id,
            authorName: authorName,
            authorAvatarUrl: authorAvatarUrl,
            timeAgo: 'Just now',
            location: location ?? '',
            imageUrl: imageUrls.isNotEmpty ? imageUrls.first : '',
            imageUrls: imageUrls,
            text: (text ?? '').trim(),
            likesCount: 0,
            commentsCount: 0,
            isMine: true,
          ),
          ...state.posts,
        ],
      ),
    );
    return id;
  }

  /// Deletes a post, persisting via the backend. Ownership is enforced
  /// here AND by rules; throws with a user-facing message otherwise.
  Future<bool> deletePostRemote(CommunityPost post) async {
    if (!post.isMine) {
      throw Exception("You can't delete others post!");
    }
    await _repository.deletePost(post.id);
    final posts = state.posts.where((p) => p.id != post.id).toList();
    emit(state.copyWith(posts: posts));
    return true;
  }

  /// Best-effort remote feed refresh. Returns true when remote data replaced
  /// the feed; false when mocks were kept — callers must surface this, never
  /// present the mock feed as live data.
  /// Server stories merge with session-local ones (which cannot persist
  /// without an upload backend); server posts replace the list.
  Future<bool> refreshRemote() async {
    try {
      final posts = await _repository.feed(uid);
      final stories = await _repository.activeStories(uid);
      List<CommunityPost>? nextPosts;
      List<CommunityStory>? nextStories;
      List<CommunityStory>? nextMine;
      if (posts is FirestoreOk<List<CommunityPost>> && posts.data.isNotEmpty) {
        nextPosts = posts.data;
      }
      if (stories is FirestoreOk<List<CommunityStory>> &&
          stories.data.isNotEmpty) {
        nextMine = stories.data.where((s) => s.isMine).toList();
        nextStories = stories.data.where((s) => !s.isMine).toList();
      }
      if (nextPosts == null && nextStories == null) {
        debugPrint('Triply: CommunityCubit.refreshRemote kept mock feed.');
        return false;
      }
      // Session-local stories (unpersistable without uploads) survive
      // alongside server ones instead of vanishing on refresh.
      final localMine = state.myStories.where((s) => s.isLocalFile).toList();
      emit(
        state.copyWith(
          stories: nextStories ?? state.stories,
          myStories: nextMine == null
              ? state.myStories
              : [...nextMine, ...localMine],
          posts: nextPosts ?? state.posts,
        ),
      );
      return true;
    } catch (e) {
      debugPrint('Triply: CommunityCubit.refreshRemote failed: $e');
      return false;
    }
  }

  /// Optimistic like toggle (existing behavior) + persistent write.
  /// Reverts the optimistic flip when the write fails and returns false;
  /// the View surfaces this (never a silent wrong count).
  Future<bool> toggleLikePersistent(CommunityPost post) async {
    toggleLike(post);
    try {
      await _repository.toggleLike(
        postId: post.id,
        uid: uid,
        currentlyLiked: !post.isLiked,
      );
      return true;
    } catch (e) {
      debugPrint('Triply: toggleLikePersistent failed, reverting: $e');
      toggleLike(post);
      return false;
    }
  }
}
