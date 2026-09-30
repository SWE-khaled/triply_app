import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../model/booking_model.dart';

/// Dedicated network helper for the Paymob sandbox 3-step workflow.
/// Secrets are read from `.env` first; sandbox fallback constants below
/// guarantee the flow still works when `.env` is missing or was never
/// initialized in `main.dart` (which stays untouched).
/// NOTE: fallbacks live in source on purpose so sandbox testing never
/// throws a null/missing-key error. Rotate them before any release.
class PaymobService {
  static const String _base = 'https://accept.paymob.com';

  // ----- Sandbox fallbacks (used only when .env has no value) -----
  static const String _fallbackApiKey =
      'ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SmpiR0Z6Y3lJNklrMWxjbU5vWVc1MElpd2ljSEp2Wm1sc1pWOXdheUk2TVRJek5qRTVNeXdpYm1GdFpTSTZJbWx1YVhScFlXd2lmUS4xQWpDQUc5SUR3U0h0a3dRNGx1anBoUi1xSWtIeTBZVGRkNk9oNmhjbW5GUEp6bFVTRGNzUHJfZWtTRW8tR0xVa2txeHJZT2V5WWRIN0VaTm5UdWVCUQ==';
  static const String _fallbackIntegrationId = '5955185';
  static const String _fallbackIframeId = '1083051';

  bool _envLoaded = false;

  /// Best-effort `.env` load. Never throws: on failure the getters below
  /// fall back to the sandbox constants, so `main.dart` stays untouched.
  Future<void> _ensureEnv() async {
    if (_envLoaded) return;
    _envLoaded = true;
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {

    }
  }

  /// `.env` value wins; sandbox fallback otherwise (never null/empty).
  String get _apiKey {
    final v = dotenv.env['PAYMOB_API_KEY'] ?? '';
    return v.isNotEmpty ? v : _fallbackApiKey;
  }

  int get _integrationId {
    final raw = dotenv.env['PAYMOB_INTEGRATION_ID'] ?? '';
    final parsed = int.tryParse(raw.isNotEmpty ? raw : _fallbackIntegrationId);
    return parsed ?? int.parse(_fallbackIntegrationId);
  }

  String get iframeId {
    final v = dotenv.env['PAYMOB_IFRAME_ID'] ?? '';
    return v.isNotEmpty ? v : _fallbackIframeId;
  }

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
      return await http
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

    print('--- Paymob Auth Step ---');
    print('Status Code: ${res.statusCode}');
    print('Response Body: ${res.body}');

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw PaymobException('Auth failed (HTTP ${res.statusCode}):${res.body}');
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

    print('--- Paymob Register Order Step ---');
    print('Status Code: ${res.statusCode}');
    print('Response Body: ${res.body}');

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw PaymobException('Order failed (HTTP ${res.statusCode}):${res.body}');
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

    print('--- Paymob Payment Key Step ---');
    print('Status Code: ${res.statusCode}');
    print('Response Body: ${res.body}');

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw PaymobException('Payment key failed (HTTP ${res.statusCode}):${res.body}');
    }
    final token = _decode(res, 'Payment key')['token'] as String?;
    if (token == null || token.isEmpty) {
      throw const PaymobException('Payment key failed: empty token.');
    }
    return token;
  }

  /// Full workflow: auth -> order -> payment key. Returns the payment token
  /// for the iframe URL.
  Future<String> createPaymentToken({
    required CheckoutBookingSummary summary,
    required PaymobBillingData billing,
  }) async {
    try {
      print('================ START PAYMOB PAYMENT ================');
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
      print('================ PAYMOB PAYMENT SUCCESS ================');
      return paymentToken;
    } catch (e, stackTrace) {
      print('================ PAYMOB ERROR CATCH ================');
      print('Exception: $e');
      print('StackTrace:\n$stackTrace');
      print('====================================================');
      rethrow;
    }
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