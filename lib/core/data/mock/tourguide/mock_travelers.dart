import 'mock_booking_details.dart';
import 'mock_guide_shared.dart';

/// Raw mock source for the travelers booked on a guide trip.
/// Convert via Traveler.fromJson() before the UI.
///
/// Each row points at the booking it belongs to (`bookingId`) and the
/// trip it travels on (`tripId`), and its seat label is the group size
/// of that booking — so the traveler list always matches the booking.

final List<Map<String, dynamic>> mockTravelersJson = [
  _traveler(
    id: 'u1',
    bookingId: 'b1',
    name: 'Sophie Martin',
    country: 'France',
    avatarUrl: 'https://i.pravatar.cc/100?img=5',
  ),
  _traveler(
    id: 'u2',
    bookingId: 'b2',
    name: 'Daniel Kim',
    country: 'South Korea',
    avatarUrl: 'https://i.pravatar.cc/100?img=21',
  ),
  _traveler(
    id: 'u3',
    bookingId: 'b2',
    name: 'Layla Hassan',
    country: 'Egypt',
    avatarUrl: 'https://i.pravatar.cc/100?img=33',
  ),
  _traveler(
    id: 'u4',
    bookingId: 'b2',
    name: 'Sara Mansour',
    country: 'Egypt',
    avatarUrl: 'https://i.pravatar.cc/100?img=44',
  ),
  _traveler(
    id: 'u5',
    bookingId: 'b3',
    name: 'Omar Farouk',
    country: 'Germany',
    avatarUrl: 'https://i.pravatar.cc/100?img=60',
  ),
  _traveler(
    id: 'u6',
    bookingId: 'b3',
    name: 'Nadia Farid',
    country: 'Egypt',
    avatarUrl: 'https://i.pravatar.cc/100?img=68',
  ),
];

/// Builds one traveler row from the booking it belongs to. Throws when
/// the booking is unknown so a broken relation fails loudly.
Map<String, dynamic> _traveler({
  required String id,
  required String bookingId,
  required String name,
  required String country,
  required String avatarUrl,
}) {
  final booking = mockBookingById(bookingId);
  if (booking == null) {
    throw StateError(
      'No mock booking "$bookingId" — add it to mock_booking_details.dart.',
    );
  }
  final travelerCount = (booking['traveler_count'] as num).toInt();
  return {
    'id': id,
    'bookingId': bookingId,
    'tripId': booking['tripId'],
    'name': name,
    'tagline': 'Traveler · $country',
    'avatarUrl': avatarUrl,
    'seatsLabel': mockTravelerLabel(travelerCount),
  };
}
