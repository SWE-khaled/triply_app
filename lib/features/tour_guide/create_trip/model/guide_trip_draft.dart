/// Form holder for the guide Create Trip flow (mock phase).
/// Nothing is persisted; toJson exists for the future API.
/// Row [id]s are client-only (stable widget keys) and excluded from JSON.
class HighlightDraft {
  final String id;
  final String text;

  const HighlightDraft({required this.id, required this.text});

  HighlightDraft copyWith({String? text}) {
    return HighlightDraft(id: id, text: text ?? this.text);
  }
}

class ItineraryStopDraft {
  final String id;
  final String time;
  final String activity;

  const ItineraryStopDraft({
    required this.id,
    required this.time,
    required this.activity,
  });

  ItineraryStopDraft copyWith({String? time, String? activity}) {
    return ItineraryStopDraft(
      id: id,
      time: time ?? this.time,
      activity: activity ?? this.activity,
    );
  }

  Map<String, dynamic> toJson() => {'time': time, 'activity': activity};
}

class GuideTripDraft {
  final String tripName;
  final String about;
  final String location;
  final String experienceLabel;
  final String date;
  final String startTime;
  final String duration;
  final String price;
  final String maxTravelers;
  final String meetingPoint;
  final List<String> highlights;
  final List<ItineraryStopDraft> itinerary;
  final String included;
  final String notes;
  final String languages;

  const GuideTripDraft({
    required this.tripName,
    required this.about,
    required this.location,
    required this.experienceLabel,
    required this.date,
    required this.startTime,
    required this.duration,
    required this.price,
    required this.maxTravelers,
    required this.meetingPoint,
    required this.highlights,
    required this.itinerary,
    required this.included,
    required this.notes,
    required this.languages,
  });

  Map<String, dynamic> toJson() {
    return {
      'tripName': tripName,
      'about': about,
      'location': location,
      'experienceLabel': experienceLabel,
      'date': date,
      'startTime': startTime,
      'duration': duration,
      'price': price,
      'maxTravelers': maxTravelers,
      'meetingPoint': meetingPoint,
      'highlights': highlights,
      'itinerary': itinerary.map((e) => e.toJson()).toList(),
      'included': included,
      'notes': notes,
      'languages': languages,
    };
  }
}
