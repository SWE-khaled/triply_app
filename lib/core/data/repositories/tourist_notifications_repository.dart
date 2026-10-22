import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../features/tourist/notifications/model/notification_item.dart';
import '../mock/tourist/mock_notifications.dart';
import '../remote/firestore_service.dart';

/// Reads the notifications of the signed-in tourist.
///
/// The notifications are written by whoever caused the event — the guide
/// when they approve a verification, the admin when they decide a trip —
/// so the tourist sees them in the same collection the guide reads.
class TouristNotificationsRepository {
  TouristNotificationsRepository({FirestoreService? firestore, this.auth})
    : _firestore = firestore ?? FirestoreService();

  /// Firestore collection holding the notifications.
  static const String notificationsCollection = 'notifications';

  final FirestoreService _firestore;

  /// The auth client to read the signed-in tourist from. Null means the
  /// default [FirebaseAuth] instance.
  final FirebaseAuth? auth;

  /// Resolved lazily so building the repository never requires a running
  /// Firebase app (which keeps it usable in plain unit tests).
  FirebaseAuth get _firebaseAuth => auth ?? FirebaseAuth.instance;

  /// The signed-in tourist's uid, or null when signed out.
  String? get currentTouristId {
    try {
      return _firebaseAuth.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  /// The tourist's notifications, live.
  ///
  /// Emits again whenever a notification is written or read — so the
  /// badge updates by itself.
  Stream<List<NotificationItem>> watchNotifications() {
    final uid = currentTouristId;
    if (uid == null) return Stream.value(_mockNotifications());
    try {
      return _firestore.instance
          .collection(notificationsCollection)
          .where('userId', isEqualTo: uid)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => _toNotification(doc.data(), doc.id))
                .toList(),
          );
    } catch (_) {
      return Stream.value(_mockNotifications());
    }
  }

  /// Marks one notification as read.
  Future<void> markAsRead(String notificationId) async {
    await _firestore.writeDoc(notificationsCollection, notificationId, {
      'isRead': true,
    });
  }

  /// Marks every notification as read.
  Future<void> markAllAsRead() async {
    final uid = currentTouristId;
    if (uid == null) return;
    final snapshot = await _firestore
        .collection(notificationsCollection)
        .where('userId', isEqualTo: uid)
        .get();
    for (final doc in snapshot.docs) {
      await markAsRead(doc.id);
    }
  }

  NotificationItem _toNotification(Map<String, dynamic>? data, String id) {
    final merged = <String, dynamic>{
      'id': id,
      'type': 'general',
      'title': '',
      'body': '',
      'is_read': false,
      ...?data,
    };
    merged['id'] = id;
    // The document carries the message, the model shows it as the body.
    merged['body'] = (data?['message'] as String?) ?? '';
    merged['is_read'] = (data?['isRead'] as bool?) ?? false;
    merged['time_label'] = _timeLabel(data?['createdAt']);
    merged['section'] = _isToday(data?['createdAt']) ? 'today' : 'earlier';
    return NotificationItem.fromJson(merged);
  }

  /// The bundled notifications, used when Firestore cannot be reached.
  List<NotificationItem> _mockNotifications() => mockNotificationsRaw
      .map(NotificationItem.fromJson)
      .toList(growable: false);

  /// A readable "when it happened" label.
  String _timeLabel(Object? createdAt) {
    if (createdAt is! Timestamp) return '';
    final value = createdAt.toDate();
    if (_isToday(createdAt)) {
      final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
      final minute = value.minute.toString().padLeft(2, '0');
      return '$hour:$minute ${value.hour < 12 ? 'AM' : 'PM'}';
    }
    return '${value.day}/${value.month}/${value.year}';
  }

  /// Whether the moment is today.
  bool _isToday(Object? createdAt) {
    if (createdAt is! Timestamp) return false;
    final value = createdAt.toDate();
    final now = DateTime.now();
    return value.year == now.year &&
        value.month == now.month &&
        value.day == now.day;
  }
}
