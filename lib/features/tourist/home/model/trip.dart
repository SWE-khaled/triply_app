import 'package:triply/core/data/models/public_trip.dart';

class Trip {
  final String id;
  final String title;
  final String imageUrl;
  final String duration;
  final String location;
  final double price;

  /// The moment of the trip — the card does not show it, but the trip
  /// details and the booking need it.
  final String dateLabel;

  /// The guide who published the trip.
  final String guideName;

  /// How many travelers the trip accepts.
  final int capacity;

  const Trip({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.duration,
    required this.location,
    required this.price,
    this.dateLabel = '',
    this.guideName = '',
    this.capacity = 12,
  });

  /// Builds the card model from the neutral Firestore model.
  factory Trip.fromPublicTrip(PublicTrip trip) {
    return Trip(
      id: trip.id,
      title: trip.title,
      imageUrl: trip.imageUrl,
      duration: trip.durationLabel,
      location: trip.location,
      price: trip.priceEgp,
      dateLabel: trip.dateLabel,
      guideName: trip.guideName,
      capacity: trip.capacity,
    );
  }

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String,
      title: json['title'] as String,
      imageUrl: json['image_url'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      location: json['location'] as String? ?? '',
      price: (json['price'] as num? ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image_url': imageUrl,
      'duration': duration,
      'location': location,
      'price': price,
    };
  }
}
