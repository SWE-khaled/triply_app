import '../model/community_post.dart';
import '../model/community_story.dart';

class CommunityState {
  /// Other users' stories (mock feed data). Never contains my stories.
  final List<CommunityStory> stories;

  /// My own stories only. Empty means I haven't posted one yet.
  final List<CommunityStory> myStories;

  final List<CommunityPost> posts;

  const CommunityState({
    required this.stories,
    required this.myStories,
    required this.posts,
  });

  CommunityState copyWith({
    List<CommunityStory>? stories,
    List<CommunityStory>? myStories,
    List<CommunityPost>? posts,
  }) {
    return CommunityState(
      stories: stories ?? this.stories,
      myStories: myStories ?? this.myStories,
      posts: posts ?? this.posts,
    );
  }
}
