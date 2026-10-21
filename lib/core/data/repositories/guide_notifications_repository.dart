import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../features/tour_guide/home_and_notification_tg/model/guide_notification.dart';
import '../mock/tourguide/mock_guide_notifications.dart';
import '../remote/firestore_service.dart';

/// Reads the notifications of the signed-in tour guide.
///
/// Firestore is the source of truth; the mock dataset is the fallback.
///
/// The notifications are written by whoever caused the event — the admin
/// when it approves a trip, the tourist when it books one — so this
/// repository also exposes [create] for the app that causes them.
class GuideNotificationsRepository {
  GuideNotificationsRepository({FirestoreService? firestore, this.auth})
    : _firestore = firestore ?? FirestoreService();

  /// Firestore collection holding the notifications.
  static const String notificationsCollection = 'notifications';

  final FirestoreService _firestore;

  /// The auth client to read the signed-in guide from. Null means the
  /// default [FirebaseAuth] instance.
  final FirebaseAuth? auth;

  /// Resolved lazily so building the repository never requires a running
  /// Firebase app (which keeps it usable in plain unit tests).
  FirebaseAuth get _firebaseAuth => auth ?? FirebaseAuth.instance;

  /// The signed-in guide's uid, or null when signed out.
  /// The signed-in guide's uid, or null when signed out.
  ///
  /// Returns null (instead of throwing) when there is no Firebase app,
  /// so the repositories stay usable in plain unit tests.
  String? get currentGuideId {
    try {
      return _firebaseAuth.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  /// The guide's notifications, live.
  ///
  /// Emits again whenever a notification is written, read or deleted — so
  /// the badge on the dashboard updates by itself.
  Stream<List<GuideNotification>> watchNotifications() {
    final uid = currentGuideId;
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

  /// The guide's notifications, newest first.
  Future<List<GuideNotification>> fetchNotifications() async {
    final uid = currentGuideId;
    if (uid == null) return _mockNotifications();
    try {
      final snapshot = await _firestore
          .collection(notificationsCollection)
          .where('userId', isEqualTo: uid)
          .get();
      return snapshot.docs
          .map((doc) => _toNotification(doc.data(), doc.id))
          .toList();
    } catch (_) {
      return _mockNotifications();
    }
  }

  /// Writes a notification for [userId].
  ///
  /// The rules allow a notification addressed to its own author, and an
  /// admin may address anybody — that is how the admin dashboard tells a
  /// guide that a trip was approved.
  Future<String?> create({
    required String userId,
    required String title,
    required String message,
    String type = 'general',
    String? relatedEntityId,
    String? relatedCollection,
  }) async {
    try {
      final ref = _firestore.collection(notificationsCollection).doc();
      await ref.set({
        'userId': userId,
        'title': title,
        'message': message,
        'type': type,
        'relatedEntityId': relatedEntityId,
        'relatedCollection': relatedCollection,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return ref.id;
    } catch (_) {
      return null;
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
    final uid = currentGuideId;
    if (uid == null) return;
    final snapshot = await _firestore
        .collection(notificationsCollection)
        .where('userId', isEqualTo: uid)
        .get();
    for (final doc in snapshot.docs) {
      await markAsRead(doc.id);
    }
  }

  GuideNotification _toNotification(Map<String, dynamic>? data, String id) {
    final merged = <String, dynamic>{
      'id': id,
      'type': 'general',
      'title': '',
      'message': '',
      ...?data,
    };
    merged['id'] = id;
    return GuideNotification.fromJson(merged);
  }

  List<GuideNotification> _mockNotifications() => mockGuideNotificationsRaw
      .map(GuideNotification.fromJson)
      .toList(growable: false);
}
