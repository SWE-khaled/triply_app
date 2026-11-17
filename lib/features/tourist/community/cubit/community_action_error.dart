import '../data/community_posts_repository.dart';
import '../data/community_stories_repository.dart';

/// Turns a Community repository failure into the message the UI shows.
///
/// Kept in the cubit layer so Views never have to inspect repository
/// exception types.
String communityActionErrorMessage(Object error) {
  if (error is CommunityPostsException) return error.message;
  if (error is CommunityStoriesException) return error.message;
  return 'Could not update Community. Please try again.';
}
