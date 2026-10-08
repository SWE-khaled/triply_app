import 'package:triply/features/tourist/guides/model/guide.dart';

class ProfileTgState {
  final Guide guide;
  final String? nameOverride;
  final String? photoOverride;
  final String? coverPath;
  final bool bookmarked;
  final String? remotePhone;
  final String? remoteAbout;
  final String? remoteLocation;
  final bool remoteLoaded;

  const ProfileTgState({
    required this.guide,
    this.nameOverride,
    this.photoOverride,
    this.coverPath,
    this.bookmarked = false,
    this.remotePhone,
    this.remoteAbout,
    this.remoteLocation,
    this.remoteLoaded = false,
  });

  ProfileTgState copyWith({
    Guide? guide,
    String? nameOverride,
    String? photoOverride,
    String? coverPath,
    bool? bookmarked,
    String? remotePhone,
    String? remoteAbout,
    String? remoteLocation,
    bool? remoteLoaded,
  }) {
    return ProfileTgState(
      guide: guide ?? this.guide,
      nameOverride: nameOverride ?? this.nameOverride,
      photoOverride: photoOverride ?? this.photoOverride,
      coverPath: coverPath ?? this.coverPath,
      bookmarked: bookmarked ?? this.bookmarked,
      remotePhone: remotePhone ?? this.remotePhone,
      remoteAbout: remoteAbout ?? this.remoteAbout,
      remoteLocation: remoteLocation ?? this.remoteLocation,
      remoteLoaded: remoteLoaded ?? this.remoteLoaded,
    );
  }
}
