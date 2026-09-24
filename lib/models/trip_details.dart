class ItineraryStop {
  final String time;
  final String title;

  const ItineraryStop({required this.time, required this.title});

  factory ItineraryStop.fromJson(Map<String, dynamic> json) {
    return ItineraryStop(
      time: json['time'] as String,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'time': time, 'title': title};
}

class TripDetails {
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
  final List<ItineraryStop> itinerary;
  final List<String> notes;
  final String meetingPoint;
  final double priceEgp;
  final String guideName;
  final String guideAvatarUrl;
  final double guideRating;
  final int guideReviews;
  final bool topRatedGuide;
  final String imageUrl;

  const TripDetails({
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
    required this.meetingPoint,
    required this.priceEgp,
    required this.guideName,
    required this.guideAvatarUrl,
    required this.guideRating,
    required this.guideReviews,
    required this.topRatedGuide,
    required this.imageUrl,
  });

  factory TripDetails.fromJson(Map<String, dynamic> json) {
    return TripDetails(
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
      highlights:
          (json['highlights'] as List).map((e) => e as String).toList(),
      itinerary: (json['itinerary'] as List)
          .map((e) => ItineraryStop.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: (json['notes'] as List).map((e) => e as String).toList(),
      meetingPoint: json['meetingPoint'] as String,
      priceEgp: (json['priceEgp'] as num).toDouble(),
      guideName: json['guideName'] as String,
      guideAvatarUrl: json['guideAvatarUrl'] as String,
      guideRating: (json['guideRating'] as num).toDouble(),
      guideReviews: json['guideReviews'] as int,
      topRatedGuide: json['topRatedGuide'] as bool,
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
      'meetingPoint': meetingPoint,
      'priceEgp': priceEgp,
      'guideName': guideName,
      'guideAvatarUrl': guideAvatarUrl,
      'guideRating': guideRating,
      'guideReviews': guideReviews,
      'topRatedGuide': topRatedGuide,
      'imageUrl': imageUrl,
    };
  }
}
