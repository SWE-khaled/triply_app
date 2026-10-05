import 'package:flutter/foundation.dart';
import '../model/guide_notification.dart';
import '../../../../core/data/mock/tourguide/mock_guide_notifications.dart';

class GuideNotificationsController extends ChangeNotifier {
  List<GuideNotification> items = [];

  GuideNotificationsController() {
    items =
        mockGuideNotificationsRaw.map(GuideNotification.fromJson).toList();
  }
}
