import '../../../../features/tour_guide/my_trips_tg/model/guide_trip.dart';
import 'mock_guide_profile.dart';
import 'mock_guide_shared.dart';

/// Raw mock source for the trips owned by the signed-in guide.
/// Convert via GuideTrip.fromJson() before the UI.
///
/// Records carry their owner (`guideId`), the admin approval state
/// (`approvalStatus`) and the seating (`capacity` / `bookedSeats`). The
/// readable `scheduleLabel` is derived from the `startAt` timestamp by
/// [mockScheduleLabel], so the two can never drift apart.
///
/// `approvalStatus` is the workflow field: a guide publishes a trip as
/// `pending` and only the admin moves it to `approved` or `rejected`.

final List<Map<String, dynamic>> mockGuideTripsJson = [
  {
    'id': 'g1',
    'guideId': mockGuideId,
    'title': 'Pyramids Sunset Tour',
    'location': 'Giza',
    'startAt': mockIso(mockAt(0, 17, 0)),
    'scheduleLabel': mockScheduleLabel(mockAt(0, 17, 0)),
    'duration': '4 hours',
    'priceEgp': 1650,
    'capacity': 12,
    'bookedSeats': 3,
    'phone': '+20 100 123 4567',
    'imageUrl': 'https://picsum.photos/seed/sunset/300/400',
    'coverUrl': 'https://picsum.photos/seed/sunset/800/600',
    'approvalStatus': 'approved',
    'createdAt': mockIso(mockAt(-9, 11, 0)),
  },
  {
    'id': 'g2',
    'guideId': mockGuideId,
    'title': 'Cairo Old Town Experience',
    'location': 'Old Cairo',
    'startAt': mockIso(mockAt(1, 10, 0)),
    'scheduleLabel': mockScheduleLabel(mockAt(1, 10, 0)),
    'duration': '3 hours',
    'priceEgp': 1250,
    'capacity': 10,
    'bookedSeats': 3,
    'phone': '+20 100 123 4567',
    'imageUrl': 'https://picsum.photos/seed/oldtown/300/400',
    'coverUrl': 'https://picsum.photos/seed/oldtown/800/600',
    'approvalStatus': 'approved',
    'createdAt': mockIso(mockAt(-12, 9, 30)),
  },
  {
    'id': 'g3',
    'guideId': mockGuideId,
    'title': 'Siwa Oasis Adventure',
    'location': 'Siwa',
    'startAt': mockIso(mockAt(13, 7, 0)),
    'scheduleLabel': mockScheduleLabel(mockAt(13, 7, 0)),
    'duration': '2 days',
    'priceEgp': 3200,
    'capacity': 8,
    'bookedSeats': 0,
    'phone': '+20 100 123 4567',
    'imageUrl': 'https://picsum.photos/seed/siwa/300/400',
    'coverUrl': 'https://picsum.photos/seed/siwa/800/600',
    'approvalStatus': 'pending',
    'createdAt': mockIso(mockAt(-2, 14, 20)),
  },
  {
    'id': 'g4',
    'guideId': mockGuideId,
    'title': 'Aswan Nile Cruise',
    'location': 'Aswan',
    'startAt': mockIso(mockAt(-17, 16, 0)),
    'scheduleLabel': mockScheduleLabel(mockAt(-17, 16, 0)),
    'duration': '5 hours',
    'priceEgp': 2800,
    'capacity': 12,
    'bookedSeats': 0,
    'phone': '+20 100 123 4567',
    'imageUrl': 'https://picsum.photos/seed/aswan/300/400',
    'coverUrl': 'https://picsum.photos/seed/aswan/800/600',
    'approvalStatus': 'approved',
    'createdAt': mockIso(mockAt(-40, 10, 0)),
  },
  {
    'id': 'g5',
    'guideId': mockGuideId,
    'title': 'Cairo Hidden Alleys',
    'location': 'Old Cairo',
    'startAt': mockIso(mockAt(1, 20, 0)),
    'scheduleLabel': mockScheduleLabel(mockAt(1, 20, 0)),
    'duration': '3 hours',
    'priceEgp': 1350,
    'capacity': 6,
    'bookedSeats': 0,
    'phone': '+20 100 123 4567',
    'imageUrl': 'https://picsum.photos/seed/alleys/300/400',
    'coverUrl': 'https://picsum.photos/seed/alleys/800/600',
    'approvalStatus': 'rejected',
    'rejectionReason':
        'The meeting point is not specific enough and the itinerary needs clear times for every stop. Please update both sections before submitting again.',
    'createdAt': mockIso(mockAt(-5, 18, 45)),
  },
];

/// Looks up a mock trip by its id.
Map<String, dynamic>? mockGuideTripById(String tripId) {
  for (final trip in mockGuideTripsJson) {
    if (trip['id'] == tripId) return trip;
  }
  return null;
}

/// How many trips sit in one "My Trips" tab.
///
/// The tab is derived the same way the model derives it: an approved
/// trip is *completed* once its date has passed and *active* before —
/// so counting by `approvalStatus` alone would be wrong.
int mockGuideTripsCountForTab(GuideTripStatus tab) => mockGuideTripsJson
    .map(GuideTrip.fromJson)
    .where((trip) => trip.status == tab)
    .length;
