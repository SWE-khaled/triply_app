part of 'notifications_cubit.dart';

@immutable
sealed class NotificationsState {
  const NotificationsState();
}

final class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

final class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

final class NotificationsSuccess extends NotificationsState {
  /// The notifications of the tourist, newest first.
  final List<NotificationItem> items;

  /// Short warnings for sources that failed. The list remains usable.
  final String? warning;

  const NotificationsSuccess({required this.items, this.warning});
}

final class NotificationsError extends NotificationsState {
  final String error;

  const NotificationsError({required this.error});
}
