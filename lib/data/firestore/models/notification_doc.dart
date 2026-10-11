import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:triply/core/firebase/firestore_converters.dart';

/// Canonical `notifications/{notificationId}` document.
///
/// `userId` is the RECIPIENT. Only the recipient may read/mark-read;
/// only Functions may create (booking/trip/verification events). Clients
/// may update `isRead` on their own docs and nothing else.
class NotificationDoc {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final String? relatedEntityId;
  final String? relatedCollection;
  final bool isRead;
  final DateTime? createdAt;

  const NotificationDoc({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    this.type = 'general',
    this.relatedEntityId,
    this.relatedCollection,
    this.isRead = false,
    this.createdAt,
  });

  factory NotificationDoc.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? {};
    return NotificationDoc.fromMap(d, doc.id);
  }

  factory NotificationDoc.fromMap(Map<String, dynamic> d, String id) {
    return NotificationDoc(
      id: FirestoreConverters.toStr(d['id'], id),
      userId: FirestoreConverters.toStr(d['userId']),
      title: FirestoreConverters.toStr(d['title']),
      message: FirestoreConverters.toStr(d['message'] ?? d['body']),
      type: FirestoreConverters.toStr(d['type'], 'general'),
      relatedEntityId: (d['relatedEntityId'] ?? d['relatedId']) as String?,
      relatedCollection: d['relatedCollection'] as String?,
      isRead: FirestoreConverters.toBool(
        d['isRead'] ?? d['is_read'],
        false,
      ),
      createdAt: FirestoreConverters.toDateTime(d['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'relatedEntityId': relatedEntityId,
      'relatedCollection': relatedCollection,
      'isRead': isRead,
      'createdAt': createdAt,
    };
  }
}
