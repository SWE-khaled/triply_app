import 'package:flutter/foundation.dart';

/// Explicit states for the actions on one Community post.
@immutable
sealed class PostActionsState {
  const PostActionsState({
    required this.action,
    this.errorMessage,
    this.isLiked,
    this.likesCount,
  });

  /// 'like' or 'delete' — lets the View avoid showing feedback for the wrong
  /// operation when a second action supersedes the first.
  final String action;
  final String? errorMessage;
  final bool? isLiked;
  final int? likesCount;
}

final class PostActionsInitial extends PostActionsState {
  const PostActionsInitial() : super(action: '');
}

final class PostActionInProgress extends PostActionsState {
  const PostActionInProgress({
    required super.action,
    super.isLiked,
    super.likesCount,
  });
}

final class PostActionSucceeded extends PostActionsState {
  const PostActionSucceeded({
    required super.action,
    super.isLiked,
    super.likesCount,
  });
}

final class PostActionFailed extends PostActionsState {
  const PostActionFailed({
    required super.action,
    required String message,
    super.isLiked,
    super.likesCount,
  }) : super(errorMessage: message);
}
