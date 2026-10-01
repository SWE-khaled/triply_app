import 'package:triply/features/guides/model/trip.dart';

/// Raw mock source (List<Map>). Converted to [Trip] models before UI.
const List<Map<String, dynamic>> _rawTrips = [
  {
    'id': 't1',
    'guide_id': 'g2',
    'title': 'Nile Felucca & Nubian Village',
    'image_url': 'https://picsum.photos/seed/nile-felucca/200/200',
    'date_label': 'Oct 22, 2026',
    'duration_label': '5 hours',
    'price': 4750,
    'currency': 'EGP',
  },
  {
    'id': 't2',
    'guide_id': 'g2',
    'title': 'Valley of the Kings Private Tour',
    'image_url': 'https://picsum.photos/seed/valley-kings/200/200',
    'date_label': 'Nov 5, 2026',
    'duration_label': '6 hours',
    'price': 7500,
    'currency': 'EGP',
  },
  // Minimal trips for other guides so profile never shows an empty state
  // when navigating from the list.
  {
    'id': 't3',
    'guide_id': 'g1',
    'title': 'Pyramids at Dawn Private Tour',
    'image_url': 'https://picsum.photos/seed/giza-dawn/200/200',
    'date_label': 'Oct 25, 2026',
    'duration_label': '4 hours',
    'price': 5200,
    'currency': 'EGP',
  },
  {
    'id': 't4',
    'guide_id': 'g1',
    'title': 'Grand Egyptian Museum Walkthrough',
    'image_url': 'https://picsum.photos/seed/gem-museum/200/200',
    'date_label': 'Oct 28, 2026',
    'duration_label': '3 hours',
    'price': 3400,
    'currency': 'EGP',
  },
];

final List<Trip> mockTrips =
    _rawTrips.map((m) => Trip.fromJson(m)).toList(growable: false);

List<Trip> mockTripsForGuide(String guideId) =>
    mockTrips.where((t) => t.guideId == guideId).toList();
