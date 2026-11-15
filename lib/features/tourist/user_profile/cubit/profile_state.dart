import '../../community/model/community_post.dart';

class ProfileState {
  final bool notificationsEnabled;
  final String selectedLanguage;
  final String? profileName;
  final String? profilePhotoUrl;
  final String? city;
  final String? country;
  final String? bio;
  final bool isLoadingProfile;
  final String? profileError;
  final List<CommunityPost> posts;
  final bool isLoadingPosts;
  final bool hasLoadedProfile;
  final bool hasLoadedPosts;
  final String? postsError;

  const ProfileState({
    this.notificationsEnabled = true,
    this.selectedLanguage = 'English',
    this.profileName,
    this.profilePhotoUrl,
    this.city,
    this.country,
    this.bio,
    this.isLoadingProfile = false,
    this.profileError,
    this.posts = const [],
    this.isLoadingPosts = false,
    this.hasLoadedProfile = false,
    this.hasLoadedPosts = false,
    this.postsError,
  });

  ProfileState copyWith({
    bool? notificationsEnabled,
    String? selectedLanguage,
    String? profileName,
    String? profilePhotoUrl,
    String? city,
    String? country,
    String? bio,
    bool? isLoadingProfile,
    String? profileError,
    bool clearProfileError = false,
    List<CommunityPost>? posts,
    bool? isLoadingPosts,
    bool? hasLoadedProfile,
    bool? hasLoadedPosts,
    String? postsError,
    bool clearPostsError = false,
  }) {
    return ProfileState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      profileName: profileName ?? this.profileName,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      city: city ?? this.city,
      country: country ?? this.country,
      bio: bio ?? this.bio,
      isLoadingProfile: isLoadingProfile ?? this.isLoadingProfile,
      profileError: clearProfileError
          ? null
          : profileError ?? this.profileError,
      posts: posts ?? this.posts,
      isLoadingPosts: isLoadingPosts ?? this.isLoadingPosts,
      hasLoadedProfile: hasLoadedProfile ?? this.hasLoadedProfile,
      hasLoadedPosts: hasLoadedPosts ?? this.hasLoadedPosts,
      postsError: clearPostsError ? null : postsError ?? this.postsError,
    );
  }
}
