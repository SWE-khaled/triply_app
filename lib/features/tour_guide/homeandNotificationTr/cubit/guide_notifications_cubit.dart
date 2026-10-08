import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/data/mock/tourguide/mock_guide_notifications.dart';
import '../model/guide_notification.dart';
import 'guide_notifications_state.dart';

class GuideNotificationsCubit extends Cubit<GuideNotificationsState> {
  GuideNotificationsCubit()
      : super(
          GuideNotificationsState(
            items: mockGuideNotificationsRaw
                .map(GuideNotification.fromJson)
                .toList(),
          ),
        );
}
