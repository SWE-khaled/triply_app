import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../model/community_story.dart';
import 'community_cloudinary_uploader.dart';

/// The Firestore contract for Community Stories.
abstract class CommunityStoriesRepository {
  /// Active Stories, newest first.
  Stream<List<CommunityStory>> watchStories();

  /// Uploads [image] to Cloudinary, then creates the Firestore document.
  Future<CommunityStory> createStory(XFile image);

  /// Deletes only the signed-in owner's Story.
  Future<void> deleteStory(CommunityStory story);
}

class CommunityStoriesException implements Exception {
  const CommunityStoriesException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// The signed-in identity used to author a Story.
abstract class CommunityStoryAuthor {
  String? get uid;
  String get displayName;
  String get email;
  String get photoUrl;
}

class FirebaseCommunityStoryAuthor implements CommunityStoryAuthor {
  FirebaseCommunityStoryAuthor({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  User? get _user => _auth.currentUser;

  @override
  String? get uid => _user?.uid;

  @override
  String get displayName => _user?.displayName ?? '';

  @override
  String get email => _user?.email ?? '';

  @override
  String get photoUrl => _user?.photoURL ?? '';
}

/// Narrow Firestore seam so publishing can be tested without a live project.
abstract class CommunityStoriesWriter {
  String newStoryId();

  Future<void> createStory(String storyId, Map<String, dynamic> data);

  Future<void> deleteStory(String storyId);
}

class FirestoreCommunityStoriesWriter implements CommunityStoriesWriter {
  FirestoreCommunityStoriesWriter({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _stories =>
      _firestore.collection(FirestoreCommunityStoriesRepository.collectionName);

  @override
  String newStoryId() => _stories.doc().id;

  @override
  Future<void> createStory(String storyId, Map<String, dynamic> data) =>
      _stories.doc(storyId).set(data);

  @override
  Future<void> deleteStory(String storyId) => _stories.doc(storyId).delete();
}

class FirestoreCommunityStoriesRepository
    implements CommunityStoriesRepository {
  factory FirestoreCommunityStoriesRepository({
    FirebaseFirestore? firestore,
    CommunityStoryAuthor? author,
    CommunityCloudinaryUploader? imageUploader,
    CommunityStoriesWriter? writer,
  }) {
    return FirestoreCommunityStoriesRepository._(
      firestore,
      author ?? FirebaseCommunityStoryAuthor(),
      imageUploader ?? CommunityCloudinaryUploader(),
      writer,
    );
  }

  FirestoreCommunityStoriesRepository._(
    this._firestore,
    this._author,
    this._imageUploader,
    this._writerOverride,
  );

  static const collectionName = 'communityStories';

  /// The 24-hour feed is small; this also bounds an abused collection.
  static const feedLimit = 100;

  final FirebaseFirestore? _firestore;
  final CommunityStoryAuthor _author;
  final CommunityCloudinaryUploader _imageUploader;
  final CommunityStoriesWriter? _writerOverride;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  late final CommunityStoriesWriter _writer =
      _writerOverride ?? FirestoreCommunityStoriesWriter(firestore: _db);

  CollectionReference<Map<String, dynamic>> get _stories =>
      _db.collection(collectionName);

  String _requireUserId({required String message}) {
    final uid = _author.uid;
    if (uid == null || uid.isEmpty) {
      throw CommunityStoriesException(message);
    }
    return uid;
  }

  @override
  Stream<List<CommunityStory>> watchStories() {
    final currentUserId = _author.uid;
    final cutoff = Timestamp.fromDate(
      DateTime.now().toUtc().subtract(CommunityStory.lifetime),
    );

    // Filtering and ordering by the same field uses Firestore's automatic
    // single-field index, so no composite index is required.
    return _stories
        .where('createdAt', isGreaterThan: cutoff)
        .orderBy('createdAt', descending: true)
        .limit(feedLimit)
        .snapshots()
        .map((snapshot) {
          final stories = snapshot.docs
              .map(
                (document) => CommunityStory.fromDocument(
                  document.data(),
                  document.id,
                  currentUserId: currentUserId,
                ),
              )
              .whereType<CommunityStory>()
              .toList(growable: false);
          return activeStories(stories);
        })
        .handleError((Object error) => throw _storyError(error));
  }

  @override
  Future<CommunityStory> createStory(XFile image) async {
    final uid = _requireUserId(message: 'Sign in to share a Story.');
    final author = _author;

    String imageUrl;
    try {
      imageUrl = await _imageUploader.upload(image);
    } on CommunityMediaException catch (error) {
      throw CommunityStoriesException(error.message);
    } catch (error) {
      throw CommunityStoriesException(
        'Could not upload the Story image. Please try again. ($error)',
      );
    }

    if (!isCloudinaryStoryUrl(imageUrl)) {
      throw const CommunityStoriesException(
        'The uploaded Story image URL is invalid. Please try again.',
      );
    }

    final now = DateTime.now().toUtc();
    final story = CommunityStory(
      id: _writer.newStoryId(),
      authorId: uid,
      authorName: resolveAuthorName(author.displayName, author.email),
      authorAvatarUrl: author.photoUrl,
      imageUrl: imageUrl,
      createdAt: now,
      expiresAt: now.add(CommunityStory.lifetime),
      isMine: true,
    );

    try {
      await _writer.createStory(story.id, story.toFirestore());
    } on CommunityStoriesException {
      rethrow;
    } catch (error) {
      throw _storyError(error);
    }
    return story;
  }

  @override
  Future<void> deleteStory(CommunityStory story) async {
    final uid = _requireUserId(message: 'Sign in to delete your Story.');
    if (story.authorId != uid) {
      throw const CommunityStoriesException(
        'You can only delete your own Stories.',
      );
    }

    try {
      // Cloudinary cannot be deleted from the client without a signed
      // server-side secret, so only the Firestore document is removed.
      await _writer.deleteStory(story.id);
    } on CommunityStoriesException {
      rethrow;
    } catch (error) {
      throw _storyError(error);
    }
  }

  /// The display-name fallback used by Community Posts.
  static String resolveAuthorName(String displayName, String email) {
    final name = displayName.trim();
    if (name.isNotEmpty) return name;
    final emailName = email.split('@').first.trim();
    return emailName.isEmpty ? 'Traveler' : emailName;
  }

  /// Strict check for the Cloudinary secure URL used by uploads.
  static bool isCloudinaryStoryUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) return false;
    return uri.scheme == 'https' &&
        uri.host == 'res.cloudinary.com' &&
        !uri.hasPort &&
        uri.userInfo.isEmpty &&
        uri.path.length > 1;
  }

  /// Applies visibility rules to a stream/page list.
  static List<CommunityStory> activeStories(
    Iterable<CommunityStory> stories, {
    DateTime? now,
  }) {
    final at = now ?? DateTime.now();
    return stories
        .where((story) => story.isDisplayableAt(at))
        .toList(growable: false);
  }

  CommunityStoriesException _storyError(Object error) {
    if (error is CommunityStoriesException) return error;
    if (error is FirebaseException) {
      if (error.code == 'permission-denied' ||
          error.code == 'unauthenticated') {
        return const CommunityStoriesException(
          'You do not have permission to change Community Stories.',
        );
      }
      if (error.code == 'unavailable') {
        return const CommunityStoriesException(
          'Community Stories are unavailable. Try again soon.',
        );
      }
      return CommunityStoriesException(
        error.message ?? 'Could not update Community Stories.',
      );
    }
    return CommunityStoriesException(
      'Could not update Community Stories: $error',
    );
  }
}
