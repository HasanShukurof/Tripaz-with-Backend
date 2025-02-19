import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io' show Platform;
import 'empty_screen.dart';

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

  @override
  void initState() {
    super.initState();
    print("Payment URL: ${widget.paymentUrl}");

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setUserAgent(Platform.isIOS
          ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15'
          : 'Mozilla/5.0 (Linux; Android 10; SM-A205U) AppleWebKit/537.36')
      ..addJavaScriptChannel(
        'PaymentChannel',
        onMessageReceived: (JavaScriptMessage message) {
          print("JavaScript message: ${message.message}");
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print("Page started loading: $url");
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            print("Page finished loading: $url");
            setState(() => _isLoading = false);

            _controller.runJavaScript('''
              window.onerror = function(message, source, lineno, colno, error) {
                PaymentChannel.postMessage(
                  JSON.stringify({type: 'error', message: message, source: source})
                );
                return true;
              };
            ''');
          },
          onWebResourceError: (WebResourceError error) {
            print("Web resource error: ${error.description}");
            print("Error Code: ${error.errorCode}");
          },
          onNavigationRequest: (NavigationRequest request) {
            print("Navigation request to: ${request.url}");

            if (widget.successUrls.any((url) => request.url.contains(url))) {
              print(
                  "Payment successful - Success URL detected: ${request.url}");
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
      )
      ..loadRequest(
        Uri.parse(widget.paymentUrl),
        headers: {
          'Accept': '*/*',
          'Accept-Language': 'en-US,en;q=0.9',
          'Cache-Control': 'no-cache',
          'Pragma': 'no-cache',
        },
      );

    print("WebView controller initialized");
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
