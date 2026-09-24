// Raw mock source (mimics future API JSON shape, snake_case).
// Converted to Place models in HomeController. No delays, no fake API.
const List<Map<String, dynamic>> mockPlacesRaw = [
  {
    'id': 'p1',
    'name': 'Giza Pyramids',
    'city': 'Giza',
    'country': 'Egypt',
    'image_url': 'https://picsum.photos/seed/giza/600/800',
    'is_favorite': false,
  },
  {
    'id': 'p2',
    'name': 'Khan El Khalili',
    'city': 'Cairo',
    'country': 'Egypt',
    'image_url': 'https://picsum.photos/seed/khan/600/800',
    'is_favorite': false,
  },
  {
    'id': 'p3',
    'name': 'Aswan',
    'city': 'Aswan',
    'country': 'Egypt',
    'image_url': 'https://picsum.photos/seed/aswan/600/800',
    'is_favorite': false,
  },
];
