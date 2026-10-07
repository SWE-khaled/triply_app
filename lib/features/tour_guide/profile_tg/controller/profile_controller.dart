import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:admin_dashboard/core/data/mock/tourist/mock_guides.dart';
import 'package:admin_dashboard/core/data/mock/tourist/mock_trips.dart';
import 'package:admin_dashboard/features/common/AuthTourguide/data/tour_guide_auth_service.dart';
import 'package:admin_dashboard/features/tourist/guides/model/guide.dart';
import 'package:admin_dashboard/features/tourist/guides/model/trip.dart';

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

  /// Permanent profile fields from the guide's Firestore document
  /// (users/{uid}: phone, about, location). Loaded once per screen via
  /// [loadRemoteProfile]; survive navigation and relogin.
  String? _remotePhone;
  String? _remoteAbout;
  String? _remoteLocation;
  bool _remoteLoaded = false;

  ProfileController({required this.guideId});

  /// Reads phone/about/location from Firestore. Safe to call repeatedly;
  /// failures leave previous values (or fallbacks) in place.
  Future<void> loadRemoteProfile() async {
    try {
      final profile = await TourGuideAuthService().fetchMyProfile();
      final phone = profile?.phone.trim() ?? '';
      _remotePhone = phone.isNotEmpty ? phone : null;
      final about = profile?.about.trim() ?? '';
      _remoteAbout = about.isNotEmpty ? about : null;
      final location = profile?.location.trim() ?? '';
      _remoteLocation = location.isNotEmpty ? location : null;
      _remoteLoaded = true;
    } catch (_) {
      // Keep fallbacks (e.g. offline or missing document): never crash.
    }
    notifyListeners();
  }

  bool get remoteLoaded => _remoteLoaded;

  /// Firestore phone or null (UI hides the row when null).
  String? get displayPhone => _remotePhone;

  /// Firestore About or the mock guide About as fallback.
  String get displayAbout => _remoteAbout ?? guide.about;

  /// Firestore location or the mock guide location as fallback.
  String get displayLocation => _remoteLocation ?? guide.location;

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

  String get displayName {
    final firebaseName =
        FirebaseAuth.instance.currentUser?.displayName?.trim() ?? '';
    if (firebaseName.isNotEmpty) return firebaseName;
    return _nameOverride ?? guide.name;
  }

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

  String get displayAvatar {
    final firebasePhoto =
        FirebaseAuth.instance.currentUser?.photoURL?.trim() ?? '';
    if (firebasePhoto.isNotEmpty) return firebasePhoto;
    return _photoOverride ?? guide.avatarUrl;
  }

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

