import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/safe_emit_mixin.dart';
import 'package:image_picker/image_picker.dart';
import 'package:triply/core/widgets/profile_avatar.dart';
import 'package:triply/features/common/AuthTourguide/data/tour_guide_auth_service.dart';

part 'profile_tg_state.dart';

/// Feature-focused cubit for GuideProfileScreen.
///
/// Everything on this screen comes from the signed-in guide's own
/// account: the name and photo from Firebase Auth, everything else from
/// the `users/{uid}` document. The tourist-facing listing of the mock
/// guides is never used here — it belongs to the other guides.
///
/// Bookmark is UI-local (no favorites screen exists in Figma, so nothing
/// is persisted).
class ProfileTgCubit extends Cubit<ProfileTgState>
    with SafeEmitMixin<ProfileTgState> {
  /// The id the profile was opened for.
  final String guideId;

  ProfileTgCubit({required this.guideId}) : super(const ProfileTgInitial()) {
    loadRemoteProfile();
    // Live verification: the VERIFIED badge follows the admin's approve /
    // reject decision through Firestore snapshots — no reload needed.
    // Lives on guideVerifications/{uid}, exactly the document the admin
    // dashboard writes, so the screen always agrees with it.
    _verificationSubscription = TourGuideAuthService()
        .watchVerificationSubmission()
        .listen(
          (data) {
            // No submission yet: the profile value decides (never hide an
            // approved badge because the guide has no document).
            if (data == null) return;
            _liveVerified = (data['status'] as String?) == 'approved';
            _refreshVerificationOnly();
          },
          onError: (_) {
            // Offline or no access: keep the loaded value, never crash.
          },
        );
  }

  /// Subscription to the guide's live verification status.
  StreamSubscription<Map<String, dynamic>?>? _verificationSubscription;

  /// The admin's latest verification decision, or null until a
  /// submission document exists (then the profile value decides).
  bool? _liveVerified;

  /// Re-emits the current success state untouched — the screen's
  /// BlocBuilder rebuilds and reads the fresh [isVerified].
  void _refreshVerificationOnly() {
    final current = state;
    if (current is ProfileTgSuccess) {
      safeEmit(
        ProfileTgSuccess(
          nameOverride: current.nameOverride,
          photoOverride: current.photoOverride,
          coverPath: current.coverPath,
          bookmarked: current.bookmarked,
          remotePhone: current.remotePhone,
          remoteAbout: current.remoteAbout,
          remoteLocation: current.remoteLocation,
        ),
      );
    }
  }

  /// The languages the guide registered with, read from Firestore.
  List<String> get languages => _profile?.languages ?? const [];

  /// Whether the admin approved this guide — the live verification
  /// decision when a submission exists, the profile value otherwise.
  bool get isVerified {
    final live = _liveVerified;
    if (live != null) return live;
    return _profile?.isApproved ?? false;
  }

  /// The guide's specialty, or empty when they have not set one.
  String get specialty => '';

  /// The guide's average rating — 0 until there are reviews.
  double get rating => 0;

  /// How many reviews the guide has — 0 until there are reviews.
  int get reviewCount => 0;

  /// The guide's hourly rate — 0 until they set one.
  double get pricePerHour => _profile?.pricePerHour ?? 0;

  /// The hourly rate, or empty when the guide has not set one.
  String get pricePerHourLabel {
    final price = _profile?.pricePerHour ?? 0;
    if (price <= 0) return '';
    return 'EGP ${price.toStringAsFixed(0)}';
  }

  /// The profile document of the signed-in guide, once it is loaded.
  TourGuideProfile? _profile;

  /// Reads phone/about/location from Firestore. Safe to call repeatedly;
  /// failures leave the previous values in place.
  Future<void> loadRemoteProfile() async {
    safeEmit(const ProfileTgLoading());
    try {
      final service = TourGuideAuthService();
      final profile = await service.fetchMyProfile();
      _profile = profile;
      // Publish the public profile the tourists browse — without it the
      // guide is invisible to them.
      await service.ensurePublicProfile();
      final phone = profile?.phone.trim() ?? '';
      final about = profile?.about.trim() ?? '';
      final location = profile?.location.trim() ?? '';
      final current = state;
      safeEmit(
        ProfileTgSuccess(
          nameOverride: current is ProfileTgSuccess
              ? current.nameOverride
              : null,
          photoOverride: current is ProfileTgSuccess
              ? current.photoOverride
              : null,
          coverPath: current is ProfileTgSuccess ? current.coverPath : null,
          bookmarked: current is ProfileTgSuccess ? current.bookmarked : false,
          remotePhone: phone.isNotEmpty ? phone : null,
          remoteAbout: about.isNotEmpty ? about : null,
          remoteLocation: location.isNotEmpty ? location : null,
        ),
      );
    } catch (_) {
      // Keep fallbacks (e.g. offline or missing document): never crash.
      final current = state;
      if (current is ProfileTgSuccess) return;
      safeEmit(
        ProfileTgSuccess(
          nameOverride: null,
          photoOverride: null,
          coverPath: null,
          bookmarked: false,
          remotePhone: null,
          remoteAbout: null,
          remoteLocation: null,
        ),
      );
    }
  }

  bool get remoteLoaded => state is ProfileTgSuccess;

  /// Firestore phone or null (UI hides the row when null).
  String? get displayPhone {
    final current = state;
    return current is ProfileTgSuccess ? current.remotePhone : null;
  }

  /// Firestore About, or empty when the guide has not written one yet.
  ///
  /// The mock guide's About belongs to the tourist-facing listing, not
  /// to this account — so it is never used as a fallback here.
  String get displayAbout {
    final current = state;
    final remote = current is ProfileTgSuccess ? current.remoteAbout : null;
    return remote ?? '';
  }

  /// Firestore location, or empty when the guide has not set one yet.
  String get displayLocation {
    final current = state;
    final remote = current is ProfileTgSuccess ? current.remoteLocation : null;
    return remote ?? '';
  }

  bool get isBookmarked {
    final current = state;
    return current is ProfileTgSuccess && current.bookmarked;
  }

  void toggleBookmark() {
    final current = state;
    if (current is! ProfileTgSuccess) return;
    safeEmit(
      ProfileTgSuccess(
        nameOverride: current.nameOverride,
        photoOverride: current.photoOverride,
        coverPath: current.coverPath,
        bookmarked: !current.bookmarked,
        remotePhone: current.remotePhone,
        remoteAbout: current.remoteAbout,
        remoteLocation: current.remoteLocation,
      ),
    );
  }

  String get displayName {
    final firebaseName =
        FirebaseAuth.instance.currentUser?.displayName?.trim() ?? '';
    if (firebaseName.isNotEmpty) return firebaseName;
    final current = state;
    final override = current is ProfileTgSuccess ? current.nameOverride : null;
    if (override != null && override.isNotEmpty) return override;
    // The name on the guide's own Firestore document, or empty.
    return _profile?.name.trim() ?? '';
  }

  String? get coverImagePath {
    final current = state;
    return current is ProfileTgSuccess ? current.coverPath : null;
  }

  /// Pulls the Firebase display name + photo (saved by EditProfileSheet)
  /// into the state so this screen reflects them.
  void pullFirebaseName() {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName?.trim() ?? '';
    final photo = user?.photoURL?.trim() ?? '';
    final current = state;
    if (current is! ProfileTgSuccess) return;
    safeEmit(
      ProfileTgSuccess(
        nameOverride: name.isNotEmpty ? name : current.nameOverride,
        photoOverride: photo.isNotEmpty ? photo : current.photoOverride,
        coverPath: current.coverPath,
        bookmarked: current.bookmarked,
        remotePhone: current.remotePhone,
        remoteAbout: current.remoteAbout,
        remoteLocation: current.remoteLocation,
      ),
    );
  }

  String get displayAvatar {
    final firebasePhoto =
        FirebaseAuth.instance.currentUser?.photoURL?.trim() ?? '';
    if (firebasePhoto.isNotEmpty) return firebasePhoto;
    final current = state;
    final override = current is ProfileTgSuccess ? current.photoOverride : null;
    // No photo yet — the bundled default, never a stock face.
    return override ?? ProfileAvatar.defaultAvatar;
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
      _setCover(file.path);
      return null;
    } catch (_) {
      return 'Could not open the gallery';
    }
  }

  void updateName(String value) {
    final v = value.trim();
    if (v.isEmpty) return;
    final current = state;
    if (current is! ProfileTgSuccess) return;
    safeEmit(
      ProfileTgSuccess(
        nameOverride: v,
        photoOverride: current.photoOverride,
        coverPath: current.coverPath,
        bookmarked: current.bookmarked,
        remotePhone: current.remotePhone,
        remoteAbout: current.remoteAbout,
        remoteLocation: current.remoteLocation,
      ),
    );
  }

  /// Stores the picked cover path on the state.
  void _setCover(String path) {
    final current = state;
    if (current is! ProfileTgSuccess) return;
    safeEmit(
      ProfileTgSuccess(
        nameOverride: current.nameOverride,
        photoOverride: current.photoOverride,
        coverPath: path,
        bookmarked: current.bookmarked,
        remotePhone: current.remotePhone,
        remoteAbout: current.remoteAbout,
        remoteLocation: current.remoteLocation,
      ),
    );
  }

  @override
  Future<void> close() {
    _verificationSubscription?.cancel();
    return super.close();
  }
}
