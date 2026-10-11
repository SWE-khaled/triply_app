import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:triply/core/firebase/firestore_converters.dart';

/// Canonical `stories/{storyId}` document.
///
/// Visual expiration (`expiresAt` = createdAt + 24h) is NOT deletion.
/// A scheduled Function (`cleanupExpiredStories`) deletes expired docs in
/// batches; clients filter `expiresAt > now` in queries. Owner or admin
/// may delete early (rules enforce).
class StoryDoc {
  final String id;
  final String userId;
  final String userName;
  final String mediaUrl;
  final bool isVideo;
  final DateTime? createdAt;
  final DateTime? expiresAt;

  const StoryDoc({
    required this.id,
    required this.userId,
    this.userName = '',
    required this.mediaUrl,
    this.isVideo = false,
    this.createdAt,
    this.expiresAt,
  });

  bool get isExpired {
    final e = expiresAt;
    if (e == null) return false;
    return DateTime.now().isAfter(e);
  }

  factory StoryDoc.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? {};
    return StoryDoc.fromMap(d, doc.id);
  }

  factory StoryDoc.fromMap(Map<String, dynamic> d, String id) {
    return StoryDoc(
      id: FirestoreConverters.toStr(d['id'], id),
      userId: FirestoreConverters.toStr(d['userId'] ?? d['user_id']),
      userName: FirestoreConverters.toStr(
        d['userName'] ?? d['user_name'],
      ),
      mediaUrl: FirestoreConverters.toStr(
        d['mediaUrl'] ?? d['imageUrl'] ?? d['image_url'],
      ),
      isVideo: FirestoreConverters.toBool(d['isVideo']),
      createdAt: FirestoreConverters.toDateTime(d['createdAt']),
      expiresAt: FirestoreConverters.toDateTime(d['expiresAt']),
    );
  }

  /// `expiresAt` is a Firestore [Timestamp] (NOT an ISO string): every
  /// reader (`listActive`, `listByUser`) and the scheduled
  /// `cleanupExpiredStories` compare it against `Timestamp.now()`, and
  /// cross-type comparisons never match. Computed from the client clock
  /// (server timestamps can't express "now + TTL" in a create map);
  /// a few minutes of client skew only shifts visibility slightly.
  Map<String, dynamic> toCreateMap({Duration ttl = const Duration(hours: 24)}) {
    return {
      'userId': userId,
      'userName': userName,
      'mediaUrl': mediaUrl,
      'isVideo': isVideo,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(DateTime.now().toUtc().add(ttl)),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'mediaUrl': mediaUrl,
      'isVideo': isVideo,
      'createdAt': createdAt,
      'expiresAt': expiresAt,
    };
  }
}
