import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:triply/core/firebase/firestore_converters.dart';

/// Canonical `posts/{postId}` document + `posts/{postId}/likes/{uid}`.
///
/// Matches the actual composer UI: text + multi-image + optional location.
/// `authorId/authorName/authorAvatarUrl` are denormalized at write time.
/// Likes live in the `likes` subcollection (ownership-safe); `likesCount`
/// is a server-maintained aggregate (Function), never client-written.
class PostDoc {
  final String id;
  final String authorId;
  final String authorName;
  final String authorAvatarUrl;
  final String text;
  final List<String> imageUrls;
  final String location;
  final int likesCount;
  final int commentsCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PostDoc({
    required this.id,
    required this.authorId,
    this.authorName = '',
    this.authorAvatarUrl = '',
    this.text = '',
    this.imageUrls = const [],
    this.location = '',
    this.likesCount = 0,
    this.commentsCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory PostDoc.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? {};
    return PostDoc.fromMap(d, doc.id);
  }

  factory PostDoc.fromMap(Map<String, dynamic> d, String id) {
    final imgs = FirestoreConverters.toStringList(
      d['imageUrls'] ?? d['image_urls'],
    );
    final single = FirestoreConverters.toStr(
      d['imageUrl'] ?? d['image_url'],
    );
    final allImgs = imgs.isNotEmpty
        ? imgs
        : (single.isEmpty ? const <String>[] : [single]);
    return PostDoc(
      id: FirestoreConverters.toStr(d['id'], id),
      authorId: FirestoreConverters.toStr(
        d['authorId'] ?? d['userId'] ?? d['user_id'],
      ),
      authorName: FirestoreConverters.toStr(
        d['authorName'] ?? d['author_name'],
      ),
      authorAvatarUrl: FirestoreConverters.toStr(
        d['authorAvatarUrl'] ?? d['author_avatar_url'],
      ),
      text: FirestoreConverters.toStr(d['text']),
      imageUrls: allImgs,
      location: FirestoreConverters.toStr(d['location']),
      likesCount: FirestoreConverters.toInt(
        d['likesCount'] ?? d['likes_count'],
      ),
      commentsCount: FirestoreConverters.toInt(
        d['commentsCount'] ?? d['comments_count'],
      ),
      createdAt: FirestoreConverters.toDateTime(d['createdAt']),
      updatedAt: FirestoreConverters.toDateTime(d['updatedAt']),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatarUrl': authorAvatarUrl,
      'text': text,
      'imageUrls': imageUrls,
      'imageUrl': imageUrls.isNotEmpty ? imageUrls.first : '',
      'location': location,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatarUrl': authorAvatarUrl,
      'text': text,
      'imageUrls': imageUrls,
      'imageUrl': imageUrls.isNotEmpty ? imageUrls.first : '',
      'location': location,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
