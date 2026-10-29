import 'package:cloud_firestore/cloud_firestore.dart';

/// A Community Story.
///
/// New Stories are Firestore-backed. The `fromJson` parser is kept for the
/// existing mock fixtures so those files can stay untouched.
class CommunityStory {
  /// A Story lives for exactly 24 hours from its resolved `createdAt`.
  static const Duration lifetime = Duration(hours: 24);

  final String id;
  final String authorId;
  final String authorName;
  final String authorAvatarUrl;
  final String imageUrl;
  final DateTime? createdAt;

  /// Stored as a cleanup hint for TTL. Visibility is derived from
  /// [createdAt] + [lifetime], not from this field.
  final DateTime? expiresAt;

  final bool hasUnseen;
  // true when this story belongs to the current (logged-in) user.
  final bool isMine;
  // Kept for the existing local-file viewer fallback. Firestore Stories
  // always set this to false.
  final bool isLocalFile;

  CommunityStory({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatarUrl = '',
    required this.imageUrl,
    this.createdAt,
    this.expiresAt,
    this.hasUnseen = true,
    this.isMine = false,
    this.isLocalFile = false,
  });

  /// Compatibility getters for the widgets that already use the old names.
  String get userId => authorId;
  String get userName => authorName;

  /// The authoritative expiry moment.
  ///
  /// A missing [createdAt] cannot be displayed, but [expiresAt] is still used
  /// as a fallback for any legacy document that only carries the cleanup
  /// field.
  DateTime? get expiryTime => createdAt?.add(lifetime) ?? expiresAt;

  bool hasResolvedCreatedAt() => createdAt != null;

  /// Whether this Story may be shown at [now].
  ///
  /// Unresolved/missing creation times are rejected, as are Stories at or
  /// after their 24-hour boundary.
  bool isDisplayableAt(DateTime now) {
    if (createdAt == null || imageUrl.isEmpty) return false;
    return !isExpiredAt(now);
  }

  bool isExpiredAt(DateTime now) {
    final expiry = expiryTime;
    if (expiry == null) return true;
    return !now.isBefore(expiry);
  }

  /// Parses a Firestore document.
  ///
  /// Returns null when the document has no resolved creation time, no image,
  /// or has already expired. Firestore server timestamps are unresolved in
  /// pending local snapshots, so those documents are intentionally skipped
  /// until the server confirms them.
  static CommunityStory? fromDocument(
    Map<String, dynamic>? data,
    String id, {
    String? currentUserId,
    DateTime? now,
  }) {
    final values = data ?? const <String, dynamic>{};
    final createdAt = _date(values['createdAt']);
    if (createdAt == null) return null;

    final imageUrl = _string(values['imageUrl']);
    if (imageUrl.isEmpty) return null;

    final authorId = _string(values['authorId']);
    final story = CommunityStory(
      id: id,
      authorId: authorId,
      authorName: _string(values['authorName'], fallback: 'Traveler'),
      authorAvatarUrl: _string(values['authorAvatarUrl']),
      imageUrl: imageUrl,
      createdAt: createdAt,
      expiresAt: _date(values['expiresAt']) ?? createdAt.add(lifetime),
      isMine: authorId.isNotEmpty && authorId == currentUserId,
    );

    return story.isDisplayableAt(now ?? DateTime.now()) ? story : null;
  }

  /// Parses the existing mock fixture. Kept compatible with its snake_case
  /// keys; mock data is deliberately not migrated to Firestore.
  factory CommunityStory.fromJson(Map<String, dynamic> json) {
    return CommunityStory(
      id: json['id'] as String,
      authorId: json['user_id'] as String? ?? '',
      authorName: json['user_name'] as String,
      authorAvatarUrl: json['author_avatar_url'] as String? ?? '',
      imageUrl: json['image_url'] as String,
      hasUnseen: json['has_unseen'] as bool? ?? true,
      isMine: json['is_mine'] as bool? ?? false,
      isLocalFile: json['is_local_file'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': authorId,
      'user_name': authorName,
      'image_url': imageUrl,
      'has_unseen': hasUnseen,
      'is_mine': isMine,
      'is_local_file': isLocalFile,
    };
  }

  /// The exact write contract for `communityStories`.
  ///
  /// `createdAt` is always a server timestamp. UI-only fields and the local
  /// file path are never serialized.
  Map<String, dynamic> toFirestore() {
    final expiry = expiresAt ?? createdAt?.add(lifetime);
    if (expiry == null) {
      throw StateError(
        'A Story needs createdAt or expiresAt before serialization.',
      );
    }
    return <String, dynamic>{
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatarUrl': authorAvatarUrl,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(expiry.toUtc()),
    };
  }

  static String _string(Object? value, {String fallback = ''}) =>
      value is String ? value : fallback;

  static DateTime? _date(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    return null;
  }
}
