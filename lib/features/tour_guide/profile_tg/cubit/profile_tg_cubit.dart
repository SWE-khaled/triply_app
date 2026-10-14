import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:triply/core/data/mock/tourist/mock_guides.dart';
import 'package:triply/core/data/mock/tourist/mock_trips.dart';
import 'package:triply/data/firestore/datasources/guide_profiles_datasource.dart';
import 'package:triply/data/firestore/datasources/users_datasource.dart';
import 'package:triply/data/firestore/mappers/firestore_mappers.dart';
import 'package:triply/features/common/AuthTourguide/data/tour_guide_auth_service.dart';
import 'package:triply/features/tourist/guides/model/guide.dart';
import 'package:triply/features/tourist/guides/model/trip.dart';
import 'profile_tg_state.dart';

/// Feature-focused cubit for GuideProfileScreen.
///
/// Baseline is local mock data; [loadRemoteProfile] swaps in the signed-in
/// guide's Firestore profile (`users` + `guideProfiles`) on success.
/// Bookmark is UI-local (no favorites screen exists in Figma).
class ProfileTgCubit extends Cubit<ProfileTgState> {
  ProfileTgCubit({
    required this.guideId,
    GuideProfilesDatasource? profiles,
    UsersDatasource? users,
  })  : _profiles = profiles ?? GuideProfilesDatasource(),
        _users = users ?? UsersDatasource(),
        super(
          ProfileTgState(
            guide: mockGuides.firstWhere(
              (g) => g.id == guideId,
              orElse: () => mockGuides.first,
            ),
          ),
        );

  final String guideId;
  final GuideProfilesDatasource _profiles;
  final UsersDatasource _users;

  /// Reads the signed-in guide's Firestore profile (`users` phone/about/
  /// location + `guideProfiles` public fields + avatar). On success the
  /// header/stats bind the remote guide; failures keep the mock baseline.
  /// Safe to call repeatedly; never crashes.
  Future<void> loadRemoteProfile() async {
    try {
      final profile = await TourGuideAuthService().fetchMyProfile();
      final phone = profile?.phone.trim() ?? '';
      final about = profile?.about.trim() ?? '';
      final location = profile?.location.trim() ?? '';
      Guide? remoteGuide;
      String avatarUrl = '';
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null && uid.isNotEmpty) {
        try {
          final gp = await _profiles.getByUserId(uid);
          if (gp != null) {
            try {
              final user = await _users.getById(uid);
              avatarUrl = user?.avatarUrl ?? '';
            } catch (_) {}
            remoteGuide = FirestoreMappers.guideProfileToGuide(
              gp,
              displayName: gp.displayName.isNotEmpty
                  ? gp.displayName
                  : (FirebaseAuth
                          .instance.currentUser?.displayName?.trim() ??
                      ''),
              avatarUrl: avatarUrl,
            );
          }
        } catch (e) {
          debugPrint('Triply: ProfileTgCubit guideProfiles failed: $e');
        }
      }
      emit(
        ProfileTgState(
          guide: remoteGuide ?? state.guide,
          nameOverride: state.nameOverride,
          photoOverride: state.photoOverride,
          coverPath: state.coverPath,
          bookmarked: state.bookmarked,
          remotePhone: phone.isNotEmpty ? phone : null,
          remoteAbout: about.isNotEmpty ? about : null,
          remoteLocation: location.isNotEmpty ? location : null,
          remoteLoaded: true,
        ),
      );
    } catch (_) {
      // Keep fallbacks (e.g. offline or missing document): never crash.
      emit(state.copyWith());
    }
  }

  bool get remoteLoaded => state.remoteLoaded;

  /// Firestore phone or null (UI hides the row when null).
  String? get displayPhone => state.remotePhone;

  /// Firestore About or the mock guide About as fallback.
  String get displayAbout => state.remoteAbout ?? state.guide.about;

  /// Firestore location or the mock guide location as fallback.
  String get displayLocation => state.remoteLocation ?? state.guide.location;

  Guide get guide => state.guide;

  List<Trip> get trips => mockTripsForGuide(guideId);

  bool get isBookmarked => state.bookmarked;

  void toggleBookmark() {
    emit(state.copyWith(bookmarked: !state.bookmarked));
  }

  String get displayName {
    final firebaseName =
        FirebaseAuth.instance.currentUser?.displayName?.trim() ?? '';
    if (firebaseName.isNotEmpty) return firebaseName;
    return state.nameOverride ?? state.guide.name;
  }

  String? get coverImagePath => state.coverPath;

  void updateName(String value) {
    final v = value.trim();
    if (v.isEmpty) return;
    emit(state.copyWith(nameOverride: v));
  }

  /// Pulls the Firebase display name + photo (saved by EditProfileSheet)
  /// into session overrides so this screen reflects them.
  void pullFirebaseName() {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName?.trim() ?? '';
    final photo = user?.photoURL?.trim() ?? '';
    emit(
      state.copyWith(
        nameOverride:
            name.isNotEmpty ? name : state.nameOverride,
        photoOverride:
            photo.isNotEmpty ? photo : state.photoOverride,
      ),
    );
  }

  /// Firebase photo, session override, or empty (no image).
  /// Empty means "user never uploaded": callers render the grey person-icon
  /// placeholder. Never falls back to the mock guide's avatar — that showed
  /// another person's photo as the default.
  String get displayAvatar {
    final firebasePhoto =
        FirebaseAuth.instance.currentUser?.photoURL?.trim() ?? '';
    if (firebasePhoto.isNotEmpty) return firebasePhoto;
    return state.photoOverride ?? '';
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
      emit(state.copyWith(coverPath: file.path));
      return null;
    } catch (_) {
      return 'Could not open the gallery';
    }
  }
}
