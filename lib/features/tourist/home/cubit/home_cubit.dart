import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/data/repositories/tourist_notifications_repository.dart';
import 'package:triply/core/utils/safe_emit_mixin.dart';

part 'home_state.dart';

/// Owns the Home notification badge only.
///
/// The badge reads the same session-wide repository and the same unread count
/// as the Notifications page and the guide dashboard. Its state shape and
/// public API are unchanged.
class HomeCubit extends Cubit<HomeState> with SafeEmitMixin<HomeState> {
  HomeCubit({TouristNotificationsRepository? notificationsRepository})
    : _notificationsRepository =
          notificationsRepository ?? TouristNotificationsRepository.instance,
      super(const HomeInitial()) {
    _unreadSubscription = _notificationsRepository.watchUnreadCount().listen(
      _onUnreadCount,
      // A stream that is refused (the user signed out, the rules changed)
      // must not throw away a Home that already loaded its content. Only the
      // unread badge is affected.
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

  StreamSubscription<int>? _unreadSubscription;

  /// How many notifications the tourist did not read yet.
  int _unreadNotifications = 0;

  /// How many notifications the tourist did not read yet.
  int get unreadNotifications => _unreadNotifications;

  /// The shared unread count changed — the badge on the bell follows.
  void _onUnreadCount(int count) {
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
    await _unreadSubscription?.cancel();
    await super.close();
  }
}
