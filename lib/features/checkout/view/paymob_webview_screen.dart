import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../services/paymob_service.dart';


class PaymobWebviewScreen extends StatefulWidget {
  final String paymentToken;
  final String guideName;

  const PaymobWebviewScreen({
    super.key,
    required this.paymentToken,
    this.guideName = '',
  });

  @override
  State<PaymobWebviewScreen> createState() => _PaymobWebviewScreenState();
}

class _PaymobWebviewScreenState extends State<PaymobWebviewScreen> {
  late final WebViewController _web;
  bool _loading = true;
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    final url = PaymobService().iframeUrl(widget.paymentToken);
    _web = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onNavigationRequest: (request) {
            _inspectUrl(request.url);
            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            if (!_handled && mounted) {
              _showResult(
                success: false,
                title: 'Connection issue',
                message:
                    'Could not reach the payment page (${error.description}). Please check your connection and retry.',
              );
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  void _inspectUrl(String url) {
    if (_handled) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final params = uri.queryParameters;
    // Paymob appends success=true/false (+ txn response codes) on redirect.
    if (!params.containsKey('success')) return;
    _handled = true;
    final ok = params['success']?.toLowerCase() == 'true';
    if (ok) {
      _showResult(
        success: true,
        title: 'Booking Confirmed!',
        message: widget.guideName.isEmpty
            ? 'Your private tour is confirmed. A confirmation email has been sent to your inbox.'
            : 'Your private tour with ${widget.guideName} is confirmed. A confirmation email has been sent to your inbox.',
      );
    } else {
      _showResult(
        success: false,
        title: 'Payment failed',
        message:
            'Your card was declined or the payment could not be completed. No charge was made — please try again or use a different card.',
      );
    }
  }

  void _showResult({
    required bool success,
    required String title,
    required String message,
  }) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: success
                    ? AppColors.primaryLight
                    : const Color(0xFFFDECEC),
                shape: BoxShape.circle,
              ),
              child: Icon(
                success ? Icons.check_circle : Icons.error_outline,
                size: 36,
                color: success
                    ? AppColors.primary
                    : const Color(0xFFC62828),
              ),
            ),
            const SizedBox(height: 12),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.title)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.subtitle)),
          ],
        ),
        actions: [
          if (!success)
            TextButton(
              // Retry: close dialog, reload the same iframe token.
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _handled = false;
                  _loading = true;
                });
                final url = PaymobService()
                    .iframeUrl(widget.paymentToken);
                _web.loadRequest(Uri.parse(url));
              },
              child: const Text('Retry'),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // dialog
              Navigator.of(context).pop(); // webview
              if (success) {
                // Back to the summary screen; the host app can pop
                // further to the booking confirmation as needed.
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            child: Text(success ? 'Done' : 'Back'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: AppColors.title),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Secure Payment',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.title)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _web),
          if (_loading)
            const Center(
              child: CircularProgressIndicator(
                  color: AppColors.primary),
            ),
        ],
      ),
    );
  }
}
