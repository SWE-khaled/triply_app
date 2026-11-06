/// The two account types that share the auth stack.
enum AuthRole {
  tourist('tourist'),
  guide('guide');

  const AuthRole(this.value);

  /// The value stored on `users/{uid}.role` in Firestore.
  final String value;

  /// Maps a Firestore role string to an [AuthRole].
  ///
  /// Returns null for an unknown role (e.g. `admin`), so the caller can
  /// reject it instead of silently accepting it.
  static AuthRole? fromValue(String? value) => switch (value) {
    'tourist' => AuthRole.tourist,
    'guide' => AuthRole.guide,
    _ => null,
  };
}
