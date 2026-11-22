import 'dart:async';
import 'package:triply/core/theme/app_colors.dart';

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
    required this.onDiagnostic,
  });

  final String finalToken;
  final String iframeId;
  final VoidCallback onFinished;
  final VoidCallback onError;
  final ValueChanged<String> onDiagnostic;

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
      ..setBackgroundColor(AppColors.surfaceDefault)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final url = request.url;
            if (url.contains('success=true') && !url.contains('iframes')) {
              if (!_succeeded) {
                _succeeded = true;
                widget.onDiagnostic('payment_callback_success');
                widget.onFinished();
              }
            } else if (url.contains('success=false') && !_failed) {
              _failed = true;
              widget.onDiagnostic('payment_callback_failure');
              widget.onError();
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (_) {
            widget.onDiagnostic('page_started');
          },
          onPageFinished: (_) {
            widget.onDiagnostic('page_finished');
            _controller.runJavaScript(paymobMobileViewportJs).catchError((
              Object error,
            ) {
              widget.onDiagnostic(
                'viewport_script_failed exception=${error.runtimeType}',
              );
            });
          },
          onHttpError: (error) {
            widget.onDiagnostic(
              'http_error status=${error.response?.statusCode ?? 'unknown'}',
            );
          },
          onWebResourceError: (error) {
            widget.onDiagnostic('resource_error code=${error.errorCode}');
          },
        ),
      );
    widget.onDiagnostic('load_request_started');
    unawaited(
      _controller
          .loadRequest(
            Uri.parse(
              'https://accept.paymob.com/api/acceptance/iframes/'
              '${widget.iframeId}?payment_token=${widget.finalToken}',
            ),
          )
          .then((_) => widget.onDiagnostic('load_request_succeeded'))
          .catchError((Object error) {
            widget.onDiagnostic(
              'load_request_failed exception=${error.runtimeType}',
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceDefault,
      body: SafeArea(child: WebViewWidget(controller: _controller)),
    );
  }
}
