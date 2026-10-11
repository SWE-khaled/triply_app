import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:triply/core/firebase/firestore_converters.dart';

/// Canonical `trips/{tripId}` document — ONE record for both tourist and
/// guide views of the same trip (replaces the mock-phase split between
/// `Trip` / `GuideTrip` / `TripDetails` static lists).
///
/// - `guideId`: owner (users/{uid} with role guide).
/// - `approvalStatus`: pending | approved | rejected | cancelled (admin-owned).
/// - Tourist list queries filter `approvalStatus == approved`; guide
///   "my trips" queries filter `guideId == me`.
/// - `bookedSeats` is maintained by the `createBooking` Function transaction,
///   never by clients.
class TripDoc {
  final String id;
  final String guideId;
  final String guideName;
  final String placeId;
  final String title;
  final String description;
  final String location;
  final String dateLabel;
  final String startTime;
  final String duration;
  final double priceEgp;
  final String currency;
  final int capacity;
  final int bookedSeats;
  final int peopleCount;
  final String meetingPoint;
  final List<String> included;
  final List<String> highlights;
  final List<Map<String, dynamic>> itinerary;
  final List<String> notes;
  final List<String> languages;
  final String coverImageUrl;
  final List<String> imageUrls;
  final String category;
  final String approvalStatus;
  final String rejectionReason;
  // Rating aggregates maintained by the `onReviewWritten` Function
  // (`trips/{id} {rating, reviewsCount}`). Absent until the first review.
  final double rating;
  final int reviewsCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TripDoc({
    required this.id,
    required this.guideId,
    this.guideName = '',
    this.placeId = '',
    required this.title,
    this.description = '',
    this.location = 'Egypt',
    this.dateLabel = '',
    this.startTime = '',
    this.duration = '',
    this.priceEgp = 0,
    this.currency = 'EGP',
    this.capacity = 12,
    this.bookedSeats = 0,
    this.peopleCount = 0,
    this.meetingPoint = '',
    this.included = const [],
    this.highlights = const [],
    this.itinerary = const [],
    this.notes = const [],
    this.languages = const [],
    this.coverImageUrl = '',
    this.imageUrls = const [],
    this.category = 'historical',
    this.approvalStatus = 'pending',
    this.rejectionReason = '',
    this.rating = 0,
    this.reviewsCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  int get availableSeats => (capacity - bookedSeats).clamp(0, capacity);

  factory TripDoc.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return TripDoc.fromMap(d, doc.id);
  }

  factory TripDoc.fromMap(Map<String, dynamic> d, String id) {
    final includedRaw = d['included'];
    final List<String> included = includedRaw is List
        ? includedRaw.map((e) => e.toString()).toList()
        : includedRaw is String && includedRaw.trim().isNotEmpty
        ? [includedRaw.trim()]
        : const [];
    return TripDoc(
      id: FirestoreConverters.toStr(d['id'], id),
      guideId: FirestoreConverters.toStr(d['guideId'] ?? d['guide_id']),
      guideName: FirestoreConverters.toStr(d['guideName']),
      placeId: FirestoreConverters.toStr(d['placeId']),
      title: FirestoreConverters.toStr(d['title'] ?? d['tripName']),
      description: FirestoreConverters.toStr(d['description'] ?? d['about']),
      location: FirestoreConverters.toStr(d['location'], 'Egypt'),
      dateLabel: FirestoreConverters.toStr(
        d['dateLabel'] ?? d['date'] ?? d['scheduleLabel'],
      ),
      startTime: FirestoreConverters.toStr(d['startTime']),
      duration: FirestoreConverters.toStr(d['duration']),
      priceEgp: FirestoreConverters.toDouble(
        d['priceEgp'] ?? d['price'] ?? d['pricePerHour'],
      ),
      currency: FirestoreConverters.toStr(d['currency'], 'EGP'),
      capacity: FirestoreConverters.toInt(
        d['capacity'] ?? d['maxTravelers'],
        12,
      ),
      bookedSeats: FirestoreConverters.toInt(
        d['bookedSeats'] ?? d['peopleCount'],
      ),
      peopleCount: FirestoreConverters.toInt(d['peopleCount']),
      meetingPoint: FirestoreConverters.toStr(
        d['meetingPoint'] ?? d['meeting_point'],
      ),
      included: included,
      highlights: FirestoreConverters.toStringList(d['highlights']),
      itinerary: FirestoreConverters.toMapList(d['itinerary']),
      notes: FirestoreConverters.toStringList(d['notes']),
      languages: d['languages'] is List
          ? FirestoreConverters.toStringList(d['languages'])
          : (d['languages'] is String &&
                    (d['languages'] as String).trim().isNotEmpty
                ? [(d['languages'] as String).trim()]
                : const []),
      coverImageUrl: FirestoreConverters.toStr(
        d['coverImageUrl'] ?? d['imageUrl'] ?? d['image_url'],
      ),
      imageUrls: FirestoreConverters.toStringList(
        d['imageUrls'] ?? d['image_urls'],
      ),
      category: FirestoreConverters.toStr(d['category'], 'historical'),
      approvalStatus: FirestoreConverters.toStr(
        d['approvalStatus'] ?? d['status'],
        'pending',
      ),
      rejectionReason: FirestoreConverters.toStr(d['rejectionReason']),
      rating: FirestoreConverters.toDouble(d['rating']),
      reviewsCount: FirestoreConverters.toInt(d['reviewsCount']),
      createdAt: FirestoreConverters.toDateTime(d['createdAt']),
      updatedAt: FirestoreConverters.toDateTime(d['updatedAt']),
    );
  }

  /// Client create payload — excludes server-owned `bookedSeats`,
  /// `approvalStatus`, timestamps (rules enforce this too).
  Map<String, dynamic> toCreateMap() {
    return {
      'guideId': guideId,
      'guideName': guideName,
      'placeId': placeId,
      'title': title,
      'description': description,
      'location': location,
      'dateLabel': dateLabel,
      'startTime': startTime,
      'duration': duration,
      'priceEgp': priceEgp,
      'currency': currency,
      'capacity': capacity,
      'meetingPoint': meetingPoint,
      'included': included,
      'highlights': highlights,
      'itinerary': itinerary,
      'notes': notes,
      'languages': languages,
      'coverImageUrl': coverImageUrl,
      'imageUrls': imageUrls,
      'category': category,
      'titleLower': title.toLowerCase(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'guideId': guideId,
      'guideName': guideName,
      'placeId': placeId,
      'title': title,
      'description': description,
      'location': location,
      'dateLabel': dateLabel,
      'startTime': startTime,
      'duration': duration,
      'priceEgp': priceEgp,
      'currency': currency,
      'capacity': capacity,
      'bookedSeats': bookedSeats,
      'peopleCount': peopleCount,
      'meetingPoint': meetingPoint,
      'included': included,
      'highlights': highlights,
      'itinerary': itinerary,
      'notes': notes,
      'languages': languages,
      'coverImageUrl': coverImageUrl,
      'imageUrls': imageUrls,
      'category': category,
      'approvalStatus': approvalStatus,
      'rejectionReason': rejectionReason,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
