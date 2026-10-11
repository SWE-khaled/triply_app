import 'package:triply/features/tour_guide/homeandNotificationTr/model/guide_notification.dart';

class GuideNotificationsState {
  final List<GuideNotification> items;

  const GuideNotificationsState({required this.items});

  GuideNotificationsState copyWith({List<GuideNotification>? items}) {
    return GuideNotificationsState(items: items ?? this.items);
  }
}
