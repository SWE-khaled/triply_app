import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/utils/page_load_error.dart';
import 'package:triply/core/utils/safe_emit_mixin.dart';

import '../../../common/auth/data/auth_repository.dart';
import 'profile_details_state.dart';

/// Owns the single read of `users/{uid}` for the profile header/bio.
///
/// Editing, posts and session preferences are separate cubits, so a failed
/// profile read can never overwrite the posts feed or the Settings switch.
class ProfileDetailsCubit extends Cubit<ProfileDetailsState>
    with SafeEmitMixin<ProfileDetailsState> {
  ProfileDetailsCubit({String? userId, AuthRepository? authRepository})
    : _userId = userId,
      _repository = authRepository ?? AuthRepository(),
      super(
        ProfileDetailsInitial(
          isLoading: userId != null,
          hasLoaded: userId == null,
        ),
      ) {
    final id = userId;
    if (id != null) unawaited(load(id));
  }

  final String? _userId;
  final AuthRepository _repository;

  bool _loading = false;

  /// Loads (or reloads) the profile. The first read shows the shimmer; a
  /// retry after an error keeps the error view until this resolves, matching
  /// the previous behavior.
  Future<void> load([String? userId]) async {
    final id = userId ?? _userId;
    if (id == null || _loading) return;
    _loading = true;
    if (state is ProfileDetailsInitial) {
      safeEmit(const ProfileDetailsLoading());
    }
    try {
      final data = await _repository.getUserProfile(id);
      if (isClosed) return;

      final savedDisplayName = data?['displayName'];
      final savedFullName = data?['fullName'];
      final rawName =
          savedDisplayName is String && savedDisplayName.trim().isNotEmpty
          ? savedDisplayName
          : savedFullName;
      final rawPhotoUrl = data?['avatarUrl'];

      safeEmit(
        ProfileDetailsReady(
          name: rawName is String && rawName.trim().isNotEmpty
              ? rawName.trim()
              : '',
          photoUrl: rawPhotoUrl is String && rawPhotoUrl.trim().isNotEmpty
              ? rawPhotoUrl.trim()
              : '',
          photoWasCleared:
              data?['avatarUrl'] is String &&
              (data?['avatarUrl'] as String).trim().isEmpty,
          city: data?['city'] is String ? (data?['city'] as String).trim() : '',
          country: data?['country'] is String
              ? (data?['country'] as String).trim()
              : '',
          bio: data?['bio'] is String ? (data?['bio'] as String).trim() : '',
        ),
      );
    } catch (error) {
      if (isClosed) return;
      safeEmit(
        ProfileDetailsError(
          message: pageLoadErrorMessage(error),
          name: state.name,
          photoUrl: state.photoUrl,
          photoWasCleared: state.photoWasCleared,
          city: state.city,
          country: state.country,
          bio: state.bio,
          hasLoaded: state.hasLoaded,
        ),
      );
    } finally {
      _loading = false;
    }
  }

  void retry() => unawaited(load());
}
