import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../model/booking_model.dart';

/// Dedicated network helper for the Paymob sandbox 3-step workflow.
///
/// Secrets come ONLY from `.env` (`PAYMOB_API_KEY`, `PAYMOB_INTEGRATION_ID`,
/// `PAYMOB_IFRAME_ID`, loaded in `main.dart`). There are no in-source
/// fallbacks: without configuration every workflow fails closed with a
/// clear message instead of silently using embedded credentials.
/// Nothing here is ever logged (responses may carry tokens).
class PaymobService {
  static const String _base = 'https://accept.paymob.com';

  final http.Client _client;

  PaymobService({http.Client? client}) : _client = client ?? http.Client();

  bool _envLoaded = false;

  /// Best-effort `.env` load. Never throws; missing keys surface later as
  /// a configuration error from the getters below. Skips when values are
  /// already present (`main.dart` loads at startup): `dotenv.load` clears
  /// first, so reloading here would wipe runtime-provided values.
  Future<void> _ensureEnv() async {
    if (_envLoaded) return;
    _envLoaded = true;
    if (dotenv.isInitialized) return;
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {}
  }

  /// `.env` value or empty when unconfigured (callers fail closed).
  String get _apiKey => dotenv.env['PAYMOB_API_KEY'] ?? '';

  int get _integrationId {
    return int.tryParse(dotenv.env['PAYMOB_INTEGRATION_ID'] ?? '') ?? 0;
  }

  String get iframeId => dotenv.env['PAYMOB_IFRAME_ID'] ?? '';

  void _assertConfigured() {
    if (_apiKey.isEmpty || _integrationId == 0 || iframeId.isEmpty) {
      throw const PaymobException(
        'Paymob is not configured. Check your .env file.',
      );
    }
  }

  static const Duration _timeout = Duration(seconds: 30);

  /// Single POST entry point with robust network error mapping.
  /// Transport failures become descriptive [PaymobException]s so the UI
  /// can show actionable messages instead of a generic fallback.
  Future<http.Response> _post(Uri url, Map<String, dynamic> body) async {
    try {
      return await _client
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(_timeout);
    } on SocketException {
      throw const PaymobException(
        'No internet connection. Please check your network and retry.',
      );
    } on TimeoutException {
      throw const PaymobException(
        'The payment server took too long to respond. Please try again.',
      );
    } on http.ClientException {
      throw const PaymobException(
        'Could not reach the payment server. Please retry.',
      );
    }
  }

  /// Decodes a JSON object body or throws a descriptive error.
  Map<String, dynamic> _decode(http.Response res, String step) {
    try {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } on FormatException {
      throw PaymobException(
        '$step failed: unexpected server response. Please try again.',
      );
    }
  }

  /// Step 1: POST /api/auth/tokens -> auth token.
  Future<String> requestAuthToken() async {
    await _ensureEnv();
    _assertConfigured();
    final res = await _post(Uri.parse('$_base/api/auth/tokens'), {
      'api_key': _apiKey,
    });

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw PaymobException('Auth failed (HTTP ${res.statusCode}).');
    }
    final token = _decode(res, 'Auth')['token'] as String?;
    if (token == null || token.isEmpty) {
      throw const PaymobException('Auth failed: empty token.');
    }
    return token;
  }

  /// Step 2: POST /api/ecommerce/orders -> order id.
  /// [amountCents] is the EGP minor-unit total.
  Future<int> registerOrder({
    required String authToken,
    required int amountCents,
  }) async {
    final res = await _post(Uri.parse('$_base/api/ecommerce/orders'), {
      'auth_token': authToken,
      'delivery_needed': 'false',
      'amount_cents': amountCents.toString(),
      'currency': 'EGP',
      'items': [],
    });

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw PaymobException('Order failed (HTTP ${res.statusCode}).');
    }
    final id = _decode(res, 'Order')['id'];
    if (id == null) throw const PaymobException('Order failed: no id.');
    return (id as num).toInt();
  }

  /// Step 3: POST /api/acceptance/payment_keys -> payment token.
  Future<String> requestPaymentKey({
    required String authToken,
    required int orderId,
    required int amountCents,
    required PaymobBillingData billing,
  }) async {
    final res = await _post(Uri.parse('$_base/api/acceptance/payment_keys'), {
      'auth_token': authToken,
      'amount_cents': amountCents,
      'expiration': 3600,
      'order_id': orderId,
      'billing_data': billing.toJson(),
      'currency': 'EGP',
      'integration_id': _integrationId,
    });

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw PaymobException('Payment key failed (HTTP ${res.statusCode}).');
    }
    final token = _decode(res, 'Payment key')['token'] as String?;
    if (token == null || token.isEmpty) {
      throw const PaymobException('Payment key failed: empty token.');
    }
    return token;
  }

  /// Full workflow: auth -> order -> payment key. Returns the iframe
  /// payment token together with the Paymob order id, so callers can
  /// persist a pending reconciliation record carrying the order reference
  /// the server verification looks up. Never logs request/response bodies
  /// (they may carry tokens).
  Future<({String paymentToken, int orderId})> createPaymentToken({
    required CheckoutBookingSummary summary,
    required PaymobBillingData billing,
  }) async {
    final authToken = await requestAuthToken();
    final amountCents = (summary.total * 100).round();
    final orderId = await registerOrder(
      authToken: authToken,
      amountCents: amountCents,
    );
    final paymentToken = await requestPaymentKey(
      authToken: authToken,
      orderId: orderId,
      amountCents: amountCents,
      billing: billing,
    );
    return (paymentToken: paymentToken, orderId: orderId);
  }

  /// Iframe URL opened by [PaymobWebviewScreen].
  String iframeUrl(String paymentToken) =>
      '$_base/api/acceptance/iframes/$iframeId?payment_token=$paymentToken';
}

class PaymobException implements Exception {
  final String message;
  const PaymobException(this.message);

  @override
  String toString() => 'PaymobException: $message';
}
