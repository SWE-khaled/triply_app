import 'package:flutter/foundation.dart';

import '../../community/model/community_post.dart';

/// Explicit states for the signed-in tourist's published posts.
@immutable
sealed class ProfilePostsState {
  const ProfilePostsState({
    this.posts = const [],
    required this.isLoading,
    required this.hasLoaded,
    this.errorMessage,
  });

  final List<CommunityPost> posts;
  final bool isLoading;
  final bool hasLoaded;
  final String? errorMessage;
}

final class ProfilePostsInitial extends ProfilePostsState {
  const ProfilePostsInitial() : super(isLoading: true, hasLoaded: false);
}

final class ProfilePostsLoading extends ProfilePostsState {
  const ProfilePostsLoading() : super(isLoading: true, hasLoaded: false);
}

final class ProfilePostsSuccess extends ProfilePostsState {
  const ProfilePostsSuccess({required super.posts})
    : super(isLoading: false, hasLoaded: true);
}

/// Retains the last snapshot so a stream error does not blank the list.
final class ProfilePostsError extends ProfilePostsState {
  const ProfilePostsError({required super.posts, required super.hasLoaded})
    : super(
        isLoading: false,
        errorMessage: 'Could not load your posts. Please try again.',
      );
}
