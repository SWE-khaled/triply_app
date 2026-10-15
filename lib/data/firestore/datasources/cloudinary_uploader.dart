import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Unsigned Cloudinary image upload (same backend + preset the profile
/// photo flow already uses successfully, so community uploads work with
/// zero Firebase console changes).
class CloudinaryUploader {
  // Same values as the working profile-photo upload (edit_profile_sheet).
  static const String _cloudName = 'yl49wcys';
  static const String _preset = 'djowcnxm';

  /// Uploads [file] and returns the hosted `secure_url`.
  /// Throws with a user-facing message on any failure.
  Future<String> uploadImageFile(File file) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
      );
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _preset
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response =
          await request.send().timeout(const Duration(seconds: 60));
      final body = await response.stream.bytesToString();
      if (response.statusCode != 200) {
        debugPrint('Triply: Cloudinary upload failed: $body');
        throw Exception(
          'Photo upload failed. Check your connection and try again.',
        );
      }
      final url = jsonDecode(body)['secure_url'] as String?;
      if (url == null || url.isEmpty) {
        throw Exception(
          'Photo upload failed. Check your connection and try again.',
        );
      }
      return url;
    } on Exception catch (e) {
      final text = e.toString();
      if (text.contains('Photo upload failed')) rethrow;
      debugPrint('Triply: Cloudinary upload failed: $e');
      throw Exception(
        'Photo upload failed. Check your connection and try again.',
      );
    }
  }
}
