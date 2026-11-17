import 'package:flutter/foundation.dart';

import '../model/story.dart';

/// Explicit states for the place's stories.
@immutable
sealed class PlaceStoriesState {
  const PlaceStoriesState();
}

final class PlaceStoriesInitial extends PlaceStoriesState {
  const PlaceStoriesInitial();
}

final class PlaceStoriesLoading extends PlaceStoriesState {
  const PlaceStoriesLoading();
}

final class PlaceStoriesSuccess extends PlaceStoriesState {
  const PlaceStoriesSuccess({required this.stories});

  final List<Story> stories;
}

final class PlaceStoriesError extends PlaceStoriesState {
  const PlaceStoriesError({required this.error});

  final String error;
}
