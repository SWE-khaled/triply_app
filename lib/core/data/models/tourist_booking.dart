import 'package:cloud_firestore/cloud_firestore.dart';

/// A booking the signed-in tourist made.
///
/// The booking carries the trip it belongs to, the seats that were taken
/// and what was paid — everything the "My Trips" list shows.
class TouristBooking {
  final String id;

  /// The trip that was booked.
  final String tripId;

  /// The title of the trip at the time of the booking.
  final String tourTitle;

  /// Whether this booking is for a guide rather than a published trip.
  final bool isPrivate;

  final String guideId;
  final String guideName;
  final String imageUrl;
  final String dateLabel;

  /// How many seats were taken.
  final int seats;

  /// What the tourist paid.
  final double totalPrice;

  /// The workflow state of the booking, e.g. `pending` or `confirmed`.
  final String status;

  /// `pending` or `paid` — whether payment has been confirmed.
  final String paymentStatus;

  /// When an unpaid `pending` booking expires (now + 30 min at creation).
  final DateTime? expiresAt;

  /// The booked moment's end (private trips); `null` for public trips until
  /// trips require an end date (see S2).
  final DateTime? endAt;

  const TouristBooking({
    required this.id,
    required this.tripId,
    required this.tourTitle,
    required this.seats,
    required this.totalPrice,
    required this.status,
    this.isPrivate = false,
    this.guideId = '',
    this.guideName = '',
    this.imageUrl = '',
    this.dateLabel = '',
    this.paymentStatus = '',
    this.expiresAt,
    this.endAt,
  });

  /// Reads a booking document, tolerating every missing field.
  factory TouristBooking.fromDocument(Map<String, dynamic>? data, String id) {
    final merged = <String, dynamic>{
      'id': id,
      'tripId': '',
      'tour_title': '',
      'seats': 0,
      'traveler_count': 0,
      'totalPrice': 0,
      'status': '',
      'paymentStatus': '',
      ...?data,
    };
    merged['id'] = id;
    // The seat count lives in `seats`; older documents used
    // `traveler_count` — the raw document decides, not the defaults.
    final seats =
        (data?['seats'] as num?) ?? (data?['traveler_count'] as num?) ?? 0;
    final tripId = (merged['tripId'] as String?) ?? '';
    final tourTitle = (merged['tour_title'] as String?) ?? '';
    final rawGuideName = (data?['guideName'] as String?)?.trim() ?? '';
    final guideName = rawGuideName.isNotEmpty
        ? rawGuideName
        : tourTitle.startsWith('Private tour with ')
        ? tourTitle.substring('Private tour with '.length)
        : '';
    final startAt = merged['startAt'] is Timestamp
        ? (merged['startAt'] as Timestamp).toDate()
        : null;
    final storedDateLabel = (data?['datetime_label'] as String?)?.trim() ?? '';
    final dateLabel = storedDateLabel.isNotEmpty
        ? storedDateLabel
        : startAt == null
        ? ''
        : '${startAt.year}-'
              '${startAt.month.toString().padLeft(2, '0')}-'
              '${startAt.day.toString().padLeft(2, '0')}';
    return TouristBooking(
      id: id,
      tripId: tripId,
      tourTitle: tourTitle,
      seats: seats.toInt(),
      totalPrice: ((merged['totalPrice'] as num?) ?? 0).toDouble(),
      status: (merged['status'] as String?) ?? '',
      isPrivate:
          data?['is_private'] == true ||
          (tripId.isEmpty && tourTitle.isNotEmpty),
      guideId: (data?['guideId'] as String?) ?? '',
      guideName: guideName,
      imageUrl: (data?['guide_image_url'] as String?) ?? '',
      dateLabel: dateLabel,
      paymentStatus: (merged['paymentStatus'] as String?) ?? '',
      expiresAt: merged['expiresAt'] is Timestamp
          ? (merged['expiresAt'] as Timestamp).toDate()
          : null,
      endAt: merged['endAt'] is Timestamp
          ? (merged['endAt'] as Timestamp).toDate()
          : null,
    );
  }
}
