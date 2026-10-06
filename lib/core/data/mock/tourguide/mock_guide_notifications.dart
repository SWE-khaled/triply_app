// Raw mock source for tour-guide Notifications (mimics future API JSON
// shape, snake_case). No delays. New file only — existing mocks untouched.
const List<Map<String, dynamic>> mockGuideNotificationsRaw = [
  {
    'id': 'gn1',
    'type': 'booking',
    'title': 'New private booking from Sophie',
    'body': 'Private guide request · 1 traveler',
  },
  {
    'id': 'gn2',
    'type': 'approval',
    'title': 'Public trip approved',
    'body': 'Cairo Old Town Experience is now live',
  },
  {
    'id': 'gn3',
    'type': 'payment',
    'title': 'Payment received',
    'body': 'EGP 1,650 added to your balance',
  },
];
