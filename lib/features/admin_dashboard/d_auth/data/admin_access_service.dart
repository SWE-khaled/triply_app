import 'package:firebase_auth/firebase_auth.dart';
import 'package:triply/data/firestore/datasources/admins_datasource.dart';

/// Server-backed admin gate to REPLACE the demo `triplykl` email-substring
/// check (see `AdminAuthCubit._hasAccess`).
///
/// Authorization sources (either suffices):
/// 1. `admins/{uid}` presence doc (provisioned via Console/Functions —
///    see `docs/ADMIN_PROVISIONING.md`), checked here.
/// 2. `admin: true` custom claim on the ID token (set by `provisionAdmin`
///    Function), checked via [hasAdminClaim].
///
/// This service is additive: `AdminAuthCubit` keeps its current demo flow
/// until the provisioning procedure is completed and approved.
class AdminAccessService {
  final AdminsDatasource _admins;
  AdminAccessService([AdminsDatasource? admins])
    : _admins = admins ?? AdminsDatasource();

  /// Returns true when [uid] (or the current user) is a provisioned admin.
  Future<bool> isAuthorized([String? uid]) async {
    final id = uid ?? FirebaseAuth.instance.currentUser?.uid ?? '';
    if (id.isEmpty) return false;
    try {
      if (await _admins.isAdmin(id)) return true;
    } catch (_) {}
    return hasAdminClaim();
  }

  /// Reads the custom claim without a network round-trip when the token
  /// is fresh, falling back to one forced refresh so a just-provisioned
  /// `admin:true` claim is observed. Returns false on any failure (fail-closed).
  Future<bool> hasAdminClaim() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final cached = await user?.getIdTokenResult();
      if ((cached?.claims?['admin'] as bool?) == true) return true;
      // Newly provisioned admins hold a cached token without the claim —
      // one refresh picks it up without forcing refresh on every check.
      final fresh = await user?.getIdTokenResult(true);
      return (fresh?.claims?['admin'] as bool?) ?? false;
    } catch (_) {
      return false;
    }
  }
}
