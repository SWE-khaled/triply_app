import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/data/mock/tourguide/mock_guide_notifications.dart';
import 'package:triply/core/firebase/firestore_result.dart';
import 'package:triply/data/firestore/repositories/notifications_repository.dart';
import 'package:triply/features/tour_guide/homeandNotificationTr/model/guide_notification.dart';
import 'package:triply/features/tour_guide/homeandNotificationTr/cubit/guide_notifications_state.dart';

class GuideNotificationsCubit extends Cubit<GuideNotificationsState> {
  /// Kill-switch: gates every remote call in the View. Phase 6
  /// (guide notifications) is activated; flipping back to `false` is
  /// instant rollback to the mock baseline.
  static const bool useRemote = true;

  final NotificationsRepository _repository;

  GuideNotificationsCubit([NotificationsRepository? repository])
    : _repository = repository ?? NotificationsRepository(),
      super(
        GuideNotificationsState(
          items: mockGuideNotificationsRaw
              .map(GuideNotification.fromJson)
              .toList(),
        ),
      );

  int get unreadCount => state.items.where((e) => !e.isRead).length;

  void _markLocal(String id) {
    emit(
      state.copyWith(
        items: state.items
            .map((e) => e.id == id ? e.copyWith(isRead: true) : e)
            .toList(),
      ),
    );
  }

  /// Best-effort server list for the signed-in guide. Returns true when
  /// remote notifications replaced the list; false keeps the mock baseline
  /// — callers must surface this, never present mocks as live data.
  Future<bool> loadRemote(String userId) async {
    try {
      final result = await _repository.guideNotifications(userId);
      if (result is FirestoreOk<List<GuideNotification>> &&
          result.data.isNotEmpty) {
        emit(GuideNotificationsState(items: result.data));
        return true;
      }
    } catch (e) {
      debugPrint('Triply: GuideNotificationsCubit.loadRemote failed: $e');
      return false;
    }
    debugPrint('Triply: GuideNotificationsCubit.loadRemote kept mocks.');
    return false;
  }

  /// Local mark-read + persistent write. Returns true when the server
  /// write succeeded.
  Future<bool> markOneReadRemote(String id) async {
    _markLocal(id);
    try {
      await _repository.markOneRead(id);
      return true;
    } catch (e) {
      debugPrint('Triply: GuideNotifications markOneReadRemote failed: $e');
      return false;
    }
  }

  /// Local mark-all-read + persistent write. Returns true when the server
  /// write succeeded.
  Future<bool> markAllReadRemote(String userId) async {
    emit(
      state.copyWith(
        items: state.items.map((e) => e.copyWith(isRead: true)).toList(),
      ),
    );
    try {
      await _repository.markAllRead(userId);
      return true;
    } catch (e) {
      debugPrint('Triply: GuideNotifications markAllReadRemote failed: $e');
      return false;
    }
  }
}
