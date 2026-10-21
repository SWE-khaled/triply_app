import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/data/mock/tourguide/mock_guide_trip_details.dart';
import 'package:triply/core/data/mock/tourguide/mock_guide_trips.dart';
import 'package:triply/core/data/repositories/guide_trips_repository.dart';
import 'package:triply/features/tour_guide/my_trips_tg/model/guide_trip.dart';
import 'package:triply/features/tour_guide/trip_details_tg/model/guide_trip_details.dart';

/// The repository mapping is what makes a Firestore document readable by
/// the models — and what makes the mock dataset seedable. These tests pin
/// that round-trip down.
void main() {
  final repository = GuideTripsRepository();

  GuideTrip tripOf(String tripId) =>
      GuideTrip.fromJson(mockGuideTripById(tripId)!);

  GuideTripDetails detailsOf(String tripId) =>
      GuideTripDetails.fromJson(mockGuideTripDetailsById(tripId)!);

  group('trip document', () {
    test('carries the owner and the approval state the model expects', () {
      final doc = repository.toTripDoc(tripOf('g1'), detailsOf('g1'), 'uid-1');

      expect(doc['guideId'], 'uid-1');
      expect(doc['id'], 'g1');
      expect(doc['tripId'], 'g1');
      expect(doc['approvalStatus'], 'approved');
      expect(doc['title'], 'Pyramids Sunset Tour');
      expect(doc['capacity'], 12);
    });

    test('stores the start moment as a Firestore timestamp', () {
      final doc = repository.toTripDoc(tripOf('g1'), detailsOf('g1'), 'uid-1');

      expect(doc['startAt'], isA<Timestamp>());
      final startAt = (doc['startAt'] as Timestamp).toDate();
      expect(startAt.hour, 17);
      expect(startAt.minute, 0);
    });

    test('a document reads back into the very same trip', () {
      final trip = tripOf('g2');
      final doc = repository.toTripDoc(trip, detailsOf('g2'), 'uid-1');

      final restored = GuideTrip.fromJson({...doc, 'id': 'g2'});

      expect(restored.id, trip.id);
      expect(restored.title, trip.title);
      expect(restored.location, trip.location);
      expect(restored.scheduleLabel, trip.scheduleLabel);
      expect(restored.priceEgp, trip.priceEgp);
      expect(restored.imageUrl, trip.imageUrl);
      expect(restored.coverUrl, trip.coverUrl);
      expect(restored.approval, trip.approval);
      expect(restored.phone, trip.phone);
      expect(restored.duration, trip.duration);
      expect(restored.bookedSeats, trip.bookedSeats);
      expect(restored.capacity, trip.capacity);
      expect(restored.approval, trip.approval);
      expect(restored.startAt, trip.startAt);
    });

    test('a document reads back into the very same details', () {
      final details = detailsOf('g3');
      final doc = repository.toTripDoc(tripOf('g3'), details, 'uid-1');

      // The details read the wide cover, not the card image.
      final restored = GuideTripDetails.fromJson({
        ...doc,
        'id': 'details-g3',
        'tripId': 'g3',
        'imageUrl': doc['coverUrl'],
      });

      expect(restored.id, 'details-g3');
      expect(restored.tripId, 'g3');
      expect(restored.title, details.title);
      expect(restored.about, details.about);
      expect(restored.highlights, details.highlights);
      expect(restored.notes, details.notes);
      expect(restored.included, details.included);
      expect(restored.meetingPoint, details.meetingPoint);
      expect(restored.priceEgp, details.priceEgp);
      expect(
        restored.itinerary.map((e) => e.toJson()).toList(),
        details.itinerary.map((e) => e.toJson()).toList(),
      );
    });

    test('every mock trip can be written and read back', () {
      for (final rawTrip in mockGuideTripsJson) {
        final tripId = rawTrip['id'] as String;
        final trip = GuideTrip.fromJson(rawTrip);
        final details = detailsOf(tripId);
        final doc = repository.toTripDoc(trip, details, 'uid-1');
        final restored = GuideTrip.fromJson({...doc, 'id': tripId});

        expect(restored.title, trip.title);
        expect(restored.approval, trip.approval);
        expect(restored.startAt, trip.startAt);
      }
    });
  });

  group('model', () {
    test('reads the start moment from a timestamp, an ISO string or null', () {
      final moment = DateTime(2026, 10, 20, 17);

      expect(
        GuideTrip.fromJson({
          ...mockGuideTripById('g1')!,
          'startAt': Timestamp.fromDate(moment),
        }).startAt,
        moment,
      );
      expect(
        GuideTrip.fromJson({
          ...mockGuideTripById('g1')!,
          'startAt': moment.toIso8601String(),
        }).startAt,
        moment,
      );
      expect(
        GuideTrip.fromJson({
          ...mockGuideTripById('g1')!,
          'startAt': null,
        }).startAt,
        isNull,
      );
    });

    test('falls back to the card image when there is no cover', () {
      final trip = GuideTrip.fromJson({
        ...mockGuideTripById('g1')!,
        'coverUrl': null,
      });

      expect(trip.coverUrl, trip.imageUrl);
    });
  });
}
