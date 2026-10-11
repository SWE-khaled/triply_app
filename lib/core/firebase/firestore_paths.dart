/// Canonical Firestore collection + subcollection paths.
///
/// Single source of truth for every datasource/repository. Stable IDs from
/// the existing mock datasets are reused as document IDs where practical
/// so navigation (`placeId`, `tripId`, `guideId`) keeps working.
class FirestorePaths {
  FirestorePaths._();

  static const String users = 'users';
  static const String guideProfiles = 'guideProfiles';
  static const String guideVerifications = 'guideVerifications';
  static const String places = 'places';
  static const String trips = 'trips';
  static const String bookings = 'bookings';
  static const String payments = 'payments';
  static const String posts = 'posts';
  static const String stories = 'stories';
  static const String notifications = 'notifications';
  static const String reviews = 'reviews';
  static const String appSettings = 'appSettings';
  static const String admins = 'admins';

  /// `posts/{postId}/likes/{uid}` — one doc per like, owned by `uid`.
  static const String postLikes = 'likes';

  static String user(String uid) => '$users/$uid';
  static String guideProfile(String uid) => '$guideProfiles/$uid';
  static String verification(String id) => '$guideVerifications/$id';
  static String place(String id) => '$places/$id';
  static String trip(String id) => '$trips/$id';
  static String booking(String id) => '$bookings/$id';
  static String payment(String id) => '$payments/$id';
  static String post(String id) => '$posts/$id';
  static String story(String id) => '$stories/$id';
  static String notification(String id) => '$notifications/$id';
}
