import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/data/models/public_guide.dart';
import 'package:triply/core/data/models/public_trip.dart';
import 'package:triply/core/data/models/tourist_booking.dart';
import 'package:triply/features/tourist/guides/model/guide.dart';
import 'package:triply/features/tourist/guides/model/trip.dart' as guide_trip;
import 'package:triply/features/tourist/home/model/guide.dart' as home_guide;
import 'package:triply/features/tourist/home/model/trip.dart' as home_trip;
import 'package:triply/features/tourist/trip_details/model/trip_details.dart';
import 'package:triply/features/tourist/trips/models/trip.dart' as trips_model;

/// The tourist screens read one neutral model and convert it into their
/// own card model. These tests lock that conversion down.
void main() {
  group('a trip document becomes the neutral model', () {
    test('every field of the document is read', () {
      final trip = PublicTrip.fromDocument({
        'guideId': 'guide-1',
        'title': 'Pyramids at Dawn',
        'location': 'Giza',
        'scheduleLabel': 'Oct 15, 2026 · 6:00 AM',
        'duration': '4 hours',
        'imageUrl': 'https://example.com/pyramids.png',
        'guideName': 'Nour Abdallah',
        'guideAvatarUrl': 'https://example.com/guide.png',
        'tag': 'Historical',
        'priceEgp': 6000,
        'capacity': 12,
        'bookedSeats': 3,
        'rating': 4.9,
        'reviewsCount': 128,
        'groupType': 'Private',
        'languages': 'Arabic, English',
        'about': 'A morning in Giza.',
        'highlights': ['The Sphinx', 'Solar Boat Museum'],
        'itinerary': [
          {'time': '6:00 AM', 'title': 'Meet at the hotel'},
        ],
        'notes': ['Bring water'],
        'meetingPoint': 'Hotel lobby',
        'guideRating': 4.9,
        'guideReviews': 40,
      }, 'trip-1');

      expect(trip.id, 'trip-1');
      expect(trip.guideId, 'guide-1');
      expect(trip.title, 'Pyramids at Dawn');
      expect(trip.location, 'Giza');
      expect(trip.dateLabel, 'Oct 15, 2026 · 6:00 AM');
      expect(trip.durationLabel, '4 hours');
      expect(trip.guideName, 'Nour Abdallah');
      expect(trip.tag, 'Historical');
      expect(trip.priceEgp, 6000);
      expect(trip.capacity, 12);
      expect(trip.bookedSeats, 3);
      expect(trip.availableSeats, 9);
      expect(trip.highlights, ['The Sphinx', 'Solar Boat Museum']);
      expect(trip.itinerary.single.title, 'Meet at the hotel');
      expect(trip.notes, ['Bring water']);
      expect(trip.meetingPoint, 'Hotel lobby');
    });

    test('a missing field never breaks the read', () {
      final trip = PublicTrip.fromDocument({'title': 'Only a title'}, 't');

      expect(trip.id, 't');
      expect(trip.title, 'Only a title');
      expect(trip.guideId, '');
      expect(trip.priceEgp, 0);
      expect(trip.capacity, 0);
      expect(trip.highlights, isEmpty);
      expect(trip.itinerary, isEmpty);
    });

    test('the tag becomes one of the categories of the screens', () {
      PublicTrip withTag(String tag) =>
          PublicTrip.fromDocument({'tag': tag}, 't');

      expect(withTag('Historical').category, 'historical');
      expect(withTag('Food Tour').category, 'food');
      expect(withTag('NATURE').category, 'nature');
      expect(withTag('Water Activities').category, 'activities');
      // Anything the guide made up falls back to the default.
      expect(withTag('Something else').category, 'historical');
      expect(withTag('').category, 'historical');
    });
  });

  group('the neutral model becomes the card of every screen', () {
    final trip = PublicTrip.fromDocument({
      'guideId': 'guide-1',
      'title': 'Nile Felucca',
      'location': 'Aswan',
      'scheduleLabel': 'Oct 22, 2026 · 3:00 PM',
      'duration': '5 hours',
      'imageUrl': 'https://example.com/nile.png',
      'guideName': 'Nour Abdallah',
      'tag': 'Activities',
      'priceEgp': 4750,
      'capacity': 12,
      'bookedSeats': 2,
    }, 'trip-2');

    test('the popular card shows the booked seats', () {
      final card = trips_model.Trip.fromPublicTrip(trip);

      expect(card.id, 'trip-2');
      expect(card.title, 'Nile Felucca');
      expect(card.dateLabel, 'Oct 22, 2026 · 3:00 PM');
      expect(card.guideName, 'Nour Abdallah');
      expect(card.peopleCount, 2);
      expect(card.priceEgp, 4750);
      expect(card.category, 'activities');
      expect(card.capacity, 12);
    });

    test('the home card shows the location and the duration', () {
      final card = home_trip.Trip.fromPublicTrip(trip);

      expect(card.id, 'trip-2');
      expect(card.title, 'Nile Felucca');
      expect(card.location, 'Aswan');
      expect(card.duration, '5 hours');
      expect(card.price, 4750);
      expect(card.dateLabel, 'Oct 22, 2026 · 3:00 PM');
      expect(card.guideName, 'Nour Abdallah');
    });

    test('the guide card keeps the owner of the trip', () {
      final card = guide_trip.Trip.fromPublicTrip(trip);

      expect(card.id, 'trip-2');
      expect(card.guideId, 'guide-1');
      expect(card.price, 4750);
      expect(card.currency, 'EGP');
    });

    test('the details screen keeps every long field', () {
      final details = TripDetails.fromPublicTrip(trip);

      expect(details.tripId, 'trip-2');
      expect(details.title, 'Nile Felucca');
      expect(details.location, 'Aswan');
      expect(details.duration, '5 hours');
      expect(details.priceEgp, 4750);
      expect(details.guideName, 'Nour Abdallah');
    });
  });

  group('a guide document becomes the public guide', () {
    test('every field of the document is read', () {
      final guide = PublicGuide.fromDocument({
        'name': 'Omar El-Rashidy',
        'specialty': 'Historical Guide',
        'avatarUrl': 'https://example.com/omar.png',
        'location': 'Giza',
        'about': 'Ten years of the pyramids.',
        'languages': ['Arabic', 'English'],
        'rating': 4.8,
        'reviewCount': 120,
        'pricePerHour': 75,
        'currency': 'EGP',
        'isApproved': true,
      }, 'guide-1');

      expect(guide.id, 'guide-1');
      expect(guide.name, 'Omar El-Rashidy');
      expect(guide.languages, ['Arabic', 'English']);
      expect(guide.pricePerHour, 75);
      expect(guide.isApproved, isTrue);
    });

    test('a missing field never breaks the read', () {
      final guide = PublicGuide.fromDocument(null, 'guide-1');

      expect(guide.id, 'guide-1');
      expect(guide.name, '');
      expect(guide.isApproved, isFalse);
      expect(guide.languages, isEmpty);
    });

    test('the list card shows the approval as the verification', () {
      final card = Guide.fromPublicGuide(
        PublicGuide.fromDocument({'name': 'Aya', 'isApproved': true}, 'g-1'),
      );

      expect(card.id, 'g-1');
      expect(card.name, 'Aya');
      expect(card.isVerified, isTrue);
    });

    test('the home card shows the guide of the list', () {
      final card = home_guide.Guide.fromPublicGuide(
        PublicGuide.fromDocument({'name': 'Aya', 'pricePerHour': 75}, 'g-1'),
      );

      expect(card.id, 'g-1');
      expect(card.name, 'Aya');
      expect(card.pricePerHour, 75);
    });
  });

  group('a booking document becomes the booking of the tourist', () {
    test('every field of the document is read', () {
      final booking = TouristBooking.fromDocument({
        'tripId': 'trip-2',
        'tour_title': 'Nile Felucca',
        'seats': 3,
        'totalPrice': 14962.5,
        'status': 'pending',
      }, 'booking-1');

      expect(booking.id, 'booking-1');
      expect(booking.tripId, 'trip-2');
      expect(booking.tourTitle, 'Nile Felucca');
      expect(booking.seats, 3);
      expect(booking.totalPrice, 14962.5);
      expect(booking.status, 'pending');
    });

    test('the seat count falls back to the traveler count', () {
      final booking = TouristBooking.fromDocument({
        'traveler_count': 2,
      }, 'booking-2');

      expect(booking.seats, 2);
    });

    test('a missing field never breaks the read', () {
      final booking = TouristBooking.fromDocument(null, 'booking-3');

      expect(booking.id, 'booking-3');
      expect(booking.tripId, '');
      expect(booking.seats, 0);
      expect(booking.totalPrice, 0);
    });
  });
}
