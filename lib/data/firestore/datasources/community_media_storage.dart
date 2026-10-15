import 'dart:io';

import 'package:triply/data/firestore/datasources/cloudinary_uploader.dart';

/// Uploads tourist community post photos via Cloudinary (the same backend
/// the profile-photo flow already uses successfully — no Firebase Storage
/// bucket or console rules required).
class CommunityMediaStorage {
  static const int maxPhotosPerPost = 10;

  final CloudinaryUploader _uploader;

  CommunityMediaStorage([CloudinaryUploader? uploader])
      : _uploader = uploader ?? CloudinaryUploader();

  /// Uploads every local file in [localPaths], in order.
  /// HTTP(S) URLs pass through untouched (already hosted). Throws with a
  /// user-facing message when the cap is exceeded, a file is
  /// missing/unreadable, or an upload fails — callers reject the post
  /// instead of persisting half-imaged records.
  /// [uid] is kept for API symmetry with the other media uploaders.
  Future<List<String>> uploadPostImages(
    String uid,
    List<String> localPaths,
  ) async {
    if (localPaths.length > maxPhotosPerPost) {
      throw Exception(
        'You can attach up to $maxPhotosPerPost photos per post.',
      );
    }
    final urls = <String>[];
    for (var i = 0; i < localPaths.length; i++) {
      final path = localPaths[i].trim();
      if (path.isEmpty) continue;
      if (path.startsWith('http://') || path.startsWith('https://')) {
        urls.add(path);
        continue;
      }
      final file = File(path);
      if (!await file.exists()) {
        throw Exception('Photo ${i + 1} could not be read.');
      }
      urls.add(await _uploader.uploadImageFile(file));
    }
    if (urls.isEmpty) {
      throw Exception('Could not read the selected photos. Please try again.');
    }
    return urls;
  }
}
