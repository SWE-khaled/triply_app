class NotificationItem {
  final String id;
  final String type;
  final String title;
  final String body;
  final String timeLabel;
  final bool isRead;
  final String section;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timeLabel,
    required this.isRead,
    required this.section,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'general',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      timeLabel: json['time_label'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? true,
      section: json['section'] as String? ?? 'earlier',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'body': body,
      'time_label': timeLabel,
      'is_read': isRead,
      'section': section,
    };
  }

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      type: type,
      title: title,
      body: body,
      timeLabel: timeLabel,
      isRead: isRead ?? this.isRead,
      section: section,
    );
  }
}
