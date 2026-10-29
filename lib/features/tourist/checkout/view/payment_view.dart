import 'dart:async';
import 'package:flutter/material.dart';
import 'package:triply/features/tourist/checkout/view/visa_view.dart';
import '../../../../core/network/dio_helper.dart';
import '../model/payment_data.dart';
import 'mobile_wallet_view.dart';

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
  });

  final VoidCallback onPaymentSuccess;
  final double price;
  final VoidCallback onPaymentError;

  @override
  PaymentViewState createState() => PaymentViewState();
}

class PaymentViewState extends State<PaymentView> {
  final PaymentData paymentData = PaymentData();
  final TextEditingController _walletNumber = TextEditingController();

  _PaymentMethod _method = _PaymentMethod.visa;
  bool _loading = false;

  /// The Paymob auth token. Fetched in the background when the screen
  /// opens, and again on demand if that did not work.
  String _authToken = '';

  @override
  void initState() {
    super.initState();
    unawaited(_prefetchAuthToken());
  }

  @override
  void dispose() {
    _walletNumber.dispose();
    super.dispose();
  }

  // ---------- Paymob steps ----------

  Future<void> _prefetchAuthToken() async {
    try {
      _authToken = await _fetchAuthToken();
    } catch (_) {
      // Fetched again when the tourist confirms.
    }
  }

  Future<String> _fetchAuthToken() async {
    final response = await DioHelper.postData(
      url: '/auth/tokens',
      data: {'api_key': paymentData.apiKey},
    );
    return response.data['token'] as String;
  }

  /// Amount in piasters, rounded — never "12345.0" or "1234.9999".
  String get _amountCents => (widget.price * 100).round().toString();

  Future<String> _registerOrder(String authToken) async {
    final response = await DioHelper.postData(
      url: '/ecommerce/orders',
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
    required bool wallet,
  }) async {
    final user = paymentData.userData;
    final integrationId = wallet
        ? paymentData.integrationMobileWalletId
        : paymentData.integrationCardId;
    final response = await DioHelper.postData(
      url: '/acceptance/payment_keys',
      data: {
        'auth_token': _authToken,
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
    return response.data['token'] as String;
  }

  /// Starts the wallet payment and returns the page the tourist
  /// finishes it on.
  Future<String> _payWithWallet(String paymentToken, String number) async {
    final response = await DioHelper.postData(
      url: '/acceptance/payments/pay',
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
    try {
      if (_authToken.isEmpty) _authToken = await _fetchAuthToken();
      final orderId = await _registerOrder(_authToken);
      final paymentToken = await _requestPaymentKey(orderId, wallet: wallet);
      if (!mounted) return;

      if (wallet) {
        final redirectUrl = await _payWithWallet(paymentToken, number);
        if (!mounted) return;
        _open(
          MobileWalletScreen(
            redirectUrl: redirectUrl,
            onSuccess: widget.onPaymentSuccess,
            onError: widget.onPaymentError,
          ),
        );
      } else {
        _open(
          VisaScreen(
            finalToken: paymentToken,
            iframeId: paymentData.iframeId,
            onFinished: widget.onPaymentSuccess,
            onError: widget.onPaymentError,
          ),
        );
      }
    } catch (_) {
      // The token may have expired: fetch a new one on the next try.
      _authToken = '';
      if (mounted) widget.onPaymentError();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _open(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
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
      backgroundColor: style?.scaffoldColor,
      appBar: AppBar(
        backgroundColor: style?.appBarBackgroundColor,
        foregroundColor: style?.appBarForegroundColor,
        title: const Text('Select Payment Method'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
        ),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                color: style?.circleProgressColor ?? Colors.blue,
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
                    cursorColor: style?.primaryColor ?? Colors.blue,
                    decoration: InputDecoration(
                      counterText: '',
                      prefixIcon: Icon(
                        Icons.wallet,
                        color: style?.primaryColor ?? Colors.blue,
                      ),
                      hintText: 'Enter your mobile wallet number',
                      hintStyle: style?.textStyle,
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
        ? style?.primaryColor ?? Colors.blue
        : style?.unselectedColor ?? Colors.grey;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Text(label, style: style?.textStyle),
          ],
        ),
      ),
    );
  }

  OutlineInputBorder _inputBorder() {
    return OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      borderSide: BorderSide(
        color: paymentData.style?.primaryColor ?? Colors.blue,
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
          style: paymentData.style?.buttonStyle ?? _defaultButtonStyle(),
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
}
