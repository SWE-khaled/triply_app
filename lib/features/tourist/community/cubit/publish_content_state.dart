import 'package:flutter/foundation.dart';

import '../model/community_post.dart';
import '../model/community_story.dart';

/// Explicit states for writing a new post or story to Community.
@immutable
sealed class PublishContentState {
  const PublishContentState({
    this.isPublishing = false,
    this.publishedPost,
    this.publishedStory,
    this.errorMessage,
  });

  final bool isPublishing;
  final CommunityPost? publishedPost;
  final CommunityStory? publishedStory;
  final String? errorMessage;
}

final class PublishInitial extends PublishContentState {
  const PublishInitial();
}

final class PublishingContent extends PublishContentState {
  const PublishingContent();
}

final class ContentPublished extends PublishContentState {
  const ContentPublished({CommunityPost? post, CommunityStory? story})
    : super(publishedPost: post, publishedStory: story);
}

final class PublishFailed extends PublishContentState {
  const PublishFailed({required String message}) : super(errorMessage: message);
}
