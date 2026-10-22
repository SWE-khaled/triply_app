/// One stop of the itinerary of a trip.
class PublicItineraryStop {
  final String time;
  final String title;

  const PublicItineraryStop({required this.time, required this.title});

  factory PublicItineraryStop.fromMap(Map<String, dynamic> map) {
    return PublicItineraryStop(
      time: map['time']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() => {'time': time, 'title': title};
}

/// A trip the tourists may book — the neutral shape every tourist screen
/// maps from.
///
/// The three tourist features each have their own `Trip` model (a card
/// shows different fields on each screen). The repository reads Firestore
/// into this one neutral model, and every feature converts it into its
/// own model — so the core never has to know about the screens.
class PublicTrip {
  final String id;

  /// The uid of the guide who published the trip.
  final String guideId;

  final String title;
  final String location;

  /// The human readable moment, e.g. "Oct 15, 2026 · 6:00 AM".
  final String dateLabel;

  /// The length of the trip, e.g. "4 hours".
  final String durationLabel;

  final String imageUrl;
  final String guideName;

  /// The free-text tag the guide typed. The tourist screens filter by
  /// category, so the tag is mapped onto one.
  final String tag;

  final double priceEgp;

  /// How many travelers the trip accepts.
  final int capacity;

  /// How many seats are already booked.
  final int bookedSeats;

  // ── the long form details ────────────────────────────────────────────
  final double rating;
  final int reviewsCount;
  final String groupType;
  final String languages;
  final String about;
  final List<String> highlights;
  final List<PublicItineraryStop> itinerary;
  final List<String> notes;
  final String included;
  final String meetingPoint;
  final double guideRating;
  final int guideReviews;
  final String guideAvatarUrl;

  const PublicTrip({
    required this.id,
    required this.guideId,
    required this.title,
    required this.location,
    required this.dateLabel,
    required this.durationLabel,
    required this.imageUrl,
    required this.guideName,
    required this.tag,
    required this.priceEgp,
    required this.capacity,
    required this.bookedSeats,
    this.rating = 0,
    this.reviewsCount = 0,
    this.groupType = '',
    this.languages = '',
    this.about = '',
    this.highlights = const [],
    this.itinerary = const [],
    this.notes = const [],
    this.included = '',
    this.meetingPoint = '',
    this.guideRating = 0,
    this.guideReviews = 0,
    this.guideAvatarUrl = '',
  });

  /// The seats still free.
  int get availableSeats => capacity - bookedSeats;

  /// A guide with a high rating is the one the tourist screen flags.
  bool get topRatedGuide => guideRating >= 4.8;

  /// The category the tourist screens filter by.
  ///
  /// The trip document only carries a free-text tag, so it is mapped here
  /// — in one place, instead of in every screen.
  String get category {
    final text = tag.toLowerCase();
    if (text.contains('activit') ||
        text.contains('adventure') ||
        text.contains('sport') ||
        text.contains('water')) {
      return 'activities';
    }
    if (text.contains('natur') ||
        text.contains('desert') ||
        text.contains('mountain') ||
        text.contains('camel')) {
      return 'nature';
    }
    if (text.contains('food') ||
        text.contains('culinary') ||
        text.contains('restaurant') ||
        text.contains('cook')) {
      return 'food';
    }
    return 'historical';
  }

  /// Reads a trip document, tolerating every missing field.
  factory PublicTrip.fromDocument(Map<String, dynamic>? data, String id) {
    final merged = <String, dynamic>{
      'id': id,
      'guideId': '',
      'title': '',
      'location': '',
      'scheduleLabel': '',
      'duration': '',
      'imageUrl': '',
      'guideName': '',
      'guideAvatarUrl': '',
      'tag': '',
      'priceEgp': 0,
      'capacity': 0,
      'bookedSeats': 0,
      'rating': 0,
      'reviewsCount': 0,
      'groupType': '',
      'languages': '',
      'about': '',
      'highlights': const <String>[],
      'itinerary': const <Map<String, dynamic>>[],
      'notes': const <String>[],
      'included': '',
      'meetingPoint': '',
      'guideRating': 0,
      'guideReviews': 0,
      ...?data,
    };
    merged['id'] = id;
    return PublicTrip(
      id: id,
      guideId: (merged['guideId'] as String?) ?? '',
      title: (merged['title'] as String?) ?? '',
      location: (merged['location'] as String?) ?? '',
      dateLabel: (merged['scheduleLabel'] as String?) ?? '',
      durationLabel: (merged['duration'] as String?) ?? '',
      imageUrl: (merged['imageUrl'] as String?) ?? '',
      guideName: (merged['guideName'] as String?) ?? '',
      guideAvatarUrl: (merged['guideAvatarUrl'] as String?) ?? '',
      tag: (merged['tag'] as String?) ?? '',
      priceEgp: ((merged['priceEgp'] as num?) ?? 0).toDouble(),
      capacity: ((merged['capacity'] as num?) ?? 0).toInt(),
      bookedSeats: ((merged['bookedSeats'] as num?) ?? 0).toInt(),
      rating: ((merged['rating'] as num?) ?? 0).toDouble(),
      reviewsCount: ((merged['reviewsCount'] as num?) ?? 0).toInt(),
      groupType: (merged['groupType'] as String?) ?? '',
      languages: (merged['languages'] as String?) ?? '',
      about: (merged['about'] as String?) ?? '',
      highlights: _strings(merged['highlights']),
      itinerary: _itinerary(merged['itinerary']),
      notes: _strings(merged['notes']),
      included: (merged['included'] as String?) ?? '',
      meetingPoint: (merged['meetingPoint'] as String?) ?? '',
      guideRating: ((merged['guideRating'] as num?) ?? 0).toDouble(),
      guideReviews: ((merged['guideReviews'] as num?) ?? 0).toInt(),
    );
  }

  static List<String> _strings(Object? raw) {
    if (raw is! List) return const [];
    return raw.map((e) => e.toString()).toList();
  }

  static List<PublicItineraryStop> _itinerary(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => PublicItineraryStop.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }
}
