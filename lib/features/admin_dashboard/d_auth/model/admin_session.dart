/// Frontend-only admin session (demo/local implementation).
/// No backend: the account is accepted locally when the identifier
/// contains 'triplykl'. Real role enforcement belongs on the server.
class AdminSession {
  final String name;
  final String email;

  const AdminSession({required this.name, required this.email});
}

/// Stored admin account for this frontend demo session.
class AdminAccount {
  final String name;
  final String email;
  final String password;

  const AdminAccount({
    required this.name,
    required this.email,
    required this.password,
  });
}
