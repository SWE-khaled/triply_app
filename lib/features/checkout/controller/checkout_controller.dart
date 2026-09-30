import 'package:flutter/foundation.dart';

import '../model/booking_model.dart';
import '../services/paymob_service.dart';

/// State + validation + Paymob workflow for the checkout feature.
/// Widgets only render state and forward events here; no secrets here.
class CheckoutController extends ChangeNotifier {
  final CheckoutBookingSummary summary;
  final PaymobService _service;

  CheckoutController({required this.summary, PaymobService? service})
      : _service = service ?? PaymobService();

  // ----- Card form state (kept in memory for masked display only) -----
  String cardNumber = '';
  String expiry = ''; // MM/YY
  String cvv = '';
  String cardholderName = '';

  // ----- Billing form state -----
  String country = 'Egypt';
  String address = '';

  // ----- Inline errors -----
  String? cardNumberError;
  String? expiryError;
  String? cvvError;
  String? cardholderError;

  // ----- Payment workflow state -----
  bool isPaying = false;
  String? payError;
  String? paymentToken;

  // ================= Validation (pure, testable) =================

  /// Sandbox mode relaxes the card-number check: Paymob test cards
  /// (e.g. '1111111111111111', '4988751111111111') fail the Luhn
  /// algorithm, so only digit length is enforced. The real card is
  /// entered and charged inside Paymob's secure iframe anyway.
  /// Set to false for production to re-enable strict Luhn checking.
  static const bool sandboxMode = true;

  static String? validateCardNumber(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return 'Enter your card number';
    if (digits.length < 15 || digits.length > 16) {
      return 'Card number must be 15–16 digits';
    }
    if (!sandboxMode && !_luhnOk(digits)) return 'Invalid card number';
    return null;
  }

  static bool _luhnOk(String digits) {
    var sum = 0;
    var doubleIt = false;
    for (var i = digits.length - 1; i >= 0; i--) {
      var d = int.parse(digits[i]);
      if (doubleIt) {
        d *= 2;
        if (d > 9) d -= 9;
      }
      sum += d;
      doubleIt = !doubleIt;
    }
    return sum % 10 == 0;
  }

  static String? validateExpiry(String input) {
    if (input.isEmpty) return 'Enter expiry (MM/YY)';
    final m = RegExp(r'^(0[1-9]|1[0-2])\/(\d{2})$').firstMatch(input.trim());
    if (m == null) return 'Use MM/YY format';
    final month = int.parse(m.group(1)!);
    final year = 2000 + int.parse(m.group(2)!);
    final now = DateTime.now();
    if (year < now.year || (year == now.year && month < now.month)) {
      return 'Card is expired';
    }
    return null;
  }

  static String? validateCvv(String input) {
    if (input.isEmpty) return 'Enter CVV';
    if (!RegExp(r'^\d{3,4}$').hasMatch(input.trim())) {
      return 'CVV must be 3–4 digits';
    }
    return null;
  }

  static String? validateCardholder(String input) {
    if (input.trim().length < 3) return 'Enter the name on card';
    return null;
  }

  /// Validates the whole card form and publishes inline errors.
  /// Returns true when the flow may continue to Review.
  bool validateCardForm() {
    cardNumberError = validateCardNumber(cardNumber);
    expiryError = validateExpiry(expiry);
    cvvError = validateCvv(cvv);
    cardholderError = validateCardholder(cardholderName);
    notifyListeners();
    return cardNumberError == null &&
        expiryError == null &&
        cvvError == null &&
        cardholderError == null;
  }

  // ----- Field setters (no rebuild spam while typing) -----
  void setCardNumber(String v) => cardNumber = v;
  void setExpiry(String v) => expiry = v;
  void setCvv(String v) => cvv = v;
  void setCardholderName(String v) => cardholderName = v;
  void setCountry(String v) {
    if (v == country) return;
    country = v;
    notifyListeners();
  }

  void setAddress(String v) => address = v;

  /// Masked card for the summary screen, e.g. "Visa •••• 3456".
  String get maskedCard {
    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');
    final last4 =
        digits.length >= 4 ? digits.substring(digits.length - 4) : '••••';
    return '$_brand •••• $last4';
  }

  String get _brand {
    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('4')) return 'Visa';
    if (RegExp(r'^(51|52|53|54|55)').hasMatch(digits)) return 'Mastercard';
    return 'Card';
  }

  PaymobBillingData get _billing {
    final parts = cardholderName.trim().split(RegExp(r'\s+'));
    return PaymobBillingData(
      firstName: parts.isNotEmpty ? parts.first : 'Guest',
      lastName: parts.length > 1 ? parts.sublist(1).join(' ') : 'Guest',
      country: country,
      street: address.trim().isEmpty ? 'NA' : address.trim(),
    );
  }

  /// Runs the Paymob 3-step workflow. Returns the payment token, or null
  /// when it failed (see [payError]). Raw card data is never transmitted.
  Future<String?> startPayment() async {
    if (isPaying) return null;
    isPaying = true;
    payError = null;
    notifyListeners();
    try {
      final token = await _service.createPaymentToken(
        summary: summary,
        billing: _billing,
      );
      paymentToken = token;
      return token;
    } on PaymobException catch (e) {
      payError = e.message;
      return null;
    } catch (_) {
      payError = 'Something went wrong. Please try again.';
      return null;
    } finally {
      isPaying = false;
      notifyListeners();
    }
  }

  void clearPayError() {
    payError = null;
    notifyListeners();
  }
}
