class CommunityStory {
  final String id;
  final String userId;
  final String userName;
  final String imageUrl;
  final bool hasUnseen;
  // true when this story belongs to the current (logged-in) user.
  final bool isMine;
  // true when imageUrl is a local device file path (from image_picker)
  // instead of a network URL (mock data).
  final bool isLocalFile;

  CommunityStory({
    required this.id,
    required this.userId,
    required this.userName,
    required this.imageUrl,
    this.hasUnseen = true,
    this.isMine = false,
    this.isLocalFile = false,
  });

  factory CommunityStory.fromJson(Map<String, dynamic> json) {
    return CommunityStory(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      userName: json['user_name'] as String,
      imageUrl: json['image_url'] as String,
      hasUnseen: json['has_unseen'] as bool? ?? true,
      isMine: json['is_mine'] as bool? ?? false,
      isLocalFile: json['is_local_file'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'image_url': imageUrl,
      'has_unseen': hasUnseen,
      'is_mine': isMine,
      'is_local_file': isLocalFile,
    };
  }
}