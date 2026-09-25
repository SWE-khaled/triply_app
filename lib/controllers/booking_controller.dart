import '../models/booking.dart';

/// Plain feature controller: no ChangeNotifier, the View holds
/// seats/text state with setState and queries this for pricing.
class BookingController {
  static const double serviceRate = 0.05;
  static const int spotsAvailable = 6;
  static const int minSeats = 1;

  int clampSeats(int seats) {
    if (seats < minSeats) return minSeats;
    if (seats > spotsAvailable) return spotsAvailable;
    return seats;
  }

  double subtotal(double unitPrice, int seats) => unitPrice * seats;

  double fee(double unitPrice, int seats) =>
      subtotal(unitPrice, seats) * serviceRate;

  double total(double unitPrice, int seats) =>
      subtotal(unitPrice, seats) + fee(unitPrice, seats);

  Booking buildBooking({
    required String tripId,
    required int seats,
    required String specialRequests,
    required double unitPrice,
  }) {
    final s = clampSeats(seats);
    return Booking(
      tripId: tripId,
      seats: s,
      specialRequests: specialRequests,
      unitPrice: unitPrice,
      serviceFee: fee(unitPrice, s),
      total: total(unitPrice, s),
    );
  }
}
