import 'package:triply/core/firebase/firestore_result.dart';
import 'package:triply/data/firestore/datasources/trips_datasource.dart';
import 'package:triply/data/firestore/mappers/firestore_mappers.dart';
import 'package:triply/data/firestore/datasources/firestore_query_helper.dart';
import 'package:triply/features/tourist/place_details/model/trip.dart'
    as place_ui;
import 'package:triply/features/tourist/trip_details/model/trip_details.dart';
import 'package:triply/features/tourist/trips/models/trip.dart' as trips_ui;

/// Tourist trip reads: Firestore-approved first, explicit failure otherwise.
///
/// Cubits call [approvedTrips]/[tripDetails] from async bridges and keep
/// their mock lists on failure (with a visible offline notice) — the
/// repository never disguises a failure as mock data.
class TripsRepository {
  TripsDatasource? _ds;
  TripsRepository([TripsDatasource? ds]) : _ds = ds;

  // Lazy: constructing the repository must not touch Firebase (keeps
  // widget/unit tests and offline startup free of Firebase initialization).
  TripsDatasource get _datasource => _ds ??= TripsDatasource();

  Future<FirestoreResult<List<trips_ui.Trip>>> approvedTrips({
    String? category,
    int limit = 20,
    Object? startAfter,
  }) async {
    try {
      final page = await _datasource.listApproved(
        category: category,
        limit: limit,
        startAfter: startAfter,
      );
      final items = page.items
          .map(FirestoreMappers.tripDocToTouristTrip)
          .toList();
      if (items.isEmpty) return const FirestoreEmpty();
      return FirestoreOk(items);
    } catch (e) {
      // No silent mock fallback here: callers keep their own mock list and
      // report the failure explicitly (offline notice), so mock data is
      // never presented as a successful Firestore read.
      return FirestoreFailure(FirestoreQueryHelper.friendlyError(e), e);
    }
  }

  /// Single-trip details for the Trip Details screen. Returns the mapped
  /// UI model on success, Empty when the doc is missing (or not approved
  /// for this caller), Failure on transport/permission errors.
  Future<FirestoreResult<TripDetails>> tripDetails(String tripId) async {
    try {
      final doc = await _datasource.getById(tripId);
      if (doc == null) return const FirestoreEmpty();
      return FirestoreOk(FirestoreMappers.tripDocToTripDetails(doc));
    } catch (e) {
      return FirestoreFailure(FirestoreQueryHelper.friendlyError(e), e);
    }
  }

  /// Place Details Trips tab: approved trips for [placeId] via the existing
  /// `TripsDatasource.listByPlace` query (placeId + approvalStatus index).
  /// Empty (no approved trips for this place) and Failure are explicit —
  /// callers keep their mock tab list and report it, never blank the tab.
  Future<FirestoreResult<List<place_ui.Trip>>> tripsByPlace(
    String placeId, {
    int limit = 20,
  }) async {
    try {
      final docs = await _datasource.listByPlace(placeId, limit: limit);
      final items = docs.map(FirestoreMappers.tripDocToPlaceTrip).toList();
      if (items.isEmpty) return const FirestoreEmpty();
      return FirestoreOk(items);
    } catch (e) {
      return FirestoreFailure(FirestoreQueryHelper.friendlyError(e), e);
    }
  }
}
