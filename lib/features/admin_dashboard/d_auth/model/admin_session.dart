/// The signed-in admin.
///
/// The session mirrors the Firebase user: the account really exists, and
/// the `role` on its Firestore document is what grants the access.
class AdminSession {
  final String name;
  final String email;

  const AdminSession({required this.name, required this.email});
}
