import 'package:triply/core/data/models/public_trip.dart';

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
  final String category;
  final int capacity;

  const Trip({
    required this.id,
    required this.title,
    required this.dateLabel,
    required this.guideName,
    required this.peopleCount,
    required this.priceEgp,
    required this.imageUrl,
    required this.status,
    required this.category,
    required this.capacity,
  });

  /// Builds the card model from the neutral Firestore model.
  factory Trip.fromPublicTrip(PublicTrip trip) {
    return Trip(
      id: trip.id,
      title: trip.title,
      dateLabel: trip.dateLabel,
      guideName: trip.guideName,
      peopleCount: trip.bookedSeats,
      priceEgp: trip.priceEgp,
      imageUrl: trip.imageUrl,
      status: TripStatus.upcoming,
      category: trip.category,
      capacity: trip.capacity,
    );
  }

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
      category: (json['category'] ?? 'historical') as String,
      capacity: (json['capacity'] ?? 12) as int,
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
      'category': category,
      'capacity': capacity,
    };
  }
}
