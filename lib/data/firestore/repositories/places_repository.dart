import 'package:triply/core/data/mock/tourist/mock_places.dart';
import 'package:triply/core/firebase/firestore_result.dart';
import 'package:triply/data/firestore/datasources/firestore_query_helper.dart';
import 'package:triply/data/firestore/datasources/places_datasource.dart';
import 'package:triply/data/firestore/mappers/firestore_mappers.dart';
import 'package:triply/features/tourist/map/model/place.dart' as map_ui;

/// Place reads: Firestore first, mock fallback. Stable mock IDs are reused
/// as Firestore doc IDs so `PlaceDetailScreen(placeId)` keeps resolving.
class PlacesRepository {
  PlacesDatasource? _ds;
  PlacesRepository([PlacesDatasource? ds]) : _ds = ds;

  // Lazy: constructing the repository must not touch Firebase (keeps
  // widget/unit tests and offline startup free of Firebase initialization).
  PlacesDatasource get _datasource => _ds ??= PlacesDatasource();

  Future<FirestoreResult<List<map_ui.Place>>> topPlaces({
    String? category,
    int limit = 20,
    Object? startAfter,
  }) async {
    try {
      final page = await _datasource.list(category: category, limit: limit, startAfter: startAfter);
      final items = page.items.map(FirestoreMappers.placeDocToMapPlace).toList();
      if (items.isEmpty) return const FirestoreEmpty();
      return FirestoreOk(items);
    } catch (e) {
      try {
        final items = mockPlaces.map(map_ui.Place.fromJson).take(limit).toList();
        if (items.isEmpty) return const FirestoreEmpty();
        return FirestoreOk(items);
      } catch (_) {
        return FirestoreFailure(FirestoreQueryHelper.friendlyError(e), e);
      }
    }
  }

  Future<FirestoreResult<List<map_ui.Place>>> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) return const FirestoreEmpty();
    try {
      final docs = await _datasource.searchByName(q);
      final items = docs.map(FirestoreMappers.placeDocToMapPlace).toList();
      if (items.isEmpty) return const FirestoreEmpty();
      return FirestoreOk(items);
    } catch (e) {
      // Local substring fallback mirrors `SearchCubit` behavior.
      try {
        final lower = q.toLowerCase();
        final items = mockPlaces
            .map(map_ui.Place.fromJson)
            .where((p) =>
                p.name.toLowerCase().contains(lower) ||
                p.city.toLowerCase().contains(lower) ||
                p.category.toLowerCase().contains(lower))
            .take(20)
            .toList();
        if (items.isEmpty) return const FirestoreEmpty();
        return FirestoreOk(items);
      } catch (_) {
        return FirestoreFailure(FirestoreQueryHelper.friendlyError(e), e);
      }
    }
  }

  Future<FirestoreResult<map_ui.Place>> byId(
    String id, {
    map_ui.Place? mockFallback,
  }) async {
    try {
      final doc = await _datasource.getById(id);
      if (doc == null) {
        if (mockFallback != null) return FirestoreOk(mockFallback);
        return const FirestoreEmpty();
      }
      return FirestoreOk(FirestoreMappers.placeDocToMapPlace(doc));
    } catch (e) {
      if (mockFallback != null) return FirestoreOk(mockFallback);
      return FirestoreFailure(FirestoreQueryHelper.friendlyError(e), e);
    }
  }
}
