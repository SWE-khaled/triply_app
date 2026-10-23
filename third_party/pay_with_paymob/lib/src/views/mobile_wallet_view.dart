
import 'package:flutter/material.dart';

import 'package:webview_flutter/webview_flutter.dart';

/// JavaScript applied to every loaded page so the Paymob checkout
/// renders with a proper mobile viewport instead of a zoomed-out
/// desktop layout (giant logos, tiny misaligned fields).
const String _mobileViewportJs = '''
(function() {
  try {
    var meta = document.querySelector('meta[name="viewport"]');
    if (!meta) {
      meta = document.createElement('meta');
      meta.name = 'viewport';
      document.head.appendChild(meta);
    }
    meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=5.0';
    var style = document.createElement('style');
    style.textContent =
      'img{max-width:100% !important;height:auto !important;}' +
      'html,body{max-width:100vw !important;overflow-x:hidden !important;' +
      'background:#ffffff !important;min-height:100vh !important;}' +
      'iframe{max-width:100% !important;}';
    document.head.appendChild(style);
  } catch (e) {}
})();
''';

class MobileWalletScreen extends StatefulWidget {
  final String redirectUrl;
  final VoidCallback onSuccess;
  final VoidCallback onError;
  const MobileWalletScreen({
    super.key,
    required this.redirectUrl,
    required this.onSuccess, required this.onError,
  });

  @override
  State<MobileWalletScreen> createState() => _MobileWalletScreenState();
}

class _MobileWalletScreenState extends State<MobileWalletScreen> {

  // Created once in the first build, then reused — recreating it on
  // every rebuild would restart the page and drop the payment session.
  WebViewController? _controller;

  @override
  void initState() {
    super.initState();
    // No need for platform check as the package handles it internally
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: WebViewWidget(
            controller: _controller ??= WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..setBackgroundColor(const Color(0x00000000))
              ..setNavigationDelegate(
                NavigationDelegate(
                  onNavigationRequest: (NavigationRequest request) async {
                    if (request.url.contains('success=true')) {
                      widget.onSuccess();
                    }
                    if (request.url.contains('success=false')) {
                      widget.onError();
                    }
                    return NavigationDecision.navigate;
                  },
                  onPageFinished: (_) {
                    _controller
                        ?.runJavaScript(_mobileViewportJs)
                        .catchError((_) {});
                  },
                ),
              )
              ..addJavaScriptChannel(
                'Toaster',
                onMessageReceived: (JavaScriptMessage message) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message.message)),
                  );
                },
              )
              ..loadRequest(Uri.parse(widget.redirectUrl))),
      ),
    );
  }
}
