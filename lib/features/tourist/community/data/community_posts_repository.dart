import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../model/community_post.dart';
import 'community_cloudinary_uploader.dart';

/// The Firestore contract for Community posts. The rules are intentionally
/// not changed here; this layer reports Firebase permission failures to the
/// UI instead of pretending a post was shared.
abstract class CommunityPostsRepository {
  Stream<List<CommunityPost>> watchPosts();

  Future<CommunityPost> createPost({
    required List<XFile> images,
    required String text,
    String? location,
  });

  Future<void> deletePost(CommunityPost post);

  /// Likes or unlikes [postId] for the signed-in user.
  Future<void> toggleLike({required String postId, required bool liked});
}

class CommunityPostsException implements Exception {
  const CommunityPostsException(this.message);

  final String message;

  @override
  String toString() => message;
}

class FirestoreCommunityPostsRepository implements CommunityPostsRepository {
  FirestoreCommunityPostsRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    CommunityCloudinaryUploader? imageUploader,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _imageUploader = imageUploader ?? CommunityCloudinaryUploader();

  static const collectionName = 'communityPosts';
  static const feedLimit = 30;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final CommunityCloudinaryUploader _imageUploader;

  CollectionReference<Map<String, dynamic>> get _posts =>
      _firestore.collection(collectionName);

  String _requireUserId({String message = 'Sign in to share a post.'}) {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw CommunityPostsException(message);
    }
    return uid;
  }

  @override
  Stream<List<CommunityPost>> watchPosts() {
    final currentUserId = _auth.currentUser?.uid;
    return _posts
        .orderBy('createdAt', descending: true)
        .limit(feedLimit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (document) => CommunityPost.fromDocument(
                  document.data(),
                  document.id,
                  currentUserId: currentUserId,
                ),
              )
              .toList(growable: false),
        )
        .handleError((Object error) => throw _firestoreError(error));
  }

  /// All posts belonging to the current user, without the feed's page limit.
  Stream<List<CommunityPost>> watchMyPosts() {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      return Stream.value(const <CommunityPost>[]);
    }
    return _posts
        .where('authorId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
          final posts = snapshot.docs
              .map(
                (document) => CommunityPost.fromDocument(
                  document.data(),
                  document.id,
                  currentUserId: uid,
                ),
              )
              .toList();
          posts.sort(
            (a, b) => (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
                .compareTo(
                  a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
                ),
          );
          return posts;
        })
        .handleError((Object error) => throw _firestoreError(error));
  }

  /// Pure transition used by the Firestore transaction and its unit tests.
  static ({int likesCount, Map<String, dynamic> likedBy, bool changed})
  nextLikeState({
    required Map<String, dynamic> data,
    required String uid,
    required bool liked,
  }) {
    final likedBy = <String, dynamic>{};
    final rawLikedBy = data['likedBy'];
    if (rawLikedBy is Map) {
      for (final entry in rawLikedBy.entries) {
        final key = entry.key;
        if (key is String) likedBy[key] = true;
      }
    }

    final rawCount = data['likesCount'];
    final count = rawCount is num ? rawCount.toInt() : 0;
    final safeCount = count < 0 ? 0 : count;
    final alreadyLiked = likedBy.containsKey(uid);
    if (liked == alreadyLiked) {
      return (likesCount: safeCount, likedBy: likedBy, changed: false);
    }

    if (liked) {
      likedBy[uid] = true;
    } else {
      likedBy.remove(uid);
    }
    final nextCount = liked
        ? safeCount + 1
        : (safeCount > 0 ? safeCount - 1 : 0);
    return (likesCount: nextCount, likedBy: likedBy, changed: true);
  }

  @override
  Future<void> toggleLike({required String postId, required bool liked}) async {
    final uid = _requireUserId(message: 'Sign in to like Community posts.');
    final document = _posts.doc(postId);
    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(document);
        if (!snapshot.exists) {
          throw const CommunityPostsException(
            'This post is no longer available.',
          );
        }

        final next = nextLikeState(
          data: snapshot.data() ?? const <String, dynamic>{},
          uid: uid,
          liked: liked,
        );
        if (!next.changed) return;

        transaction.update(document, <String, dynamic>{
          'likesCount': next.likesCount,
          'likedBy': next.likedBy,
        });
      });
    } on CommunityPostsException {
      rethrow;
    } on FirebaseException catch (error) {
      if (error.code == 'permission-denied' ||
          error.code == 'unauthenticated') {
        throw const CommunityPostsException(
          'You do not have permission to update this like.',
        );
      }
      throw _firestoreError(error);
    } catch (error) {
      throw _firestoreError(error);
    }
  }

  @override
  Future<CommunityPost> createPost({
    required List<XFile> images,
    required String text,
    String? location,
  }) async {
    final uid = _requireUserId();
    final body = text.trim();
    if (body.isEmpty && images.isEmpty) {
      throw const CommunityPostsException(
        'Add a photo or write something first.',
      );
    }

    final user = _auth.currentUser!;
    final document = _posts.doc();
    final imageUrls = <String>[];
    try {
      for (final image in images) {
        imageUrls.add(await _imageUploader.upload(image));
      }

      final post = CommunityPost(
        id: document.id,
        authorId: uid,
        authorName: _displayName(user),
        authorAvatarUrl: user.photoURL ?? '',
        createdAt: DateTime.now(),
        location: location?.trim() ?? '',
        imageUrls: imageUrls,
        // Cloudinary owns the files now; the deployed rules require this
        // Firebase Storage path list to stay empty.
        storagePaths: const [],
        text: body,
        likesCount: 0,
        commentsCount: 0,
        isMine: true,
      );
      await document.set(<String, dynamic>{
        ...post.toFirestore(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return post;
    } on CommunityMediaException catch (error) {
      throw CommunityPostsException(error.message);
    } catch (error) {
      if (error is CommunityPostsException) rethrow;
      throw _firestoreError(error);
    }
  }

  @override
  Future<void> deletePost(CommunityPost post) async {
    final uid = _requireUserId();
    if (post.authorId != uid) {
      throw const CommunityPostsException(
        'You can only delete your own posts.',
      );
    }
    try {
      // Cloudinary images cannot be deleted from the client without a signed
      // server-side secret, so deleting the post only removes its document.
      await _posts.doc(post.id).delete();
    } catch (error) {
      if (error is CommunityPostsException) rethrow;
      throw _firestoreError(error);
    }
  }

  static String _displayName(User user) {
    final name = user.displayName?.trim() ?? '';
    if (name.isNotEmpty) return name;
    final emailName = user.email?.split('@').first.trim() ?? '';
    return emailName.isEmpty ? 'Traveler' : emailName;
  }

  CommunityPostsException _firestoreError(Object error) {
    if (error is CommunityPostsException) return error;
    if (error is FirebaseException) {
      if (error.code == 'permission-denied' ||
          error.code == 'unauthenticated') {
        return const CommunityPostsException(
          'Community posts are not enabled for this account yet.',
        );
      }
      if (error.code == 'unavailable') {
        return const CommunityPostsException(
          'Community is unavailable. Try again soon.',
        );
      }
      return CommunityPostsException(
        error.message ?? 'Could not update Community.',
      );
    }
    return CommunityPostsException('Could not update Community: $error');
  }
}
