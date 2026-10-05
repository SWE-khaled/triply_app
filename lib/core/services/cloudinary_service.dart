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
    try {
      if (file.path == null) {
        throw Exception('File path is null');
      }

      // Specify the folder path as requested
      final String folderPath = 'triply/guide_verifications/$userId';

      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path!,
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
