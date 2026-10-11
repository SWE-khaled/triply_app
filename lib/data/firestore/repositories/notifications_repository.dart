import 'package:triply/core/firebase/firestore_result.dart';
import 'package:triply/data/firestore/datasources/firestore_query_helper.dart';
import 'package:triply/data/firestore/datasources/notifications_datasource.dart';
import 'package:triply/data/firestore/mappers/firestore_mappers.dart';
import 'package:triply/features/tour_guide/homeandNotificationTr/model/guide_notification.dart';
import 'package:triply/features/tourist/notifications/model/notification_item.dart';

/// Notification reads + mark-read. Creation is Functions-only.
/// Failures are explicit ([FirestoreFailure]) — never disguised as mock
/// data; cubits keep their own baseline and report the failure.
class NotificationsRepository {
  NotificationsDatasource? _dsInit;
  NotificationsRepository([NotificationsDatasource? ds]) : _dsInit = ds;

  // Lazy: constructing the repository must not touch Firebase (keeps
  // widget/unit tests and offline startup free of Firebase initialization).
  NotificationsDatasource get _ds => _dsInit ??= NotificationsDatasource();

  Future<FirestoreResult<List<NotificationItem>>> myNotifications(
    String userId, {
    int limit = 20,
    Object? startAfter,
  }) async {
    try {
      final page = await _ds.listByUser(
        userId,
        limit: limit,
        startAfter: startAfter,
      );
      final items = page.items
          .map(FirestoreMappers.notificationDocToItem)
          .toList();
      if (items.isEmpty) return const FirestoreEmpty();
      return FirestoreOk(items);
    } catch (e) {
      return FirestoreFailure(FirestoreQueryHelper.friendlyError(e), e);
    }
  }

  Future<void> markOneRead(String id) => _ds.markOneRead(id);
  Future<void> markAllRead(String userId) => _ds.markAllRead(userId);
  Stream<int> unreadCount(String userId) => _ds.unreadCount(userId);

  /// Same recipient-scoped records for the guide list, mapped onto the
  /// guide card model. Empty stays empty; failures are explicit.
  Future<FirestoreResult<List<GuideNotification>>> guideNotifications(
    String userId, {
    int limit = 20,
    Object? startAfter,
  }) async {
    try {
      final page = await _ds.listByUser(
        userId,
        limit: limit,
        startAfter: startAfter,
      );
      final items = page.items
          .map(FirestoreMappers.notificationDocToGuideNotification)
          .toList();
      if (items.isEmpty) return const FirestoreEmpty();
      return FirestoreOk(items);
    } catch (e) {
      return FirestoreFailure(FirestoreQueryHelper.friendlyError(e), e);
    }
  }
}
