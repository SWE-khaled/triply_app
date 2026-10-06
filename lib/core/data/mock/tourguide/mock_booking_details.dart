// Raw mock source for tour-guide Booking Details (mimics future API JSON
// shape, snake_case). No delays. New file only — existing mocks untouched.
// Avatar/name/title/type intentionally mirror mock_dashboard.dart so the
// details screen stays consistent with the Dashboard cards.
const List<Map<String, dynamic>> mockBookingDetailsRaw = [
  {
    'id': 'b1',
    'guest_name': 'Sophie Martin',
    'country': 'France',
    'traveler_count': 1,
    'avatar_url': 'https://i.pravatar.cc/100?img=47',
    'is_private': true,
    'tour_title': 'Private Guide Booking',
    'datetime_label': 'Today · 5:00 PM',
    'location': 'Giza Plateau main entrance',
    'booking_code': 'TRP-2841',
    'price_label': 'EGP 3,300',
  },
  {
    'id': 'b2',
    'guest_name': 'Daniel Kim',
    'country': 'South Korea',
    'traveler_count': 3,
    'avatar_url': 'https://i.pravatar.cc/100?img=12',
    'is_private': false,
    'tour_title': 'Cairo Food Experience',
    'datetime_label': 'Oct 28 · 10:00 AM',
    'location': 'Khan El Khalili main gate',
    'booking_code': 'TRP-2842',
    'price_label': 'EGP 2,100',
  },
];
