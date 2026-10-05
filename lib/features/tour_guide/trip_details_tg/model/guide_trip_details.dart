class GuideItineraryStop {
  final String time;
  final String title;

  const GuideItineraryStop({required this.time, required this.title});

  factory GuideItineraryStop.fromJson(Map<String, dynamic> json) {
    return GuideItineraryStop(
      time: json['time'] as String,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'time': time, 'title': title};
}

class GuideTripDetails {
  final String id;
  final String tripId;
  final String tag;
  final String title;
  final double rating;
  final int reviewsCount;
  final String location;
  final String duration;
  final String groupType;
  final String languages;
  final String about;
  final List<String> highlights;
  final List<GuideItineraryStop> itinerary;
  final List<String> notes;
  final String included;
  final String meetingPoint;
  final double priceEgp;
  final String guideName;
  final String guideAvatarUrl;
  final double guideRating;
  final int guideReviews;
  final String imageUrl;

  const GuideTripDetails({
    required this.id,
    required this.tripId,
    required this.tag,
    required this.title,
    required this.rating,
    required this.reviewsCount,
    required this.location,
    required this.duration,
    required this.groupType,
    required this.languages,
    required this.about,
    required this.highlights,
    required this.itinerary,
    required this.notes,
    required this.included,
    required this.meetingPoint,
    required this.priceEgp,
    required this.guideName,
    required this.guideAvatarUrl,
    required this.guideRating,
    required this.guideReviews,
    required this.imageUrl,
  });

  factory GuideTripDetails.fromJson(Map<String, dynamic> json) {
    return GuideTripDetails(
      id: json['id'] as String,
      tripId: json['tripId'] as String,
      tag: json['tag'] as String,
      title: json['title'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewsCount: json['reviewsCount'] as int,
      location: json['location'] as String,
      duration: json['duration'] as String,
      groupType: json['groupType'] as String,
      languages: json['languages'] as String,
      about: json['about'] as String,
      highlights: (json['highlights'] as List).map((e) => e as String).toList(),
      itinerary: (json['itinerary'] as List)
          .map((e) => GuideItineraryStop.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: (json['notes'] as List).map((e) => e as String).toList(),
      included: json['included'] as String,
      meetingPoint: json['meetingPoint'] as String,
      priceEgp: (json['priceEgp'] as num).toDouble(),
      guideName: json['guideName'] as String,
      guideAvatarUrl: json['guideAvatarUrl'] as String,
      guideRating: (json['guideRating'] as num).toDouble(),
      guideReviews: json['guideReviews'] as int,
      imageUrl: json['imageUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'tag': tag,
      'title': title,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'location': location,
      'duration': duration,
      'groupType': groupType,
      'languages': languages,
      'about': about,
      'highlights': highlights,
      'itinerary': itinerary.map((e) => e.toJson()).toList(),
      'notes': notes,
      'included': included,
      'meetingPoint': meetingPoint,
      'priceEgp': priceEgp,
      'guideName': guideName,
      'guideAvatarUrl': guideAvatarUrl,
      'guideRating': guideRating,
      'guideReviews': guideReviews,
      'imageUrl': imageUrl,
    };
  }
}
