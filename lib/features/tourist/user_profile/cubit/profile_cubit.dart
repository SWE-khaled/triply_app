import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/mock/tourist/mock_emergency_contacts.dart';
import '../../../../core/data/mock/tourist/mock_profile.dart';
import '../../../../core/data/my_bookings_public.dart';
import '../../../../core/utils/page_load_error.dart';
import '../../../common/auth/data/auth_repository.dart';
import '../../community/data/community_posts_repository.dart';
import '../../community/model/community_post.dart';
import '../model/emergency_contact.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    String? userId,
    AuthRepository? authRepository,
    CommunityPostsRepository? postsRepository,
  }) : _authRepository = authRepository ?? AuthRepository(),
       _postsRepository =
           postsRepository ?? FirestoreCommunityPostsRepository(),
       _userId = userId,
       super(
         ProfileState(
           selectedLanguage: mockDefaultLanguage,
           isLoadingProfile: userId != null,
           hasLoadedProfile: userId == null,
           isLoadingPosts: true,
         ),
       ) {
    if (userId != null) {
      unawaited(loadUserProfile(userId));
    }
    _watchMyPosts();
  }

  final AuthRepository _authRepository;
  final CommunityPostsRepository _postsRepository;
  final String? _userId;
  StreamSubscription<List<CommunityPost>>? _postsSubscription;

  Future<void> loadUserProfile(String userId) async {
    try {
      final data = await _authRepository.getUserProfile(userId);
      if (isClosed) return;

      final savedDisplayName = data?['displayName'];
      final savedFullName = data?['fullName'];
      final rawName =
          savedDisplayName is String && savedDisplayName.trim().isNotEmpty
          ? savedDisplayName
          : savedFullName;
      final rawPhotoUrl = data?['avatarUrl'];

      emit(
        state.copyWith(
          profileName: rawName is String && rawName.trim().isNotEmpty
              ? rawName.trim()
              : '',
          profilePhotoUrl:
              rawPhotoUrl is String && rawPhotoUrl.trim().isNotEmpty
              ? rawPhotoUrl.trim()
              : '',
          city: data?['city'] is String ? (data?['city'] as String).trim() : '',
          country: data?['country'] is String
              ? (data?['country'] as String).trim()
              : '',
          bio: data?['bio'] is String ? (data?['bio'] as String).trim() : '',
          isLoadingProfile: false,
          hasLoadedProfile: true,
          clearProfileError: true,
        ),
      );
    } catch (error) {
      if (isClosed) return;

      emit(
        state.copyWith(
          isLoadingProfile: false,
          profileError: pageLoadErrorMessage(error),
        ),
      );
    }
  }

  void _watchMyPosts() {
    _postsSubscription = _postsRepository.watchMyPosts().listen(
      (posts) {
        if (isClosed) return;
        emit(
          state.copyWith(
            posts: posts,
            isLoadingPosts: false,
            hasLoadedPosts: true,
            clearPostsError: true,
          ),
        );
      },
      onError: (Object error, StackTrace stackTrace) {
        if (isClosed) return;
        emit(
          state.copyWith(
            isLoadingPosts: false,
            postsError: pageLoadErrorMessage(error),
          ),
        );
      },
    );
  }

  void retryInitialLoad() {
    if (state.profileError != null && _userId != null) {
      unawaited(loadUserProfile(_userId));
    }
    if (state.postsError != null) {
      unawaited(_postsSubscription?.cancel());
      emit(state.copyWith(isLoadingPosts: true, clearPostsError: true));
      _watchMyPosts();
    }
  }

  List<String> get languages => mockLanguages;

  /// Trips count is driven by the real My Trips bookings
  /// (increments with every added trip); other stats stay mock.
  Map<String, int> get stats => {
    ...mockProfileStats,
    'trips': MyBookingsPublic.count,
  };

  List<EmergencyContact> get emergencyContacts =>
      mockEmergencyContactsRaw.map(EmergencyContact.fromJson).toList();

  void toggleNotifications(bool value) {
    emit(state.copyWith(notificationsEnabled: value));
  }

  void setLanguage(String language) {
    if (!mockLanguages.contains(language)) return;
    emit(state.copyWith(selectedLanguage: language));
  }

  @override
  Future<void> close() async {
    await _postsSubscription?.cancel();
    await super.close();
  }
}
