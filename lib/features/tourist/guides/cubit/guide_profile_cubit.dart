import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/data/mock/tourist/mock_guides.dart';
import 'package:triply/core/data/mock/tourist/mock_trips.dart';
import 'package:triply/features/tourist/guides/model/guide.dart';
import 'package:triply/features/tourist/guides/model/trip.dart';
import 'guide_profile_state.dart';

/// Feature-focused cubit for GuideProfileScreen.
/// Reads local mock data only. Bookmark is UI-local (no favorites screen
/// exists in Figma, so nothing is persisted).
class GuideProfileCubit extends Cubit<GuideProfileState> {
  final String guideId;

  GuideProfileCubit({required this.guideId})
      : super(const GuideProfileState());

  Guide get guide {
    return mockGuides.firstWhere(
      (g) => g.id == guideId,
      orElse: () => mockGuides.first,
    );
  }

  List<Trip> get trips => mockTripsForGuide(guideId);

  bool get isBookmarked => state.bookmarked;

  void toggleBookmark() {
    emit(state.copyWith(bookmarked: !state.bookmarked));
  }
}
