import 'mock_booking_details.dart';
import 'mock_guide_profile.dart';
import 'mock_guide_shared.dart';
import 'mock_guide_trips.dart';

/// Raw mock source for the tour-guide Notifications.
/// Convert via GuideNotification.fromJson() before the UI.
///
/// Every notification points at the record it talks about
/// (`relatedEntityId`) so the centre can deep-link into a trip or a
/// booking later. `isRead` and `createdAt` are extra keys the current
/// model ignores.

final List<Map<String, dynamic>> mockGuideNotificationsRaw = [
  _bookingNotification(
    id: 'gn1',
    bookingId: 'b1',
    isRead: false,
    createdAt: mockAt(0, 9, 12),
  ),
  _approvalNotification(
    id: 'gn2',
    tripId: 'g2',
    isRead: false,
    createdAt: mockAt(-1, 15, 20),
  ),
  _paymentNotification(
    id: 'gn3',
    bookingId: 'b1',
    isRead: true,
    createdAt: mockAt(-1, 10, 0),
  ),
];

/// A new booking request for the guide.
Map<String, dynamic> _bookingNotification({
  required String id,
  required String bookingId,
  required bool isRead,
  required DateTime createdAt,
}) {
  final booking = _requireBooking(bookingId);
  final guest = booking['guest_name'] as String;
  final isPrivate = booking['is_private'] as bool;
  final count = (booking['traveler_count'] as num).toInt();
  return {
    'id': id,
    'userId': mockGuideId,
    'type': 'booking',
    'title': 'New ${isPrivate ? 'private ' : ''}booking from $guest',
    'message': '${mockTravelerLabel(count)} · ${booking['tour_title']}',
    'relatedEntityId': bookingId,
    'relatedCollection': 'bookings',
    'isRead': isRead,
    'createdAt': mockIso(createdAt),
  };
}

/// A trip that passed admin review and is now live.
Map<String, dynamic> _approvalNotification({
  required String id,
  required String tripId,
  required bool isRead,
  required DateTime createdAt,
}) {
  final trip = mockGuideTripById(tripId);
  if (trip == null) {
    throw StateError(
      'No mock trip "$tripId" — add it to mock_guide_trips.dart first.',
    );
  }
  return {
    'id': id,
    'userId': mockGuideId,
    'type': 'trip_decided',
    'title': 'Trip approved',
    'message': '"${trip['title']}" is now live and visible to tourists.',
    'relatedEntityId': tripId,
    'relatedCollection': 'trips',
    'isRead': isRead,
    'createdAt': mockIso(createdAt),
  };
}

/// A payment that landed in the guide's balance.
Map<String, dynamic> _paymentNotification({
  required String id,
  required String bookingId,
  required bool isRead,
  required DateTime createdAt,
}) {
  final booking = _requireBooking(bookingId);
  final total = (booking['totalPrice'] as num).toDouble();
  return {
    'id': id,
    'userId': mockGuideId,
    'type': 'payment',
    'title': 'Payment received',
    'message': '${mockEgpLabel(total)} added to your balance',
    'relatedEntityId': bookingId,
    'relatedCollection': 'bookings',
    'isRead': isRead,
    'createdAt': mockIso(createdAt),
  };
}

Map<String, dynamic> _requireBooking(String bookingId) {
  final booking = mockBookingById(bookingId);
  if (booking == null) {
    throw StateError(
      'No mock booking "$bookingId" — add it to mock_booking_details.dart.',
    );
  }
  return booking;
}
