import 'package:image_picker/image_picker.dart';

import '../../community/data/community_cloudinary_uploader.dart';

/// Maps the Community Cloudinary failure to the exact message the profile
/// sheet has always shown. Reuses the existing unsigned preset uploader so no
/// second HTTP implementation is introduced.
class ProfilePhotoUploader {
  ProfilePhotoUploader({CommunityCloudinaryUploader? uploader})
    : _uploader = uploader ?? CommunityCloudinaryUploader();

  final CommunityCloudinaryUploader _uploader;

  Future<String> upload(XFile image) async {
    try {
      return await _uploader.upload(image);
    } on CommunityMediaException {
      throw const ProfilePhotoUploadException(
        'Photo upload failed. Please try again.',
      );
    }
  }
}

class ProfilePhotoUploadException implements Exception {
  const ProfilePhotoUploadException(this.message);

  final String message;

  @override
  String toString() => message;
}
