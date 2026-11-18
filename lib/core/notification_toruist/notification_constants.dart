/// Shared constants for the free-tier (Firebase-only) notification flow.
class NotificationConstants {
  const NotificationConstants._();

  /// The single Android channel used by every local notification.
  static const String channelId = 'triply_channel';
  static const String channelName = 'Triply Notifications';
  static const String channelDescription = 'Notifications for Triply app';

  static const String usersCollection = 'users';
  static const String fcmTokensField = 'fcmTokens';
  static const String lastSeenField = 'notificationsLastSeenAt';

  static const String roleTourist = 'tourist';
  static const String roleGuide = 'guide';

  /// Notification list item types — also the FCM `type` data value.
  static const String typePost = 'post';
  static const String typeTrip = 'trip';
  static const String typeChat = 'chat';
  static const String typeLike = 'like';
  static const String typeBooking = 'booking';
  static const String typeTripDecided = 'trip_decided';
}
