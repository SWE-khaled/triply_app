import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:file_picker/file_picker.dart';

class CloudinaryService {
  // Initialize Cloudinary with the provided cloud name and upload preset.
  // Using cache: false to ensure we don't return stale cached URLs.
  final _cloudinary = CloudinaryPublic(
    'gfhygmmz',
    'triply_tour_guide_info',
    cache: false,
  );

  /// Uploads a file to Cloudinary and returns its secure URL.
  Future<String> uploadFile(PlatformFile file, String userId) async {
    if (file.path == null) {
      throw Exception('File path is null');
    }
    return uploadFileAtPath(file.path!, userId);
  }

  /// Uploads a local file by its path and returns its secure URL.
  ///
  /// Used by the flows that pick an image with the gallery, which hands
  /// over a path rather than a picked file.
  Future<String> uploadFileAtPath(String path, String userId) async {
    try {
      final localFile = File(path);
      if (!localFile.existsSync() || localFile.lengthSync() == 0) {
        throw Exception(
          'Selected file is empty or unreadable. Please pick the file again.',
        );
      }

      // Specify the folder path as requested
      final String folderPath = 'triply/guide_verifications/$userId';

      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          path,
          folder: folderPath,
          resourceType: CloudinaryResourceType.Auto,
        ),
      );

      return response.secureUrl;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }
}
