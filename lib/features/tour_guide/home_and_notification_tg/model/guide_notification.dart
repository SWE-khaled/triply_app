import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

/// One notification for the tour guide.
///
/// The document holds who it is for (`userId`), what happened (`type`),
/// the text, and the record it is about (`relatedEntityId`) so the guide
/// can jump straight to the trip or the booking.
class GuideNotification {
  final String id;
  final String type;
  final String title;
  final String body;

  /// Whether the guide has already read it.
  final bool isRead;

  /// When it was created.
  final DateTime? createdAt;

  /// The trip or booking it is about.
  final String? relatedEntityId;

  /// `trips` or `bookings`.
  final String? relatedCollection;

  const GuideNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.isRead = true,
    this.createdAt,
    this.relatedEntityId,
    this.relatedCollection,
  });

  factory GuideNotification.fromJson(Map<String, dynamic> json) {
    return GuideNotification(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'general',
      title: json['title'] as String? ?? '',
      body: json['message'] as String? ?? json['body'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? json['is_read'] as bool? ?? true,
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']),
      relatedEntityId:
          json['relatedEntityId'] as String? ??
          json['related_entity_id'] as String?,
      relatedCollection:
          json['relatedCollection'] as String? ??
          json['related_collection'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': body,
      'isRead': isRead,
      'createdAt': createdAt?.toIso8601String(),
      'relatedEntityId': relatedEntityId,
      'relatedCollection': relatedCollection,
    };
  }

  /// A short "when" label: Today / Yesterday / a date.
  String get timeLabel {
    final at = createdAt;
    if (at == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(at.year, at.month, at.day);
    final diff = day.difference(today).inDays;
    final clock = _clock(at);
    if (diff == 0) return 'Today, $clock';
    if (diff == 1) return 'Yesterday, $clock';
    return '${at.day}/${at.month}/${at.year}';
  }

  /// Whether the guide has not read it yet.
  bool get isUnread => !isRead;

  static String _clock(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${value.hour < 12 ? 'AM' : 'PM'}';
  }

  static DateTime? _parseDate(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
