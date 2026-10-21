import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/data/mock/tourguide/mock_booking_details.dart';
import 'package:triply/core/data/mock/tourguide/mock_earnings.dart';
import 'package:triply/core/data/mock/tourguide/mock_guide_dashboard.dart';
import 'package:triply/core/data/mock/tourguide/mock_guide_notifications.dart';
import 'package:triply/core/data/mock/tourguide/mock_guide_profile.dart';
import 'package:triply/core/data/mock/tourguide/mock_guide_trip_details.dart';
import 'package:triply/core/data/mock/tourguide/mock_guide_trips.dart';
import 'package:triply/core/data/mock/tourguide/mock_travelers.dart';
import 'package:triply/features/tour_guide/my_trips_tg/model/guide_trip.dart';

/// Guards the relations of the tour-guide mock dataset: every record
/// must point at a record that exists, and shared fields must be derived
/// from a single source so the dataset can never contradict itself.
void main() {
  group('trips', () {
    test('every trip belongs to the same guide', () {
      expect(mockGuideTripsJson, isNotEmpty);
      expect(mockGuideTripsJson.map((t) => t['guideId']).toSet(), {
        mockGuideId,
      });
    });

    test('every trip carries a start timestamp and a matching label', () {
      for (final trip in mockGuideTripsJson) {
        expect(trip['startAt'], isA<String>());
        expect(trip['scheduleLabel'], isA<String>());
        expect(
          DateTime.parse(
            trip['startAt'] as String,
          ).isBefore(DateTime.now().add(const Duration(days: 400))),
          isTrue,
        );
      }
    });
  });

  group('trip details', () {
    test('one details record per trip', () {
      expect(mockGuideTripDetailsJson.length, mockGuideTripsJson.length);
      for (final trip in mockGuideTripsJson) {
        expect(
          mockGuideTripDetailsById(trip['id'] as String),
          isNotNull,
          reason: 'trip ${trip['id']} has no details',
        );
      }
    });

    test('details copy the shared fields from their trip', () {
      for (final details in mockGuideTripDetailsJson) {
        final trip = mockGuideTripById(details['tripId'] as String)!;
        expect(details['title'], trip['title']);
        expect(details['location'], trip['location']);
        expect(details['duration'], trip['duration']);
        expect(details['priceEgp'], trip['priceEgp']);
      }
    });

    test('details name the one guide of the dataset', () {
      for (final details in mockGuideTripDetailsJson) {
        expect(details['guideName'], mockGuideProfileJson['name']);
        expect(details['guideAvatarUrl'], mockGuideProfileJson['avatarUrl']);
        expect(details['guideRating'], mockGuideProfileJson['rating']);
      }
    });
  });

  group('bookings', () {
    test('every booking points at an existing trip', () {
      for (final booking in mockBookingDetailsRaw) {
        expect(mockGuideTripById(booking['tripId'] as String), isNotNull);
        expect(
          mockGuideTripDetailsById(booking['tripId'] as String),
          isNotNull,
          reason: 'booking ${booking['id']} books a trip without details',
        );
      }
    });

    test('booking title, meeting point and total come from its trip', () {
      for (final booking in mockBookingDetailsRaw) {
        final trip = mockGuideTripById(booking['tripId'] as String)!;
        final details = mockGuideTripDetailsById(booking['tripId'] as String)!;
        final count = (booking['traveler_count'] as num).toInt();

        expect(booking['tour_title'], trip['title']);
        expect(booking['location'], details['meetingPoint']);
        expect(booking['totalPrice'], (trip['priceEgp'] as num) * count);
        expect(booking['price_label'], startsWith('EGP '));
      }
    });

    test('every booking points at an existing traveler', () {
      for (final booking in mockBookingDetailsRaw) {
        expect(
          mockTravelersJson.any((t) => t['id'] == booking['touristId']),
          isTrue,
          reason: 'booking ${booking['id']} has no lead traveler',
        );
      }
    });

    test('the booked seats of a trip equal the travelers it carries', () {
      for (final trip in mockGuideTripsJson) {
        final tripId = trip['id'];
        final booked = mockBookingDetailsRaw
            .where((b) => b['tripId'] == tripId)
            .fold<int>(
              0,
              (sum, b) => sum + (b['traveler_count'] as num).toInt(),
            );
        expect(
          trip['bookedSeats'],
          booked,
          reason: 'trip $tripId claims a different number of booked seats',
        );
        expect(
          (trip['bookedSeats'] as num).toInt(),
          lessThanOrEqualTo((trip['capacity'] as num).toInt()),
          reason: 'trip $tripId is overbooked',
        );
      }
    });
  });

  group('travelers', () {
    test('every traveler inherits trip and group size from its booking', () {
      for (final traveler in mockTravelersJson) {
        final booking = mockBookingById(traveler['bookingId'] as String)!;
        final count = (booking['traveler_count'] as num).toInt();

        expect(traveler['tripId'], booking['tripId']);
        expect(
          traveler['seatsLabel'],
          '$count ${count == 1 ? 'traveler' : 'travelers'}',
        );
      }
    });

    test('every booking has one traveler row per traveler', () {
      for (final booking in mockBookingDetailsRaw) {
        final count = (booking['traveler_count'] as num).toInt();
        final rows = mockTravelersJson
            .where((t) => t['bookingId'] == booking['id'])
            .length;
        expect(
          rows,
          count,
          reason:
              'booking ${booking['id']} carries $count travelers but has $rows rows',
        );
      }
    });
  });

  group('dashboard', () {
    test('counters agree with the trips and bookings they summarize', () {
      int tripsWith(GuideTripStatus tab) => mockGuideTripsCountForTab(tab);

      expect(
        mockGuideDashboardRaw['total_bookings'],
        mockBookingDetailsRaw.length,
      );
      expect(
        mockGuideDashboardRaw['active_trips'],
        tripsWith(GuideTripStatus.active),
      );
      expect(
        mockGuideDashboardRaw['completed_trips'],
        tripsWith(GuideTripStatus.completed),
      );
      expect(
        mockGuideDashboardRaw['pending_requests'],
        tripsWith(GuideTripStatus.pending),
      );
      expect(
        mockGuideDashboardRaw['upcoming_trips'],
        tripsWith(GuideTripStatus.active) + tripsWith(GuideTripStatus.pending),
      );

      // The absolute numbers of this dataset, so a broken counter is
      // caught even when it is "consistent" with a wrong derivation.
      // Only the time-independent ones: a trip scheduled for *today* turns
      // from active to completed once its start time passes, so the
      // active/completed/upcoming counts depend on when the suite runs.
      expect(mockGuideDashboardRaw['total_bookings'], 3);
      expect(mockGuideDashboardRaw['pending_requests'], 1);
    });

    test('the dashboard names the one guide of the dataset', () {
      expect(mockGuideDashboardRaw['guide_name'], mockGuideProfileJson['name']);
      expect(
        mockGuideDashboardRaw['avatar_url'],
        mockGuideProfileJson['avatarUrl'],
      );
    });

    test('booking requests mirror the booking records', () {
      expect(mockBookingRequestsRaw.length, mockBookingDetailsRaw.length);
      for (var i = 0; i < mockBookingRequestsRaw.length; i++) {
        final request = mockBookingRequestsRaw[i];
        final booking = mockBookingDetailsRaw[i];
        expect(request['id'], booking['id']);
        expect(request['guest_name'], booking['guest_name']);
        expect(request['tour_title'], booking['tour_title']);
        expect(request['detail_label'], booking['detail_label']);
        expect(request['is_private'], booking['is_private']);
      }
    });
  });

  group('earnings', () {
    test('balance equals the sum of the listed activities', () {
      final activities = mockEarningsJson['activities'] as List;
      final sum = activities.fold<double>(
        0,
        (total, a) => total + ((a as Map)['amountEgp'] as num).toDouble(),
      );
      expect(mockEarningsJson['availableBalance'], sum);
    });

    test('activities are the guide bookings', () {
      final activities = mockEarningsJson['activities'] as List;
      expect(activities.length, mockBookingDetailsRaw.length);
      for (var i = 0; i < activities.length; i++) {
        expect(
          (activities[i] as Map)['bookingId'],
          mockBookingDetailsRaw[i]['id'],
        );
        expect(
          (activities[i] as Map)['title'],
          mockBookingDetailsRaw[i]['tour_title'],
        );
      }
    });
  });

  group('notifications', () {
    test('every notification points at an existing record', () {
      for (final notification in mockGuideNotificationsRaw) {
        final refId = notification['relatedEntityId'] as String;
        expect(
          mockBookingById(refId) != null || mockGuideTripById(refId) != null,
          isTrue,
          reason: 'notification ${notification['id']} points at nothing',
        );
      }
    });
  });
}
