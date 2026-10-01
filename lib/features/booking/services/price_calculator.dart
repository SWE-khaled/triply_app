
class PriceCalculator {
  PriceCalculator._();

  static const double serviceFeeRate = 0.05;

  static double subtotal(
      double pricePerHour, int durationHours, int travelers) {
    return pricePerHour * durationHours * travelers;
  }

  static double serviceFee(double sub) => sub * serviceFeeRate;

  static double total(double pricePerHour, int durationHours, int travelers) {
    final sub = subtotal(pricePerHour, durationHours, travelers);
    return sub + serviceFee(sub);
  }

  /// Full Day is priced as 8 hours (mock rule, documented for team).
  static int durationHoursFor(String durationLabel) {
    switch (durationLabel) {
      case '2 hours':
        return 2;
      case '4 hours':
        return 4;
      case '6 hours':
        return 6;
      case 'Full Day':
        return 8;
      default:
        return 0;
    }
  }
}
