// Single source of truth for the tour-guide identity used by the
// tourguide mock dataset.
//
// Every other mock file references these values (id, name, avatar,
// rating), so the dataset never presents two different guides. Kept in
// sync with the tourist-side listing of the same guide
// (`mock/tourist/mock_guides.dart`, id `g2`).

/// The owner id stamped on every guide-side mock record. In Firestore
/// this becomes the signed-in guide's `uid`.
const String mockGuideId = 'g2';

const Map<String, dynamic> mockGuideProfileJson = {
  'id': mockGuideId,
  'name': 'Nour Abdallah',
  'title': 'Nile Valley & Temples',
  'avatarUrl': 'https://i.pravatar.cc/150?img=47',
  'coverUrl': 'https://picsum.photos/seed/temple-luxor/800/500',
  'rating': 4.93,
  'reviewsCount': 218,
  'location': 'Luxor & Aswan',
  'languagesCount': 3,
  'pricePerHour': 3750,
  'languages': ['Arabic', 'English', 'Italian'],
  'about':
      'Born in Luxor, raised between temples. I offer intimate small-group and private tours of the Valley of the Kings, Karnak, and Philae — with dawn access most tourists never see.',
};
