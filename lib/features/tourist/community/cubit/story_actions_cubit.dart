import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/utils/safe_emit_mixin.dart';

import '../data/community_stories_repository.dart';
import '../model/community_story.dart';
import 'story_actions_state.dart';

/// Owns one active Story viewer: the author's displayable stories, their
/// expiry pruning and the delete operation. Page/animation controllers stay
/// in the View; the story list never does.
class StoryActionsCubit extends Cubit<StoryActionsState>
    with SafeEmitMixin<StoryActionsState> {
  StoryActionsCubit({
    required List<CommunityStory> stories,
    CommunityStoriesRepository? storiesRepository,
    DateTime Function()? now,
  }) : _repository =
            storiesRepository ?? FirestoreCommunityStoriesRepository(),
        _now = now ?? DateTime.now,
        _stories = _displayable(
          stories,
          now != null ? now() : DateTime.now(),
        ),
        super(
          StoryViewerReady(
            stories: _displayable(
              stories,
              now != null ? now() : DateTime.now(),
            ),
          ),
        );

  final CommunityStoriesRepository _repository;
  final DateTime Function() _now;

  List<CommunityStory> _stories;

  /// Authoritative viewer snapshot.
  List<CommunityStory> get stories => _stories;

  static List<CommunityStory> _displayable(
    List<CommunityStory> stories,
    DateTime now,
  ) => List.unmodifiable(
    stories.where((story) => story.isDisplayableAt(now)),
  );

  Future<void> delete(CommunityStory story) async {
    if (!story.isMine) {
      safeEmit(
        const StoryDeleteError(
          stories: [],
          message: 'You can only delete your own Stories.',
        ),
      );
      return;
    }
    safeEmit(StoryDeleting(stories: _stories));
    try {
      await _repository.deleteStory(story);
      _stories = _stories
          .where((item) => item.id != story.id)
          .toList(growable: false);
      safeEmit(StoryDeleted(stories: _stories, storyId: story.id));
    } catch (error) {
      safeEmit(
        StoryDeleteError(
          stories: _stories,
          message: error is CommunityStoriesException
              ? error.message
              : 'Could not delete this Story. Please try again.',
        ),
      );
    }
  }

  /// Drops stories whose 24-hour window has ended and emits a fresh snapshot.
  void pruneExpired([DateTime? now]) {
    final at = now ?? _now();
    final active = _stories
        .where((story) => story.isDisplayableAt(at))
        .toList(growable: false);
    if (active.length == _stories.length) return;
    _stories = active;
    safeEmit(StoryViewerReady(stories: _stories));
  }
}
