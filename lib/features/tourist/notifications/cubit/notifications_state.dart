import '../model/notification_item.dart';

class NotificationsState {
  final List<NotificationItem> items;

  const NotificationsState({required this.items});

  NotificationsState copyWith({List<NotificationItem>? items}) {
    return NotificationsState(items: items ?? this.items);
  }
}
