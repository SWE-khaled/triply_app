import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Uploads guide trip cover images to Firebase Storage.
///
/// Path: `trip_covers/{uid}/{timestamp}_{filename}`.
/// Returns the download URL, or null when the file is missing/unreadable
/// or the upload fails (e.g. Storage rules not deployed) — callers must
/// fall back to the existing image URL and never fail the trip submit.
class TripCoverStorage {
  FirebaseStorage? _storageInit;
  TripCoverStorage([FirebaseStorage? storage]) : _storageInit = storage;

  // Lazy: constructing must not touch Firebase (offline/tests safe).
  FirebaseStorage get _storage =>
      _storageInit ??= FirebaseStorage.instance;

  /// Uploads [localPath] when it points to a device file.
  /// HTTP(S) URLs and empty paths are returned as-is (no upload).
  Future<String?> uploadIfLocal(String uid, String localPath) async {
    final path = localPath.trim();
    if (path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    try {
      final file = File(path);
      if (!await file.exists()) return null;
      final name = path.split(RegExp(r'[/\\]')).last;
      final ref = _storage.ref().child(
          'trip_covers/$uid/${DateTime.now().millisecondsSinceEpoch}_$name');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Triply: TripCoverStorage upload failed: $e');
      return null;
    }
  }
}
