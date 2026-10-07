import 'package:flutter/foundation.dart';
import 'package:admin_dashboard/core/data/mock/tourist/mock_guides.dart';
import 'package:admin_dashboard/core/data/mock/tourist/mock_trips.dart';
import 'package:admin_dashboard/features/tourist/guides/model/guide.dart';
import 'package:admin_dashboard/features/tourist/guides/model/trip.dart';

/// Feature-focused controller for GuideProfileScreen.
/// Reads local mock data only. Bookmark is UI-local (no favorites screen
/// exists in Figma, so nothing is persisted).
class GuideProfileController extends ChangeNotifier {
  final String guideId;
  bool _bookmarked = false;

  GuideProfileController({required this.guideId});

  Guide get guide {
    return mockGuides.firstWhere(
      (g) => g.id == guideId,
      orElse: () => mockGuides.first,
    );
  }

  List<Trip> get trips => mockTripsForGuide(guideId);

  bool get isBookmarked => _bookmarked;

  void toggleBookmark() {
    _bookmarked = !_bookmarked;
    notifyListeners();
  }
}

