import '../../../../core/data/repositories/admin_trips_repository.dart';

/// Data model for trip applications in the admin dashboard.
class AdminTripApplication {
  final String tripId;
  final String tripTitle;
  final String guide;
  final String date;
  final String price;
  final String status;
  final String type;
  final int travelers;
  final String location;
  final List<String> itinerary;
  final List<String> participants;
  final String imageUrl;
  final String rejectionReason;

  const AdminTripApplication({
    required this.tripId,
    required this.tripTitle,
    required this.guide,
    required this.date,
    required this.price,
    required this.status,
    required this.type,
    required this.travelers,
    this.location = '',
    this.itinerary = const [],
    this.participants = const [],
    this.imageUrl = '',
    this.rejectionReason = '',
  });

  /// Maps a Firestore trip onto the application row the table renders.
  factory AdminTripApplication.fromAdminTrip(AdminTrip trip) {
    return AdminTripApplication(
      tripId: trip.tripId,
      tripTitle: trip.title.isNotEmpty ? trip.title : 'Trip Application',
      guide: trip.guideName.isNotEmpty ? trip.guideName : 'Tour Guide',
      date: trip.scheduleLabel.isNotEmpty ? trip.scheduleLabel : 'Upcoming',
      price: trip.priceLabel,
      status: trip.approvalStatus,
      type: 'public',
      travelers: trip.travelers,
      location: trip.location,
      itinerary: trip.itinerary,
      participants: const [],
      imageUrl: trip.imageUrl,
      rejectionReason: trip.rejectionReason,
    );
  }

  AdminTripApplication copyWith({
    String? tripId,
    String? tripTitle,
    String? guide,
    String? date,
    String? price,
    String? status,
    String? type,
    int? travelers,
    String? location,
    List<String>? itinerary,
    List<String>? participants,
    String? imageUrl,
    String? rejectionReason,
  }) {
    return AdminTripApplication(
      tripId: tripId ?? this.tripId,
      tripTitle: tripTitle ?? this.tripTitle,
      guide: guide ?? this.guide,
      date: date ?? this.date,
      price: price ?? this.price,
      status: status ?? this.status,
      type: type ?? this.type,
      travelers: travelers ?? this.travelers,
      location: location ?? this.location,
      itinerary: itinerary ?? this.itinerary,
      participants: participants ?? this.participants,
      imageUrl: imageUrl ?? this.imageUrl,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}
