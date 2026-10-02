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
    'image_url': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTvi3xmuK5KiYF8KD8GsDkenLC8aypmvHxgOoyDviuSsg&s=10',
  },
  {
    'name': 'Khan El Khalili',
    'subtitle': 'Cairo · Shopping',
    'image_url': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT3d1F6I1VkP9vmN-ohhQ8-drlpILaCIPeM517yMRzzkQ&s=10',
  },
  {
    'name': 'Aswan',
    'subtitle': 'Upper Egypt · Historical',
    'image_url': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQxpGWwQqw3qmyLkJ-E7ES-6saHVet3wOF97NptrHsspw&s=10',
  },
  {
    'name': 'Luxor Temple',
    'subtitle': 'Luxor · Historical',
    'image_url': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS3mi0gq5U7fxAhIeDz5nVpsscMDryijss4LikyF-njvg&s=10',
  },
];
