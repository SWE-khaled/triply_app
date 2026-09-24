enum TripStatus { upcoming, ongoing, completed, cancelled }

class Trip {
  final String id;
  final String title;
  final String dateLabel;
  final String guideName;
  final int peopleCount;
  final double priceEgp;
  final String imageUrl;
  final TripStatus status;

  const Trip({
    required this.id,
    required this.title,
    required this.dateLabel,
    required this.guideName,
    required this.peopleCount,
    required this.priceEgp,
    required this.imageUrl,
    required this.status,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String,
      title: json['title'] as String,
      dateLabel: json['dateLabel'] as String,
      guideName: json['guideName'] as String,
      peopleCount: json['peopleCount'] as int,
      priceEgp: (json['priceEgp'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      status: TripStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TripStatus.upcoming,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dateLabel': dateLabel,
      'guideName': guideName,
      'peopleCount': peopleCount,
      'priceEgp': priceEgp,
      'imageUrl': imageUrl,
      'status': status.name,
    };
  }
}
