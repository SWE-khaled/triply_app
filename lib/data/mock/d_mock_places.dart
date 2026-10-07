// Mock data for User Posts and Trip Applications

// ── User Posts ──────────────────────────────────────────
class MockPost {
  final String title;
  final String author;
  final String imageUrl;

  const MockPost({
    required this.title,
    required this.author,
    required this.imageUrl,
  });
}

final List<MockPost> mockPosts = [
  MockPost(
    title: 'Pyramids at sunrise',
    author: 'Sara Ahmed',
    imageUrl: 'https://picsum.photos/seed/pyramids/600/400',
  ),
  MockPost(
    title: 'A night in Cairo',
    author: 'John Miller',
    imageUrl: 'https://picsum.photos/seed/cairo/600/400',
  ),
  MockPost(
    title: 'Beautiful Aswan',
    author: 'Nour Hassan',
    imageUrl: 'https://picsum.photos/seed/aswan2/600/400',
  ),
];

// ── Trip Applications ────────────────────────────────────
class MockTripApplication {
  final String tripTitle;
  final String guide;
  final String date;
  final String price;
  final String status; // 'pending_review' | 'approved' | 'rejected'
  final String type; // 'public' | 'private'
  final int travelers;
  final String location;
  final List<String> itinerary;
  final List<String> participants;
  final String imageUrl;
  final String? rejectionReason;

  const MockTripApplication({
    required this.tripTitle,
    required this.guide,
    required this.date,
    required this.price,
    required this.status,
    required this.type,
    required this.travelers,
    required this.location,
    required this.itinerary,
    required this.participants,
    required this.imageUrl,
    this.rejectionReason,
  });
}

final List<MockTripApplication> mockTripApplications = [
  MockTripApplication(
    tripTitle: 'Pyramids Day Tour',
    guide: 'Hany Samir',
    date: 'Today · 5:00 PM',
    price: 'EGP 3,960',
    status: 'pending_review',
    type: 'public',
    travelers: 3,
    location: 'Giza Plateau',
    itinerary: [
      'Meet at the main entrance',
      'Panoramic pyramid viewpoint',
      'Sphinx & Valley Temple',
      'Golden hour tea',
    ],
    participants: ['Ahmed Ali', 'Mona Zaki', 'John Doe'],
    imageUrl: 'https://picsum.photos/seed/pyramids/600/400',
  ),
  MockTripApplication(
    tripTitle: 'Custom Luxor Trip',
    guide: 'Mahmoud Ali',
    date: 'Oct 12 · 8:00 AM',
    price: 'EGP 6,200',
    status: 'pending_review',
    type: 'private',
    travelers: 2,
    location: 'Luxor Temple',
    itinerary: [
      'Hotel pickup',
      'Karnak Temple tour',
      'Felucca ride on the Nile',
    ],
    participants: ['Sarah Smith', 'Mike Smith'],
    imageUrl: 'https://picsum.photos/seed/luxor/600/400',
  ),
  MockTripApplication(
    tripTitle: 'Siwa Desert Safari',
    guide: 'Omar Fathy',
    date: 'Oct 18 · 6:00 AM',
    price: 'EGP 4,800',
    status: 'pending_review',
    type: 'public',
    travelers: 6,
    location: 'Siwa Oasis',
    itinerary: [
      'Departure from Alexandria',
      'Arrive at Siwa',
      'Salt lakes swim',
      'Desert camp',
    ],
    participants: ['Ahmed M.', 'Nour H.', 'Kareem S.', 'Layla T.', 'Mostafa F.', 'Hoda G.'],
    imageUrl: 'https://picsum.photos/seed/desert/600/400',
  ),
];
