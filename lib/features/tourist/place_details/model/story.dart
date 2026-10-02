class Story {
  final String id;
  final String placeId;
  final String authorName;
  final String timeAgo;
  final String text;
  final String imageUrl;

  Story({
    required this.id,
    required this.placeId,
    required this.authorName,
    required this.timeAgo,
    required this.text,
    required this.imageUrl,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'] as String,
      placeId: json['place_id'] as String,
      authorName: json['author_name'] as String,
      timeAgo: json['time_ago'] as String,
      text: json['text'] as String,
      imageUrl: json['image_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'place_id': placeId,
      'author_name': authorName,
      'time_ago': timeAgo,
      'text': text,
      'image_url': imageUrl,
    };
  }
}
