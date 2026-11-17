import 'package:triply/core/data/my_bookings_public.dart';
import 'package:triply/core/data/repositories/booking_repository.dart';

/// The booking-side half of the payment workflow.
///
/// Paymob UI stays in the checkout views; this service owns the two writes
/// that book the trip in Firestore and the local session record, plus the
/// confirmation write after the WebView reports success. Booking cubits call
/// it so neither View ever touches a repository or the session store.
class PaymentService {
  PaymentService({BookingRepository? repository})
    : _repository = repository ?? BookingRepository();

  final BookingRepository _repository;

  /// Creates the private booking as pending/pending and then records it in
  /// My Trips. The order matters: a failed Firestore write must not leave a
  /// phantom entry in the session.
  Future<BookingReceipt> createPrivatePendingBooking({
    required String guideId,
    required String guideName,
    required String guideImageUrl,
    required String title,
    required int travelers,
    required double totalPrice,
    required DateTime startAt,
    required DateTime? endAt,
    required String meetingPoint,
    required String dateLabel,
  }) async {
    final receipt = await _repository.createPrivateBooking(
      guideId: guideId,
      guideName: guideName,
      guideImageUrl: guideImageUrl,
      title: title,
      travelers: travelers,
      totalPrice: totalPrice,
      paymentMethod: 'card',
      startAt: startAt,
      endAt: endAt,
      meetingPoint: meetingPoint,
      dateLabel: dateLabel,
    );
    MyBookingsPublic.recordPrivate(
      guideId: guideId,
      guideName: guideName,
      title: title,
      imageUrl: guideImageUrl,
      dateLabel: dateLabel,
      travelers: travelers,
      totalPaid: totalPrice,
    );
    return receipt;
  }

  /// Creates the public booking as pending/pending and reserves its seats,
  /// then records it in My Trips. The local record is written *before* the
  /// Firestore transaction (as before) and rolled back when the trip filled
  /// up in the meantime.
  ///
  /// Returns the booking id, or null when the trip filled up.
  Future<String?> createPublicPendingBooking({
    required String tripId,
    required int seats,
    required double unitPrice,
    required String paymentMethod,
    required String specialRequests,
  }) async {
    final total = unitPrice * seats + (unitPrice * seats * 0.05);
    MyBookingsPublic.record(tripId, seats, totalPaid: total);
    try {
      final receipt = await _repository.createPublicBooking(
        tripId: tripId,
        seats: seats,
        unitPrice: unitPrice,
        paymentMethod: paymentMethod,
        specialRequests: specialRequests,
      );
      return receipt.bookingId;
    } on BookingException {
      MyBookingsPublic.cancelBooking(tripId);
      return null;
    }
  }

  /// Confirms a pending booking after payment. The Paymob callback does not
  /// expose a transaction id, so the booking id doubles as the payment id.
  Future<void> confirmBooking(
    String bookingId, {
    String? paymentId,
  }) async {
    await _repository.confirmPayment(
      bookingId: bookingId,
      paymentId: paymentId ?? bookingId,
    );
  }
}
