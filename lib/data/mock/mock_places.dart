// Raw mock source (mimics future API JSON shape, snake_case).
// Converted to Place models in HomeController. No delays, no fake API.
const List<Map<String, dynamic>> mockPlacesRaw = [
  {
    'id': 'p1',
    'name': 'Giza Pyramids',
    'city': 'Giza',
    'country': 'Egypt',
    'image_url': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTvi3xmuK5KiYF8KD8GsDkenLC8aypmvHxgOoyDviuSsg&s=10',
    'is_favorite': false,
  },
  {
    'id': 'p2',
    'name': 'Khan El Khalili',
    'city': 'Cairo',
    'country': 'Egypt',
    'image_url': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT3d1F6I1VkP9vmN-ohhQ8-drlpILaCIPeM517yMRzzkQ&s=10',
    'is_favorite': false,
  },
  {
    'id': 'p3',
    'name': 'Aswan',
    'city': 'Aswan',
    'country': 'Egypt',
    'image_url': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQxpGWwQqw3qmyLkJ-E7ES-6saHVet3wOF97NptrHsspw&s=10',
    'is_favorite': false,
  },
];
