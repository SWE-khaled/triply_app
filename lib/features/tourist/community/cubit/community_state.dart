import 'package:flutter/foundation.dart';

import '../model/community_post.dart';

/// Explicit states for the Community posts feed.
///
/// This file was the old aggregate Community state. It now owns only the
/// posts stream; stories, publishing and actions have their own states.
@immutable
sealed class CommunityPostsState {
  const CommunityPostsState({
    this.posts = const [],
    this.hasLoaded = false,
    this.isLoading = false,
    this.errorMessage,
  });

  /// The last authoritative feed snapshot. It stays visible when a later
  /// stream error arrives, exactly as before.
  final List<CommunityPost> posts;
  final bool hasLoaded;
  final bool isLoading;
  final String? errorMessage;

  /// Show the empty message only after a clean, completed load with no posts.
  bool get showPostsEmptyState =>
      hasLoaded && !isLoading && errorMessage == null && posts.isEmpty;
}

final class CommunityPostsInitial extends CommunityPostsState {
  const CommunityPostsInitial() : super(isLoading: true);
}

final class CommunityPostsLoading extends CommunityPostsState {
  const CommunityPostsLoading() : super(isLoading: true);
}

final class CommunityPostsSuccess extends CommunityPostsState {
  const CommunityPostsSuccess({required super.posts}) : super(hasLoaded: true);
}

final class CommunityPostsError extends CommunityPostsState {
  const CommunityPostsError({
    required String message,
    required super.posts,
    required super.hasLoaded,
  }) : super(errorMessage: message);
}
