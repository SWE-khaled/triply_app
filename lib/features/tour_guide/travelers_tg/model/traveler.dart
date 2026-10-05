class Traveler {
  final String id;
  final String tripId;
  final String name;
  final String tagline;
  final String avatarUrl;
  final String seatsLabel;

  const Traveler({
    required this.id,
    required this.tripId,
    required this.name,
    required this.tagline,
    required this.avatarUrl,
    required this.seatsLabel,
  });

  factory Traveler.fromJson(Map<String, dynamic> json) {
    return Traveler(
      id: json['id'] as String,
      tripId: json['tripId'] as String,
      name: json['name'] as String,
      tagline: json['tagline'] as String,
      avatarUrl: json['avatarUrl'] as String,
      seatsLabel: json['seatsLabel'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'name': name,
      'tagline': tagline,
      'avatarUrl': avatarUrl,
      'seatsLabel': seatsLabel,
    };
  }
}
