import '../model/community_post.dart';
import '../model/community_story.dart';

class CommunityState {
  /// Other tourists' active Stories from Firestore. Never contains my Stories.
  final List<CommunityStory> stories;

  /// The signed-in tourist's active Stories from Firestore.
  final List<CommunityStory> myStories;

  final List<CommunityPost> posts;
  final bool isLoadingStories;
  final String? storiesError;
  final bool isLoadingPosts;
  final String? postsError;

  const CommunityState({
    required this.stories,
    required this.myStories,
    required this.posts,
    this.isLoadingStories = false,
    this.storiesError,
    this.isLoadingPosts = false,
    this.postsError,
  });

  /// The posts area should show its empty message only after loading has
  /// finished, without an error, and with no posts to display.
  bool get showPostsEmptyState =>
      !isLoadingPosts && postsError == null && posts.isEmpty;

  CommunityState copyWith({
    List<CommunityStory>? stories,
    List<CommunityStory>? myStories,
    List<CommunityPost>? posts,
    bool? isLoadingStories,
    String? storiesError,
    bool clearStoriesError = false,
    bool? isLoadingPosts,
    String? postsError,
    bool clearPostsError = false,
  }) {
    return CommunityState(
      stories: stories ?? this.stories,
      myStories: myStories ?? this.myStories,
      posts: posts ?? this.posts,
      isLoadingStories: isLoadingStories ?? this.isLoadingStories,
      storiesError: clearStoriesError
          ? null
          : (storiesError ?? this.storiesError),
      isLoadingPosts: isLoadingPosts ?? this.isLoadingPosts,
      postsError: clearPostsError ? null : (postsError ?? this.postsError),
    );
  }
}
