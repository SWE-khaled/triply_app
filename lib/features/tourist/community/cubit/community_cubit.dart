import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/mock/tourist/mock_community.dart';
import '../model/community_post.dart';
import '../model/community_story.dart';
import 'community_state.dart';

/// Mock signed-in user id. Replace with the real auth uid when a backend
/// exists; ownership checks below already key off it.
const String currentUserId = 'me';

class CommunityCubit extends Cubit<CommunityState> {
  CommunityCubit()
      : super(
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
    if (userId == currentUserId) return state.myStories;
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

  /// Appends a gallery image to MY stories. Returns the created story.
  CommunityStory addMyStory(String imagePath) {
    final story = CommunityStory(
      id: 'my_story_${DateTime.now().millisecondsSinceEpoch}',
      userId: currentUserId,
      userName: 'You',
      imageUrl: imagePath,
      isMine: true,
      isLocalFile: true,
    );
    final myStories = [...state.myStories, story];
    emit(state.copyWith(myStories: myStories));
    return story;
  }

  /// Deletes a story only if it is mine and the id matches.
  /// Returns true when something was actually removed.
  bool deleteStory(CommunityStory story) {
    if (!story.isMine || story.userId != currentUserId) return false;
    final before = state.myStories.length;
    final myStories =
        state.myStories.where((s) => s.id != story.id).toList();
    final removed = myStories.length < before;
    if (removed) emit(state.copyWith(myStories: myStories));
    return removed;
  }

  /// Adds a new post (from the composer) to the top of the feed.
  /// authorAvatarUrl is intentionally left empty so the post card falls
  /// back to the generic profile icon instead of showing the post photo.
  void addPost({
    required List<String> imagePaths,
    String? text,
    String? location,
  }) {
    if (imagePaths.isEmpty && (text == null || text.trim().isEmpty)) {
      return;
    }
    emit(
      state.copyWith(
        posts: [
          CommunityPost(
            id: 'post_${DateTime.now().millisecondsSinceEpoch}',
            authorName: 'You',
            authorAvatarUrl: '',
            timeAgo: 'Just now',
            location: location ?? '',
            imageUrl: imagePaths.isEmpty ? '' : imagePaths.first,
            imageUrls: List<String>.from(imagePaths),
            text: text ?? '',
            likesCount: 0,
            commentsCount: 0,
            isLocalImage: true,
            isMine: true,
          ),
          ...state.posts,
        ],
      ),
    );
  }

  /// Deletes a post only if it is mine and the id matches.
  /// Returns true when something was actually removed.
  bool deletePost(CommunityPost post) {
    final index = state.posts.indexWhere((p) => p.id == post.id);
    if (index == -1 || !state.posts[index].isMine) return false;
    final posts = [...state.posts]..removeAt(index);
    emit(state.copyWith(posts: posts));
    return true;
  }
}
