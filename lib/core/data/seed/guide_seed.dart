import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../features/tour_guide/my_trips_tg/model/guide_trip.dart';
import '../../../features/tour_guide/trip_details_tg/model/guide_trip_details.dart';
import '../mock/tourguide/mock_guide_notifications.dart';
import '../mock/tourguide/mock_guide_trip_details.dart';
import '../mock/tourguide/mock_guide_trips.dart';
import '../remote/firestore_service.dart';
import '../repositories/guide_notifications_repository.dart';
import '../repositories/guide_trips_repository.dart';

/// What a seeding run wrote.
class GuideSeedResult {
  /// The trips that were written.
  final int trips;

  /// The notifications that were written.
  final int notifications;

  const GuideSeedResult({required this.trips, required this.notifications});
}

/// Copies the mock tour-guide dataset into Firestore for the signed-in
/// guide.
///
/// After seeding, the app shows real, persistent data instead of the
/// mock fallback. Safe to run more than once — the documents are
/// overwritten, never duplicated.
///
/// The trips are published as `pending`, exactly like a trip the guide
/// creates from the app: the rules only let the admin dashboard approve
/// a trip, never its author. Approve them from the admin dashboard to
/// fill the other tabs.
class GuideSeed {
  GuideSeed({GuideTripsRepository? trips, FirestoreService? firestore})
    : _trips = trips ?? GuideTripsRepository(),
      _firestore = firestore ?? FirestoreService();

  final GuideTripsRepository _trips;
  final FirestoreService _firestore;

  /// Seeds the trips and the notifications of the mock dataset.
  Future<GuideSeedResult> run() async {
    final guideId = _trips.currentGuideId;
    if (guideId == null) {
      throw StateError('Sign in before seeding the guide data.');
    }
    final trips = await seedTrips(guideId);
    final notifications = await seedNotifications(guideId);
    return GuideSeedResult(trips: trips, notifications: notifications);
  }

  /// Seeds the mock trips (and their details) for [guideId].
  ///
  /// A trip that does not exist yet is published as `pending` — the rules
  /// only let the admin dashboard approve a trip. A trip that already
  /// exists keeps its approval state, so re-running the seed never
  /// fights the rules.
  Future<int> seedTrips(String guideId) async {
    var count = 0;
    for (final raw in mockGuideTripDetailsJson) {
      final tripId = raw['tripId'] as String;
      final rawTrip = mockGuideTripById(tripId);
      if (rawTrip == null) continue;
      final trip = GuideTrip.fromJson(rawTrip);
      final details = GuideTripDetails.fromJson(raw);
      final approval = await _approvalOf(tripId);
      final published = GuideTrip(
        id: trip.id,
        title: trip.title,
        location: trip.location,
        scheduleLabel: trip.scheduleLabel,
        priceEgp: trip.priceEgp,
        imageUrl: trip.imageUrl,
        approval: approval,
        capacity: trip.capacity,
        bookedSeats: 0,
        phone: trip.phone,
        duration: trip.duration,
        startAt: trip.startAt,
        coverUrl: trip.coverUrl,
      );
      await _firestore.writeDoc(
        GuideTripsRepository.tripsCollection,
        tripId,
        _trips.toTripDoc(published, details, guideId),
        merge: true,
      );
      count++;
    }
    return count;
  }

  /// The approval state a trip already has, or [pending] for a new one.
  Future<GuideTripApproval> _approvalOf(String tripId) async {
    try {
      final data = await _firestore.readDoc(
        GuideTripsRepository.tripsCollection,
        tripId,
      );
      final name = data?['approvalStatus'] as String?;
      return GuideTripApproval.values.firstWhere(
        (e) => e.name == name,
        orElse: () => GuideTripApproval.pending,
      );
    } catch (_) {
      return GuideTripApproval.pending;
    }
  }

  /// Seeds the mock notifications for [guideId].
  Future<int> seedNotifications(String guideId) async {
    var count = 0;
    for (final raw in mockGuideNotificationsRaw) {
      await _firestore.writeDoc(
        GuideNotificationsRepository.notificationsCollection,
        raw['id'] as String,
        {
          'userId': guideId,
          'title': raw['title'],
          'message': raw['message'],
          'type': raw['type'],
          'relatedEntityId': raw['relatedEntityId'],
          'relatedCollection': raw['relatedCollection'],
          'isRead': raw['isRead'],
          'createdAt': Timestamp.fromDate(
            DateTime.parse(raw['createdAt'] as String),
          ),
        },
        merge: false,
      );
      count++;
    }
    return count;
  }
}
