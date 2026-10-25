import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../paymob_mobile_viewport_js.dart';

/// The Paymob mobile wallet page, opened in a web view.
///
/// Calls [onSuccess] once when the payment succeeds and [onError] when
/// Paymob reports a failure.
class MobileWalletScreen extends StatefulWidget {
  const MobileWalletScreen({
    super.key,
    required this.redirectUrl,
    required this.onSuccess,
    required this.onError,
  });

  final String redirectUrl;
  final VoidCallback onSuccess;
  final VoidCallback onError;

  @override
  State<MobileWalletScreen> createState() => _MobileWalletScreenState();
}

class _MobileWalletScreenState extends State<MobileWalletScreen> {
  // Created once, then reused — recreating it on a rebuild would restart
  // the page and drop the payment session.
  late final WebViewController _controller;

  // Paymob can load the result url more than once; the booking must be
  // created exactly once.
  bool _succeeded = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final url = request.url;
            if (url.contains('success=true')) {
              if (!_succeeded) {
                _succeeded = true;
                widget.onSuccess();
              }
            } else if (url.contains('success=false') && !_failed) {
              _failed = true;
              widget.onError();
            }
            return NavigationDecision.navigate;
          },
          onPageFinished: (_) {
            _controller
                .runJavaScript(paymobMobileViewportJs)
                .catchError((_) {});
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.redirectUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: WebViewWidget(controller: _controller)),
    );
  }
}