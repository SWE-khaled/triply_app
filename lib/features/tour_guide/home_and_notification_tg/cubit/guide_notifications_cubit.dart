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
/// Reads the notifications from Firestore, with the mock dataset as
/// fallback. The list is live: a new notification shows up without a
/// refresh.
class GuideNotificationsCubit extends Cubit<GuideNotificationsState>
    with SafeEmitMixin<GuideNotificationsState> {
  GuideNotificationsCubit({GuideNotificationsRepository? repository})
    : _repository = repository ?? GuideNotificationsRepository(),
      super(const GuideNotificationsInitial()) {
    _subscription = _repository.watchNotifications().listen(
      (items) => safeEmit(GuideNotificationsSuccess(items: items)),
      onError: (Object error) =>
          safeEmit(GuideNotificationsError(error: error.toString())),
    );
  }

  final GuideNotificationsRepository _repository;

  /// The trips repository — a notification points at one of them.
  final GuideTripsRepository _trips = GuideTripsRepository();

  StreamSubscription<List<GuideNotification>>? _subscription;

  /// Re-reads the notifications (used by the retry button).
  Future<void> load() async {
    safeEmit(const GuideNotificationsLoading());
    try {
      final items = await _repository.fetchNotifications();
      safeEmit(GuideNotificationsSuccess(items: items));
    } catch (e) {
      safeEmit(GuideNotificationsError(error: e.toString()));
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
    _subscription?.cancel();
    return super.close();
  }
}
