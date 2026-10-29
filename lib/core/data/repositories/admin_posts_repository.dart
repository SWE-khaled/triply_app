import 'package:cloud_firestore/cloud_firestore.dart';
import '../remote/firestore_service.dart';

/// One user post as seen and managed by the admin dashboard.
class AdminPost {
  final String id;
  final String title;
  final String text;
  final String author;
  final String authorId;
  final String imageUrl;
  final List<String> imageUrls;
  final String location;
  final DateTime? createdAt;

  const AdminPost({
    required this.id,
    required this.title,
    required this.text,
    required this.author,
    this.authorId = '',
    required this.imageUrl,
    this.imageUrls = const [],
    this.location = '',
    this.createdAt,
  });

  factory AdminPost.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final title = (data['title'] as String?) ??
        (data['text'] as String?) ??
        'User Post';
    final text = (data['text'] as String?) ?? (data['title'] as String?) ?? '';
    final author = (data['author'] as String?) ??
        (data['author_name'] as String?) ??
        (data['authorName'] as String?) ??
        'User';
    final authorId = (data['authorId'] as String?) ??
        (data['userId'] as String?) ??
        '';
    final imageUrl = (data['imageUrl'] as String?) ??
        (data['image_url'] as String?) ??
        '';
    final imageUrls = (data['imageUrls'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        (data['image_urls'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        (imageUrl.isNotEmpty ? [imageUrl] : <String>[]);
    final location = (data['location'] as String?) ?? '';

    DateTime? createdAt;
    if (data['createdAt'] is Timestamp) {
      createdAt = (data['createdAt'] as Timestamp).toDate();
    }

    return AdminPost(
      id: doc.id,
      title: title.length > 50 ? '${title.substring(0, 47)}...' : title,
      text: text,
      author: author,
      authorId: authorId,
      imageUrl: imageUrls.isNotEmpty ? imageUrls.first : imageUrl,
      imageUrls: imageUrls,
      location: location,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'text': text,
      'author': author,
      'authorId': authorId,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'location': location,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}

/// Repository for reading and managing user posts from Firestore.
class AdminPostsRepository {
  AdminPostsRepository({FirestoreService? firestore})
      : _firestore = firestore ?? FirestoreService();

  static const String postsCollection = 'posts';
  final FirestoreService _firestore;

  /// Fetches all user posts, newest first.
  Future<List<AdminPost>> fetchPosts() async {
    try {
      final snapshot = await _firestore
          .collection(postsCollection)
          .get();
      final posts = snapshot.docs.map((doc) => AdminPost.fromDoc(doc)).toList();
      posts.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return -1;
        if (b.createdAt == null) return 1;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      return posts;
    } catch (_) {
      return const [];
    }
  }

  /// Real-time stream of all user posts.
  Stream<List<AdminPost>> watchPosts() {
    return _firestore
        .collection(postsCollection)
        .snapshots()
        .map((snapshot) {
          final posts =
              snapshot.docs.map((doc) => AdminPost.fromDoc(doc)).toList();
          posts.sort((a, b) {
            if (a.createdAt == null && b.createdAt == null) return 0;
            if (a.createdAt == null) return -1;
            if (b.createdAt == null) return 1;
            return b.createdAt!.compareTo(a.createdAt!);
          });
          return posts;
        });
  }

  /// Ensures that if the posts collection in Firestore is completely empty,
  /// the published tourist post is saved to Firestore so it is immediately visible
  /// in the admin dashboard and tourist community feed.
  Future<void> ensureInitialPostIfEmpty() async {
    try {
      final snap = await _firestore.collection(postsCollection).limit(1).get();
      if (snap.docs.isEmpty) {
        await _firestore.collection(postsCollection).doc('post_tourist_published').set({
          'title': 'Amazing day in Egypt! ✨',
          'text': 'Spent an incredible day exploring historic sites in Egypt. The atmosphere, culture and people are truly wonderful! 🇪🇬✨',
          'author': 'Tourist',
          'author_name': 'Tourist',
          'authorName': 'Tourist',
          'authorId': 'tourist_user',
          'imageUrl': 'https://images.unsplash.com/photo-1568322445389-f64ac2515020?q=80&w=800&auto=format&fit=crop',
          'image_url': 'https://images.unsplash.com/photo-1568322445389-f64ac2515020?q=80&w=800&auto=format&fit=crop',
          'imageUrls': ['https://images.unsplash.com/photo-1568322445389-f64ac2515020?q=80&w=800&auto=format&fit=crop'],
          'image_urls': ['https://images.unsplash.com/photo-1568322445389-f64ac2515020?q=80&w=800&auto=format&fit=crop'],
          'location': 'Cairo, Egypt',
          'createdAt': FieldValue.serverTimestamp(),
          'likes_count': 0,
          'comments_count': 0,
        });
      }
    } catch (_) {}
  }

  /// Deletes a post from Firestore.
  Future<bool> deletePost(String postId) async {
    try {
      await _firestore.collection(postsCollection).doc(postId).delete();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Creates a new user post in Firestore.
  Future<String?> createPost({
    required String text,
    required String author,
    String authorId = '',
    String imageUrl = '',
    List<String> imageUrls = const [],
    String location = '',
  }) async {
    try {
      final docRef = await _firestore.collection(postsCollection).add({
        'title': text.length > 50 ? '${text.substring(0, 47)}...' : text,
        'text': text,
        'author': author,
        'authorId': authorId,
        'imageUrl': imageUrl,
        'imageUrls': imageUrls.isNotEmpty ? imageUrls : [imageUrl],
        'location': location,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (_) {
      return null;
    }
  }
}
