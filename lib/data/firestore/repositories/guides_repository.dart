import 'package:triply/core/data/mock/tourist/mock_guides.dart';
import 'package:triply/core/firebase/firestore_result.dart';
import 'package:triply/data/firestore/datasources/firestore_query_helper.dart';
import 'package:triply/data/firestore/datasources/guide_profiles_datasource.dart';
import 'package:triply/data/firestore/datasources/users_datasource.dart';
import 'package:triply/data/firestore/mappers/firestore_mappers.dart';
import 'package:triply/features/tourist/guides/model/guide.dart' as guides_ui;

/// Guide directory reads: verified `guideProfiles` + `users` display names,
/// mock fallback offline. No new Guide model — reuses the tourist `Guide`.
class GuidesRepository {
  final GuideProfilesDatasource _profiles;
  final UsersDatasource _users;
  GuidesRepository({
    GuideProfilesDatasource? profiles,
    UsersDatasource? users,
  })  : _profiles = profiles ?? GuideProfilesDatasource(),
        _users = users ?? UsersDatasource();

  Future<FirestoreResult<List<guides_ui.Guide>>> verifiedGuides({
    int limit = 20,
    Object? startAfter,
  }) async {
    try {
      final page =
          await _profiles.listVerified(limit: limit, startAfter: startAfter);
      final out = <guides_ui.Guide>[];
      for (final p in page.items) {
        // Canonical profile fields first. The `users` read is best-effort:
        // deployed rules restrict user docs to owner/admin, so a cross-user
        // read here must never fail the whole directory (falls back below).
        var name = p.displayName;
        var avatar = '';
        try {
          final user = await _users.getById(p.userId);
          if (user != null) {
            if (name.isEmpty) name = user.fullName;
            avatar = user.avatarUrl;
          }
        } catch (_) {}
        if (name.isEmpty) name = 'Guide';
        out.add(
          FirestoreMappers.guideProfileToGuide(
            p,
            displayName: name,
            avatarUrl: avatar,
          ),
        );
      }
      if (out.isEmpty) return const FirestoreEmpty();
      return FirestoreOk(out);
    } catch (e) {
      try {
        if (mockGuides.isEmpty) return const FirestoreEmpty();
        return FirestoreOk(List<guides_ui.Guide>.from(mockGuides));
      } catch (_) {
        return FirestoreFailure(FirestoreQueryHelper.friendlyError(e), e);
      }
    }
  }
}
