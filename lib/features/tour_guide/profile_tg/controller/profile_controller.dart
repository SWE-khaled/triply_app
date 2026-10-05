import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:triply/core/data/mock/tourist/mock_guides.dart';
import 'package:triply/core/data/mock/tourist/mock_trips.dart';
import 'package:triply/features/tourist/guides/model/guide.dart';
import 'package:triply/features/tourist/guides/model/trip.dart';

/// Feature-focused controller for GuideProfileScreen.
/// Reads local mock data only. Bookmark is UI-local (no favorites screen
/// exists in Figma, so nothing is persisted).
class ProfileController extends ChangeNotifier {
  final String guideId;
  bool _bookmarked = false;

  /// Session-only edits (mock phase). Shared mock data is never mutated,
  /// so the tourist side keeps showing the original values.
  String? _nameOverride;
  String? _coverPath;
  String? _photoOverride;

  ProfileController({required this.guideId});

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

  String get displayName => _nameOverride ?? guide.name;

  String? get coverImagePath => _coverPath;

  void updateName(String value) {
    final v = value.trim();
    if (v.isEmpty) return;
    _nameOverride = v;
    notifyListeners();
  }

  /// Pulls the Firebase display name + photo (saved by EditProfileSheet)
  /// into session overrides so this screen reflects them.
  void pullFirebaseName() {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName?.trim() ?? '';
    if (name.isNotEmpty) _nameOverride = name;
    final photo = user?.photoURL?.trim() ?? '';
    if (photo.isNotEmpty) _photoOverride = photo;
    notifyListeners();
  }

  String get displayAvatar => _photoOverride ?? guide.avatarUrl;

  /// Picks a gallery cover for local preview only (no upload yet).
  /// Returns an error message when picking fails, else null.
  Future<String?> pickCoverImage() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (file == null) return null;
      _coverPath = file.path;
      notifyListeners();
      return null;
    } catch (_) {
      return 'Could not open the gallery';
    }
  }
}
