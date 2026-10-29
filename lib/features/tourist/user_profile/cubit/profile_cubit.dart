import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/mock/tourist/mock_emergency_contacts.dart';
import '../../../../core/data/mock/tourist/mock_profile.dart';
import '../../../../core/data/my_bookings_public.dart';
import '../../../common/AuthTourist/data/auth_repository.dart';
import '../model/emergency_contact.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({String? userId, AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository(),
      super(
        ProfileState(
          selectedLanguage: mockDefaultLanguage,
          isLoadingProfile: userId != null,
        ),
      ) {
    if (userId != null) {
      unawaited(loadUserProfile(userId));
    }
  }

  final AuthRepository _authRepository;

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
          clearProfileError: true,
        ),
      );
    } catch (_) {
      if (isClosed) return;

      emit(
        state.copyWith(
          isLoadingProfile: false,
          profileError: 'Could not load your saved profile information.',
        ),
      );
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
}
