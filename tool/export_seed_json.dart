// Exports Firestore-ready seed JSON from the existing mock datasets.
// Pure Dart (dart:io + dart:convert + mock sources only) — run with:
//   dart run tool/export_seed_json.dart
// Output: tool/seed_data/places.json, trips.json
// Nothing is uploaded; the Node seed script consumes this JSON explicitly.

import 'dart:convert';
import 'dart:io';

import 'package:triply/core/data/mock/tourist/mock_places.dart';
import 'package:triply/core/data/mock/tourist/mock_trips_public.dart';

Future<void> main() async {
  final outDir = Directory('tool/seed_data');
  if (!outDir.existsSync()) outDir.createSync(recursive: true);

  // Places → canonical PlaceDoc shape (stable mock IDs preserved).
  final places = mockPlaces.map((m) {
    final map = Map<String, dynamic>.from(m);
    final name = (map['name'] ?? '').toString();
    final imgs = <String>[];
    final hero = (map['image_url'] ?? '').toString();
    if (hero.isNotEmpty) imgs.add(hero);
    return {
      'id': map['id'],
      'name': map['name'],
      'city': map['city'] ?? '',
      'country': map['country'] ?? 'Egypt',
      'category': (map['category'] ?? 'historical').toString().toLowerCase(),
      'type': map['type'] ?? 'place',
      'address': map['address'] ?? '',
      'latitude': (map['latitude'] as num?)?.toDouble() ?? 0,
      'longitude': (map['longitude'] as num?)?.toDouble() ?? 0,
      'rating': (map['rating'] as num?)?.toDouble() ?? 0,
      'reviewsCount': map['reviews_count'] ?? map['reviewsCount'] ?? 0,
      'shortDescription':
          map['short_description'] ?? map['shortDescription'] ?? '',
      'about': map['about'] ?? '',
      'highlights': (map['highlights'] as List?)?.map((e) => e.toString()).toList() ?? [],
      'imageUrl': hero,
      'imageUrls': imgs,
      'nameLower': name.toLowerCase(),
      'cityLower': (map['city'] ?? '').toString().toLowerCase(),
    };
  }).toList();

  // Public trips → canonical TripDoc shape. NOTE: guideId is unknown for
  // mock trips (only guideName exists) — left empty for manual attribution
  // during import; approvalStatus defaults pending for admin review.
  final trips = mockTripsJson.map((m) {
    final map = Map<String, dynamic>.from(m);
    final title = (map['title'] ?? '').toString();
    final cover = (map['imageUrl'] ?? map['image_url'] ?? '').toString();
    return {
      'id': map['id'],
      'guideId': '',
      'guideName': map['guideName'] ?? '',
      'placeId': '',
      'title': title,
      'description': '',
      'location': 'Egypt',
      'dateLabel': map['dateLabel'] ?? '',
      'priceEgp': (map['priceEgp'] as num?)?.toDouble() ?? 0,
      'currency': 'EGP',
      'capacity': map['capacity'] ?? 12,
      'meetingPoint': '',
      'included': [],
      'highlights': [],
      'itinerary': [],
      'notes': [],
      'languages': [],
      'coverImageUrl': cover,
      'imageUrls': cover.isEmpty ? [] : [cover],
      'category': (map['category'] ?? 'historical').toString().toLowerCase(),
      'titleLower': title.toLowerCase(),
    };
  }).toList();

  File('tool/seed_data/places.json')
      .writeAsStringSync(const JsonEncoder.withIndent('  ').convert(places));
  File('tool/seed_data/trips.json')
      .writeAsStringSync(const JsonEncoder.withIndent('  ').convert(trips));

  stdout.writeln('Exported ${places.length} places, ${trips.length} trips to tool/seed_data/.');
  stdout.writeln('Review the JSON, then run the guarded importer:');
  stdout.writeln('  node tool/seed_firestore.js --dry-run');
}
