import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../features/tourist/notifications/model/notification_item.dart';
import '../data/repositories/tourist_notifications_repository.dart';
import '../utils/active_chat_tracker.dart';
import 'notification_constants.dart';
import 'notification_target.dart';

// لازم تكون دالة top-level (برّه أي class)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message: ${message.messageId}');
}

/// One place for FCM + local notifications + the Firestore-backed in-app list.
///
/// `main.dart` keeps calling `NotificationService().initFCM()`; the factory
/// below makes that a singleton so repeated calls can never create duplicate
/// listeners.
class NotificationService {
  NotificationService._();

  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // نفس الـ ID ده تكتبه في Android Notification Channel في الـ Console
  static const _channel = AndroidNotificationChannel(
    NotificationConstants.channelId,
    NotificationConstants.channelName,
    description: NotificationConstants.channelDescription,
    importance: Importance.high,
  );

  static bool _initialized = false;
  bool _started = false;

  late final TouristNotificationsRepository _repository;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<NotificationItem>? _newItemSubscription;

  String? _boundUid;
  String? _boundToken;
  int _nextNotificationId = 1;

  /// In-memory ids already shown in this session. Derived streams can emit the
  /// same event twice on a reconnect; the in-app list de-duplicates it, and so
  /// does the tray notification.
  final Set<String> _shownLocalIds = <String>{};
  static const int _maxShownLocalIds = 200;

  Future<void> initFCM() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    _repository = TouristNotificationsRepository.instance;

    // 1) الصلاحية
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    // 2) إعداد الإشعارات المحلية + الضغط على الإشعار
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _localNotifications.initialize(
      settings: const InitializationSettings(android: androidInit),
      onDidReceiveNotificationResponse: _onLocalTap,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    // 3) الإشعار والتطبيق مفتوح (Foreground)
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    _tokenSubscription = FirebaseMessaging.instance.onTokenRefresh.listen(
      _onTokenRefreshed,
    );

    // 4) لما المستخدم يضغط على الإشعار (التطبيق في الخلفية)
    FirebaseMessaging.onMessageOpenedApp.listen(_onOpenedFromTray);

    // 5) لما التطبيق كان مقفول وفتح من الإشعار
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _onOpenedFromTray(initial);

    // 6) قائمة الإشعارات داخل التطبيق تبدأ بعد Login وتتوقف بعد Logout
    _authSubscription = _auth.authStateChanges().listen(_onAuthChanged);
    await _onAuthChanged(_auth.currentUser);
  }

  // ── auth-scoped listeners ────────────────────────────────────────────────
  Future<void> _onAuthChanged(User? user) async {
    final uid = user?.uid;
    if (uid == _boundUid) return;

    await _stopForCurrentUser();
    _boundUid = uid;
    _shownLocalIds.clear();
    if (uid == null) return;

    // التوكن بيتربط بحساب المستخدم في users/{uid}.fcmTokens
    try {
      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) await _saveToken(token, uid);
    } catch (error) {
      debugPrint('NotificationService: getToken failed — $error');
    }

    _repository.start(uid);
    _newItemSubscription = _repository.watchNewItems().listen(
      _onNewInAppItem,
      onError: (Object error) {
        debugPrint('NotificationService: new item stream failed — $error');
      },
    );
    _started = true;
  }

  Future<void> _stopForCurrentUser() async {
    await _newItemSubscription?.cancel();
    _newItemSubscription = null;
    _repository.stop();
    _started = false;

    final uid = _boundUid;
    final token = _boundToken;
    if (uid != null && token != null && token.isNotEmpty) {
      try {
        await _removeToken(token, uid);
      } catch (error) {
        debugPrint('NotificationService: token removal failed — $error');
      }
    }
    _boundToken = null;
  }

  // ── tokens ───────────────────────────────────────────────────────────────
  Future<void> _saveToken(String token, String uid) async {
    await _userDoc(uid).set(<String, dynamic>{
      NotificationConstants.fcmTokensField: FieldValue.arrayUnion(<String>[
        token,
      ]),
    }, SetOptions(merge: true));
    _boundToken = token;
  }

  Future<void> _removeToken(String token, String uid) async {
    await _userDoc(uid).update(<String, dynamic>{
      NotificationConstants.fcmTokensField: FieldValue.arrayRemove(<String>[
        token,
      ]),
    });
  }

  void _onTokenRefreshed(String token) {
    final uid = _boundUid;
    if (uid == null || token.isEmpty) return;
    unawaited(_saveToken(token, uid));
  }

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection(NotificationConstants.usersCollection).doc(uid);

  // ── display + navigation ─────────────────────────────────────────────────
  void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    final target = NotificationTarget.fromData(message.data);
    final title = notification?.title ?? 'Triply';
    final body = notification?.body ?? '';
    if (!target.isValid && body.isEmpty) return;
    // A message in the room the user is already reading is silent. Other
    // chats still produce a tray notification.
    if (target.type == NotificationTargetType.chat &&
        ActiveChatTracker.instance.isActive(target.id)) {
      return;
    }

    unawaited(
      _showLocal(
        title: title,
        body: body,
        payload: target.isValid ? jsonEncode(target.toData()) : null,
      ),
    );
  }

  void _onNewInAppItem(NotificationItem item) {
    // Derived chat rows point at the chat document through `targetId`.
    // Suppress only that room; unrelated chats keep notifying normally.
    if (item.type == NotificationConstants.typeChat &&
        ActiveChatTracker.instance.isActive(item.targetId)) {
      return;
    }
    if (!_started || !_rememberLocalId(item.id)) return;

    // Stored `like` / `trip_decided` rows carry their destination in
    // `targetId`; derived rows keep using the event id. `booking` has no
    // global route, so it is shown without a payload.
    final type = _targetTypeFor(item);
    final targetId = item.targetId.isNotEmpty ? item.targetId : item.id;
    final payload = type == null || targetId.isEmpty
        ? null
        : jsonEncode(NotificationTarget(type: type, id: targetId).toData());

    unawaited(_showLocal(title: item.title, body: item.body, payload: payload));
  }

  NotificationTargetType? _targetTypeFor(NotificationItem item) {
    final route = item.routeType.isNotEmpty ? item.routeType : item.type;
    return switch (route) {
      NotificationConstants.typePost => NotificationTargetType.post,
      NotificationConstants.typeTrip => NotificationTargetType.trip,
      NotificationConstants.typeChat => NotificationTargetType.chat,
      _ => null,
    };
  }

  bool _rememberLocalId(String id) {
    if (id.isEmpty) return false;
    if (_shownLocalIds.contains(id)) return false;
    _shownLocalIds.add(id);
    if (_shownLocalIds.length > _maxShownLocalIds) {
      _shownLocalIds.remove(_shownLocalIds.first);
    }
    return true;
  }

  Future<void> _showLocal({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      await _localNotifications.show(
        id: _nextNotificationId++,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        payload: payload,
      );
    } catch (error) {
      debugPrint('NotificationService: local show failed — $error');
    }
  }

  void _onLocalTap(NotificationResponse response) {
    final raw = response.payload;
    if (raw == null || raw.isEmpty) return;
    try {
      final map = jsonDecode(raw);
      if (map is Map<String, dynamic>) {
        NotificationNavigator.open(NotificationTarget.fromData(map));
      }
    } catch (error) {
      debugPrint('NotificationService: tap payload failed — $error');
    }
  }

  void _onOpenedFromTray(RemoteMessage message) {
    NotificationNavigator.open(NotificationTarget.fromData(message.data));
  }

  Future<void> dispose() async {
    await _stopForCurrentUser();
    await _authSubscription?.cancel();
    await _tokenSubscription?.cancel();
    _authSubscription = null;
    _tokenSubscription = null;
    _boundUid = null;
  }
}
