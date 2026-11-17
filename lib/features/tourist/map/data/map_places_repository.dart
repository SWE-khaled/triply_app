import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/place.dart';

/// Reads the shared `places` catalog used by the tourist map.
///
/// The query and mapping are unchanged from the original MapCubit; only the
/// Firestore access now lives behind a repository boundary.
class MapPlacesRepository {
  MapPlacesRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<Place>> fetchPlaces() async {
    final snapshot = await _firestore.collection('places').get();
    return snapshot.docs.map((doc) => Place.fromJson(doc.data())).toList();
  }
}
