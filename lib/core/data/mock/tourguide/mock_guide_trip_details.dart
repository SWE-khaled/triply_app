import 'mock_guide_profile.dart';
import 'mock_guide_trips.dart';

/// Raw mock source for the long-form details of each guide trip.
/// Convert via GuideTripDetails.fromJson() before the UI.
///
/// One entry per trip in [mockGuideTripsJson]. The shared fields (title,
/// location, duration, price, cover) are copied from the trip itself, so
/// a trip and its details can never disagree â€” and every trip has its
/// own details, instead of falling back to the first one.

final List<Map<String, dynamic>> mockGuideTripDetailsJson = [
  _details(
    tripId: 'g1',
    tag: 'GUIDED TOUR',
    groupType: 'Public-Group',
    languages: 'English / Arabic',
    rating: 4.9,
    reviewsCount: 124,
    about:
        'Watch the Giza plateau turn gold as the sun drops behind the pyramids. We time the walk so you get the classic sunset light without the midday heat â€” and the quieter side of the plateau most groups never see.',
    highlights: [
      'Sunset view from the western plateau',
      'Inside Khafre Pyramid',
      'Private Sphinx viewing terrace',
      'Bedouin tea ceremony',
    ],
    itinerary: [
      {'time': '4:30 PM', 'title': 'Meet at the Giza Plateau main entrance'},
      {'time': '5:00 PM', 'title': 'Plateau walk and pyramid overview'},
      {'time': '6:10 PM', 'title': 'Inside Khafre Pyramid'},
      {'time': '7:00 PM', 'title': 'Sphinx terrace and tea ceremony'},
    ],
    notes: [
      'Wear comfortable shoes â€” expect uneven terrain.',
      'Bring sunscreen, a hat, and plenty of water.',
      'Photography allowed; flash restricted in closed spaces.',
      'Free cancellation up to 24 hours before the trip.',
    ],
    included:
        'Professional guide, entrance tickets, bottled water, hotel pickup and Bedouin tea.',
    meetingPoint: 'Giza Plateau main entrance',
  ),
  _details(
    tripId: 'g2',
    tag: 'CITY WALK',
    groupType: 'Public-Group',
    languages: 'English / Arabic / Italian',
    rating: 4.8,
    reviewsCount: 96,
    about:
        'Cairo\'s old city is a maze of alleys, courtyards and eight centuries of layered history. We walk it slowly â€” the lanes of Khan El Khalili, a 19th-century house, and Al-Muizz where the city still keeps its originals.',
    highlights: [
      'Khan El Khalili back-alleys walk',
      'Al-Azhar courtyard and lamp makers',
      'Traditional coffee and tahina break',
    ],
    itinerary: [
      {'time': '10:00 AM', 'title': 'Meet at the Khan El Khalili main gate'},
      {'time': '10:30 AM', 'title': 'Al-Muizz street and house facades'},
      {'time': '11:30 AM', 'title': 'Al-Azhar courtyard and workshops'},
      {'time': '12:15 PM', 'title': 'Coffee and tahina break'},
    ],
    notes: [
      'Comfortable walking shoes recommended.',
      'Some workshops ask for photos â€” always ask first.',
      'Free cancellation up to 24 hours before the trip.',
    ],
    included:
        'Professional guide, entrance tickets, bottled water and a coffee stop.',
    meetingPoint: 'Khan El Khalili main gate',
  ),
  _details(
    tripId: 'g3',
    tag: 'DESERT ESCAPE',
    groupType: 'Private-Group',
    languages: 'English / Arabic',
    rating: 4.95,
    reviewsCount: 64,
    about:
        'Two days deep in the western desert: salt lakes, palm groves and the rock-cut amphitheatres of the oasis. We drive out early to catch the reflection in the salt pools, then walk the old town before dinner under the stars.',
    highlights: [
      'Sunrise over the salt lakes',
      'Amphitheatre and rock-cut tombs',
      'Palm grove and old town walk',
      'Desert dinner under the stars',
    ],
    itinerary: [
      {'time': '7:00 AM', 'title': 'Departure from Siwa town'},
      {'time': '8:30 AM', 'title': 'Salt lakes sunrise'},
      {'time': '11:00 AM', 'title': 'Amphitheatre and rock-cut tombs'},
      {'time': '4:00 PM', 'title': 'Palm groves and old town walk'},
      {'time': '7:00 PM', 'title': 'Desert dinner'},
    ],
    notes: [
      'Two full days â€” pack light.',
      'Evening temperatures drop sharply; bring a jacket.',
      'Cash is needed in the old town â€” no card machines.',
      'Free cancellation up to 48 hours before the trip.',
    ],
    included:
        'Professional guide, 4x4 transport, entrance tickets, lunch and desert dinner.',
    meetingPoint: 'Siwa Town â€” main square',
  ),
  _details(
    tripId: 'g4',
    tag: 'RIVER CRUISE',
    groupType: 'Public-Group',
    languages: 'English / Arabic / German',
    rating: 4.7,
    reviewsCount: 143,
    about:
        'A slow afternoon on the Nile around Elephantine and Philae. We sail past the feluccas and the unfinished Aswan High Dam, stopping long enough to walk the island temples while the light is still soft.',
    highlights: [
      'Felucca crossing around Elephantine',
      'Philae temple visit',
      'High Dam viewpoint',
    ],
    itinerary: [
      {'time': '4:00 PM', 'title': 'Board at Aswan Marina'},
      {'time': '4:45 PM', 'title': 'Elephantine island walk'},
      {'time': '5:45 PM', 'title': 'Philae temple'},
      {'time': '6:45 PM', 'title': 'Return and high dam viewpoint'},
    ],
    notes: [
      'Bring a light jacket for the breeze on deck.',
      'Temple floors are uneven â€” wear flat shoes.',
      'Free cancellation up to 24 hours before the trip.',
    ],
    included:
        'Professional guide, boat charter, entrance tickets and bottled water.',
    meetingPoint: 'Aswan Marina â€” Gate 2',
  ),
  _details(
    tripId: 'g5',
    tag: 'NIGHT WALK',
    groupType: 'Public-Group',
    languages: 'English / Arabic',
    rating: 4.6,
    reviewsCount: 41,
    about:
        'A short evening walk through the passages most visitors never find â€” craftsmen workshops, an abandoned cinema and the rooftop laundry lines of downtown.',
    highlights: [
      'Lantern-makers street',
      'Abandoned Rivoli cinema',
      'Rooftop laundry walk',
    ],
    itinerary: [
      {'time': '8:00 PM', 'title': 'Meet near Ramses station'},
      {'time': '8:30 PM', 'title': 'Lantern-makers street'},
      {'time': '9:15 PM', 'title': 'Rivoli cinema'},
      {'time': '9:45 PM', 'title': 'Rooftop overlook'},
    ],
    notes: [
      'Evening only â€” the alleys are closed to traffic.',
      'Keep your phone away from the tight corners.',
      'Free cancellation up to 12 hours before the trip.',
    ],
    included: 'Professional guide, bottled water and a late coffee stop.',
    meetingPoint: 'Ramses station â€” exit 3',
  ),
];

/// Looks up the details of a mock trip by its id.
Map<String, dynamic>? mockGuideTripDetailsById(String tripId) {
  for (final details in mockGuideTripDetailsJson) {
    if (details['tripId'] == tripId) return details;
  }
  return null;
}

/// Builds one details record, copying the shared fields from the trip it
/// belongs to. Throws when the trip is unknown so a broken relation
/// fails loudly instead of silently showing the wrong content.
Map<String, dynamic> _details({
  required String tripId,
  required String tag,
  required String groupType,
  required String languages,
  required double rating,
  required int reviewsCount,
  required String about,
  required List<String> highlights,
  required List<Map<String, dynamic>> itinerary,
  required List<String> notes,
  required String included,
  required String meetingPoint,
}) {
  final trip = mockGuideTripById(tripId);
  if (trip == null) {
    throw StateError(
      'No mock trip "$tripId" â€” add it to mock_guide_trips.dart first.',
    );
  }
  return {
    'id': 'details-$tripId',
    'tripId': tripId,
    'guideId': mockGuideId,
    'tag': tag,
    'title': trip['title'],
    'rating': rating,
    'reviewsCount': reviewsCount,
    'location': trip['location'],
    'duration': trip['duration'],
    'groupType': groupType,
    'languages': languages,
    'about': about,
    'highlights': highlights,
    'itinerary': itinerary,
    'notes': notes,
    'included': included,
    'meetingPoint': meetingPoint,
    'priceEgp': trip['priceEgp'],
    'guideName': mockGuideProfileJson['name'],
    'guideAvatarUrl': mockGuideProfileJson['avatarUrl'],
    'guideRating': mockGuideProfileJson['rating'],
    'guideReviews': mockGuideProfileJson['reviewsCount'],
    'imageUrl': trip['coverUrl'],
  };
}
