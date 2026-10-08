// Raw mock source for the tour-guide Dashboard (mimics future API JSON
// shape, snake_case). No delays. New file only — existing mocks untouched.
const Map<String, dynamic> mockGuideDashboardRaw = {
  'guide_name': 'Yasmin Ali',
  'avatar_url': 'https://i.pravatar.cc/100?img=5',
  'total_bookings': 24,
  'upcoming_trips': 1,
  'active_trips': 1,
  'completed_trips': 1,
  'earnings_label': '\$4,120',
  'pending_requests': 3,
};

const List<Map<String, dynamic>> mockBookingRequestsRaw = [
  {
    'id': 'b1',
    'guest_name': 'Sophie Martin',
    'tour_title': 'Private guide booking', 
    'detail_label': '1 traveler · Today',
    'avatar_url': 'https://i.pravatar.cc/100?img=47',
    'is_private': true,
  },
  {
    'id': 'b2',
    'guest_name': 'Daniel Kim',
    'tour_title': 'Cairo Food Experience',
    'detail_label': '3 people · Oct 28',
    'avatar_url': 'https://i.pravatar.cc/100?img=12',
    'is_private': false,
  },
];
