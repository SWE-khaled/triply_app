import 'package:flutter/foundation.dart';
import '../models/notification_item.dart';
import '../data/mock/mock_notifications.dart';

class NotificationsController extends ChangeNotifier {
  List<NotificationItem> items = [];

  NotificationsController() {
    items = mockNotificationsRaw.map(NotificationItem.fromJson).toList();
  }

  List<NotificationItem> get today =>
      items.where((e) => e.section == 'today').toList();
  List<NotificationItem> get earlier =>
      items.where((e) => e.section == 'earlier').toList();
  int get unreadCount => items.where((e) => !e.isRead).length;

  void markAllRead() {
    items = items.map((e) => e.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  void markOneRead(String id) {
    items = items.map((e) => e.id == id ? e.copyWith(isRead: true) : e).toList();
    notifyListeners();
  }
}
