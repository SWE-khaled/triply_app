import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:triply/core/firebase/firestore_converters.dart';

/// Canonical `bookings/{bookingId}` document.
///
/// Covers BOTH flows: public (`bookingType=public`, `tripId` set) and
/// private (`bookingType=private`, `guideId`+`placeId` set).
/// `createdAt` (booking creation) is distinct from `tripDate`/`appointmentAt`
/// (when the trip happens). Price fields are server-authoritative — the
/// `createBooking` Function recomputes them and rejects client totals.
class BookingDoc {
  final String id;
  final String touristId;
  final String bookingType; // public | private
  final String? tripId;
  final String guideId;
  final String? placeId;
  final DateTime? tripDate;
  final DateTime? appointmentAt;
  final String timeSlot;
  final int seats;
  final int durationHours;
  final double unitPrice;
  final double serviceFee;
  final double totalAmount;
  final String currency;
  final String status; // pending | confirmed | completed | cancelled
  final String paymentStatus; // pending | succeeded | failed | refunded
  final String? paymentId;
  final String meetingPoint;
  final String specialRequests;
  final String idempotencyKey;
  final DateTime? cancelledAt;
  final String cancelReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BookingDoc({
    required this.id,
    required this.touristId,
    required this.bookingType,
    this.tripId,
    required this.guideId,
    this.placeId,
    this.tripDate,
    this.appointmentAt,
    this.timeSlot = '',
    this.seats = 1,
    this.durationHours = 0,
    this.unitPrice = 0,
    this.serviceFee = 0,
    this.totalAmount = 0,
    this.currency = 'EGP',
    this.status = 'pending',
    this.paymentStatus = 'pending',
    this.paymentId,
    this.meetingPoint = '',
    this.specialRequests = '',
    this.idempotencyKey = '',
    this.cancelledAt,
    this.cancelReason = '',
    this.createdAt,
    this.updatedAt,
  });

  bool get isPublic => bookingType == 'public';
  bool get isPrivate => bookingType == 'private';

  factory BookingDoc.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? {};
    return BookingDoc.fromMap(d, doc.id);
  }

  factory BookingDoc.fromMap(Map<String, dynamic> d, String id) {
    return BookingDoc(
      id: FirestoreConverters.toStr(d['id'], id),
      touristId: FirestoreConverters.toStr(d['touristId']),
      bookingType: FirestoreConverters.toStr(d['bookingType'], 'public'),
      tripId: d['tripId'] as String?,
      guideId: FirestoreConverters.toStr(d['guideId']),
      placeId: d['placeId'] as String?,
      tripDate: FirestoreConverters.toDateTime(
        d['tripDate'] ?? d['dateLabel'] ?? d['date'],
      ),
      appointmentAt: FirestoreConverters.toDateTime(d['appointmentAt']),
      timeSlot: FirestoreConverters.toStr(d['timeSlot']),
      seats: FirestoreConverters.toInt(
        d['seats'] ?? d['travelers'] ?? d['numberOfTravelers'],
        1,
      ),
      durationHours: FirestoreConverters.toInt(d['durationHours']),
      unitPrice: FirestoreConverters.toDouble(
        d['unitPrice'] ?? d['pricePerHour'] ?? d['price'],
      ),
      serviceFee: FirestoreConverters.toDouble(d['serviceFee'] ?? d['fee']),
      totalAmount: FirestoreConverters.toDouble(
        d['totalAmount'] ?? d['total'] ?? d['totalPaid'],
      ),
      currency: FirestoreConverters.toStr(d['currency'], 'EGP'),
      status: FirestoreConverters.toStr(d['status'], 'pending'),
      paymentStatus: FirestoreConverters.toStr(d['paymentStatus'], 'pending'),
      paymentId: d['paymentId'] as String?,
      meetingPoint: FirestoreConverters.toStr(d['meetingPoint']),
      specialRequests: FirestoreConverters.toStr(
        d['specialRequests'] ?? d['notes'],
      ),
      idempotencyKey: FirestoreConverters.toStr(d['idempotencyKey']),
      cancelledAt: FirestoreConverters.toDateTime(d['cancelledAt']),
      cancelReason: FirestoreConverters.toStr(d['cancelReason']),
      createdAt: FirestoreConverters.toDateTime(d['createdAt']),
      updatedAt: FirestoreConverters.toDateTime(d['updatedAt']),
    );
  }

  /// Minimal client create payload. Totals/status are set by the Function.
  Map<String, dynamic> toCreateMap() {
    return {
      'bookingType': bookingType,
      if (tripId != null) 'tripId': tripId,
      'guideId': guideId,
      if (placeId != null) 'placeId': placeId,
      if (tripDate != null) 'tripDate': Timestamp.fromDate(tripDate!),
      if (appointmentAt != null)
        'appointmentAt': Timestamp.fromDate(appointmentAt!),
      'timeSlot': timeSlot,
      'seats': seats,
      'durationHours': durationHours,
      'meetingPoint': meetingPoint,
      'specialRequests': specialRequests,
      'currency': currency,
      'idempotencyKey': idempotencyKey,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'touristId': touristId,
      'bookingType': bookingType,
      'tripId': tripId,
      'guideId': guideId,
      'placeId': placeId,
      'tripDate': tripDate,
      'appointmentAt': appointmentAt,
      'timeSlot': timeSlot,
      'seats': seats,
      'durationHours': durationHours,
      'unitPrice': unitPrice,
      'serviceFee': serviceFee,
      'totalAmount': totalAmount,
      'currency': currency,
      'status': status,
      'paymentStatus': paymentStatus,
      'paymentId': paymentId,
      'meetingPoint': meetingPoint,
      'specialRequests': specialRequests,
      'idempotencyKey': idempotencyKey,
      'cancelledAt': cancelledAt,
      'cancelReason': cancelReason,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
