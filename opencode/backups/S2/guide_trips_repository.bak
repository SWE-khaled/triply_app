import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../features/tour_guide/my_trips_tg/model/guide_trip.dart';
import '../../../features/tour_guide/trip_details_tg/model/guide_trip_details.dart';
import '../guide_trip_details_source.dart';
import '../guide_trips_store.dart';
import '../mock/tourguide/mock_guide_trip_details.dart';
import '../mock/tourguide/mock_guide_trips.dart';
import '../remote/firestore_service.dart';

/// Reads and writes the trips owned by the signed-in tour guide.
///
/// Firestore is the source of truth. The mock dataset is the fallback used
/// when the guide is signed out or the network call fails, so the screens
/// never end up empty.
///
/// A trip document holds the card fields *and* the long-form details, so
/// one read gives the list and the details screen everything they need.
class GuideTripsRepository {
  GuideTripsRepository({FirestoreService? firestore, this.auth})
    : _firestore = firestore ?? FirestoreService();

  /// Firestore collection holding the guide trips.
  static const String tripsCollection = 'trips';

  final FirestoreService _firestore;

  /// The auth client to read the signed-in guide from. Null means the
  /// default [FirebaseAuth] instance.
  final FirebaseAuth? auth;

  /// Resolved lazily so building the repository never requires a running
  /// Firebase app (which keeps it usable in plain unit tests).
  FirebaseAuth get _firebaseAuth => auth ?? FirebaseAuth.instance;

  /// The signed-in guide's uid, or null when signed out.
  /// The signed-in guide's uid, or null when signed out.
  ///
  /// Returns null (instead of throwing) when there is no Firebase app,
  /// so the repositories stay usable in plain unit tests.
  String? get currentGuideId {
    try {
      return _firebaseAuth.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  /// Live list of the guide's trips.
  ///
  /// Emits whenever Firestore changes, and falls back to the mock
  /// dataset when the guide is signed out or the read fails.
  Stream<List<GuideTrip>> watchTrips() async* {
    final uid = currentGuideId;
    debugPrint('GuideTripsRepository.watchTrips: uid=$uid');
    if (uid == null) {
      yield _mockTrips();
      return;
    }
    var emitted = false;
    try {
      await for (final snapshot
          in _firestore
              .collection(tripsCollection)
              .where('guideId', isEqualTo: uid)
              .snapshots()) {
        emitted = true;
        debugPrint(
          'GuideTripsRepository.watchTrips: ${snapshot.docs.length} trips '
          '(${snapshot.docs.map((d) => d.id).join(', ')})',
        );
        yield _merge(
          snapshot.docs
              .map((doc) {
                // One broken document must not take the whole list down.
                try {
                  return _toTrip(doc.data(), doc.id);
                } catch (e) {
                  debugPrint('skipping trip ${doc.id}: $e');
                  return null;
                }
              })
              .whereType<GuideTrip>()
              .toList(),
        );
      }
    } catch (e) {
      debugPrint('GuideTripsRepository.watchTrips failed: $e');
      // Network down, rules missing, … — keep the app usable.
      if (!emitted) yield _mockTrips();
    }
  }

  /// One-shot read of the guide's trips.
  Future<List<GuideTrip>> fetchTrips() async {
    final uid = currentGuideId;
    if (uid == null) return _mockTrips();
    try {
      final snapshot = await _firestore
          .collection(tripsCollection)
          .where('guideId', isEqualTo: uid)
          .get();
      return _merge(
        snapshot.docs.map((doc) => _toTrip(doc.data(), doc.id)).toList(),
      );
    } catch (_) {
      return _mockTrips();
    }
  }

  /// Writes a new trip (and its details) and returns the stored id.
  Future<String> createTrip({
    required GuideTrip trip,
    required GuideTripDetails details,
  }) async {
    final uid = currentGuideId;
    if (uid == null) {
      throw StateError('Sign in before saving a trip.');
    }
    final doc = toTripDoc(trip, details, uid);
    try {
      await _firestore.writeDoc(tripsCollection, trip.id, doc, merge: false);
    } catch (e) {
      // The security rules can refuse a write for any one of its
      // conditions — log the fields so the reason is obvious.
      debugPrint('GuideTripsRepository.createTrip failed: $e');
      debugPrint(
        '  guideId=${doc['guideId']} '
        'approvalStatus=${doc['approvalStatus']} '
        'capacity=${doc['capacity']} '
        'bookedSeats=${doc['bookedSeats']} '
        'priceEgp=${doc['priceEgp']} '
        'title=${doc['title']}',
      );
      rethrow;
    }
    return trip.id;
  }

  /// Saves an edited trip (and its details).
  Future<void> updateTrip({
    required GuideTrip trip,
    required GuideTripDetails details,
  }) async {
    final uid = currentGuideId;
    if (uid == null) {
      throw StateError('Sign in before saving a trip.');
    }
    await _firestore.writeDoc(
      tripsCollection,
      trip.id,
      toTripDoc(trip, details, uid),
    );
  }

  /// Deletes a trip.
  ///
  /// Signed out there is nothing in Firestore — the trip is dropped from
  /// the session store instead. The store cleanup also runs after a
  /// successful Firestore delete, so a just-created trip that has not
  /// round-tripped yet cannot reappear before the snapshot arrives.
  Future<void> deleteTrip(String tripId) async {
    final uid = currentGuideId;
    if (uid == null) {
      GuideTripsStore.delete(tripId);
      return;
    }
    try {
      await _firestore.deleteDoc(tripsCollection, tripId);
    } catch (e) {
      debugPrint('GuideTripsRepository.deleteTrip($tripId) failed: $e');
      rethrow;
    }
    GuideTripsStore.delete(tripId);
  }

  /// One trip by id, or null when it does not exist.
  Future<GuideTrip?> fetchTrip(String tripId) async {
    final uid = currentGuideId;
    if (uid == null) return null;
    try {
      final data = await _firestore.readDoc(tripsCollection, tripId);
      if (data == null) return null;
      return _toTrip(data, tripId);
    } catch (_) {
      return null;
    }
  }

  /// The details of one trip, read from Firestore.
  ///
  /// A trip that is not published yet — a draft the guide is previewing —
  /// only exists in the session cache, so that is checked before the
  /// mock dataset.
  ///
  /// Returns null when the trip does not exist anywhere.
  Future<GuideTripDetails?> fetchDetails(String tripId) async {
    final uid = currentGuideId;
    if (uid != null) {
      try {
        final data = await _firestore.readDoc(tripsCollection, tripId);
        if (data != null) {
          final details = _toDetails(data, tripId);
          GuideTripDetailsSource.save(details);
          return details;
        }
      } catch (_) {
        // Offline or no permission — fall through to the session cache.
      }
    }
    final draft = GuideTripDetailsSource.savedFor(tripId);
    if (draft != null) return draft;
    return _mockDetails(tripId);
  }

  /// The details of a trip in the mock dataset.
  GuideTripDetails? _mockDetails(String tripId) {
    for (final details in mockGuideTripDetailsJson) {
      if (details['tripId'] == tripId) {
        return GuideTripDetails.fromJson(details);
      }
    }
    return null;
  }

  // ──────────────── mapping ────────────────

  /// Builds the Firestore document of a trip.
  ///
  /// The keys match the models one-to-one, so a document can be read back
  /// with `Model.fromJson(doc.data())` and the mock dataset can be seeded
  /// without any translation.
  ///
  /// `approvalStatus` is the admin workflow: a guide always publishes as
  /// `pending`, the admin dashboard moves it to `approved` / `rejected`.
  Map<String, dynamic> toTripDoc(
    GuideTrip trip,
    GuideTripDetails details,
    String guideId,
  ) {
    return {
      'id': trip.id,
      'tripId': trip.id,
      'guideId': guideId,
      'title': trip.title,
      'location': trip.location,
      'approvalStatus': trip.approval.name,
      'rejectionReason': trip.rejectionReason ?? '',
      'scheduleLabel': trip.scheduleLabel,
      'startAt': trip.startAt == null
          ? null
          : Timestamp.fromDate(trip.startAt!),
      'duration': trip.duration,
      'priceEgp': trip.priceEgp,
      'capacity': trip.capacity,
      'bookedSeats': trip.bookedSeats,
      'phone': trip.phone,
      'imageUrl': trip.imageUrl,
      'coverUrl': trip.coverUrl,
      'tag': details.tag,
      'rating': details.rating,
      'reviewsCount': details.reviewsCount,
      'groupType': details.groupType,
      'languages': details.languages,
      'about': details.about,
      'highlights': details.highlights,
      'itinerary': details.itinerary.map((e) => e.toJson()).toList(),
      'notes': details.notes,
      'included': details.included,
      'meetingPoint': details.meetingPoint,
      'guideName': details.guideName,
      'guideAvatarUrl': details.guideAvatarUrl,
      'guideRating': details.guideRating,
      'guideReviews': details.guideReviews,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Reads a trip document, tolerating missing fields.
  GuideTrip _toTrip(Map<String, dynamic>? data, String id) {
    try {
      final merged = <String, dynamic>{
        'id': id,
        'title': '',
        'location': '',
        'scheduleLabel': '',
        'priceEgp': 0,
        'imageUrl': '',
        'approvalStatus': GuideTripApproval.pending.name,
        ...?data,
      };
      merged['id'] = id;
      final trip = GuideTrip.fromJson(merged);
      // Cache the details so the details/manage screens can read them
      // synchronously, exactly like the session cache used to.
      GuideTripDetailsSource.save(_toDetails(data, id));
      return trip;
    } catch (e) {
      final nulls = data?.entries
          .where((entry) => entry.value == null)
          .map((entry) => entry.key)
          .toList();
      debugPrint('GuideTripsRepository._toTrip($id) failed: $e');
      debugPrint('  null fields: $nulls');
      rethrow;
    }
  }

  /// Reads the details part of a trip document, tolerating missing fields.
  GuideTripDetails _toDetails(Map<String, dynamic>? data, String tripId) {
    final merged = <String, dynamic>{
      'id': 'details-$tripId',
      'tripId': tripId,
      'tag': '',
      'title': '',
      'rating': 0.0,
      'reviewsCount': 0,
      'location': '',
      'duration': '',
      'groupType': '',
      'languages': '',
      'about': '',
      'highlights': <String>[],
      'itinerary': <Map<String, dynamic>>[],
      'notes': <String>[],
      'included': '',
      'meetingPoint': '',
      'priceEgp': 0,
      'guideName': '',
      'guideAvatarUrl': '',
      'guideRating': 0.0,
      'guideReviews': 0,
      'imageUrl': '',
      ...?data,
    };
    merged['id'] = 'details-$tripId';
    merged['tripId'] = tripId;
    merged['imageUrl'] = data?['coverUrl'] ?? data?['imageUrl'] ?? '';
    return GuideTripDetails.fromJson(merged);
  }

  /// The mock trips, with their details cached for the details screens.
  List<GuideTrip> _mockTrips() {
    for (final details in mockGuideTripDetailsJson) {
      GuideTripDetailsSource.save(GuideTripDetails.fromJson(details));
    }
    return mockGuideTripsJson
        .map((e) => GuideTrip.fromJson(e))
        .toList(growable: false);
  }

  /// Merges the Firestore list with the session cache, so a trip that was
  /// just created shows up before the write round-trips.
  List<GuideTrip> _merge(List<GuideTrip> remote) {
    final byId = <String, GuideTrip>{
      for (final trip in GuideTripsStore.applyUpdates(remote)) trip.id: trip,
    };
    for (final trip in GuideTripsStore.created) {
      byId.putIfAbsent(trip.id, () => trip);
    }
    return byId.values.toList();
  }
}
