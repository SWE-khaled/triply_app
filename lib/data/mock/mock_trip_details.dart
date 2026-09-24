// Raw mock source. Convert via TripDetails.fromJson() before passing to UI.
const List<Map<String, dynamic>> mockTripDetailsJson = [
  {
    'id': 'd1',
    'tripId': 't1',
    'tag': 'GUIDED TOUR',
    'title': 'Pyramids at Dawn & Sphinx',
    'rating': 4.9,
    'reviewsCount': 124,
    'location': 'Giza Plateau',
    'duration': '4 hours',
    'groupType': 'Group / Private',
    'languages': 'English / Arabic',
    'about':
        'Experience the Giza Plateau at its most magical — before the crowds arrive. Watch the pyramids glow amber in the first light of day with exclusive early-access entry.',
    'highlights': [
      'Early access before public opening',
      'Inside Khafre Pyramid',
      'Private Sphinx viewing platform',
      'Bedouin tea ceremony',
    ],
    'itinerary': [
      {'time': '8:00 AM', 'title': 'Early access before public opening'},
      {'time': '9:00 AM', 'title': 'Inside Khafre Pyramid'},
      {'time': '10:00 AM', 'title': 'Private Sphinx viewing platform'},
      {'time': '11:00 AM', 'title': 'Bedouin tea ceremony'},
    ],
    'notes': [
      'Wear comfortable shoes — expect uneven terrain.',
      'Bring sunscreen, a hat, and plenty of water.',
      'Photography allowed; flash restricted in closed spaces.',
      'Free cancellation up to 24 hours before the trip.',
    ],
    'meetingPoint': 'Marriott Mena House, Entrance Gate',
    'priceEgp': 6000,
    'guideName': 'Omar El-Rashidy',
    'guideAvatarUrl': 'https://picsum.photos/seed/omar/100/100',
    'guideRating': 4.97,
    'guideReviews': 342,
    'topRatedGuide': true,
    'imageUrl': 'https://picsum.photos/seed/pyramids/800/600',
  },
];
