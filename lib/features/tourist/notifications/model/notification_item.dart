class NotificationItem {
  final String id;
  final String type;
  final String title;
  final String body;
  final String timeLabel;
  final bool isRead;
  final String section;

  /// When the underlying event happened. Used to sort the merged list and to
  /// decide unread state against the shared `users/{uid}` read marker.
  final DateTime? createdAt;

  /// The id the notification points at (post/chat/booking/trip id). This can
  /// differ from [id] for chat messages, whose [id] is a per-message key.
  final String targetId;

  /// The destination understood by the notification navigator: `post`,
  /// `trip` or `chat`. Empty for notifications with no deep link.
  final String routeType;

  /// The record this notification is about, for feature screens that use
  /// their own navigation (for example a guide opening a booking).
  final String? relatedEntityId;

  /// The collection of [relatedEntityId]: `communityPosts`, `bookings`,
  /// `trips` or `chats`.
  final String? relatedCollection;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timeLabel,
    required this.isRead,
    required this.section,
    this.createdAt,
    this.targetId = '',
    this.routeType = '',
    this.relatedEntityId,
    this.relatedCollection,
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
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
      targetId: json['target_id'] as String? ?? '',
      routeType: json['route_type'] as String? ?? '',
      relatedEntityId: json['related_entity_id'] as String?,
      relatedCollection: json['related_collection'] as String?,
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
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
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      'target_id': targetId,
      'route_type': routeType,
      'related_entity_id': relatedEntityId,
      'related_collection': relatedCollection,
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
      createdAt: createdAt,
      targetId: targetId,
      routeType: routeType,
      relatedEntityId: relatedEntityId,
      relatedCollection: relatedCollection,
    );
  }
}
