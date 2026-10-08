import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/notification_item.dart';
import '../../../../core/data/mock/tourist/mock_notifications.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit()
      : super(
          NotificationsState(
            items: mockNotificationsRaw
                .map(NotificationItem.fromJson)
                .toList(),
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
}
