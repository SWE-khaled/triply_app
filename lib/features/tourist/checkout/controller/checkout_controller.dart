import 'dart:async';

import 'package:flutter/foundation.dart';

import '../cubit/checkout_cubit.dart';
import '../cubit/checkout_state.dart';
import '../model/booking_model.dart';
import '../services/paymob_service.dart';

/// Compatibility wrapper around [CheckoutCubit] preserving the old
/// controller API. Existing callers (`booking`, `booking_public`) keep
/// working unchanged; the cubit is the single source of truth.
class CheckoutController extends ChangeNotifier {
  final CheckoutCubit _cubit;
  late final StreamSubscription<CheckoutState> _subscription;

  CheckoutController({required CheckoutBookingSummary summary, PaymobService? service})
      : _cubit = CheckoutCubit(summary: summary, service: service) {
    _subscription = _cubit.stream.listen((_) => notifyListeners());
  }

  CheckoutBookingSummary get summary => _cubit.summary;

  // ----- Card form state (kept in memory for masked display only) -----
  String get cardNumber => _cubit.cardNumber;
  String get expiry => _cubit.expiry; // MM/YY
  String get cvv => _cubit.cvv;
  String get cardholderName => _cubit.cardholderName;

  // ----- Billing form state -----
  String get country => _cubit.country;
  String get address => _cubit.address;

  // ----- Inline errors -----
  String? get cardNumberError => _cubit.cardNumberError;
  String? get expiryError => _cubit.expiryError;
  String? get cvvError => _cubit.cvvError;
  String? get cardholderError => _cubit.cardholderError;

  // ----- Payment workflow state -----
  bool get isPaying => _cubit.isPaying;
  String? get payError => _cubit.payError;
  String? get paymentToken => _cubit.paymentToken;

  // ================= Validation (pure, testable) =================

  /// See [CheckoutCubit.sandboxMode].
  static const bool sandboxMode = CheckoutCubit.sandboxMode;

  static String? validateCardNumber(String input) =>
      CheckoutCubit.validateCardNumber(input);

  static String? validateExpiry(String input) =>
      CheckoutCubit.validateExpiry(input);

  static String? validateCvv(String input) =>
      CheckoutCubit.validateCvv(input);

  static String? validateCardholder(String input) =>
      CheckoutCubit.validateCardholder(input);

  /// Validates the whole card form and publishes inline errors.
  /// Returns true when the flow may continue to Review.
  bool validateCardForm() => _cubit.validateCardForm();

  // ----- Field setters (no rebuild spam while typing) -----
  void setCardNumber(String v) => _cubit.setCardNumber(v);
  void setExpiry(String v) => _cubit.setExpiry(v);
  void setCvv(String v) => _cubit.setCvv(v);
  void setCardholderName(String v) => _cubit.setCardholderName(v);
  void setCountry(String v) => _cubit.setCountry(v);

  void setAddress(String v) => _cubit.setAddress(v);

  /// Masked card for the summary screen, e.g. "Visa •••• 3456".
  String get maskedCard => _cubit.maskedCard;

  /// Runs the Paymob 3-step workflow. Returns the payment token, or null
  /// when it failed (see [payError]). Raw card data is never transmitted.
  Future<String?> startPayment() => _cubit.startPayment();

  void clearPayError() => _cubit.clearPayError();

  @override
  void dispose() {
    _subscription.cancel();
    _cubit.close();
    super.dispose();
  }
}
