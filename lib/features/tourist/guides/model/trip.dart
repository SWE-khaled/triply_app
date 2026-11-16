import 'package:triply/core/data/models/public_trip.dart';

/// Trip offered by a guide (shown on GuideProfileScreen).
/// UI consumes this Model, never raw Maps.
class Trip {
  final String id;
  final String guideId;
  final String title;
  final String imageUrl;
  final String dateLabel; // e.g. "Oct 22, 2026" — Figma shows label as-is
  final String durationLabel; // e.g. "5 hours"
  final double price;
  final String currency; // e.g. "EGP"

  /// The maximum number of travelers configured by the guide.
  final int capacity;

  /// How many seats are already booked.
  final int bookedSeats;

  const Trip({
    required this.id,
    required this.guideId,
    required this.title,
    required this.imageUrl,
    required this.dateLabel,
    required this.durationLabel,
    required this.price,
    required this.currency,
    this.capacity = 0,
    this.bookedSeats = 0,
  });

  /// Builds the card model from the neutral Firestore model.
  factory Trip.fromPublicTrip(PublicTrip trip) {
    return Trip(
      id: trip.id,
      guideId: trip.guideId,
      title: trip.title,
      imageUrl: trip.imageUrl,
      dateLabel: trip.dateLabel,
      durationLabel: trip.durationLabel,
      price: trip.priceEgp,
      currency: 'EGP',
      capacity: trip.capacity,
      bookedSeats: trip.bookedSeats,
    );
  }

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String,
      guideId: json['guide_id'] as String,
      title: json['title'] as String,
      imageUrl: json['image_url'] as String? ?? '',
      dateLabel: json['date_label'] as String? ?? '',
      durationLabel: json['duration_label'] as String? ?? '',
      price: (json['price'] as num? ?? 0).toDouble(),
      currency: json['currency'] as String? ?? 'EGP',
      capacity: ((json['capacity'] as num?) ?? 0).toInt(),
      bookedSeats: ((json['bookedSeats'] as num?) ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'guide_id': guideId,
      'title': title,
      'image_url': imageUrl,
      'date_label': dateLabel,
      'duration_label': durationLabel,
      'price': price,
      'currency': currency,
      'capacity': capacity,
      'bookedSeats': bookedSeats,
    };
  }

  //void operator [](String other) {}
}
