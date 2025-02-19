import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io' show Platform;
import 'empty_screen.dart';
import 'payment_error_screen.dart';

class WebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final List<String> successUrls = [
    'tripaz.az/api/Payriff/payment-status',
    'api.payriff.com/api/v3/gateway/kapital/callback',
    'pay.payriff.com/success'
  ];

  WebViewScreen({Key? key, required this.paymentUrl}) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasNavigatedAway = false;
  late final Map<String, String> headers;

  void _handlePaymentError(String message, {bool isTimeout = false}) {
    if (!_hasNavigatedAway) {
      _hasNavigatedAway = true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentErrorScreen(
            errorMessage: message,
            isTimeout: isTimeout,
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    print("Payment URL: ${widget.paymentUrl}");

    headers = {
      'Accept': '*/*',
      'Accept-Language': 'en-US,en;q=0.9',
      'Cache-Control': 'no-cache',
      'Pragma': 'no-cache',
    };

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..enableZoom(false)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print("Page started loading: $url");
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            print("Page finished loading: $url");
            setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            print("Web resource error: ${error.description}");
            _handlePaymentError(
              'An error occurred during the payment process. Please check your internet connection and try again.',
            );
          },
          onNavigationRequest: (NavigationRequest request) {
            print("Navigation request to: ${request.url}");
            if (widget.successUrls.any((url) => request.url.contains(url))) {
              _hasNavigatedAway = true;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const EmptyScreen()),
                (route) => false,
              );
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    _controller.loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await _controller.canGoBack()) {
          await _controller.goBack();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Payment'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              Container(
                color: Colors.white.withOpacity(0.8),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
