import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../data/community_posts_repository.dart';
import '../data/community_stories_repository.dart';
import '../model/community_post.dart';
import '../model/community_story.dart';
import 'community_state.dart';

class CommunityCubit extends Cubit<CommunityState> {
  CommunityCubit({
    CommunityPostsRepository? postsRepository,
    CommunityStoriesRepository? storiesRepository,
    DateTime Function()? now,
  }) : _postsRepository =
           postsRepository ?? FirestoreCommunityPostsRepository(),
       _storiesRepository =
           storiesRepository ?? FirestoreCommunityStoriesRepository(),
       _now = now ?? DateTime.now,
       super(
         CommunityState(
           // Both feeds are Firestore-backed. Mock data must not appear while
           // the first snapshot is loading or when a read is denied.
           stories: const [],
           myStories: const [],
           posts: const [],
           isLoadingStories: true,
           isLoadingPosts: true,
         ),
       ) {
    _postsSubscription = _postsRepository.watchPosts().listen(
      _onPosts,
      onError: _onPostsError,
    );
    _storiesSubscription = _storiesRepository.watchStories().listen(
      _onStories,
      onError: _onStoriesError,
    );
    _expiryTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => pruneExpiredStories(),
    );
  }

  final CommunityPostsRepository _postsRepository;
  final CommunityStoriesRepository _storiesRepository;
  final DateTime Function() _now;
  final Set<String> _likeRequestsInFlight = <String>{};

  StreamSubscription<List<CommunityPost>>? _postsSubscription;
  StreamSubscription<List<CommunityStory>>? _storiesSubscription;
  Timer? _expiryTimer;

  /// Stories of a single user only — the viewer must never mix users.
  /// Ordered oldest first, which is the natural Story playback order.
  List<CommunityStory> storiesOf(String authorId) {
    final stories =
        [
            ...state.myStories,
            ...state.stories,
          ].where((story) => story.authorId == authorId).toList()
          ..sort((a, b) => _createdAt(a).compareTo(_createdAt(b)));
    return stories;
  }

  /// One ring per user (newest Story is the cover), "mine" excluded.
  List<CommunityStory> get userRings {
    final seen = <String>{};
    final rings = <CommunityStory>[];
    for (final story in state.stories) {
      if (seen.add(story.authorId)) rings.add(story);
    }
    return rings;
  }

  List<CommunityStory> get myStories => state.myStories;

  List<CommunityPost> get posts => state.posts;

  void _onPosts(List<CommunityPost> posts) {
    if (isClosed) return;

    emit(
      state.copyWith(
        posts: posts,
        isLoadingPosts: false,
        clearPostsError: true,
      ),
    );
  }

  void _onPostsError(Object error, StackTrace stackTrace) {
    if (isClosed) return;

    emit(
      state.copyWith(
        isLoadingPosts: false,
        postsError: error is CommunityPostsException
            ? error.message
            : 'Could not load Community posts.',
      ),
    );
  }

  void _onStories(List<CommunityStory> stories) {
    if (isClosed) return;

    final at = _now();
    final mine = <CommunityStory>[];
    final others = <CommunityStory>[];
    final seen = <String>{};

    for (final story in stories) {
      if (!story.isDisplayableAt(at)) continue;
      // A newly published Story can reach the stream before/after the
      // optimistic entry. Deduplicate defensively by document id.
      if (!seen.add(story.id)) continue;
      if (story.isMine) {
        mine.add(story);
      } else {
        others.add(story);
      }
    }

    mine.sort(_newestFirst);
    others.sort(_newestFirst);

    emit(
      state.copyWith(
        stories: others,
        myStories: mine,
        isLoadingStories: false,
        clearStoriesError: true,
      ),
    );
  }

  void _onStoriesError(Object error, StackTrace stackTrace) {
    if (isClosed) return;

    emit(
      state.copyWith(
        isLoadingStories: false,
        storiesError: error is CommunityStoriesException
            ? error.message
            : 'Could not load Community Stories.',
      ),
    );
  }

  /// Removes Stories whose authoritative `createdAt + 24h` has passed.
  ///
  /// Called by the Cubit timer and from the Community screen when the app
  /// resumes from the background.
  void pruneExpiredStories([DateTime? now]) {
    if (isClosed) return;

    final at = now ?? _now();
    final mine = state.myStories
        .where((story) => story.isDisplayableAt(at))
        .toList(growable: false);
    final others = state.stories
        .where((story) => story.isDisplayableAt(at))
        .toList(growable: false);

    if (mine.length == state.myStories.length &&
        others.length == state.stories.length) {
      return;
    }

    emit(state.copyWith(stories: others, myStories: mine));
  }

  Future<void> toggleLike(CommunityPost post) async {
    // Ignore extra taps while this post's transaction is in flight. The
    // repository transaction also makes a repeated target a no-op.
    if (!_likeRequestsInFlight.add(post.id)) return;
    try {
      await _postsRepository.toggleLike(postId: post.id, liked: !post.isLiked);
      // The Firestore snapshot updates the count and isLiked state.
    } finally {
      _likeRequestsInFlight.remove(post.id);
    }
  }

  /// Uploads the Story image, writes Firestore metadata, then updates state.
  /// No local Story is created when either step fails.
  Future<CommunityStory> publishStory(XFile image) async {
    final story = await _storiesRepository.createStory(image);
    if (isClosed) return story;

    final activeMine = state.myStories
        .where((item) => item.id != story.id && item.isDisplayableAt(_now()))
        .toList();
    final activeOthers = state.stories
        .where((item) => item.id != story.id && item.isDisplayableAt(_now()))
        .toList();

    emit(
      state.copyWith(myStories: [story, ...activeMine], stories: activeOthers),
    );
    return story;
  }

  /// Deletes a Story through Firestore. Ownership is enforced by the
  /// repository as well as by the local [CommunityStory.isMine] flag.
  Future<void> deleteStory(CommunityStory story) async {
    if (!story.isMine) {
      throw const CommunityStoriesException(
        'You can only delete your own Stories.',
      );
    }
    await _storiesRepository.deleteStory(story);
    if (isClosed) return;

    emit(
      state.copyWith(
        myStories: state.myStories
            .where((item) => item.id != story.id)
            .toList(),
        stories: state.stories.where((item) => item.id != story.id).toList(),
      ),
    );
  }

  /// Uploads selected media, then creates the Firestore document. The UI only
  /// reports success after both operations complete.
  Future<void> publishPost({
    required List<XFile> images,
    required String text,
    String? location,
  }) async {
    final post = await _postsRepository.createPost(
      images: images,
      text: text,
      location: location,
    );
    if (isClosed) return;

    final posts = state.posts.where((item) => item.id != post.id).toList();
    emit(state.copyWith(posts: [post, ...posts]));
  }

  Future<void> deletePost(CommunityPost post) async {
    if (!post.isMine) {
      throw const CommunityPostsException(
        'You can only delete your own posts.',
      );
    }
    await _postsRepository.deletePost(post);
    if (isClosed) return;

    emit(
      state.copyWith(
        posts: state.posts.where((item) => item.id != post.id).toList(),
      ),
    );
  }

  static DateTime _createdAt(CommunityStory story) =>
      story.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  static int _newestFirst(CommunityStory a, CommunityStory b) =>
      _createdAt(b).compareTo(_createdAt(a));

  @override
  Future<void> close() async {
    _expiryTimer?.cancel();
    await _postsSubscription?.cancel();
    await _storiesSubscription?.cancel();
    return super.close();
  }
}
