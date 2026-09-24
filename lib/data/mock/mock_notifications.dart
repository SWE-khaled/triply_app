// Raw mock source (mimics future API JSON shape, snake_case). No delays.
const List<Map<String, dynamic>> mockNotificationsRaw = [
  {
    'id': 'n1',
    'type': 'booking',
    'title': 'Booking Confirmed! 🎉',
    'body': 'Pyramids Sunset Tour with Guide Ahmed has been booked.',
    'time_label': '2 mins ago',
    'is_read': false,
    'section': 'today',
  },
  {
    'id': 'n2',
    'type': 'reminder',
    'title': 'Trip starting soon ⏰',
    'body': 'Your Luxor morning exploration starts in 2 hours.',
    'time_label': '1 hour ago',
    'is_read': false,
    'section': 'today',
  },
  {
    'id': 'n3',
    'type': 'message',
    'title': 'Ahmed Shamy',
    'body': "Sent you a message: 'Hello! Let's arrange our meeting details...'",
    'time_label': 'Yesterday',
    'is_read': true,
    'section': 'earlier',
  },
  {
    'id': 'n4',
    'type': 'like',
    'title': 'Nour liked your story ❤️',
    'body': 'Nour El-Din liked your post about Khan El Khalili bazaar.',
    'time_label': '2 days ago',
    'is_read': true,
    'section': 'earlier',
  },
];
