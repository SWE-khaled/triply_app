class GuideNotification {
  final String id;
  final String type;
  final String title;
  final String body;

  const GuideNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
  });

  factory GuideNotification.fromJson(Map<String, dynamic> json) {
    return GuideNotification(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'general',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'body': body,
    };
  }
}
