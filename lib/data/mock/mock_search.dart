// Search mock: plain strings + destination display rows. No delays.
const List<String> mockRecentSearches = [
  'Giza Pyramids',
  'Luxor Temple',
  'Khan El Khalili',
  'Nile cruise',
];

const List<String> mockPopularSearches = [
  'Historical sites',
  'Guided tours',
  'Desert safari',
  'Nile cruises',
  'Local food',
  'Photography',
];

// Display rows for "Popular Destinations" (title/subtitle/image only).
const List<Map<String, String>> mockPopularDestinations = [
  {
    'name': 'Giza Pyramids',
    'subtitle': 'Giza · Historical',
    'image_url': 'https://picsum.photos/seed/giza/200/200',
  },
  {
    'name': 'Khan El Khalili',
    'subtitle': 'Cairo · Shopping',
    'image_url': 'https://picsum.photos/seed/khan/200/200',
  },
  {
    'name': 'Aswan',
    'subtitle': 'Upper Egypt · Historical',
    'image_url': 'https://picsum.photos/seed/aswan/200/200',
  },
  {
    'name': 'Luxor Temple',
    'subtitle': 'Luxor · Historical',
    'image_url': 'https://picsum.photos/seed/luxor-temple/200/200',
  },
];
