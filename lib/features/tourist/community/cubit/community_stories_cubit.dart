import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/utils/page_load_error.dart';
import 'package:triply/core/utils/safe_emit_mixin.dart';

import '../data/community_stories_repository.dart';
import '../model/community_story.dart';
import 'community_stories_state.dart';

/// Owns the active stories feed, its one-ring-per-user derivation and the
/// 24-hour expiry pruning. Publishing and deleting are separate cubits.
class CommunityStoriesCubit extends Cubit<CommunityStoriesState>
    with SafeEmitMixin<CommunityStoriesState> {
  CommunityStoriesCubit({
    CommunityStoriesRepository? storiesRepository,
    DateTime Function()? now,
  }) : _repository =
            storiesRepository ?? FirestoreCommunityStoriesRepository(),
        _now = now ?? DateTime.now,
        super(const CommunityStoriesInitial()) {
    safeEmit(const CommunityStoriesLoading());
    _listen();
    _expiryTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => pruneExpiredStories(),
    );
  }

  final CommunityStoriesRepository _repository;
  final DateTime Function() _now;

  StreamSubscription<List<CommunityStory>>? _subscription;
  Timer? _expiryTimer;

  List<CommunityStory> _stories = const [];
  List<CommunityStory> _myStories = const [];
  bool _hasLoaded = false;

  /// Authoritative snapshots for derived reads.
  List<CommunityStory> get myStories => _myStories;

  /// Stories of a single user only — the viewer must never mix users.
  /// Ordered oldest first, which is the natural Story playback order.
  List<CommunityStory> storiesOf(String authorId) {
    final stories = [..._myStories, ..._stories]
        .where((story) => story.authorId == authorId)
        .toList()
        ..sort((a, b) => _createdAt(a).compareTo(_createdAt(b)));
    return stories;
  }

  /// One ring per user (newest story is the cover), "mine" excluded.
  List<CommunityStory> get userRings {
    final seen = <String>{};
    final rings = <CommunityStory>[];
    for (final story in _stories) {
      if (seen.add(story.authorId)) rings.add(story);
    }
    return rings;
  }

  void _listen() {
    _subscription = _repository.watchStories().listen(
      _onStories,
      onError: _onStoriesError,
    );
  }

  void _onStories(List<CommunityStory> stories) {
    if (isClosed) return;

    final at = _now();
    final mine = <CommunityStory>[];
    final others = <CommunityStory>[];
    final seen = <String>{};

    for (final story in stories) {
      if (!story.isDisplayableAt(at)) continue;
      // A newly published Story can reach the stream before/after the
      // optimistic entry. Deduplicate defensively by document id.
      if (!seen.add(story.id)) continue;
      if (story.isMine) {
        mine.add(story);
      } else {
        others.add(story);
      }
    }

    mine.sort(_newestFirst);
    others.sort(_newestFirst);

    _stories = List.unmodifiable(others);
    _myStories = List.unmodifiable(mine);
    _hasLoaded = true;
    safeEmit(
      CommunityStoriesSuccess(stories: _stories, myStories: _myStories),
    );
  }

  void _onStoriesError(Object error, StackTrace stackTrace) {
    if (isClosed) return;
    safeEmit(
      CommunityStoriesError(
        message: pageLoadErrorMessage(error),
        stories: _stories,
        myStories: _myStories,
        hasLoaded: _hasLoaded,
      ),
    );
  }

  /// Removes stories whose authoritative `createdAt + 24h` has passed.
  /// Called by the timer and when the Community screen resumes.
  void pruneExpiredStories([DateTime? now]) {
    if (isClosed) return;

    final at = now ?? _now();
    final mine = _myStories
        .where((story) => story.isDisplayableAt(at))
        .toList(growable: false);
    final others = _stories
        .where((story) => story.isDisplayableAt(at))
        .toList(growable: false);

    if (mine.length == _myStories.length &&
        others.length == _stories.length) {
      return;
    }

    _stories = others;
    _myStories = mine;
    safeEmit(
      CommunityStoriesSuccess(stories: _stories, myStories: _myStories),
    );
  }

  /// Immediate optimistic insertion after a successful story publish.
  void addStory(CommunityStory story) {
    if (isClosed) return;
    final at = _now();
    final mine = _myStories
        .where(
          (item) => item.id != story.id && item.isDisplayableAt(at),
        )
        .toList();
    final others = _stories
        .where(
          (item) => item.id != story.id && item.isDisplayableAt(at),
        )
        .toList();
    _myStories = List.unmodifiable([story, ...mine]);
    _stories = List.unmodifiable(others);
    _hasLoaded = true;
    safeEmit(
      CommunityStoriesSuccess(stories: _stories, myStories: _myStories),
    );
  }

  /// Re-subscribes without restarting the shimmer.
  void retry() {
    unawaited(_subscription?.cancel());
    _listen();
  }

  static DateTime _createdAt(CommunityStory story) =>
      story.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  static int _newestFirst(CommunityStory a, CommunityStory b) =>
      _createdAt(b).compareTo(_createdAt(a));

  @override
  Future<void> close() async {
    _expiryTimer?.cancel();
    await _subscription?.cancel();
    return super.close();
  }
}
