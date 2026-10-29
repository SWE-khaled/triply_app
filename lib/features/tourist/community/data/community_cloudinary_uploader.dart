import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/// Uploads Community post images with the same unsigned Cloudinary preset
/// used by the profile picture flow.
///
/// This is intentionally Community-specific: the profile sheets keep their
/// own upload code, and the shared `CloudinaryService` uses a different
/// Cloudinary account/preset.
class CommunityCloudinaryUploader {
  static const String cloudName = 'yl49wcys';
  static const String uploadPreset = 'djowcnxm';
  static const String uploadEndpoint =
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

  /// Uploads one local image and returns Cloudinary's `secure_url`.
  Future<String> upload(XFile image) async {
    final request = http.MultipartRequest('POST', Uri.parse(uploadEndpoint))
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode != 200) {
      throw CommunityMediaException('Upload failed: $body');
    }

    final decoded = jsonDecode(body);
    final secureUrl = decoded is Map<String, dynamic>
        ? decoded['secure_url']
        : null;
    if (secureUrl is! String || secureUrl.isEmpty) {
      throw const CommunityMediaException(
        'Cloudinary did not return an image URL.',
      );
    }
    return secureUrl;
  }
}

class CommunityMediaException implements Exception {
  const CommunityMediaException(this.message);

  final String message;

  @override
  String toString() => message;
}
