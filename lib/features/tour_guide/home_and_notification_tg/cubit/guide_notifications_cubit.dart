import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/data/repositories/guide_notifications_repository.dart';
import '../../../../../core/data/repositories/guide_trips_repository.dart';
import '../../../../../core/utils/safe_emit_mixin.dart';
import '../../my_trips_tg/model/guide_trip.dart';
import '../model/guide_notification.dart';

part 'guide_notifications_state.dart';

/// The guide's notification centre.
///
/// Reads the shared session-wide notification repository through the guide
/// adapter. The list is live: a new notification shows up without a refresh.
/// One failed source is shown as a warning, never as a blank screen: the
/// other sources keep feeding the list.
class GuideNotificationsCubit extends Cubit<GuideNotificationsState>
    with SafeEmitMixin<GuideNotificationsState> {
  GuideNotificationsCubit({GuideNotificationsRepository? repository})
    : _repository = repository ?? GuideNotificationsRepository.instance,
      super(const GuideNotificationsInitial()) {
    _emit(const GuideNotificationsLoading());
    _subscription = _repository.watchNotifications().listen(
      _onNotifications,
      onError: (Object error) => _onFatalError(error),
    );
    _errorSubscription = _repository.watchSourceErrors().listen(
      _onSourceErrors,
    );
    _firstSnapshotTimer = Timer(_loadingTimeout, () {
      // A signed-out user or a source that never reports must not leave the
      // page on its loading skeleton forever. Surface the wait as an empty,
      // usable list with an explanatory warning.
      if (!_hasDataEvent && !_repository.hasListSourceData && !isClosed) {
        _emit(
          GuideNotificationsSuccess(
            items: const <GuideNotification>[],
            warning: _warning ?? 'Notifications are taking too long to load.',
          ),
        );
      }
    });
  }

  void _emit(GuideNotificationsState state) {
    safeEmit(state);
  }

  /// Long enough to let a slow first Firestore snapshot arrive, short enough
  /// that the page never sits on a shimmer forever.
  static const Duration _loadingTimeout = Duration(seconds: 5);

  final GuideNotificationsRepository _repository;

  /// The trips repository — a notification points at one of them.
  final GuideTripsRepository _trips = GuideTripsRepository();

  StreamSubscription<List<GuideNotification>>? _subscription;
  StreamSubscription<List<String>>? _errorSubscription;
  Timer? _firstSnapshotTimer;

  List<GuideNotification> _items = const <GuideNotification>[];
  bool _hasDataEvent = false;

  String? get _warning {
    final errors = _repository.sourceErrors;
    if (errors.isEmpty) return null;
    return errors.join(' • ');
  }

  /// The rows the list renders. Kept next to the state so the page can read
  /// the freshest list even when a source-error event triggers the rebuild.
  List<GuideNotification> get items =>
      List<GuideNotification>.unmodifiable(_items);

  void _onNotifications(List<GuideNotification> items) {
    // The shared stream replays its cached list. Before `stored`/`chat` have
    // reported, that list carries no rows; keep waiting for a real snapshot.
    // Never store a list without emitting it, so state and rows stay in sync.
    if (!_repository.hasListSourceData) {
      return;
    }
    _items = items;
    _hasDataEvent = true;
    _firstSnapshotTimer?.cancel();
    _emit(GuideNotificationsSuccess(items: _items, warning: _warning));
  }

  void _onSourceErrors(List<String> errors) {
    if (isClosed) return;
    if (errors.isEmpty) {
      if (!_repository.hasListSourceData) return;
      _firstSnapshotTimer?.cancel();
      _emit(GuideNotificationsSuccess(items: _items, warning: null));
      return;
    }
    if (!_repository.hasListSourceData) {
      _firstSnapshotTimer?.cancel();
      _emit(GuideNotificationsError(error: errors.join('\n')));
      return;
    }
    // A failed source is visible, but the successful ones stay usable.
    _emit(
      GuideNotificationsSuccess(items: _items, warning: errors.join(' • ')),
    );
  }

  void _onFatalError(Object error) {
    if (isClosed) return;
    _firstSnapshotTimer?.cancel();
    if (_repository.hasListSourceData) {
      _emit(
        GuideNotificationsSuccess(items: _items, warning: error.toString()),
      );
    } else {
      _emit(GuideNotificationsError(error: error.toString()));
    }
  }

  /// Re-reads the notifications (used by the retry button).
  Future<void> load() async {
    _firstSnapshotTimer?.cancel();
    _emit(const GuideNotificationsLoading());
    try {
      final items = await _repository.fetchNotifications();
      if (!_repository.hasListSourceData) {
        _emit(
          GuideNotificationsError(
            error: _warning ?? 'Notifications are unavailable. Try again.',
          ),
        );
        return;
      }
      _items = items;
      _emit(GuideNotificationsSuccess(items: _items, warning: _warning));
    } catch (e) {
      _emit(GuideNotificationsError(error: e.toString()));
    }
  }

  /// Marks every notification as read.
  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
    } catch (_) {
      // Keep the list as it is; the stream re-reads the truth.
    }
  }

  /// Marks one notification as read.
  Future<void> markAsRead(String notificationId) async {
    try {
      await _repository.markAsRead(notificationId);
    } catch (_) {
      // Keep the list as it is; the stream re-reads the truth.
    }
  }

  /// The trip a notification is about, or null when it is gone.
  Future<GuideTrip?> fetchTrip(String tripId) async {
    try {
      return await _trips.fetchTrip(tripId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> close() {
    _firstSnapshotTimer?.cancel();
    _subscription?.cancel();
    _errorSubscription?.cancel();
    return super.close();
  }
}
