import 'package:triply/features/guides/model/guide.dart';

/// Raw mock source (List<Map>). Converted to [Guide] models before UI.
/// Later replaced by API JSON -> Guide.fromJson with no UI change.
const List<Map<String, dynamic>> _rawGuides = [
  {
    'id': 'g1',
    'name': 'Omar El-Rashidy',
    'specialty': 'Ancient Egypt & Archaeology',
    'avatar_url': 'https://i.pravatar.cc/150?img=11',
    'cover_url': 'https://picsum.photos/seed/temple-g1/800/500',
    'location': 'Giza & Cairo',
    'about':
        'Born in Cairo, I guide private tours of the Pyramids, Saqqara and the Grand Egyptian Museum, with early access before the crowds.',
    'languages': ['Arabic', 'English', 'French'],
    'rating': 4.97,
    'review_count': 342,
    'price_per_hour': 85,
    'currency': '\$',
    'is_verified': true,
  },
  {
    'id': 'g2',
    'name': 'Nour Abdallah',
    'specialty': 'Nile Valley & Temples',
    'avatar_url': 'https://i.pravatar.cc/150?img=47',
    'cover_url': 'https://picsum.photos/seed/temple-luxor/800/500',
    'location': 'Luxor & Aswan',
    'about':
        'Born in Luxor, raised between temples. I offer intimate small-group and private tours of the Valley of the Kings, Karnak, and Philae — with dawn access most tourists never see.',
    'languages': ['Arabic', 'English', 'Italian'],
    'rating': 4.93,
    'review_count': 218,
    'price_per_hour': 75,
    'currency': '\$',
    'is_verified': true,
  },
  {
    'id': 'g3',
    'name': 'Tariq Suleiman',
    'specialty': 'Mediterranean & Coastal History',
    'avatar_url': 'https://i.pravatar.cc/150?img=12',
    'cover_url': 'https://picsum.photos/seed/temple-g3/800/500',
    'location': 'Alexandria & Coast',
    'about':
        'Alexandria native. I lead coastal history walks, catacombs visits and Mediterranean food stops.',
    'languages': ['Arabic', 'English', 'Greek'],
    'rating': 4.88,
    'review_count': 156,
    'price_per_hour': 65,
    'currency': '\$',
    'is_verified': true,
  },
  {
    'id': 'g4',
    'name': 'Ahmed Hassan',
    'specialty': 'Egyptology & History',
    'avatar_url': 'https://i.pravatar.cc/150?img=13',
    'cover_url': 'https://picsum.photos/seed/temple-g4/800/500',
    'location': 'Cairo & Saqqara',
    'about':
        'Egyptologist with 10 years of guiding. I focus on history-first storytelling at Saqqara, Memphis and Old Cairo.',
    'languages': ['Arabic', 'English'],
    'rating': 4.9,
    'review_count': 124,
    'price_per_hour': 70,
    'currency': '\$',
    'is_verified': true,
  },
  {
    'id': 'g5',
    'name': 'Mona Adel',
    'specialty': 'History & Culture',
    'avatar_url': 'https://i.pravatar.cc/150?img=32',
    'cover_url': 'https://picsum.photos/seed/temple-g5/800/500',
    'location': 'Cairo',
    'about':
        'Culture lover. My tours mix history, crafts and local food — ideal for first-time visitors.',
    'languages': ['Arabic', 'English', 'French'],
    'rating': 4.8,
    'review_count': 98,
    'price_per_hour': 65,
    'currency': '\$',
    'is_verified': true,
  },
  {
    'id': 'g6',
    'name': 'Omar Farouk',
    'specialty': 'Adventure Guide',
    'avatar_url': 'https://i.pravatar.cc/150?img=59',
    'cover_url': 'https://picsum.photos/seed/temple-g6/800/500',
    'location': 'Sinai & Red Sea',
    'about':
        'Adventure guide for desert hikes, canyon walks and snorkeling days around Sinai and the Red Sea.',
    'languages': ['Arabic', 'English', 'Italian'],
    'rating': 4.85,
    'review_count': 156,
    'price_per_hour': 60,
    'currency': '\$',
    'is_verified': false,
  },
];

/// Public mock list as Models (View consumes this, never [_rawGuides]).
final List<Guide> mockGuides =
    _rawGuides.map((m) => Guide.fromJson(m)).toList(growable: false);

/// Language filter chips shown in Figma: All + top languages.
const List<String> mockGuideLanguageFilters = [
  'All',
  'English',
  'Arabic',
  'French',
];
