class GuideNotification {
  final String id;
  final String type;
  final String title;
  final String body;

  /// Read state from the backend (`notifications/{id}.isRead`).
  /// Defaults to read for legacy mock entries (no dot rendered).
  final bool isRead;

  /// Relative display label (e.g. "2h ago"). Empty when unknown.
  final String timeLabel;

  const GuideNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.isRead = true,
    this.timeLabel = '',
  });

  factory GuideNotification.fromJson(Map<String, dynamic> json) {
    return GuideNotification(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'general',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? true,
      timeLabel: json['time_label'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'body': body,
      'is_read': isRead,
      'time_label': timeLabel,
    };
  }

  GuideNotification copyWith({bool? isRead}) {
    return GuideNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      isRead: isRead ?? this.isRead,
      timeLabel: timeLabel,
    );
  }
}
