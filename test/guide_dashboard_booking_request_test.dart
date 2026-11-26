import 'package:flutter_test/flutter_test.dart';
import 'package:triply/features/tour_guide/home_and_notification_tg/model/guide_dashboard_booking_request.dart';

void main() {
  for (final isPrivate in [true, false]) {
    test('reads a booking avatar from the user profile for '
        '${isPrivate ? 'private' : 'public'} bookings', () {
      final booking = BookingRequest.fromJson({
        'id': 'booking-1',
        'avatar_url': '',
        'avatarUrl': ' https://example.com/tourist.png ',
        'is_private': isPrivate,
      });

      expect(booking.avatarUrl, 'https://example.com/tourist.png');
      expect(booking.isPrivate, isPrivate);
    });
  }
}
