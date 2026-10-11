import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:triply/core/firebase/firestore_converters.dart';

/// Canonical `guideProfiles/{uid}` document (uid == users/{uid}).
///
/// Holds guide-specific public fields only; identity fields stay in `users`.
/// `isVerified`/`canPublishTrips` are server-owned (rules reject client
/// writes); clients may update about/location/languages/pricing/cover.
///
/// `displayName` + `contactPhone` are intentionally PUBLIC: the trip-details
/// screen already shows the guide's contact number to any tourist
/// (`getGuidePhoneByName`), a lookup that stops working under the deployed
/// `users` list rules. Guides supply both at guide signup for this purpose.
/// Existing docs without them need the documented backfill (seed/migration).
class GuideProfileDoc {
  final String userId;
  final String displayName;
  final String contactPhone;
  final String about;
  final String location;
  final List<String> languages;
  final String specialty;
  final double pricePerHour;
  final String currency;
  final String coverUrl;
  final double ratingAvg;
  final int ratingCount;
  final bool isVerified;
  final bool canPublishTrips;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const GuideProfileDoc({
    required this.userId,
    this.displayName = '',
    this.contactPhone = '',
    this.about = '',
    this.location = '',
    this.languages = const [],
    this.specialty = '',
    this.pricePerHour = 0,
    this.currency = '\$',
    this.coverUrl = '',
    this.ratingAvg = 0,
    this.ratingCount = 0,
    this.isVerified = false,
    this.canPublishTrips = false,
    this.createdAt,
    this.updatedAt,
  });

  factory GuideProfileDoc.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? {};
    return GuideProfileDoc.fromMap(d, doc.id);
  }

  factory GuideProfileDoc.fromMap(Map<String, dynamic> d, String userId) {
    return GuideProfileDoc(
      userId: FirestoreConverters.toStr(d['userId'], userId),
      displayName: FirestoreConverters.toStr(
        d['displayName'] ?? d['name'],
      ),
      contactPhone: FirestoreConverters.toStr(
        d['contactPhone'] ?? d['phone'],
      ),
      about: FirestoreConverters.toStr(d['about']),
      location: FirestoreConverters.toStr(d['location']),
      languages: FirestoreConverters.toStringList(d['languages']),
      specialty: FirestoreConverters.toStr(d['specialty']),
      pricePerHour: FirestoreConverters.toDouble(
        d['pricePerHour'] ?? d['price_per_hour'],
      ),
      currency: FirestoreConverters.toStr(d['currency'], '\$'),
      coverUrl: FirestoreConverters.toStr(
        d['coverUrl'] ?? d['cover_url'] ?? d['avatarUrl'],
      ),
      ratingAvg: FirestoreConverters.toDouble(
        d['ratingAvg'] ?? d['rating'],
      ),
      ratingCount: FirestoreConverters.toInt(
        d['ratingCount'] ?? d['reviewCount'] ?? d['review_count'],
      ),
      isVerified: FirestoreConverters.toBool(
        d['isVerified'] ?? d['is_verified'],
      ),
      canPublishTrips: FirestoreConverters.toBool(d['canPublishTrips']),
      createdAt: FirestoreConverters.toDateTime(d['createdAt']),
      updatedAt: FirestoreConverters.toDateTime(d['updatedAt']),
    );
  }

  /// Client-safe payload (excludes server-owned verification/rating fields).
  Map<String, dynamic> toClientMap() {
    return {
      'userId': userId,
      'displayName': displayName,
      'contactPhone': contactPhone,
      'about': about,
      'location': location,
      'languages': languages,
      'specialty': specialty,
      'pricePerHour': pricePerHour,
      'currency': currency,
      'coverUrl': coverUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'displayName': displayName,
      'contactPhone': contactPhone,
      'about': about,
      'location': location,
      'languages': languages,
      'specialty': specialty,
      'pricePerHour': pricePerHour,
      'currency': currency,
      'coverUrl': coverUrl,
      'ratingAvg': ratingAvg,
      'ratingCount': ratingCount,
      'isVerified': isVerified,
      'canPublishTrips': canPublishTrips,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
