import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:triply/core/utils/safe_emit_mixin.dart';

import '../../../common/auth/data/auth_repository.dart';
import '../data/profile_photo_uploader.dart';
import '../data/profile_update_repository.dart';
import 'update_profile_state.dart';

/// Owns validation, photo upload and the profile write. The sheet only
/// collects input and dispatches this cubit; it never touches Firebase.
class UpdateProfileCubit extends Cubit<UpdateProfileState>
    with SafeEmitMixin<UpdateProfileState> {
  UpdateProfileCubit({
    AuthRepository? authRepository,
    ProfileUpdateRepository? repository,
    ProfilePhotoUploader? photoUploader,
    this.onUpdated,
  }) : _auth = authRepository ?? AuthRepository(),
       _repository = repository ?? ProfileUpdateRepository(),
       _uploader = photoUploader ?? ProfilePhotoUploader(),
       super(const UpdateProfileInitial());

  final AuthRepository _auth;
  final ProfileUpdateRepository _repository;
  final ProfilePhotoUploader _uploader;

  /// Re-reads the Firebase user after a successful save so the header updates.
  final Future<void> Function()? onUpdated;

  Future<bool> save({
    required String name,
    required String city,
    required String country,
    required String bio,
    required XFile? image,
    required bool removePhoto,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      safeEmit(const ProfileUpdateFailed(message: "Name can't be empty"));
      return false;
    }
    final user = _auth.currentUser;
    if (user == null) {
      safeEmit(const ProfileUpdateFailed(message: 'Please sign in first.'));
      return false;
    }

    safeEmit(const UpdateProfileLoading());
    try {
      String? newPhotoUrl;
      if (image != null) {
        newPhotoUrl = await _uploader.upload(image);
      }
      final photo = removePhoto ? '' : (newPhotoUrl ?? user.photoURL ?? '');

      await _repository.update(
        uid: user.uid,
        name: trimmedName,
        city: city.trim(),
        country: country.trim(),
        bio: bio.trim(),
        photo: photo,
        updatePhoto: image != null || removePhoto,
      );
      await onUpdated?.call();
      safeEmit(const ProfileUpdateSucceeded());
      return true;
    } on ProfilePhotoUploadException catch (error) {
      safeEmit(ProfileUpdateFailed(message: error.message));
      return false;
    } catch (error) {
      safeEmit(ProfileUpdateFailed(message: 'Could not save profile: $error'));
      return false;
    }
  }
}
