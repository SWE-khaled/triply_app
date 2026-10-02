class CommunityPost {
  final String id;
  final String authorName;
  final String authorAvatarUrl;
  final String timeAgo;
  final String location;
  final String imageUrl;
  final List<String> imageUrls;
  final String text;
  final int commentsCount;
  int likesCount;
  bool isLiked;
  // true when this post belongs to the current (logged-in) user.
  final bool isMine;
  // true when imageUrl points to a local device file (a post created from
  // the composer) instead of a network URL (mock data).
  final bool isLocalImage;

  CommunityPost({
    required this.id,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.timeAgo,
    required this.location,
    required this.imageUrl,
    List<String>? imageUrls,
    required this.text,
    required this.likesCount,
    required this.commentsCount,
    this.isLiked = false,
    this.isLocalImage = false,
    this.isMine = false,
  }) : imageUrls = imageUrls ?? [imageUrl];

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'] as String,
      authorName: json['author_name'] as String,
      authorAvatarUrl: json['author_avatar_url'] as String,
      timeAgo: json['time_ago'] as String,
      location: json['location'] as String,
      imageUrl: json['image_url'] as String,
      text: json['text'] as String,
      likesCount: json['likes_count'] as int,
      commentsCount: json['comments_count'] as int,
      isLiked: json['is_liked'] as bool? ?? false,
      imageUrls: (json['image_urls'] as List?)
          ?.map((e) => e as String)
          .toList(),
      isMine: json['is_mine'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author_name': authorName,
      'author_avatar_url': authorAvatarUrl,
      'time_ago': timeAgo,
      'location': location,
      'image_url': imageUrl,
      'image_urls': imageUrls,
      'text': text,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'is_liked': isLiked,
      'is_mine': isMine,
    };
  }
}