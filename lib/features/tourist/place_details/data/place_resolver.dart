import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:triply/core/data/mock/tourist/mock_places.dart';

import '../../map/model/place.dart';

/// Resolves one `places/{placeId}` document for the place screen.
///
/// All four place cubits share one instance so the Firestore read happens
/// once and every section filters against the same place. Failures fall back
/// to the bundled catalog, exactly as the map and the old aggregate cubit did.
class PlaceResolver {
  PlaceResolver({
    required this.placeId,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final String placeId;
  final FirebaseFirestore _firestore;

  Place? _cached;
  Future<Place>? _pending;

  Future<Place> resolve() {
    final cached = _cached;
    if (cached != null) return Future.value(cached);
    final pending = _pending;
    if (pending != null) return pending;
    final future = _fetch();
    _pending = future;
    return future;
  }

  Future<Place> _fetch() async {
    try {
      final doc = await _firestore.collection('places').doc(placeId).get();
      if (doc.exists) {
        final place = Place.fromJson(doc.data()!);
        _cached = place;
        _pending = null;
        return place;
      }
    } catch (_) {
      // Offline / denied / unknown id: the bundled catalog takes over.
    }
    final place = _mockPlace();
    _cached = place;
    _pending = null;
    return place;
  }

  Place _mockPlace() {
    final placeJson = mockPlaces.firstWhere(
      (e) => e['id'] == placeId,
      orElse: () => mockPlaces.first,
    );
    return Place.fromJson(placeJson);
  }
}
