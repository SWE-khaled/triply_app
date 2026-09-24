// Raw mock source. Convert to Trip via Trip.fromJson() before passing to UI.
const List<Map<String, dynamic>> mockTripsJson = [
  {
    'id': 't1',
    'title': 'Pyramids at Dawn & Sphinx',
    'dateLabel': 'Oct 15, 2026 · 6:00 AM',
    'guideName': 'Omar El-Rashidy',
    'peopleCount': 6,
    'priceEgp': 6000,
    'imageUrl': 'https://picsum.photos/seed/pyramids/300/400',
    'status': 'upcoming',
  },
  {
    'id': 't2',
    'title': 'Nile Felucca & Nubian Village',
    'dateLabel': 'Oct 22, 2026 · 3:00 PM',
    'guideName': 'Nour Abdallah',
    'peopleCount': 8,
    'priceEgp': 4750,
    'imageUrl': 'https://picsum.photos/seed/nile/300/400',
    'status': 'upcoming',
  },
  {
    'id': 't3',
    'title': 'Valley of the Kings Private Tour',
    'dateLabel': 'Nov 5, 2026 · 8:00 AM',
    'guideName': 'Nour Abdallah',
    'peopleCount': 3,
    'priceEgp': 7500,
    'imageUrl': 'https://picsum.photos/seed/valley/300/400',
    'status': 'upcoming',
  },
];
