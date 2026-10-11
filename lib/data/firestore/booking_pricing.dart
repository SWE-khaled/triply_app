/// Trusted price math — mirrors the `createBooking` Cloud Function.
///
/// The Flutter cubits (`BookingPublicCubit` 5%, `BookingCubit`
/// `pricePerHour × hours × travelers`) compute DISPLAY totals only. The
/// Function recomputes with these exact helpers and rejects client totals.
/// Amounts are EGP doubles in-app; Paymob minor units = (total*100).round().
///
/// No refund policy is invented here: cancellation releases capacity and
/// leaves `paymentStatus` for the admin/Function flow (see docs).
class BookingPricing {
  BookingPricing._();

  static const double defaultServiceFeeRate = 0.05;

  static double _round2(double v) => (v * 100).round() / 100;

  /// Public trip booking: unit price × seats + fee.
  static ({double subtotal, double fee, double total}) public({
    required double unitPrice,
    required int seats,
    double feeRate = defaultServiceFeeRate,
  }) {
    final safeSeats = seats < 1 ? 1 : seats;
    final safeUnit = unitPrice < 0 ? 0.0 : unitPrice;
    final subtotal = _round2(safeUnit * safeSeats);
    final fee = _round2(subtotal * feeRate);
    return (subtotal: subtotal, fee: fee, total: _round2(subtotal + fee));
  }

  /// Private guide booking: pricePerHour × hours × travelers + fee.
  static ({double subtotal, double fee, double total}) private({
    required double pricePerHour,
    required int hours,
    required int travelers,
    double feeRate = defaultServiceFeeRate,
  }) {
    final safeH = hours < 1 ? 1 : hours;
    final safeT = travelers < 1 ? 1 : travelers;
    final safeP = pricePerHour < 0 ? 0.0 : pricePerHour;
    final subtotal = _round2(safeP * safeH * safeT);
    final fee = _round2(subtotal * feeRate);
    return (subtotal: subtotal, fee: fee, total: _round2(subtotal + fee));
  }

  /// Duration label ("2 hours", "Full Day") → billable hours.
  /// Matches `PriceCalculator.durationHoursFor` used by `BookingCubit`.
  static int hoursForLabel(String label) {
    final v = label.trim().toLowerCase();
    if (v.startsWith('2')) return 2;
    if (v.startsWith('4')) return 4;
    if (v.startsWith('6')) return 6;
    if (v.contains('full')) return 8;
    return 2;
  }

  /// EGP → Paymob minor units.
  static int toMinorUnits(double total) => (total * 100).round();

  /// Short deterministic hash (FNV-1a, 8 hex chars) for binding free-form
  /// fields (e.g. special requests) into idempotency keys. A collision only
  /// fails closed: same key + different fingerprint is rejected by the
  /// server, never resolved to an unrelated booking.
  static String shortHash(String input) {
    var h = 0x811c9dc5;
    for (var i = 0; i < input.length; i++) {
      h ^= input.codeUnitAt(i);
      h = (h * 0x01000193) & 0xffffffff;
    }
    return h.toRadixString(16).padLeft(8, '0');
  }

  /// Basic request validation shared by client (UX) and Function (enforced).
  static String? validatePublic({required int seats, required int available}) {
    if (seats < 1) return 'Select at least 1 seat.';
    if (seats > available) return 'Only $available seats left.';
    return null;
  }

  static String? validatePrivate({required int travelers, int max = 10}) {
    if (travelers < 1) return 'Select at least 1 traveler.';
    if (travelers > max) return 'Maximum $max travelers.';
    return null;
  }
}
