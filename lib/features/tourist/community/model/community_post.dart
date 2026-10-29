import 'package:cloud_firestore/cloud_firestore.dart';

/// A community-feed post. The author snapshot deliberately lives on the post
/// so everyone who can read the public feed can render it without reading a
/// private `users/{uid}` document.
class CommunityPost {
  final String id;
  final String authorId;
  final String authorName;
  final String authorAvatarUrl;
  final DateTime? createdAt;
  final String? timeAgoLabel;
  final String location;
  final List<String> imageUrls;
  final List<String> storagePaths;
  final String text;
  final int commentsCount;
  final int likesCount;
  final Map<String, bool> likedBy;
  final bool isLiked;
  final bool isMine;
  final bool isLocalImage;

  CommunityPost({
    required this.id,
    this.authorId = '',
    required this.authorName,
    required this.authorAvatarUrl,
    this.createdAt,
    this.timeAgoLabel,
    required this.location,
    String imageUrl = '',
    List<String>? imageUrls,
    List<String>? storagePaths,
    required this.text,
    required this.likesCount,
    required this.commentsCount,
    Map<String, bool>? likedBy,
    this.isLiked = false,
    this.isLocalImage = false,
    this.isMine = false,
  }) : imageUrls = imageUrls ?? (imageUrl.isEmpty ? const [] : [imageUrl]),
       storagePaths = storagePaths ?? const [],
       likedBy = likedBy ?? const <String, bool>{};

  String get imageUrl => imageUrls.isEmpty ? '' : imageUrls.first;

  String get timeAgo => timeAgoLabel ?? CommunityPostTime.format(createdAt);

  CommunityPost copyWith({
    int? likesCount,
    Map<String, bool>? likedBy,
    bool? isLiked,
    bool? isMine,
    DateTime? createdAt,
  }) => CommunityPost(
    id: id,
    authorId: authorId,
    authorName: authorName,
    authorAvatarUrl: authorAvatarUrl,
    createdAt: createdAt ?? this.createdAt,
    timeAgoLabel: timeAgoLabel,
    location: location,
    imageUrls: imageUrls,
    storagePaths: storagePaths,
    text: text,
    likesCount: likesCount ?? this.likesCount,
    commentsCount: commentsCount,
    likedBy: likedBy ?? this.likedBy,
    isLiked: isLiked ?? this.isLiked,
    isLocalImage: isLocalImage,
    isMine: isMine ?? this.isMine,
  );

  factory CommunityPost.fromDocument(
    Map<String, dynamic>? data,
    String id, {
    String? currentUserId,
  }) {
    final values = data ?? const <String, dynamic>{};
    final authorId = _string(values['authorId']);
    final imageUrls = _stringList(values['imageUrls']);
    final likedBy = _likedBy(values['likedBy']);
    // `imageUrl` was used by the mock-only screen. Reading it keeps old
    // documents and manually seeded data compatible with the new feed.
    final legacyImage = _string(values['imageUrl']);
    return CommunityPost(
      id: id,
      authorId: authorId,
      authorName: _string(values['authorName'], fallback: 'Traveler'),
      authorAvatarUrl: _string(values['authorAvatarUrl']),
      createdAt: _date(values['createdAt']),
      location: _string(values['location']),
      imageUrls: imageUrls.isNotEmpty
          ? imageUrls
          : (legacyImage.isEmpty ? const [] : [legacyImage]),
      storagePaths: _stringList(values['storagePaths']),
      text: _string(values['text']),
      likesCount: _int(values['likesCount']),
      commentsCount: _int(values['commentsCount']),
      likedBy: likedBy,
      isLiked: currentUserId != null && likedBy.containsKey(currentUserId),
      isMine: authorId.isNotEmpty && authorId == currentUserId,
    );
  }

  /// Parses the existing mock fixture and keeps it as a no-network fallback.
  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    final rawImages = _stringList(json['image_urls']);
    final legacyImage = _string(json['image_url']);
    return CommunityPost(
      id: _string(json['id']),
      authorId: _string(json['author_id']),
      authorName: _string(json['author_name'], fallback: 'Traveler'),
      authorAvatarUrl: _string(json['author_avatar_url']),
      timeAgoLabel: _string(json['time_ago']).isEmpty
          ? null
          : _string(json['time_ago']),
      location: _string(json['location']),
      imageUrls: rawImages.isNotEmpty
          ? rawImages
          : (legacyImage.isEmpty ? const [] : [legacyImage]),
      text: _string(json['text']),
      likesCount: _int(json['likes_count']),
      commentsCount: _int(json['comments_count']),
      isLiked: json['is_liked'] == true,
      isMine: json['is_mine'] == true,
    );
  }

  Map<String, dynamic> toFirestore() => <String, dynamic>{
    'authorId': authorId,
    'authorName': authorName,
    'authorAvatarUrl': authorAvatarUrl,
    'location': location,
    'imageUrls': imageUrls,
    'storagePaths': storagePaths,
    'text': text,
    'likesCount': likesCount,
    'commentsCount': commentsCount,
    // Creating a post must stay compatible with the existing create rule,
    // which does not allowlist `likedBy`. Likes add this field later through
    // the update transaction.
    if (likedBy.isNotEmpty) 'likedBy': likedBy,
  };

  static String _string(Object? value, {String fallback = ''}) =>
      value is String ? value : fallback;

  static int _int(Object? value) => value is num ? value.toInt() : 0;

  static List<String> _stringList(Object? value) => value is List
      ? value.whereType<String>().where((item) => item.isNotEmpty).toList()
      : const [];

  static Map<String, bool> _likedBy(Object? value) {
    if (value is! Map) return const <String, bool>{};
    return <String, bool>{
      for (final entry in value.entries)
        if (entry.key is String) entry.key as String: true,
    };
  }

  static DateTime? _date(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    return null;
  }
}

class CommunityPostTime {
  const CommunityPostTime._();

  static String format(DateTime? value, {DateTime? now}) {
    if (value == null) return 'Just now';
    final difference = (now ?? DateTime.now()).difference(value);
    if (difference.isNegative || difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours} hours ago';
    if (difference.inDays == 1) return 'Yesterday';
    return '${difference.inDays} days ago';
  }
}
