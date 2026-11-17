import 'package:flutter/foundation.dart';

import '../model/community_story.dart';

/// Explicit states for the Community stories feed.
@immutable
sealed class CommunityStoriesState {
  const CommunityStoriesState({
    this.stories = const [],
    this.myStories = const [],
    this.hasLoaded = false,
    this.isLoading = false,
    this.errorMessage,
  });

  /// Other tourists' active stories (never mine).
  final List<CommunityStory> stories;

  /// The signed-in tourist's active stories.
  final List<CommunityStory> myStories;
  final bool hasLoaded;
  final bool isLoading;
  final String? errorMessage;
}

final class CommunityStoriesInitial extends CommunityStoriesState {
  const CommunityStoriesInitial() : super(isLoading: true);
}

final class CommunityStoriesLoading extends CommunityStoriesState {
  const CommunityStoriesLoading() : super(isLoading: true);
}

final class CommunityStoriesSuccess extends CommunityStoriesState {
  const CommunityStoriesSuccess({
    required super.stories,
    required super.myStories,
  }) : super(hasLoaded: true);
}

final class CommunityStoriesError extends CommunityStoriesState {
  const CommunityStoriesError({
    required String message,
    required super.stories,
    required super.myStories,
    required super.hasLoaded,
  }) : super(errorMessage: message);
}
