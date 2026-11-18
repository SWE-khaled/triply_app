import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../features/chat/model/chat_audience.dart';
import '../../features/tourist/trips/models/trip.dart';
import '../data/repositories/public_trips_repository.dart';
import '../routing/app_routes.dart';
import 'notification_constants.dart';

/// The three notification destinations supported by the free-tier flow.
enum NotificationTargetType { post, trip, chat }

/// The `type` + `id` pair carried by every FCM/local notification.
@immutable
class NotificationTarget {
  const NotificationTarget({required this.type, required this.id});

  static const String typeKey = 'type';
  static const String idKey = 'id';

  final NotificationTargetType type;
  final String id;

  factory NotificationTarget.fromData(Map<String, dynamic> data) {
    final rawType = data[typeKey]?.toString() ?? '';
    return NotificationTarget(
      type: NotificationTargetType.values.firstWhere(
        (value) => value.name == rawType,
        orElse: () => NotificationTargetType.post,
      ),
      id: data[idKey]?.toString() ?? '',
    );
  }

  Map<String, String> toData() => {typeKey: type.name, idKey: id};

  bool get isValid => id.isNotEmpty;

  @override
  String toString() => 'NotificationTarget(${type.name}, $id)';
}

/// Routes notification taps to the right screen.
///
/// A tap can arrive before Firebase auth and the startup gate are ready (cold
/// start from a terminated notification). The target is held as `pending` and
/// drained once both are available — `main.dart` calls [notifyReady] when the
/// splash/startup cubit reaches its ready state.
class NotificationNavigator {
  NotificationNavigator._();

  /// Assign to `MaterialApp.navigatorKey` in `main.dart`.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static NotificationTarget? _pending;
  static bool _ready = false;
  static bool _draining = false;

  /// Called by `main.dart` once the startup gate has resolved the session.
  static void notifyReady() {
    _ready = true;
    unawaited(_drain());
  }

  /// Stores [target] and tries to navigate. Invalid targets are ignored.
  static void open(NotificationTarget target) {
    if (!target.isValid) return;
    _pending = target;
    unawaited(_drain());
  }

  static Future<void> _drain() async {
    if (_draining || !_ready) return;
    final target = _pending;
    final navigator = navigatorKey.currentState;
    if (target == null || navigator == null) return;

    _draining = true;
    try {
      // On a cold start auth restoration can lag the first frame. Wait for it
      // instead of dropping the tap; keep the target pending when signed out.
      final user =
          FirebaseAuth.instance.currentUser ??
          await FirebaseAuth.instance.authStateChanges().first.timeout(
            const Duration(seconds: 5),
            onTimeout: () => null,
          );
      if (user == null) return;

      switch (target.type) {
        case NotificationTargetType.post:
          navigator.push(AppRoutes.community(focusPostId: target.id));

        case NotificationTargetType.trip:
          final public = await PublicTripsRepository().fetchTrip(target.id);
          if (public == null) return;
          navigator.push(AppRoutes.tripDetails(Trip.fromPublicTrip(public)));

        case NotificationTargetType.chat:
          final role = await _roleOf(user.uid);
          navigator.push(
            AppRoutes.chatRoom(
              chatId: target.id,
              audience: role == NotificationConstants.roleGuide
                  ? ChatAudience.guide
                  : ChatAudience.tourist,
            ),
          );
      }
      _pending = null;
    } catch (error) {
      debugPrint('NotificationNavigator: $error');
    } finally {
      _draining = false;
    }
  }

  /// The role on `users/{uid}` is authoritative; the remembered role is only
  /// an offline fallback so a chat still opens with a sensible audience.
  static Future<String> _roleOf(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(NotificationConstants.usersCollection)
          .doc(uid)
          .get();
      final role = doc.data()?['role'];
      if (role is String && role.isNotEmpty) return role;
    } catch (error) {
      debugPrint('NotificationNavigator: role read failed — $error');
    }
    return NotificationConstants.roleTourist;
  }
}
