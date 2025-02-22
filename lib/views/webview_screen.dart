import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io' show Platform;
import 'empty_screen.dart';
import 'payment_error_screen.dart';
import 'package:provider/provider.dart';
import '../viewmodels/payment_view_model.dart';
import 'booking_success_screen.dart';

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
            _handlePaymentError('Ödeme işlemi sırasında bir hata oluştu.');
          },
          onNavigationRequest: (NavigationRequest request) {
            print("Navigation request to: ${request.url}");

            if (request.url.contains('tripaz.az/api/Payriff/payment-status')) {
              _checkPaymentStatus();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    _controller.loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _checkPaymentStatus() async {
    try {
      final paymentViewModel =
          Provider.of<PaymentViewModel>(context, listen: false);
      final statusResponse = await paymentViewModel.checkPaymentStatus();

      print('Payment Status Check Response in WebView:');
      print('Full Response: $statusResponse');

      if (statusResponse == null) {
        throw Exception('Payment status response is null');
      }

      // Response'daki payment status'u direkt kontrol et
      final paymentStatus = statusResponse['payload']?['paymentStatus'];
      print('Payment Status: $paymentStatus');

      if (mounted) {
        if (paymentStatus == 'APPROVED') {
          print('Payment is successful, navigating to success screen');
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => const BookingSuccessScreen()),
            (route) => false,
          );
        } else {
          print('Payment failed with status: $paymentStatus');
          String errorMessage = 'Ödeme işlemi başarısız oldu.';
          if (paymentStatus == 'DECLINED') {
            errorMessage =
                'Ödeme reddedildi. Lütfen başka bir kart ile tekrar deneyin.';
          } else if (paymentStatus == 'PENDING') {
            errorMessage =
                'Ödeme işlemi beklemede. Lütfen daha sonra tekrar deneyin.';
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentErrorScreen(
                errorMessage: errorMessage,
                isTimeout: false,
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Error checking payment status: $e');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const PaymentErrorScreen(
              errorMessage: 'Ödeme durumu kontrol edilirken bir hata oluştu.',
              isTimeout: false,
            ),
          ),
        );
      }
    }
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
