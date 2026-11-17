import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/data/repositories/tourist_notifications_repository.dart';
import 'package:triply/core/utils/safe_emit_mixin.dart';
import '../../notifications/model/notification_item.dart';

part 'home_state.dart';

/// Owns the Home notification badge only.
///
/// The badge logic is intentionally kept in [HomeCubit]: it is the existing
/// session-scoped provider and its stream behavior must not change.
class HomeCubit extends Cubit<HomeState> with SafeEmitMixin<HomeState> {
  HomeCubit({TouristNotificationsRepository? notificationsRepository})
    : _notificationsRepository =
          notificationsRepository ?? TouristNotificationsRepository(),
      super(const HomeInitial()) {
    _notificationsSubscription = _notificationsRepository
        .watchNotifications()
        .listen(
          _onNotifications,
          // A stream that is refused (the user signed out, the rules
          // changed) must not throw away a Home that already loaded its
          // content. Only the unread badge is affected.
          onError: (Object error) {
            _unreadNotifications = 0;
            _emitSuccess();
          },
        );
    // The section Cubits own the loading states. This Cubit only needs a
    // resolved state so the badge can be rebuilt when the stream answers.
    _emitSuccess();
  }

  final TouristNotificationsRepository _notificationsRepository;

  StreamSubscription<List<NotificationItem>>? _notificationsSubscription;

  /// How many notifications the tourist did not read yet.
  int _unreadNotifications = 0;

  /// How many notifications the tourist did not read yet.
  int get unreadNotifications => _unreadNotifications;

  /// A new notification arrived — the badge on the bell follows.
  void _onNotifications(List<NotificationItem> items) {
    final count = items.where((e) => !e.isRead).length;
    if (count == _unreadNotifications) return;
    _unreadNotifications = count;
    _emitSuccess();
  }

  /// Emits the badge count from the authoritative private field.
  void _emitSuccess() {
    safeEmit(HomeSuccess(unreadNotifications: _unreadNotifications));
  }

  @override
  Future<void> close() async {
    await _notificationsSubscription?.cancel();
    await super.close();
  }
}
