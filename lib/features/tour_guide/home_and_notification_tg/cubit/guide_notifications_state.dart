part of 'guide_notifications_cubit.dart';

@immutable
sealed class GuideNotificationsState {
  const GuideNotificationsState();
}

final class GuideNotificationsInitial extends GuideNotificationsState {
  const GuideNotificationsInitial();
}

final class GuideNotificationsLoading extends GuideNotificationsState {
  const GuideNotificationsLoading();
}

final class GuideNotificationsSuccess extends GuideNotificationsState {
  final List<GuideNotification> items;

  const GuideNotificationsSuccess({required this.items});
}

final class GuideNotificationsError extends GuideNotificationsState {
  final String error;

  const GuideNotificationsError({required this.error});
}
