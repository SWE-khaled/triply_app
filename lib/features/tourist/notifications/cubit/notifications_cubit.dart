import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/data/repositories/tourist_notifications_repository.dart';
import 'package:triply/core/utils/safe_emit_mixin.dart';

import '../model/notification_item.dart';

part 'notifications_state.dart';

/// The notifications of the signed-in tourist.
///
/// The list comes from the same [TouristNotificationsRepository.instance] the
/// Home badge and the guide adapter use. Opening this cubit never marks
/// anything read; only the two explicit mark methods write the shared marker.
///
/// One broken source never blanks the page: successful sources still emit,
/// and a short warning is surfaced next to the list. If no source produces a
/// snapshot, the page shows an error with retry instead of an endless shimmer.
class NotificationsCubit extends Cubit<NotificationsState>
    with SafeEmitMixin<NotificationsState> {
  NotificationsCubit({TouristNotificationsRepository? repository})
    : _repository = repository ?? TouristNotificationsRepository.instance,
      super(const NotificationsInitial()) {
    safeEmit(const NotificationsLoading());
    unawaited(_repository.ensureStarted());
    _subscription = _repository.watchNotifications().listen(
      _onNotifications,
      onError: _onFatalError,
    );
    _errorSubscription = _repository.watchSourceErrors().listen(
      _onSourceErrors,
    );
    _firstSnapshotTimer = Timer(_loadingTimeout, () {
      if (!_repository.hasSourceData && !isClosed) {
        safeEmit(
          NotificationsError(
            error: _warning ?? 'Notifications are taking too long to load.',
          ),
        );
      }
    });
  }

  /// Long enough to let a slow first Firestore snapshot arrive, short enough
  /// that the page never sits on a shimmer forever.
  static const Duration _loadingTimeout = Duration(seconds: 4);

  final TouristNotificationsRepository _repository;
  StreamSubscription<List<NotificationItem>>? _subscription;
  StreamSubscription<List<String>>? _errorSubscription;
  Timer? _firstSnapshotTimer;

  /// The notifications of the tourist.
  List<NotificationItem> _items = const [];

  String? get _warning {
    final errors = _repository.sourceErrors;
    if (errors.isEmpty) return null;
    return errors.join(' • ');
  }

  List<NotificationItem> get today =>
      _items.where((e) => e.section == 'today').toList();
  List<NotificationItem> get earlier =>
      _items.where((e) => e.section == 'earlier').toList();
  int get unreadCount => _items.where((e) => !e.isRead).length;

  void _onNotifications(List<NotificationItem> items) {
    _items = items;
    // A fresh cubit first receives a replayed empty snapshot. That is not a
    // Firestore emission, so keep the loading state until a source really
    // reports in.
    if (!_repository.hasSourceData) return;
    _firstSnapshotTimer?.cancel();
    safeEmit(NotificationsSuccess(items: items, warning: _warning));
  }

  void _onSourceErrors(List<String> errors) {
    if (isClosed) return;
    if (errors.isEmpty) {
      if (!_repository.hasSourceData) return;
      _firstSnapshotTimer?.cancel();
      safeEmit(NotificationsSuccess(items: _items, warning: null));
      return;
    }
    if (!_repository.hasSourceData) {
      _firstSnapshotTimer?.cancel();
      safeEmit(NotificationsError(error: errors.join('\n')));
      return;
    }
    // Keep the successful sources visible and show a compact warning.
    safeEmit(NotificationsSuccess(items: _items, warning: errors.join(' • ')));
  }

  void _onFatalError(Object error) {
    if (isClosed) return;
    _firstSnapshotTimer?.cancel();
    if (_repository.hasSourceData) {
      safeEmit(NotificationsSuccess(items: _items, warning: error.toString()));
    } else {
      safeEmit(NotificationsError(error: error.toString()));
    }
  }

  /// Retries after a total failure (used by the error view's button).
  Future<void> load() async {
    _firstSnapshotTimer?.cancel();
    safeEmit(const NotificationsLoading());
    await _repository.ensureStarted();
    if (!_repository.hasSourceData) {
      safeEmit(
        NotificationsError(
          error: _warning ?? 'Notifications are unavailable. Try again.',
        ),
      );
      return;
    }
    _items = _repository.currentItems;
    safeEmit(NotificationsSuccess(items: _items, warning: _warning));
  }

  /// One atomic write marks every notification read for this account.
  Future<void> markAllRead() => _repository.markAllAsRead();

  /// Tapping one row marks only that notification id.
  Future<void> markOneRead(String id) => _repository.markOneRead(id);

  @override
  Future<void> close() {
    _firstSnapshotTimer?.cancel();
    _subscription?.cancel();
    _errorSubscription?.cancel();
    return super.close();
  }
}
