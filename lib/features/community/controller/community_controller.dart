import '../../../data/mock/mock_community.dart';
import '../model/community_post.dart';
import '../model/community_story.dart';

/// Mock signed-in user id. Replace with the real auth uid when a backend
/// exists; ownership checks below already key off it.
const String currentUserId = 'me';

class CommunityController {
  /// Other users' stories (mock feed data). Never contains my stories.
  late final List<CommunityStory> stories;

  /// My own stories only. Empty means I haven't posted one yet.
  final List<CommunityStory> myStories = [];

  late final List<CommunityPost> posts;

  CommunityController() {
    stories =
        mockCommunityStories.map((e) => CommunityStory.fromJson(e)).toList();
    posts = mockCommunityPosts.map((e) => CommunityPost.fromJson(e)).toList();
  }

  /// Stories of a single user only — the viewer must never mix users.
  List<CommunityStory> storiesOf(String userId) {
    if (userId == currentUserId) return myStories;
    return stories.where((s) => s.userId == userId).toList();
  }

  /// One ring per user (first story is the cover), "mine" excluded.
  List<CommunityStory> get userRings {
    final seen = <String>{};
    final rings = <CommunityStory>[];
    for (final s in stories) {
      if (seen.add(s.userId)) rings.add(s);
    }
    return rings;
  }

  void toggleLike(CommunityPost post) {
    post.isLiked = !post.isLiked;
    post.likesCount += post.isLiked ? 1 : -1;
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
    myStories.add(story);
    return story;
  }

  /// Deletes a story only if it is mine and the id matches.
  /// Returns true when something was actually removed.
  bool deleteStory(CommunityStory story) {
    if (!story.isMine || story.userId != currentUserId) return false;
    final before = myStories.length;
    myStories.removeWhere((s) => s.id == story.id);
    return myStories.length < before;
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
    posts.insert(
      0,
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
    );
  }

  /// Deletes a post only if it is mine and the id matches.
  /// Returns true when something was actually removed.
  bool deletePost(CommunityPost post) {
    final index = posts.indexWhere((p) => p.id == post.id);
    if (index == -1 || !posts[index].isMine) return false;
    posts.removeAt(index);
    return true;
  }
}
