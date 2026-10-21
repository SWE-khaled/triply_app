import '../../../features/tourist/trip_details/model/trip_details.dart';
import '../../../features/tourist/trips/models/trip.dart';
import '../remote/firestore_service.dart';

/// The trips the tourists browse.
///
/// A trip becomes visible here only after the admin approved it — the
/// rules enforce the same thing, so the query can never return a trip
/// that is still pending or rejected.
///
/// The mock dataset stays the fallback: when the read fails (offline, no
/// permission) the screens keep showing the bundled trips instead of an
/// empty page.
class PublicTripsRepository {
  PublicTripsRepository({FirestoreService? firestore})
    : _firestore = firestore ?? FirestoreService();

  /// The Firestore collection holding the trips.
  static const String tripsCollection = 'trips';

  /// The approval state that makes a trip visible to the tourists.
  static const String approvedStatus = 'approved';

  final FirestoreService _firestore;

  /// The approved trips, the closest date first.
  ///
  /// Returns null when the read failed (offline, no permission) — that
  /// is the caller's cue to fall back to the mock dataset. An empty list
  /// means the read worked and no trip is approved yet.
  Future<List<Trip>?> fetchApprovedTrips() async {
    try {
      final snapshot = await _firestore
          .collection(tripsCollection)
          .where('approvalStatus', isEqualTo: approvedStatus)
          .get();
      final trips = snapshot.docs
          .map((doc) => _toTrip(doc.data(), doc.id))
          .toList();
      trips.sort((a, b) => a.id.compareTo(b.id));
      return trips;
    } catch (_) {
      return null;
    }
  }

  /// The approved trips of one guide.
  ///
  /// Returns null when the read failed.
  Future<List<Trip>?> fetchGuideTrips(String guideId) async {
    if (guideId.isEmpty) return const [];
    try {
      final snapshot = await _firestore
          .collection(tripsCollection)
          .where('approvalStatus', isEqualTo: approvedStatus)
          .where('guideId', isEqualTo: guideId)
          .get();
      return snapshot.docs.map((doc) => _toTrip(doc.data(), doc.id)).toList();
    } catch (_) {
      return null;
    }
  }

  /// The full details of one trip, or null when it is gone.
  Future<TripDetails?> fetchTripDetails(String tripId) async {
    try {
      final data = await _firestore.readDoc(tripsCollection, tripId);
      if (data == null) return null;
      return _toTripDetails(data, tripId);
    } catch (_) {
      return null;
    }
  }

  /// Reads a trip document into the model the tourist screens use.
  Trip _toTrip(Map<String, dynamic>? data, String id) {
    final merged = <String, dynamic>{
      'id': id,
      'title': '',
      'dateLabel': '',
      'guideName': '',
      'peopleCount': 0,
      'priceEgp': 0,
      'imageUrl': '',
      'status': 'upcoming',
      'category': 'historical',
      'capacity': 0,
      ...?data,
    };
    merged['id'] = id;
    // The trip document stores the moment and the label of the schedule
    // separately — the tourist card shows the label.
    merged['dateLabel'] =
        (data?['scheduleLabel'] as String?) ?? (merged['dateLabel'] as String);
    merged['guideName'] = (data?['guideName'] as String?) ?? '';
    merged['peopleCount'] = ((data?['bookedSeats'] as num?) ?? 0).toInt();
    merged['priceEgp'] = ((data?['priceEgp'] as num?) ?? 0).toDouble();
    merged['imageUrl'] = (data?['imageUrl'] as String?) ?? '';
    merged['capacity'] = ((data?['capacity'] as num?) ?? 0).toInt();
    merged['category'] = _categoryOf(data?['tag'] as String?);
    merged['status'] = 'upcoming';
    return Trip.fromJson(merged);
  }

  /// Reads a trip document into the details model.
  TripDetails _toTripDetails(Map<String, dynamic>? data, String id) {
    final merged = <String, dynamic>{
      'id': id,
      'tripId': id,
      'tag': '',
      'title': '',
      'rating': 0.0,
      'reviewsCount': 0,
      'location': '',
      'duration': '',
      'groupType': '',
      'languages': '',
      'about': '',
      'highlights': const <String>[],
      'itinerary': const <Map<String, dynamic>>[],
      'notes': const <String>[],
      'meetingPoint': '',
      'priceEgp': 0.0,
      'guideName': '',
      'guideAvatarUrl': '',
      'guideRating': 0.0,
      'guideReviews': 0,
      'topRatedGuide': false,
      'imageUrl': '',
      ...?data,
    };
    merged['id'] = id;
    merged['tripId'] = id;
    merged['rating'] = ((data?['rating'] as num?) ?? 0).toDouble();
    merged['reviewsCount'] = ((data?['reviewsCount'] as num?) ?? 0).toInt();
    merged['priceEgp'] = ((data?['priceEgp'] as num?) ?? 0).toDouble();
    merged['guideRating'] = ((data?['guideRating'] as num?) ?? 0).toDouble();
    merged['guideReviews'] = ((data?['guideReviews'] as num?) ?? 0).toInt();
    merged['duration'] = (data?['duration'] as String?) ?? '';
    merged['groupType'] = (data?['groupType'] as String?) ?? '';
    merged['languages'] = (data?['languages'] as String?) ?? '';
    merged['about'] = (data?['about'] as String?) ?? '';
    merged['meetingPoint'] = (data?['meetingPoint'] as String?) ?? '';
    merged['tag'] = (data?['tag'] as String?) ?? '';
    merged['location'] = (data?['location'] as String?) ?? '';
    merged['imageUrl'] = (data?['imageUrl'] as String?) ?? '';
    merged['guideName'] = (data?['guideName'] as String?) ?? '';
    merged['guideAvatarUrl'] = (data?['guideAvatarUrl'] as String?) ?? '';
    merged['highlights'] = _stringList(data?['highlights']);
    merged['notes'] = _stringList(data?['notes']);
    merged['itinerary'] = _itinerary(data?['itinerary']);
    // A guide with a high rating is the one the tourist screen flags.
    final guideRating = merged['guideRating'] as double;
    merged['topRatedGuide'] = guideRating >= 4.8;
    return TripDetails.fromJson(merged);
  }

  List<String> _stringList(Object? raw) {
    if (raw is! List) return const [];
    return raw.map((e) => e.toString()).toList();
  }

  List<Map<String, dynamic>> _itinerary(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map(
          (e) => {
            'time': e['time']?.toString() ?? '',
            'title': e['title']?.toString() ?? '',
          },
        )
        .toList();
  }

  /// Maps the free-text tag of a trip onto the categories the tourist
  /// screens filter by.
  String _categoryOf(String? tag) {
    final text = (tag ?? '').toLowerCase();
    if (text.contains('activit') ||
        text.contains('adventure') ||
        text.contains('sport') ||
        text.contains('water')) {
      return 'activities';
    }
    if (text.contains('natur') ||
        text.contains('desert') ||
        text.contains('mountain') ||
        text.contains('camel')) {
      return 'nature';
    }
    if (text.contains('food') ||
        text.contains('culinary') ||
        text.contains('restaurant') ||
        text.contains('cook')) {
      return 'food';
    }
    return 'historical';
  }
}
