import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../features/tourist/notifications/model/notification_item.dart';
import '../remote/firestore_service.dart';
import '../../utils/active_chat_tracker.dart';

/// The single notification source shared by the tourist and guide apps.
///
/// Persisted events (`like`, `booking`, `trip_decided`) live only in
/// `users/{uid}/notifications`. The other rows are derived from the streams
/// the app already owns: `communityPosts`, approved `trips` and `chats`.
/// Nothing is stored in the retired top-level `notifications` collection.
///
/// Unread state is also shared: `users/{uid}.notificationsLastSeenAt` plus a
/// bounded `readNotificationIds` map. Opening a screen never writes either
/// field; only an explicit mark action does.
class TouristNotificationsRepository {
  TouristNotificationsRepository({FirestoreService? firestore, this.auth})
    : _firestore = firestore ?? FirestoreService() {
    // Fan-out only. [watchNotifications] gives every subscriber the cached
    // snapshot before this controller's live events.
    _itemsController = StreamController<List<NotificationItem>>.broadcast();
    _unreadController = StreamController<int>.broadcast(
      onListen: () => _replayUnreadCount(),
    );
    // Opening/closing a chat is local state. Rebuild synchronously so the
    // badge and the list stop counting that room immediately, without a
    // Firestore round trip.
    ActiveChatTracker.instance.addListener(_onActiveChatChanged);
  }

  /// One repository for the whole signed-in session.
  static final TouristNotificationsRepository instance =
      TouristNotificationsRepository();

  static const String usersCollection = 'users';

  /// The ONLY persisted notification collection, nested under the recipient.
  static const String storedCollection = 'notifications';
  static const String postsCollection = 'communityPosts';
  static const String tripsCollection = 'trips';
  static const String chatsCollection = 'chats';
  static const String lastSeenField = 'notificationsLastSeenAt';
  static const String readIdsField = 'readNotificationIds';
  static const String createdAtField = 'createdAt';

  static const String roleTourist = 'tourist';
  static const String roleGuide = 'guide';
  static const String roleAdmin = 'admin';

  /// Reads per source stay bounded. No listener is unbounded.
  static const int sourceLimit = 20;
  static const int listLimit = 50;
  static const int maxReadIds = 200;

  final FirestoreService _firestore;

  /// The auth client to read the signed-in user from. Null means the default
  /// [FirebaseAuth] instance.
  final FirebaseAuth? auth;

  FirebaseAuth get _auth => auth ?? FirebaseAuth.instance;
  FirebaseFirestore get _db => _firestore.instance;

  late final StreamController<List<NotificationItem>> _itemsController;
  late final StreamController<int> _unreadController;
  final StreamController<NotificationItem> _newItemsController =
      StreamController<NotificationItem>.broadcast();
  final StreamController<List<String>> _sourceErrorsController =
      StreamController<List<String>>.broadcast();

  final Map<String, StreamSubscription<dynamic>> _subscriptions =
      <String, StreamSubscription<dynamic>>{};
  final Map<String, List<NotificationItem>> _bySource =
      <String, List<NotificationItem>>{};

  /// Fingerprints seen in the FIRST snapshot of each source. Nothing is
  /// reported as "new" until after that snapshot, which is what stops old
  /// documents from firing local notifications on login.
  final Map<String, Set<String>> _knownFingerprints = <String, Set<String>>{};

  final Map<String, int> _readNotificationIds = <String, int>{};

  String? _activeUid;
  String? _detectedRole;
  String? _explicitRole;
  Timestamp? _lastSeen;
  DateTime? _accountCreatedAt;
  bool _accountCreatedAtWriteAttempted = false;
  List<NotificationItem> _currentItems = const <NotificationItem>[];
  int _currentUnread = 0;
  bool _hasAnySourceSnapshot = false;
  final Map<String, String> _sourceErrors = <String, String>{};
  final Set<String> _sourceHasEmitted = <String>{};

  /// The merged, newest-first list for the Notifications page.
  ///
  /// Every subscriber first gets the cached snapshot, then the live events.
  /// The empty placeholder is withheld until a real source has reported.
  Stream<List<NotificationItem>> watchNotifications() async* {
    if (hasSourceData) {
      yield List<NotificationItem>.unmodifiable(_currentItems);
    }
    yield* _itemsController.stream;
  }

  /// The same unread count used by the tourist Home and guide dashboard.
  Stream<int> watchUnreadCount() => _unreadController.stream;

  /// Genuinely new events (after the listener started) for local display.
  Stream<NotificationItem> watchNewItems() => _newItemsController.stream;

  /// Short, user-facing messages for failed sources. A failure on one source
  /// never stops the others; the UI can still show whatever did arrive.
  Stream<List<String>> watchSourceErrors() {
    return _sourceErrorsController.stream;
  }

  /// Current source warnings, newest first.
  List<String> get sourceErrors =>
      _sourceErrors.values.toList().reversed.toList();

  /// True once at least one Firestore source has actually produced a
  /// snapshot. A replayed empty list is not a source emission.
  bool get hasSourceData => _hasAnySourceSnapshot;

  /// True once a notification-producing source has reported.
  ///
  /// The profile doc carries read state but no rows, so it must not end the
  /// guide page's loading state on its own. This getter is additive; the
  /// tourist screen keeps using [hasSourceData].
  bool get hasListSourceData =>
      _sourceHasEmitted.contains('stored') ||
      _sourceHasEmitted.contains('chat');

  /// The last merged snapshot, for adapters that need a one-shot read.
  List<NotificationItem> get currentItems => _currentItems;

  /// Kept for the existing callers; the shared repository is role-agnostic.
  String? get currentTouristId {
    try {
      return _auth.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  /// Attaches the listeners for [uid]. Idempotent for the same uid.
  ///
  /// [role] is optional. When omitted it is read from `users/{uid}.role`;
  /// derived post/trip rows are only watched for a tourist, chats for every
  /// non-admin account.
  void start(String uid, {String? role}) {
    if (uid.isEmpty) return;
    if (_activeUid == uid) {
      if (role != null) {
        _explicitRole = role;
        _syncRoleStreams();
      }
      return;
    }

    stop();
    _activeUid = uid;
    _explicitRole = role;
    _accountCreatedAtWriteAttempted = false;
    try {
      _accountCreatedAt = _auth.currentUser?.metadata.creationTime;
    } catch (_) {
      _accountCreatedAt = null;
    }

    _setSubscription(
      'user',
      _db
          .collection(usersCollection)
          .doc(uid)
          .snapshots()
          .listen(
            _onUserSnapshot,
            onError: (Object error, StackTrace stack) =>
                _onSourceError(error, stack, source: 'user'),
          ),
    );
    _setSubscription(
      'stored',
      _db
          .collection(usersCollection)
          .doc(uid)
          .collection(storedCollection)
          .orderBy(createdAtField, descending: true)
          .limit(sourceLimit)
          .snapshots()
          .listen(
            _onStoredSnapshot,
            onError: (Object error, StackTrace stack) =>
                _onSourceError(error, stack, source: 'stored'),
          ),
    );
    _syncRoleStreams();
    _rebuild();
  }

  /// Starts from the current auth user when the caller has no uid handy.
  Future<void> ensureStarted({String? role}) async {
    final uid = currentTouristId;
    if (uid == null || uid.isEmpty) {
      return;
    }
    start(uid, role: role);
  }

  /// Stops every listener and clears the list (used on logout / account switch).
  void stop() {
    for (final subscription in _subscriptions.values) {
      unawaited(subscription.cancel());
    }
    _subscriptions.clear();
    _bySource.clear();
    _knownFingerprints.clear();
    _readNotificationIds.clear();
    _activeUid = null;
    _detectedRole = null;
    _explicitRole = null;
    _lastSeen = null;
    _accountCreatedAt = null;
    _accountCreatedAtWriteAttempted = false;
    _currentItems = const <NotificationItem>[];
    _currentUnread = 0;
    _hasAnySourceSnapshot = false;
    _sourceErrors.clear();
    _sourceHasEmitted.clear();
    _replayCurrentItems();
    _replayUnreadCount();
    _replaySourceErrors();
  }

  /// Single atomic write for "Mark all read" — never one write per item.
  Future<void> markAllAsRead() async {
    final uid = _activeUid ?? currentTouristId;
    if (uid == null) return;
    await _db.collection(usersCollection).doc(uid).set(<String, dynamic>{
      lastSeenField: FieldValue.serverTimestamp(),
      readIdsField: const <String, int>{},
    }, SetOptions(merge: true));
  }

  /// Kept for the older screen API; it now means "mark all read".
  Future<void> markSeen() => markAllAsRead();

  /// Marks exactly one item by recording its id in the shared bounded map.
  Future<void> markOneRead(String notificationId) async {
    final uid = _activeUid ?? currentTouristId;
    if (uid == null || notificationId.isEmpty) return;

    final item = _itemById(notificationId);
    final micros =
        item?.createdAt?.microsecondsSinceEpoch ??
        DateTime.now().microsecondsSinceEpoch;
    final ref = _db.collection(usersCollection).doc(uid);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      final raw = snapshot.data()?[readIdsField];
      final ids = _parseReadIds(raw);
      ids[notificationId] = micros;

      final ordered = ids.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final pruned = <String, int>{
        for (final entry in ordered.take(maxReadIds)) entry.key: entry.value,
      };
      transaction.set(ref, <String, dynamic>{
        readIdsField: pruned,
      }, SetOptions(merge: true));
    });
  }

  Future<void> markAsRead(String notificationId) => markOneRead(notificationId);

  // ── persisted notification writers ───────────────────────────────────────
  /// Writes the deterministic like notification after the like itself has
  /// committed. A repeat like writes the same id; rules deny that UPDATE and
  /// the caller ignores it silently.
  Future<void> createLikeNotification({
    required String recipientId,
    required String postId,
    String? actorName,
    String? actorAvatarUrl,
  }) async {
    final actorId = currentTouristId;
    if (actorId == null ||
        actorId.isEmpty ||
        recipientId.isEmpty ||
        recipientId == actorId ||
        postId.isEmpty) {
      return;
    }
    final id = 'like_${postId}_$actorId';
    await _writeStoredNotification(
      recipientId: recipientId,
      id: id,
      payload: <String, dynamic>{
        'type': 'like',
        'postId': postId,
        'title': _clean(_actorName(actorName), 100, fallback: 'Traveler'),
        'message': 'Liked your community post.',
      },
      actorId: actorId,
      actorName: actorName,
      actorAvatarUrl: actorAvatarUrl,
    );
  }

  /// Writes the deterministic booking notification after the booking has
  /// committed. Rules verify the booking belongs to this actor/recipient.
  Future<void> createBookingNotification({
    required String recipientId,
    required String bookingId,
    required int seats,
    String? tripId,
    String? actorName,
    String? actorAvatarUrl,
    String? title,
    String? message,
  }) async {
    final actorId = currentTouristId;
    if (actorId == null ||
        actorId.isEmpty ||
        recipientId.isEmpty ||
        recipientId == actorId ||
        bookingId.isEmpty) {
      return;
    }
    final id = 'booking_$bookingId';
    await _writeStoredNotification(
      recipientId: recipientId,
      id: id,
      payload: <String, dynamic>{
        'type': 'booking',
        'bookingId': bookingId,
        'tripId': tripId ?? '',
        'seats': seats,
        'title': _clean(title, 300, fallback: 'New booking'),
        'message': _clean(
          message,
          300,
          fallback: 'A tourist booked your trip.',
        ),
      },
      actorId: actorId,
      actorName: actorName,
      actorAvatarUrl: actorAvatarUrl,
    );
  }

  /// Writes the admin's trip decision for the trip's guide.
  Future<void> createTripDecisionNotification({
    required String recipientId,
    required String tripId,
    required String decision,
    String? tripTitle,
    String? actorName,
    String? actorAvatarUrl,
    String? message,
  }) async {
    final actorId = currentTouristId;
    if (actorId == null ||
        actorId.isEmpty ||
        recipientId.isEmpty ||
        recipientId == actorId ||
        tripId.isEmpty) {
      return;
    }
    final micros = DateTime.now().microsecondsSinceEpoch;
    final id = 'trip_decided_${tripId}_${actorId}_$micros';
    await _writeStoredNotification(
      recipientId: recipientId,
      id: id,
      payload: <String, dynamic>{
        'type': 'trip_decided',
        'tripId': tripId,
        'tripTitle': _clean(tripTitle, 300, fallback: 'Your trip'),
        'decision': _clean(decision, 100, fallback: 'decided'),
        'title': _clean(
          decision == 'approved' ? 'Trip approved' : 'Trip update',
          300,
          fallback: 'Trip update',
        ),
        'message': _clean(
          message,
          300,
          fallback: 'The admin updated your trip.',
        ),
      },
      actorId: actorId,
      actorName: actorName,
      actorAvatarUrl: actorAvatarUrl,
    );
  }

  Future<void> _writeStoredNotification({
    required String recipientId,
    required String id,
    required Map<String, dynamic> payload,
    required String actorId,
    String? actorName,
    String? actorAvatarUrl,
  }) async {
    final data = <String, dynamic>{
      ...payload,
      'actorId': actorId,
      'actorName': _clean(_actorName(actorName), 100, fallback: 'Someone'),
      'actorAvatarUrl': _clean(actorAvatarUrl ?? '', 500, fallback: ''),
      'createdAt': FieldValue.serverTimestamp(),
      'read': false,
      'dedupeKey': id,
    };
    try {
      await _db
          .collection(usersCollection)
          .doc(recipientId)
          .collection(storedCollection)
          .doc(id)
          .set(data);
    } on FirebaseException catch (error) {
      // A duplicate deterministic id becomes an UPDATE and rules deny it.
      // That is expected; never surface it to the user.
      if (error.code != 'permission-denied') {
        debugPrint('TouristNotificationsRepository: notification — $error');
      }
    } catch (error) {
      debugPrint('TouristNotificationsRepository: notification — $error');
    }
  }

  // ── internals ────────────────────────────────────────────────────────────
  void _setSubscription(String key, StreamSubscription<dynamic> subscription) {
    final previous = _subscriptions.remove(key);
    if (previous != null) unawaited(previous.cancel());
    _subscriptions[key] = subscription;
  }

  void _detachSource(String key) {
    final subscription = _subscriptions.remove(key);
    if (subscription != null) {
      unawaited(subscription.cancel());
    }
    _sourceErrors.remove(key);
    _replaySourceErrors();
    if (_bySource.remove(key) != null) _rebuild();
  }

  void _syncRoleStreams() {
    final uid = _activeUid;
    if (uid == null) {
      return;
    }
    // Firestore is authoritative; an explicit hint only helps before its
    // first snapshot arrives.
    final role = _detectedRole ?? _explicitRole;
    if (role == null) {
      return;
    }

    if (role == roleTourist) {
      _attachSource(
        'post',
        _db
            .collection(postsCollection)
            .orderBy(createdAtField, descending: true)
            .limit(sourceLimit)
            .snapshots(),
        _onPostsSnapshot,
      );
      _attachSource(
        'trip',
        _db
            .collection(tripsCollection)
            .where('approvalStatus', isEqualTo: 'approved')
            .limit(sourceLimit)
            .snapshots(),
        _onTripsSnapshot,
      );
    } else {
      _detachSource('post');
      _detachSource('trip');
    }

    if (role == roleAdmin) {
      _detachSource('chat');
    } else {
      _attachSource(
        'chat',
        _db
            .collection(chatsCollection)
            .where('participants', arrayContains: uid)
            .orderBy('lastMessageAt', descending: true)
            .limit(sourceLimit)
            .snapshots(),
        _onChatsSnapshot,
      );
    }
  }

  void _attachSource(
    String key,
    Stream<QuerySnapshot<Map<String, dynamic>>> stream,
    void Function(QuerySnapshot<Map<String, dynamic>> snapshot) onData,
  ) {
    if (_subscriptions.containsKey(key)) {
      return;
    }
    _subscriptions[key] = stream.listen(
      onData,
      onError: (Object error, StackTrace stack) =>
          _onSourceError(error, stack, source: key),
    );
  }

  void _onUserSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    _markSourceHealthy('user');
    final data = doc.data();
    final role = data?['role'];
    if (role is String && role.isNotEmpty) _detectedRole = role;

    final seen = data?[lastSeenField];
    _lastSeen = seen is Timestamp ? seen : null;

    final created = data?[createdAtField];
    if (created is Timestamp) {
      _accountCreatedAt = created.toDate();
    } else if (created is DateTime) {
      _accountCreatedAt = created;
    } else if (created is String) {
      _accountCreatedAt = DateTime.tryParse(created);
    }

    _readNotificationIds
      ..clear()
      ..addAll(_parseReadIds(data?[readIdsField]));
    if (created == null && _accountCreatedAt == null) {
      unawaited(_writeAccountCreatedAtOnce(doc.reference));
    }
    _syncRoleStreams();
    _rebuild();
  }

  Future<void> _writeAccountCreatedAtOnce(
    DocumentReference<Map<String, dynamic>> ref,
  ) async {
    if (_accountCreatedAtWriteAttempted) return;
    _accountCreatedAtWriteAttempted = true;
    try {
      await _db.runTransaction((transaction) async {
        final snapshot = await transaction.get(ref);
        if (!snapshot.exists ||
            snapshot.data()?.containsKey(createdAtField) == true) {
          return;
        }
        transaction.update(ref, <String, dynamic>{
          createdAtField: FieldValue.serverTimestamp(),
        });
      });
    } catch (_) {
      // Best effort only; the auth metadata fallback still applies.
    }
  }

  void _onStoredSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final uid = _activeUid;
    if (uid == null) return;
    final items = <String, NotificationItem>{};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final type = _string(data['type']);
      if (type.isEmpty ||
          !const <String>['like', 'booking', 'trip_decided'].contains(type)) {
        continue;
      }
      items[doc.id] = _storedItem(doc.id, data);
    }
    _applySource('stored', items);
  }

  void _onPostsSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final uid = _activeUid;
    if (uid == null) return;
    final items = <String, NotificationItem>{};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      if (data['authorId'] == uid) continue;
      final created = _dateOf(data[createdAtField]);
      final name = _string(data['authorName'], fallback: 'New community post');
      final text = _string(data['text']);
      items[doc.id] = NotificationItem(
        id: doc.id,
        type: 'post',
        title: name,
        body: text.isEmpty ? 'Shared a new post.' : _preview(text),
        timeLabel: _timeLabel(created),
        isRead: false,
        section: _section(created),
        createdAt: created,
        targetId: doc.id,
        routeType: 'post',
        relatedEntityId: doc.id,
        relatedCollection: postsCollection,
      );
    }
    _applySource('post', items);
  }

  void _onTripsSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final uid = _activeUid;
    if (uid == null) return;
    final items = <String, NotificationItem>{};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      if (data['guideId'] == uid) continue;
      final created = _dateOf(data[createdAtField]);
      final title = _string(data['title']);
      final guide = _string(data['guideName'], fallback: 'A tour guide');
      items[doc.id] = NotificationItem(
        id: doc.id,
        type: 'trip',
        title: guide,
        body: title.isEmpty
            ? 'Added a new trip.'
            : 'Added a new trip: ${_preview(title)}',
        timeLabel: _timeLabel(created),
        isRead: false,
        section: _section(created),
        createdAt: created,
        targetId: doc.id,
        routeType: 'trip',
        relatedEntityId: doc.id,
        relatedCollection: tripsCollection,
      );
    }
    _applySource('trip', items);
  }

  void _onChatsSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final uid = _activeUid;
    if (uid == null) return;
    final items = <String, NotificationItem>{};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final lastMessage = data['lastMessage'];
      if (lastMessage is! Map) continue;
      final senderId = lastMessage['senderId'];
      if (senderId is! String || senderId.isEmpty || senderId == uid) {
        continue;
      }
      final text = lastMessage['text'];
      final body = text is String && text.trim().isNotEmpty
          ? _preview(text.trim())
          : 'Sent you a new message.';
      final created =
          _dateOf(lastMessage[createdAtField]) ??
          _dateOf(data['lastMessageAt']);
      final stamp = created?.microsecondsSinceEpoch ?? 0;
      final key = '${doc.id}|$stamp|$senderId';
      items[key] = NotificationItem(
        id: key,
        type: 'chat',
        title: _senderName(data, senderId),
        body: body,
        timeLabel: _timeLabel(created),
        isRead: false,
        section: _section(created),
        createdAt: created,
        targetId: doc.id,
        routeType: 'chat',
        relatedEntityId: doc.id,
        relatedCollection: chatsCollection,
      );
    }
    _applySource('chat', items);
  }

  void _applySource(String source, Map<String, NotificationItem> items) {
    if (!_sourceHasEmitted.contains(source)) {
      _sourceHasEmitted.add(source);
    }
    _markSourceHealthy(source);
    final previous = _knownFingerprints[source];
    final newKeys = previous == null
        ? const <String>[]
        : items.keys.where((key) => !previous.contains(key)).toList();

    _knownFingerprints[source] = items.keys.toSet();
    _bySource[source] = items.values.toList();
    _rebuild();

    if (newKeys.isEmpty) return;
    for (final key in newKeys) {
      final fresh = _itemById(key) ?? items[key];
      if (fresh != null && !_newItemsController.isClosed) {
        _newItemsController.add(fresh);
      }
    }
  }

  void _rebuild() {
    final byId = <String, NotificationItem>{};
    for (final item in _bySource.values.expand((items) => items)) {
      byId[item.id] = item;
    }
    final all = byId.values.toList()
      ..sort((a, b) {
        final left = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final right = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return right.compareTo(left);
      });

    final threshold = _readThreshold();
    final unread = all.where((item) => !_isRead(item, threshold)).length;
    final merged = all
        .take(listLimit)
        .map((item) {
          return item.copyWith(isRead: _isRead(item, threshold));
        })
        .toList(growable: false);

    _currentItems = merged;
    _replayCurrentItems();
    if (unread != _currentUnread) {
      _currentUnread = unread;
      _replayUnreadCount();
    }
  }

  void _replayCurrentItems() {
    if (!_itemsController.isClosed) _itemsController.add(_currentItems);
  }

  void _replayUnreadCount() {
    if (!_unreadController.isClosed) _unreadController.add(_currentUnread);
  }

  DateTime _readThreshold() {
    final seen = _lastSeen?.toDate();
    final created = _accountCreatedAt;
    if (seen == null) {
      return created ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
    if (created == null || seen.isAfter(created)) return seen;
    return created;
  }

  bool _isRead(NotificationItem item, DateTime threshold) {
    final created = item.createdAt;
    if (created == null) return true;
    if (_readNotificationIds.containsKey(item.id)) return true;
    // The room on screen must not keep re-adding itself to the unread count.
    // Other chats are unaffected: only the tracked id is treated as read.
    if (item.type == 'chat' &&
        ActiveChatTracker.instance.isActive(item.targetId)) {
      return true;
    }
    return !created.isAfter(threshold);
  }

  void _onActiveChatChanged() {
    if (_activeUid == null) return;
    _rebuild();
  }

  NotificationItem? _itemById(String id) {
    for (final item in _currentItems) {
      if (item.id == id) return item;
    }
    return null;
  }

  NotificationItem _storedItem(String id, Map<String, dynamic> data) {
    final type = _string(data['type']);
    final created = _dateOf(data[createdAtField]);
    final actor = _string(data['actorName'], fallback: 'Someone');
    final title = _string(data['title'], fallback: actor);
    final message = _string(data['message']);
    final postId = _string(data['postId']);
    final bookingId = _string(data['bookingId']);
    final tripId = _string(data['tripId']);

    final target = switch (type) {
      'like' => postId,
      'booking' => bookingId,
      'trip_decided' => tripId,
      _ => '',
    };
    final route = switch (type) {
      'like' => 'post',
      'trip_decided' => 'trip',
      'booking' => 'booking',
      _ => '',
    };
    final collection = switch (type) {
      'like' => postsCollection,
      'booking' => 'bookings',
      'trip_decided' => tripsCollection,
      _ => null,
    };
    final fallbackBody = switch (type) {
      'like' => '$actor liked your community post.',
      'booking' => '$actor made a new booking.',
      'trip_decided' => 'The admin updated your trip.',
      _ => 'You have a new notification.',
    };

    return NotificationItem(
      id: id,
      type: type,
      title: title,
      body: message.isEmpty ? fallbackBody : message,
      timeLabel: _timeLabel(created),
      isRead: false,
      section: _section(created),
      createdAt: created,
      targetId: target,
      routeType: route,
      relatedEntityId: target.isEmpty ? null : target,
      relatedCollection: collection,
    );
  }

  Map<String, int> _parseReadIds(Object? raw) {
    if (raw is! Map) return const <String, int>{};
    final ids = <String, int>{};
    for (final entry in raw.entries) {
      final key = entry.key;
      if (key is! String || key.isEmpty) continue;
      ids[key] = _readIdValue(entry.value);
    }
    final ordered = ids.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return <String, int>{
      for (final entry in ordered.take(maxReadIds)) entry.key: entry.value,
    };
  }

  int _readIdValue(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  String _actorName(String? explicit) {
    final value = explicit?.trim().isNotEmpty == true ? explicit!.trim() : '';
    if (value.isNotEmpty) return value;
    try {
      final user = _auth.currentUser;
      final name = user?.displayName?.trim() ?? '';
      if (name.isNotEmpty) return name;
      final email = user?.email?.split('@').first.trim() ?? '';
      if (email.isNotEmpty) return email;
    } catch (_) {
      // Fall through to the neutral name.
    }
    return 'Someone';
  }

  String _clean(Object? value, int max, {required String fallback}) {
    final raw = value is String ? value.trim() : '';
    if (raw.isEmpty) return fallback;
    return raw.length <= max ? raw : raw.substring(0, max);
  }

  String _string(Object? value, {String fallback = ''}) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return fallback;
  }

  String _senderName(Map<String, dynamic> chat, String senderId) {
    final profiles = chat['profiles'];
    if (profiles is Map) {
      final profile = profiles[senderId];
      if (profile is Map) {
        final name = profile['displayName'];
        if (name is String && name.trim().isNotEmpty) return name.trim();
      }
    }
    if (chat['touristId'] == senderId) return 'A traveler';
    return 'A tour guide';
  }

  DateTime? _dateOf(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  String _preview(String value, {int max = 100}) =>
      value.length <= max ? value : '${value.substring(0, max - 1)}…';

  String _timeLabel(DateTime? created) {
    if (created == null) return '';
    final local = created.toLocal();
    if (_isToday(local)) {
      final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
      final minute = local.minute.toString().padLeft(2, '0');
      return '$hour:$minute ${local.hour < 12 ? 'AM' : 'PM'}';
    }
    return '${local.day}/${local.month}/${local.year}';
  }

  String _section(DateTime? created) => _isToday(created) ? 'today' : 'earlier';

  bool _isToday(DateTime? created) {
    if (created == null) return false;
    final local = created.toLocal();
    final now = DateTime.now();
    return local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
  }

  void _markSourceHealthy(String source) {
    if (!_sourceHasEmitted.contains(source)) {
      _sourceHasEmitted.add(source);
    }
    _hasAnySourceSnapshot = true;
    if (_sourceErrors.remove(source) != null) _replaySourceErrors();
  }

  void _replaySourceErrors() {
    if (!_sourceErrorsController.isClosed) {
      _sourceErrorsController.add(sourceErrors);
    }
  }

  void _onSourceError(
    Object error,
    StackTrace? stackTrace, {
    String source = 'source',
  }) {
    // A permission error on logout is expected; do not tear down the stream.
    debugPrint('TouristNotificationsRepository[$source]: $error');
    final message = _describeSourceError(source, error);
    if (_sourceErrors[source] == message) return;
    _sourceErrors[source] = message;
    _replaySourceErrors();
  }

  String _describeSourceError(String source, Object error) {
    final label = switch (source) {
      'user' => 'Profile',
      'stored' => 'Notifications',
      'post' => 'Posts',
      'trip' => 'Trips',
      'chat' => 'Chats',
      _ => source,
    };
    final code = error is FirebaseException ? error.code : '';
    if (code == 'permission-denied') return '$label: access denied';
    if (code == 'failed-precondition' ||
        error.toString().toLowerCase().contains('index')) {
      return '$label: missing index';
    }
    return '$label: unavailable';
  }

  Future<void> dispose() async {
    ActiveChatTracker.instance.removeListener(_onActiveChatChanged);
    stop();
    await _itemsController.close();
    await _unreadController.close();
    await _newItemsController.close();
    await _sourceErrorsController.close();
  }
}
