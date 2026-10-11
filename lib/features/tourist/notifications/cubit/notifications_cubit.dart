import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/firebase/firestore_result.dart';
import 'package:triply/data/firestore/repositories/notifications_repository.dart';
import '../model/notification_item.dart';
import '../../../../core/data/mock/tourist/mock_notifications.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  /// Kill-switch: gates every remote call in the View. Phase 6
  /// (notifications) is activated; flipping back to `false` is instant
  /// rollback to the mock baseline.
  static const bool useRemote = true;

  final NotificationsRepository _repository;
  NotificationsCubit([NotificationsRepository? repository])
    : _repository = repository ?? NotificationsRepository(),
      super(
        NotificationsState(
          items: mockNotificationsRaw.map(NotificationItem.fromJson).toList(),
        ),
      );

  List<NotificationItem> get today =>
      state.items.where((e) => e.section == 'today').toList();
  List<NotificationItem> get earlier =>
      state.items.where((e) => e.section == 'earlier').toList();
  int get unreadCount => state.items.where((e) => !e.isRead).length;

  void markAllRead() {
    emit(
      state.copyWith(
        items: state.items.map((e) => e.copyWith(isRead: true)).toList(),
      ),
    );
  }

  void markOneRead(String id) {
    emit(
      state.copyWith(
        items: state.items
            .map((e) => e.id == id ? e.copyWith(isRead: true) : e)
            .toList(),
      ),
    );
  }

  /// Best-effort remote refresh for [userId]. Returns true when remote
  /// notifications replaced the list; false when mocks were kept — callers
  /// must surface this, never present mocks as live data.
  Future<bool> loadRemote(String userId) async {
    try {
      final result = await _repository.myNotifications(userId);
      if (result is FirestoreOk<List<NotificationItem>> &&
          result.data.isNotEmpty) {
        emit(NotificationsState(items: result.data));
        return true;
      }
    } catch (e) {
      debugPrint('Triply: NotificationsCubit.loadRemote failed: $e');
      return false;
    }
    debugPrint('Triply: NotificationsCubit.loadRemote kept mocks.');
    return false;
  }

  /// Local mark-all-read (existing behavior) + persistent write.
  /// Returns true when the server write succeeded.
  Future<bool> markAllReadRemote(String userId) async {
    markAllRead();
    try {
      await _repository.markAllRead(userId);
      return true;
    } catch (e) {
      debugPrint('Triply: markAllReadRemote failed: $e');
      return false;
    }
  }

  /// Local mark-one-read (existing behavior) + persistent write.
  /// Returns true when the server write succeeded.
  Future<bool> markOneReadRemote(String userId, String id) async {
    markOneRead(id);
    try {
      await _repository.markOneRead(id);
      return true;
    } catch (e) {
      debugPrint('Triply: markOneReadRemote failed: $e');
      return false;
    }
  }
}
