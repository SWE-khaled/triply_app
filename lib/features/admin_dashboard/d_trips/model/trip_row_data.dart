import '../../../../core/data/repositories/admin_trips_repository.dart';

/// Row data model for trips in the admin dashboard.
class TripRowData {
  final String tripId;
  final String title;
  final String guide;
  final String date;
  final int travelers;
  final String price;
  final String status;
  final String location;
  final String about;
  final List<String> itinerary;
  final String imageUrl;
  final String rejectionReason;

  const TripRowData({
    required this.tripId,
    required this.title,
    required this.guide,
    required this.date,
    required this.travelers,
    required this.price,
    required this.status,
    this.location = '',
    this.about = '',
    this.itinerary = const [],
    this.imageUrl = '',
    this.rejectionReason = '',
  });

  /// Maps a Firestore trip onto the row the table renders.
  factory TripRowData.fromAdminTrip(AdminTrip trip) {
    return TripRowData(
      tripId: trip.tripId,
      title: trip.title,
      guide: trip.guideName.isNotEmpty ? trip.guideName : 'Tour Guide',
      date: trip.scheduleLabel.isNotEmpty ? trip.scheduleLabel : 'Scheduled',
      travelers: trip.travelers,
      price: trip.priceLabel,
      status: trip.approvalStatus,
      location: trip.location,
      about: trip.about,
      itinerary: trip.itinerary,
      imageUrl: trip.imageUrl,
      rejectionReason: trip.rejectionReason,
    );
  }

  TripRowData copyWith({
    String? tripId,
    String? title,
    String? guide,
    String? date,
    int? travelers,
    String? price,
    String? status,
    String? location,
    String? about,
    List<String>? itinerary,
    String? imageUrl,
    String? rejectionReason,
  }) {
    return TripRowData(
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      guide: guide ?? this.guide,
      date: date ?? this.date,
      travelers: travelers ?? this.travelers,
      price: price ?? this.price,
      status: status ?? this.status,
      location: location ?? this.location,
      about: about ?? this.about,
      itinerary: itinerary ?? this.itinerary,
      imageUrl: imageUrl ?? this.imageUrl,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}
