import 'package:triply/core/firebase/firestore_result.dart';
import 'package:triply/data/firestore/datasources/firestore_query_helper.dart';
import 'package:triply/data/firestore/datasources/trips_datasource.dart';
import 'package:triply/data/firestore/mappers/firestore_mappers.dart';
import 'package:triply/data/firestore/models/trip_doc.dart';
import 'package:triply/features/tour_guide/my_trips_tg/model/guide_trip.dart';

/// Guide trip reads/creates with session/mock fallback.
///
/// New trips are `pending` until admin approval (Function stamps status).
/// The in-memory `GuideTripsStore` remains the session mirror so existing
/// screens (dashboard stats, edit flow) keep working during migration.
class GuideTripsRepository {
  final TripsDatasource _ds;
  GuideTripsRepository([TripsDatasource? ds]) : _ds = ds ?? TripsDatasource();

  Future<FirestoreResult<List<GuideTrip>>> myTrips(
    String guideId, {
    String? approvalStatus,
    int limit = 50,
  }) async {
    try {
      final page = await _ds.listByGuide(
        guideId,
        approvalStatus: approvalStatus,
        limit: limit,
      );
      final items =
          page.items.map(FirestoreMappers.tripDocToGuideTrip).toList();
      if (items.isEmpty) return const FirestoreEmpty();
      return FirestoreOk(items);
    } catch (e) {
      // Honest failure: the cubit's session/mock baseline stays in place
      // and the caller reports it — never present mocks as a successful
      // remote fetch (masks real Firebase errors on this screen).
      return FirestoreFailure(FirestoreQueryHelper.friendlyError(e), e);
    }
  }

  Future<String> createTrip(TripDoc doc) => _ds.create(doc);

  Future<void> updateTrip(String id, Map<String, dynamic> fields) =>
      _ds.updateClientFields(id, fields);
}
