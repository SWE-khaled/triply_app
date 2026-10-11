import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:triply/core/firebase/firestore_converters.dart';

/// Canonical `places/{placeId}` document.
///
/// Reuses stable mock IDs (`mockPlaces[].id`) so `PlaceDetailScreen(placeId)`
/// navigation keeps working after migration. `geo` is the queryable point;
/// `latitude`/`longitude` are kept as plain numbers for existing
/// `Place.fromJson` compat.
class PlaceDoc {
  final String id;
  final String name;
  final String city;
  final String country;
  final String category;
  final String type;
  final String address;
  final double latitude;
  final double longitude;
  final double rating;
  final int reviewsCount;
  final String shortDescription;
  final String about;
  final List<String> highlights;
  final String imageUrl;
  final List<String> imageUrls;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PlaceDoc({
    required this.id,
    required this.name,
    this.city = '',
    this.country = 'Egypt',
    this.category = 'historical',
    this.type = 'place',
    this.address = '',
    this.latitude = 0,
    this.longitude = 0,
    this.rating = 0,
    this.reviewsCount = 0,
    this.shortDescription = '',
    this.about = '',
    this.highlights = const [],
    this.imageUrl = '',
    this.imageUrls = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory PlaceDoc.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? {};
    return PlaceDoc.fromMap(d, doc.id);
  }

  factory PlaceDoc.fromMap(Map<String, dynamic> d, String id) {
    final latLng = FirestoreConverters.toLatLng(d);
    final imgs = FirestoreConverters.toStringList(
      d['imageUrls'] ?? d['image_urls'],
    );
    final hero = FirestoreConverters.toStr(
      d['imageUrl'] ?? d['image_url'],
      imgs.isNotEmpty ? imgs.first : '',
    );
    return PlaceDoc(
      id: FirestoreConverters.toStr(d['id'], id),
      name: FirestoreConverters.toStr(d['name']),
      city: FirestoreConverters.toStr(d['city']),
      country: FirestoreConverters.toStr(d['country'], 'Egypt'),
      category: FirestoreConverters.toStr(d['category'], 'historical'),
      type: FirestoreConverters.toStr(d['type'], 'place'),
      address: FirestoreConverters.toStr(d['address']),
      latitude: latLng.lat,
      longitude: latLng.lng,
      rating: FirestoreConverters.toDouble(d['rating']),
      reviewsCount: FirestoreConverters.toInt(
        d['reviewsCount'] ?? d['reviews_count'],
      ),
      shortDescription: FirestoreConverters.toStr(
        d['shortDescription'] ?? d['short_description'],
      ),
      about: FirestoreConverters.toStr(d['about']),
      highlights: FirestoreConverters.toStringList(d['highlights']),
      imageUrl: hero,
      imageUrls: imgs.isNotEmpty ? imgs : (hero.isEmpty ? const [] : [hero]),
      createdAt: FirestoreConverters.toDateTime(d['createdAt']),
      updatedAt: FirestoreConverters.toDateTime(d['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'country': country,
      'category': category,
      'type': type,
      'address': address,
      'geo': GeoPoint(latitude, longitude),
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'shortDescription': shortDescription,
      'about': about,
      'highlights': highlights,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'nameLower': name.toLowerCase(),
      'cityLower': city.toLowerCase(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
