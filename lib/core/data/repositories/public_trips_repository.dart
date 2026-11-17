import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/public_trip.dart';
import '../remote/firestore_service.dart';

/// The trips the tourists browse.
///
/// A trip becomes visible here only after the admin approved it — the
/// security rules enforce the same thing, so the query can never return a
/// trip that is still pending or rejected.
///
/// The mock dataset stays the fallback: when the read fails (offline, no
/// permission) the screens keep showing the bundled trips instead of an
/// empty page. An empty list is a real answer — no trip is approved yet.
class PublicTripsRepository {
  PublicTripsRepository({FirestoreService? firestore})
    : _firestore = firestore ?? FirestoreService();

  /// The Firestore collection holding the trips.
  static const String tripsCollection = 'trips';

  /// The approval state that makes a trip visible to the tourists.
  static const String approvedStatus = 'approved';

  final FirestoreService _firestore;

  /// The approved trips.
  ///
  /// Returns null when the read failed — that is the caller's cue to
  /// fall back to the mock dataset.
  Future<List<PublicTrip>?> fetchApprovedTrips({
    bool rethrowOnError = false,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(tripsCollection)
          .where('approvalStatus', isEqualTo: approvedStatus)
          .get();
      return snapshot.docs
          .map((doc) => PublicTrip.fromDocument(doc.data(), doc.id))
          .toList();
    } catch (_) {
      if (rethrowOnError) rethrow;
      return null;
    }
  }

  /// The approved trips of one guide.
  ///
  /// The guide is addressed by its uid — the same key the trip documents
  /// carry — so no name matching is needed.
  Future<List<PublicTrip>?> fetchApprovedTripsOfGuide(String guideId) async {
    if (guideId.isEmpty) return const [];
    try {
      final snapshot = await _firestore
          .collection(tripsCollection)
          .where('approvalStatus', isEqualTo: approvedStatus)
          .where('guideId', isEqualTo: guideId)
          .get();
      return snapshot.docs
          .map((doc) => PublicTrip.fromDocument(doc.data(), doc.id))
          .toList();
    } catch (_) {
      return null;
    }
  }

  /// One trip, or null when it does not exist.
  Future<PublicTrip?> fetchTrip(
    String tripId, {
    bool rethrowOnError = false,
  }) async {
    try {
      final data = await _firestore.readDoc(tripsCollection, tripId);
      if (data == null) return null;
      return PublicTrip.fromDocument(data, tripId);
    } catch (_) {
      if (rethrowOnError) rethrow;
      return null;
    }
  }

  /// The trips of the given ids.
  ///
  /// The Firestore SDK does not accept a list of ids in a
  /// `FieldPath.documentId` query ("must provide a valid String"), so the
  /// trips are fetched concurrently — each booking needs its own trip read.
  Future<List<PublicTrip>> fetchTripsByIds(
    List<String> tripIds, {
    bool rethrowOnError = false,
  }) async {
    final wanted = tripIds.where((id) => id.isNotEmpty).toSet().toList();
    if (wanted.isEmpty) return const [];
    try {
      final trips = await Future.wait(
        wanted.map((id) async {
          try {
            final data = await _firestore.readDoc(tripsCollection, id);
            if (data == null) return null;
            return PublicTrip.fromDocument(data, id);
          } on FirebaseException catch (error) {
            // A booking can reference a trip the tourist can no longer
            // read (missing, rejected or cancelled). That is specific to
            // this one booking: skip its join, keep the other bookings,
            // and leave an auditable trace of the original error.
            if (error.code == 'permission-denied') {
              debugPrint(
                'PublicTripsRepository.fetchTripsByIds: '
                'trip $id is not readable (${error.code}).',
              );
              return null;
            }
            rethrow;
          }
        }),
      );
      return trips.whereType<PublicTrip>().toList();
    } catch (_) {
      if (rethrowOnError) rethrow;
      return const [];
    }
  }
}
