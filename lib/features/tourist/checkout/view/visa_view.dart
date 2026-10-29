import 'package:flutter/material.dart';
import 'package:triply/features/tourist/checkout/paymob_mobile_viewport_js.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// The Paymob card form, opened in a web view.
///
/// Calls [onFinished] once when the payment succeeds and [onError] when
/// Paymob reports a failure.
class VisaScreen extends StatefulWidget {
  const VisaScreen({
    super.key,
    required this.finalToken,
    required this.iframeId,
    required this.onFinished,
    required this.onError,
  });

  final String finalToken;
  final String iframeId;
  final VoidCallback onFinished;
  final VoidCallback onError;

  @override
  State<VisaScreen> createState() => _VisaScreenState();
}

class _VisaScreenState extends State<VisaScreen> {
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
            if (url.contains('success=true') && !url.contains('iframes')) {
              if (!_succeeded) {
                _succeeded = true;
                widget.onFinished();
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
      ..loadRequest(
        Uri.parse(
          'https://accept.paymob.com/api/acceptance/iframes/'
          '${widget.iframeId}?payment_token=${widget.finalToken}',
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: WebViewWidget(controller: _controller)),
    );
  }
}
