import 'package:flutter/foundation.dart';

import '../model/community_story.dart';

/// Explicit states for the active Story viewer.
@immutable
sealed class StoryActionsState {
  const StoryActionsState({required this.stories});

  /// The viewer's authoritative, already displayable stories of one author.
  final List<CommunityStory> stories;
}

final class StoryViewerReady extends StoryActionsState {
  const StoryViewerReady({required super.stories});
}

final class StoryDeleting extends StoryActionsState {
  const StoryDeleting({required super.stories});
}

final class StoryDeleted extends StoryActionsState {
  const StoryDeleted({required super.stories, required this.storyId});

  final String storyId;
}

final class StoryDeleteError extends StoryActionsState {
  const StoryDeleteError({required super.stories, required this.message});

  final String message;
}
