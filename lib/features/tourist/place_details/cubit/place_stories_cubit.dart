import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/data/mock/tourist/mock_stories.dart';
import 'package:triply/core/utils/safe_emit_mixin.dart';

import '../data/place_resolver.dart';
import '../model/story.dart';
import 'place_stories_state.dart';

/// Owns the bundled stories of one place. Kept out of the place/trips cubits
/// so a story read can never replace the other sections.
class PlaceStoriesCubit extends Cubit<PlaceStoriesState>
    with SafeEmitMixin<PlaceStoriesState> {
  PlaceStoriesCubit({required this.resolver})
    : super(const PlaceStoriesInitial()) {
    load();
  }

  final PlaceResolver resolver;

  Future<void> load() async {
    safeEmit(const PlaceStoriesLoading());
    try {
      final place = await resolver.resolve();
      final stories = mockStories
          .where((e) => e['place_id'] == place.id)
          .map((e) => Story.fromJson(e))
          .toList();
      if (isClosed) return;
      safeEmit(PlaceStoriesSuccess(stories: stories));
    } catch (error) {
      if (isClosed) return;
      safeEmit(PlaceStoriesError(error: '$error'));
    }
  }

  void retry() => load();
}
