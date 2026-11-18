import 'package:firebase_auth/firebase_auth.dart';

import '../../../features/tour_guide/home_and_notification_tg/model/guide_notification.dart';
import '../../../features/tourist/notifications/model/notification_item.dart';
import '../remote/firestore_service.dart';
import 'tourist_notifications_repository.dart';

/// Adapter over the one session-wide notification repository.
///
/// The guide app keeps its own [GuideNotification] model and cubit API, but
/// there is no second Firestore listener and no mock fallback. When auth has
/// not restored yet, the stream waits for the first signed-in user instead of
/// completing with an empty snapshot.
class GuideNotificationsRepository {
  GuideNotificationsRepository({
    FirestoreService? firestore,
    this.auth,
    TouristNotificationsRepository? shared,
  }) : _shared = shared ?? TouristNotificationsRepository.instance;

  /// One adapter for the whole signed-in session.
  static final GuideNotificationsRepository instance =
      GuideNotificationsRepository();

  final TouristNotificationsRepository _shared;

  /// The auth client used only to resolve the signed-in guide's uid. Null means
  /// the default [FirebaseAuth] instance.
  final FirebaseAuth? auth;

  FirebaseAuth get _auth => auth ?? FirebaseAuth.instance;

  /// The signed-in guide's uid, or null when signed out. Returns null instead
  /// of throwing when no Firebase app exists (plain unit tests).
  String? get currentGuideId {
    try {
      return _auth.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  /// The guide's notifications, live. The badge follows this stream.
  ///
  /// Auth can still be restoring when the page is built. Waiting on
  /// [FirebaseAuth.authStateChanges] here keeps this stream alive until a
  /// guide is available, then hands over to the shared session repository.
  Stream<List<GuideNotification>> watchNotifications() async* {
    if (currentGuideId == null) {
      final user = await _auth.authStateChanges().firstWhere(
        (user) => user != null,
        orElse: () => null,
      );
      if (user == null) return;
    }
    await _shared.ensureStarted(role: TouristNotificationsRepository.roleGuide);
    await for (final items in _shared.watchNotifications()) {
      // A snapshot before `stored`/`chat` report carries no rows. Forwarding
      // it would end the guide page's loading state with a false empty list.
      if (!_shared.hasListSourceData && items.isEmpty) continue;
      yield _mapItems(items);
    }
  }

  /// Short warnings from failed sources. The list page still works with
  /// whichever sources succeeded.
  Stream<List<String>> watchSourceErrors() => _shared.watchSourceErrors();

  /// True once at least one real Firestore source has emitted.
  bool get hasSourceData => _shared.hasSourceData;

  /// True once `stored` or `chat` has produced a real snapshot.
  ///
  /// This is the gate used by the guide page; the profile doc alone does not
  /// carry notifications and must not produce an empty list.
  bool get hasListSourceData => _shared.hasListSourceData;

  /// Current source warnings, newest first.
  List<String> get sourceErrors => _shared.sourceErrors;

  /// One-shot read used by the cubit's retry action.
  Future<List<GuideNotification>> fetchNotifications() async {
    if (currentGuideId == null) return const <GuideNotification>[];
    await _shared.ensureStarted(role: TouristNotificationsRepository.roleGuide);
    try {
      return await _shared
          .watchNotifications()
          .map(_mapItems)
          .first
          .timeout(
            const Duration(seconds: 2),
            onTimeout: () =>
                _shared.currentItems.map(_toGuideNotification).toList(),
          );
    } catch (_) {
      return _shared.currentItems.map(_toGuideNotification).toList();
    }
  }

  /// Writes the persisted booking notification after the booking committed.
  Future<void> createBookingNotification({
    required String userId,
    required String bookingId,
    required int seats,
    String? tripId,
    String? actorName,
    String? actorAvatarUrl,
    String? title,
    String? message,
  }) {
    if (userId.isEmpty || bookingId.isEmpty) return Future<void>.value();
    return _shared.createBookingNotification(
      recipientId: userId,
      bookingId: bookingId,
      seats: seats,
      tripId: tripId,
      actorName: actorName,
      actorAvatarUrl: actorAvatarUrl,
      title: title,
      message: message,
    );
  }

  /// Writes the persisted admin trip-decision notification.
  Future<void> createTripDecisionNotification({
    required String userId,
    required String tripId,
    required String decision,
    String? tripTitle,
    String? actorName,
    String? actorAvatarUrl,
    String? message,
  }) {
    if (userId.isEmpty || tripId.isEmpty) return Future<void>.value();
    return _shared.createTripDecisionNotification(
      recipientId: userId,
      tripId: tripId,
      decision: decision,
      tripTitle: tripTitle,
      actorName: actorName,
      actorAvatarUrl: actorAvatarUrl,
      message: message,
    );
  }

  /// Marks one notification by writing only the shared read-id map.
  Future<void> markAsRead(String notificationId) =>
      _shared.markOneRead(notificationId);

  /// Marks every notification in one atomic user-document write.
  Future<void> markAllAsRead() => _shared.markAllAsRead();

  List<GuideNotification> _mapItems(List<NotificationItem> items) =>
      items.map(_toGuideNotification).toList(growable: false);

  GuideNotification _toGuideNotification(NotificationItem item) {
    return GuideNotification(
      id: item.id,
      type: item.type,
      title: item.title,
      body: item.body,
      isRead: item.isRead,
      createdAt: item.createdAt,
      relatedEntityId: item.relatedEntityId ?? item.targetId,
      relatedCollection: item.relatedCollection,
    );
  }
}
