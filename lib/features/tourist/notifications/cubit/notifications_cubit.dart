import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/data/repositories/tourist_notifications_repository.dart';
import 'package:triply/core/utils/safe_emit_mixin.dart';
import '../model/notification_item.dart';

part 'notifications_state.dart';

/// The notifications of the signed-in tourist.
///
/// They come from Firestore and update by themselves — a notification
/// that arrives while the screen is open shows up without a reload.
class NotificationsCubit extends Cubit<NotificationsState>
    with SafeEmitMixin<NotificationsState> {
  NotificationsCubit({TouristNotificationsRepository? repository})
    : _repository = repository ?? TouristNotificationsRepository(),
      super(const NotificationsInitial()) {
    _subscription = _repository.watchNotifications().listen(
      _onNotifications,
      onError: (Object error) =>
          safeEmit(NotificationsError(error: error.toString())),
    );
  }

  final TouristNotificationsRepository _repository;
  StreamSubscription<List<NotificationItem>>? _subscription;

  /// The notifications of the tourist.
  List<NotificationItem> _items = const [];

  List<NotificationItem> get today =>
      _items.where((e) => e.section == 'today').toList();
  List<NotificationItem> get earlier =>
      _items.where((e) => e.section == 'earlier').toList();
  int get unreadCount => _items.where((e) => !e.isRead).length;

  void _onNotifications(List<NotificationItem> items) {
    _items = items;
    safeEmit(NotificationsSuccess(items: items));
  }

  /// Marks every notification as read.
  Future<void> markAllRead() => _repository.markAllAsRead();

  /// Marks one notification as read.
  Future<void> markOneRead(String id) => _repository.markAsRead(id);

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
