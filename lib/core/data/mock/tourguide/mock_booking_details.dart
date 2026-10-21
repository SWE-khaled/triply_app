import 'mock_guide_shared.dart';
import 'mock_guide_trip_details.dart';
import 'mock_guide_trips.dart';

/// Raw mock source for the guide's booking requests.
/// Convert via BookingDetails.fromJson() before the UI.
///
/// Every booking points at a real trip (`tripId`) and a real traveler
/// (`touristId`), and derives its title, date, meeting point and total
/// from that trip — so a booking can never contradict the trip it books.
///
/// `detail_label` is an extra key kept for the dashboard card (it shows
/// the same traveler count and date); `BookingDetails.fromJson` ignores
/// it.

final List<Map<String, dynamic>> mockBookingDetailsRaw = [
  _booking(
    id: 'b1',
    tripId: 'g1',
    touristId: 'u1',
    guestName: 'Sophie Martin',
    country: 'France',
    travelerCount: 1,
    avatarUrl: 'https://i.pravatar.cc/100?img=5',
    isPrivate: true,
    bookingCode: 'TRP-2841',
    status: 'pending',
    paymentStatus: 'pending',
    createdAt: mockAt(0, 9, 12),
  ),
  _booking(
    id: 'b2',
    tripId: 'g2',
    touristId: 'u2',
    guestName: 'Daniel Kim',
    country: 'South Korea',
    travelerCount: 3,
    avatarUrl: 'https://i.pravatar.cc/100?img=21',
    isPrivate: false,
    bookingCode: 'TRP-2842',
    status: 'confirmed',
    paymentStatus: 'paid',
    createdAt: mockAt(-1, 16, 40),
  ),
  _booking(
    id: 'b3',
    tripId: 'g1',
    touristId: 'u5',
    guestName: 'Omar Farouk',
    country: 'Germany',
    travelerCount: 2,
    avatarUrl: 'https://i.pravatar.cc/100?img=60',
    isPrivate: false,
    bookingCode: 'TRP-2843',
    status: 'pending',
    paymentStatus: 'pending',
    createdAt: mockAt(0, 8, 5),
  ),
];

/// Looks up a mock booking by its id.
Map<String, dynamic>? mockBookingById(String bookingId) {
  for (final booking in mockBookingDetailsRaw) {
    if (booking['id'] == bookingId) return booking;
  }
  return null;
}

/// The total amount earned across every mock booking.
double mockBookingsTotal() => mockBookingDetailsRaw.fold<double>(
  0,
  (sum, booking) => sum + ((booking['totalPrice'] as num?)?.toDouble() ?? 0),
);

/// Builds one booking, deriving every shared field from the trip it
/// books. Throws when the trip is unknown so a broken relation fails
/// loudly instead of silently showing the wrong content.
Map<String, dynamic> _booking({
  required String id,
  required String tripId,
  required String touristId,
  required String guestName,
  required String country,
  required int travelerCount,
  required String avatarUrl,
  required bool isPrivate,
  required String bookingCode,
  required String status,
  required String paymentStatus,
  required DateTime createdAt,
}) {
  final trip = mockGuideTripById(tripId);
  if (trip == null) {
    throw StateError(
      'No mock trip "$tripId" — add it to mock_guide_trips.dart first.',
    );
  }
  final details = mockGuideTripDetailsById(tripId);
  final startAt = DateTime.parse(trip['startAt'] as String);
  final unitPrice = (trip['priceEgp'] as num).toDouble();
  final total = unitPrice * travelerCount;
  return {
    'id': id,
    'tripId': tripId,
    'touristId': touristId,
    'guest_name': guestName,
    'country': country,
    'traveler_count': travelerCount,
    'avatar_url': avatarUrl,
    'is_private': isPrivate,
    'tour_title': trip['title'],
    'datetime_label': mockDateTimeLabel(startAt),
    'detail_label':
        '${mockTravelerLabel(travelerCount)} · ${mockShortDate(startAt)}',
    'location': details?['meetingPoint'] ?? trip['location'],
    'booking_code': bookingCode,
    'price_label': mockEgpLabel(total),
    'totalPrice': total,
    'status': status,
    'paymentStatus': paymentStatus,
    'createdAt': mockIso(createdAt),
  };
}
