import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:triply/core/theme/app_theme_colors.dart';
import 'package:triply/core/theme/app_theme_dark.dart';
import 'package:triply/features/tourist/checkout/view/visa_view.dart';
import '../../../../core/network/dio_helper.dart';
import '../model/payment_data.dart';
import 'mobile_wallet_view.dart';

enum PaymentFlow { publicBooking, privateBooking }

enum _PaymentMethod { visa, wallet }

/// Lets the tourist choose Visa or a mobile wallet, then runs the Paymob
/// steps (auth token → order → payment key → card form / wallet page).
///
/// [onPaymentSuccess] fires once, when Paymob reports a successful
/// payment. [onPaymentError] fires when a step fails or Paymob reports a
/// failure.
class PaymentView extends StatefulWidget {
  const PaymentView({
    super.key,
    required this.onPaymentSuccess,
    required this.price,
    required this.onPaymentError,
    required this.flow,
  });

  final VoidCallback onPaymentSuccess;
  final double price;
  final VoidCallback onPaymentError;
  final PaymentFlow flow;

  @override
  PaymentViewState createState() => PaymentViewState();
}

class PaymentViewState extends State<PaymentView> {
  final PaymentData paymentData = PaymentData();
  final TextEditingController _walletNumber = TextEditingController();

  _PaymentMethod _method = _PaymentMethod.visa;
  bool _loading = false;

  @override
  void dispose() {
    _walletNumber.dispose();
    super.dispose();
  }

  // ---------- Paymob steps ----------

  Future<String> _fetchAuthToken({required String method}) async {
    final response = await _postPaymob(
      endpoint: '/auth/tokens',
      stage: 'auth_token',
      method: method,
      data: {'api_key': paymentData.apiKey},
    );
    return response.data['token'] as String;
  }

  /// Amount in piasters, rounded — never "12345.0" or "1234.9999".
  String get _amountCents => (widget.price * 100).round().toString();

  Future<String> _registerOrder(
    String authToken, {
    required String method,
  }) async {
    final response = await _postPaymob(
      endpoint: '/ecommerce/orders',
      stage: 'order',
      method: method,
      data: {
        'auth_token': authToken,
        'delivery_needed': 'false',
        'amount_cents': _amountCents,
        'currency': 'EGP',
        'items': [],
      },
    );
    return response.data['id'].toString();
  }

  Future<String> _requestPaymentKey(
    String orderId, {
    required String authToken,
    required bool wallet,
    required String method,
  }) async {
    final user = paymentData.userData;
    final integrationId = wallet
        ? paymentData.integrationMobileWalletId
        : paymentData.integrationCardId;
    late final Response response;
    try {
      response = await _postPaymob(
        endpoint: '/acceptance/payment_keys',
        stage: 'payment_key',
        method: method,
        data: {
          'auth_token': authToken,
          'amount_cents': _amountCents,
          'expiration': 3600,
          'order_id': orderId,
          'billing_data': {
            'apartment': 'NA',
            'email': user?.email ?? 'NA',
            'floor': 'NA',
            'first_name': user?.name ?? 'NA',
            'street': 'NA',
            'building': 'NA',
            'phone_number': user?.phone ?? 'NA',
            'shipping_method': 'NA',
            'postal_code': 'NA',
            'city': 'NA',
            'country': 'NA',
            'last_name': user?.lastName ?? 'NA',
            'state': 'NA',
          },
          'currency': 'EGP',
          'integration_id': int.tryParse(integrationId) ?? integrationId,
          'lock_order_when_paid': 'false',
        },
      );
    } on DioException catch (error) {
      final response = error.response;
      if (response != null && response.statusCode == 401) {
        _logPaymentKeyUnauthorized(
          response,
          method: method,
          wallet: wallet,
          integrationId: integrationId,
          authToken: authToken,
          orderId: orderId,
          userValues: [user?.email, user?.name, user?.lastName, user?.phone],
        );
      }
      rethrow;
    }
    return response.data['token'] as String;
  }

  /// Starts the wallet payment and returns the page the tourist
  /// finishes it on.
  Future<String> _payWithWallet(
    String paymentToken,
    String number, {
    required String method,
  }) async {
    final response = await _postPaymob(
      endpoint: '/acceptance/payments/pay',
      stage: 'wallet_charge',
      method: method,
      data: {
        'source': {'identifier': number, 'subtype': 'WALLET'},
        'payment_token': paymentToken,
      },
    );
    final data = response.data;
    final url = data is Map ? (data['redirect_url']?.toString() ?? '') : '';
    if (url.isEmpty) throw Exception('The wallet payment has no redirect url');
    return url;
  }

  Future<Response> _postPaymob({
    required String endpoint,
    required String stage,
    required String method,
    required Map<String, dynamic> data,
  }) async {
    _logDiagnostic(
      event: 'request_started',
      stage: stage,
      method: method,
      endpoint: endpoint,
    );
    try {
      final response = await DioHelper.postData(url: endpoint, data: data);
      _logDiagnostic(
        event: 'request_succeeded',
        stage: stage,
        method: method,
        endpoint: endpoint,
        statusCode: response.statusCode,
      );
      return response;
    } on DioException catch (error) {
      _logDiagnostic(
        event: 'request_failed',
        stage: stage,
        method: method,
        endpoint: endpoint,
        statusCode: error.response?.statusCode,
        error: error,
      );
      rethrow;
    } catch (error) {
      _logDiagnostic(
        event: 'request_failed',
        stage: stage,
        method: method,
        endpoint: endpoint,
        error: error,
      );
      rethrow;
    }
  }

  void _logDiagnostic({
    required String event,
    required String stage,
    required String method,
    String? endpoint,
    int? statusCode,
    Object? error,
  }) {
    if (!kDebugMode) return;
    debugPrint(
      '[PaymobDiag] flow=${widget.flow.name} method=$method stage=$stage '
      'event=$event'
      '${endpoint == null ? '' : ' endpoint=$endpoint'}'
      '${statusCode == null ? '' : ' httpStatus=$statusCode'}'
      '${error == null ? '' : ' exception=${error.runtimeType}'}',
    );
  }

  void _logPaymentKeyUnauthorized(
    Response response, {
    required String method,
    required bool wallet,
    required String integrationId,
    required String authToken,
    required String orderId,
    required List<String?> userValues,
  }) {
    if (!kDebugMode) return;

    final contentType = response.headers.value(Headers.contentTypeHeader);
    final candidateContentType = contentType?.split(';').first.trim() ?? '';
    final normalizedContentType =
        RegExp(
          r'^[A-Za-z0-9!#$&^_.+-]+/[A-Za-z0-9!#$&^_.+-]+$',
        ).hasMatch(candidateContentType)
        ? candidateContentType
        : 'unknown';
    final cardIntegrationSelected = !wallet && method == 'visa';
    final cardIntegrationPresent = paymentData.integrationCardId.isNotEmpty;
    final cardIntegrationValue = int.tryParse(paymentData.integrationCardId);
    final cardIntegrationNumeric = cardIntegrationValue != null;
    final responseDetails = _safePaymentKeyErrorDetails(
      response.data,
      sensitiveValues: [
        paymentData.apiKey,
        authToken,
        integrationId,
        orderId,
        _amountCents,
        ...userValues,
      ],
    );

    debugPrint(
      '[PaymobDiag] flow=${widget.flow.name} stage=payment_key '
      'method=$method event=unauthorized httpStatus=${response.statusCode} '
      'contentType=$normalizedContentType '
      'responseDataType=${response.data.runtimeType} '
      'selectedMethodVisa=$cardIntegrationSelected '
      'selectedIntegrationIsCard=${!wallet && integrationId == paymentData.integrationCardId} '
      'cardIntegrationPresent=$cardIntegrationPresent '
      'cardIntegrationNumeric=$cardIntegrationNumeric '
      'cardIntegrationNonZero=${cardIntegrationValue != null && cardIntegrationValue != 0} '
      'responseDetails=$responseDetails',
    );
  }

  String _safePaymentKeyErrorDetails(
    Object? data, {
    required List<String?> sensitiveValues,
  }) {
    if (data == null) return 'response_details_unavailable';

    Object? parsedData = data;
    if (data is String) {
      try {
        parsedData = jsonDecode(data);
      } on FormatException {
        final summary = _sanitizePaymentDiagnosticText(
          data,
          sensitiveValues: sensitiveValues,
        );
        return summary.isEmpty ? 'response_details_unavailable' : summary;
      }
    }

    if (parsedData is! Map) return 'response_details_unavailable';

    const allowedFields = {
      'message',
      'detail',
      'error',
      'errors',
      'description',
    };
    final excerpts = <String>[];
    for (final entry in parsedData.entries) {
      final key = entry.key;
      if (key is! String || !allowedFields.contains(key.toLowerCase())) {
        continue;
      }
      final value = _safePaymentDiagnosticValue(
        entry.value,
        sensitiveValues: sensitiveValues,
      );
      if (value.isNotEmpty) excerpts.add('${key.toLowerCase()}=$value');
      if (excerpts.length == allowedFields.length) break;
    }

    if (excerpts.isEmpty) return 'response_details_unavailable';
    final details = excerpts.join(' | ');
    return details.length > 500 ? details.substring(0, 500) : details;
  }

  String _safePaymentDiagnosticValue(
    Object? value, {
    required List<String?> sensitiveValues,
    int depth = 0,
  }) {
    if (depth > 2 || value == null) return '';
    if (value is String) {
      return _sanitizePaymentDiagnosticText(
        value,
        sensitiveValues: sensitiveValues,
      );
    }
    if (value is List) {
      return value
          .take(3)
          .map(
            (item) => _safePaymentDiagnosticValue(
              item,
              sensitiveValues: sensitiveValues,
              depth: depth + 1,
            ),
          )
          .where((item) => item.isNotEmpty)
          .join(', ');
    }
    if (value is Map) {
      return value.entries
          .take(3)
          .map((entry) {
            final key = entry.key;
            if (key is String &&
                RegExp(
                  r'api[_ -]?key|auth[_ -]?token|payment[_ -]?(key|token)|integration[_ -]?id|token|card|wallet|phone|email|name|address|billing',
                  caseSensitive: false,
                ).hasMatch(key)) {
              return '[redacted-field]';
            }
            final item = _safePaymentDiagnosticValue(
              entry.value,
              sensitiveValues: sensitiveValues,
              depth: depth + 1,
            );
            return item;
          })
          .where((item) => item.isNotEmpty)
          .join(', ');
    }
    return '';
  }

  String _sanitizePaymentDiagnosticText(
    String value, {
    required List<String?> sensitiveValues,
  }) {
    var sanitized = value;
    final knownValues =
        sensitiveValues
            .whereType<String>()
            .where((item) => item.trim().length >= 3)
            .where(
              (item) => !RegExp(
                r'^(?:N/?A|none|null|unknown)$',
                caseSensitive: false,
              ).hasMatch(item.trim()),
            )
            .toSet()
            .toList()
          ..sort((left, right) => right.length.compareTo(left.length));
    for (final sensitiveValue in knownValues) {
      sanitized = sanitized.replaceAllMapped(
        RegExp(
          '(^|[^A-Za-z0-9])(${RegExp.escape(sensitiveValue)})(?=\$|[^A-Za-z0-9])',
        ),
        (match) => '${match.group(1)}[redacted]',
      );
    }

    sanitized = sanitized
        .replaceAll(
          RegExp(
            r"""\b(api[_ -]?key|auth[_ -]?token|payment[_ -]?(key|token)|integration[_ -]?id|token|card([_ -]?number)?|wallet([_ -]?number)?|phone([_ -]?number)?|email|name|first[_ -]?name|last[_ -]?name|address|billing[_ -]?[a-z_]*)\b\s*["']?\s*[:=]\s*["']?[^,\s;"'}]+""",
            caseSensitive: false,
          ),
          '[redacted-field]',
        )
        .replaceAll(
          RegExp(r'https?://\S+', caseSensitive: false),
          '[redacted-url]',
        )
        .replaceAll(
          RegExp(
            r'\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b',
            caseSensitive: false,
          ),
          '[redacted-email]',
        )
        .replaceAll(
          RegExp(
            r'\b(integration[_ -]?id|card(?:[_ -]?(?:number|no))?|wallet(?:[_ -]?(?:number|no))?|phone(?:[_ -]?number)?|mobile(?:[_ -]?(?:number|no))?|account(?:[_ -]?number)?)\b(?:\s+(?:is|number|id))?\s*[:=#]?\s*[+(\d][\d\s().-]{2,}\d',
            caseSensitive: false,
          ),
          '[redacted-sensitive-number]',
        )
        .replaceAll(RegExp(r'\b\d{13,19}\b'), '[redacted-card-number]')
        .replaceAll(RegExp(r'\b[A-Za-z0-9_-]{24,}\b'), '[redacted-token]')
        .replaceAll(RegExp(r'[\r\n\t]+'), ' ')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();

    if (sanitized.length > 180) {
      sanitized = '${sanitized.substring(0, 180)}…';
    }
    return sanitized;
  }

  // ---------- Confirm ----------

  Future<void> _confirmPayment() async {
    if (_loading) return;
    final wallet = _method == _PaymentMethod.wallet;
    final number = _walletNumber.text.trim();

    if (wallet) {
      if (paymentData.integrationMobileWalletId.isEmpty) {
        _toast('Mobile wallet payment is not available right now.');
        return;
      }
      // Egyptian mobile numbers: 010 / 011 / 012 / 015 + 8 digits.
      if (!RegExp(r'^01[0125]\d{8}$').hasMatch(number)) {
        _toast('Enter a valid 11-digit mobile wallet number.');
        return;
      }
    }

    setState(() => _loading = true);
    final method = wallet ? 'wallet' : 'visa';
    var stage = 'auth_token';
    try {
      _logDiagnostic(event: 'confirm_started', stage: stage, method: method);
      final authToken = await _fetchAuthToken(method: method);
      stage = 'order';
      final orderId = await _registerOrder(authToken, method: method);
      stage = 'payment_key';
      final paymentToken = await _requestPaymentKey(
        orderId,
        authToken: authToken,
        wallet: wallet,
        method: method,
      );
      if (!mounted) return;

      if (wallet) {
        stage = 'wallet_charge';
        final redirectUrl = await _payWithWallet(
          paymentToken,
          number,
          method: method,
        );
        if (!mounted) return;
        _open(
          MobileWalletScreen(
            redirectUrl: redirectUrl,
            onSuccess: widget.onPaymentSuccess,
            onError: widget.onPaymentError,
            onDiagnostic: (event) =>
                _logDiagnostic(event: event, stage: 'webview', method: method),
          ),
          method: method,
        );
      } else {
        _open(
          VisaScreen(
            finalToken: paymentToken,
            iframeId: paymentData.iframeId,
            onFinished: widget.onPaymentSuccess,
            onError: widget.onPaymentError,
            onDiagnostic: (event) =>
                _logDiagnostic(event: event, stage: 'webview', method: method),
          ),
          method: method,
        );
      }
    } catch (error) {
      _logDiagnostic(
        event: 'payment_flow_failed',
        stage: stage,
        method: method,
        statusCode: error is DioException ? error.response?.statusCode : null,
        error: error,
      );
      if (mounted) widget.onPaymentError();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _open(Widget screen, {required String method}) {
    _logDiagnostic(
      event: 'payment_screen_push_started',
      stage: 'navigation',
      method: method,
    );
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    _logDiagnostic(
      event: 'payment_screen_push_succeeded',
      stage: 'navigation',
      method: method,
    );
  }

  void _toast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    final style = paymentData.style;
    return Scaffold(
      backgroundColor: AppThemeColors.resolve(
        context,
        light: style?.scaffoldColor ?? Colors.white,
        dark: AppThemeDark.backgroundPrimary,
      ),
      appBar: AppBar(
        backgroundColor: AppThemeColors.resolve(
          context,
          light: style?.appBarBackgroundColor ?? Colors.white,
          dark: AppThemeDark.backgroundPrimary,
        ),
        foregroundColor: AppThemeColors.resolve(
          context,
          light: style?.appBarForegroundColor ?? Colors.black,
          dark: AppThemeDark.textPrimary,
        ),
        title: const Text('Select Payment Method'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
        ),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                color: AppThemeColors.resolve(
                  context,
                  light: style?.circleProgressColor ?? Colors.blue,
                  dark: AppThemeDark.homeSeeAll,
                ),
              ),
            )
          : _buildOptions(),
      bottomNavigationBar: _loading ? null : _buildConfirmButton(),
    );
  }

  Widget _buildOptions() {
    final style = paymentData.style;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildOption(
            label: 'Pay with Visa',
            icon: Icons.credit_card,
            selected: _method == _PaymentMethod.visa,
            onTap: () => setState(() => _method = _PaymentMethod.visa),
          ),
          const SizedBox(height: 20),
          _buildOption(
            label: 'Pay with Mobile Wallet',
            icon: Icons.phone_android,
            selected: _method == _PaymentMethod.wallet,
            onTap: () => setState(() => _method = _PaymentMethod.wallet),
          ),
          const SizedBox(height: 30),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child: _method == _PaymentMethod.visa
                ? const SizedBox(width: double.infinity)
                : TextFormField(
                    controller: _walletNumber,
                    keyboardType: TextInputType.number,
                    maxLength: 11,
                    cursorColor: _paymentColor(
                      context,
                      style?.primaryColor ?? Colors.blue,
                      AppThemeDark.homeSeeAll,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      prefixIcon: Icon(
                        Icons.wallet,
                        color: _paymentColor(
                          context,
                          style?.primaryColor ?? Colors.blue,
                          AppThemeDark.homeSeeAll,
                        ),
                      ),
                      hintText: 'Enter your mobile wallet number',
                      hintStyle: Theme.of(context).brightness == Brightness.dark
                          ? (style?.textStyle ?? const TextStyle()).copyWith(
                              color: AppThemeDark.textDisabled,
                            )
                          : style?.textStyle,
                      border: _inputBorder(),
                      focusedBorder: _inputBorder(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final style = paymentData.style;
    final color = selected
        ? _paymentColor(
            context,
            style?.primaryColor ?? Colors.blue,
            AppThemeDark.homeSeeAll,
          )
        : _paymentColor(
            context,
            style?.unselectedColor ?? Colors.grey,
            AppThemeDark.homeGuideSecondary,
          );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? selected
                    ? AppThemeDark.surfaceElevated
                    : AppThemeDark.surfaceDefault
              : Colors.transparent,
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Text(
              label,
              style: isDark
                  ? (style?.textStyle ?? const TextStyle()).copyWith(
                      color: selected
                          ? AppThemeDark.homeGuideName
                          : AppThemeDark.homeGuideSecondary,
                    )
                  : style?.textStyle,
            ),
          ],
        ),
      ),
    );
  }

  OutlineInputBorder _inputBorder() {
    return OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      borderSide: BorderSide(
        color: _paymentColor(
          context,
          paymentData.style?.primaryColor ?? Colors.blue,
          AppThemeDark.homeSeeAll,
        ),
        width: 2,
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: ElevatedButton(
          onPressed: _confirmPayment,
          style: _confirmButtonStyle(),
          child: const Text('Confirm Payment', style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }

  ButtonStyle _defaultButtonStyle() {
    return ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    );
  }

  ButtonStyle _confirmButtonStyle() {
    final style = paymentData.style?.buttonStyle ?? _defaultButtonStyle();
    if (Theme.of(context).brightness != Brightness.dark) return style;
    return style.copyWith(
      backgroundColor: const WidgetStatePropertyAll(AppThemeDark.homeSeeAll),
      foregroundColor: const WidgetStatePropertyAll(
        AppThemeDark.backgroundPrimary,
      ),
    );
  }

  Color _paymentColor(BuildContext context, Color light, Color dark) =>
      AppThemeColors.resolve(context, light: light, dark: dark);
}
