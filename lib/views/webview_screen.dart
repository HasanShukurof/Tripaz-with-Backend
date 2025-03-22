import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io' show Platform;
import 'empty_screen.dart';
import 'payment_error_screen.dart';
import 'package:provider/provider.dart';
import '../viewmodels/payment_view_model.dart';
import 'booking_success_screen.dart';
import 'dart:async';

class WebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final List<String> successUrls = [
    'tripaz.az/api/Payriff/payment-status',
    'api.payriff.com/api/v3/gateway/kapital/callback',
    'pay.payriff.com/success',
    'pay.payriff.com/r/',
    '/payment/success'
  ];

  WebViewScreen({Key? key, required this.paymentUrl}) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasNavigatedAway = false;
  Timer? _timeoutTimer;

  void _handlePaymentError(String message, {bool isTimeout = false}) {
    if (!_hasNavigatedAway) {
      _hasNavigatedAway = true;

      // WebView'ı temizle ve sayfadan çıkmadan önce kısa bir gecikme ekle
      _cleanupWebView();

      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentErrorScreen(
                errorMessage: message,
                isTimeout: isTimeout,
              ),
            ),
            (route) => false,
          );
        }
      });
    }
  }

  // WebView Temizleme
  void _cleanupWebView() {
    try {
      _timeoutTimer?.cancel();
      // Sayfanın yüklenmesi gerektiğini engelliyoruz
      _controller.loadRequest(Uri.parse('about:blank'));
      _isLoading = false;
      print("WebView cleanup completed");
    } catch (e) {
      print("WebView cleanup error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    print("Payment URL: ${widget.paymentUrl}");

    _startTimeoutTimer();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..enableZoom(false)
      ..setUserAgent(
          'Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/604.1')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print("Page started loading: $url");
            if (mounted && !_hasNavigatedAway) {
              setState(() => _isLoading = true);
            }

            // Sayfanın başlaması sırasında başarılı URL'leri kontrol et
            _checkForSuccessUrls(url);
          },
          onPageFinished: (String url) {
            print("Page finished loading: $url");
            if (mounted && !_hasNavigatedAway) {
              setState(() => _isLoading = false);
            }

            // Sayfanın yüklenmesi tamamlandığında tekrar başarılı URL'leri kontrol et
            _checkForSuccessUrls(url);
          },
          onWebResourceError: (WebResourceError error) {
            print("Web resource error: ${error.description}");

            // Bazı hatalar önemsiz olabilir (özellikle 3D Secure redirect'leri sırasında)
            if (error.errorType == WebResourceErrorType.unknown ||
                error.errorCode == -999) {
              // -999 genellikle gezinme iptal edildiğinde görülür
              print("Non-critical error, not navigating away");
              return;
            }

            _handlePaymentError('An error occurred during payment process.');
          },
          onNavigationRequest: (NavigationRequest request) {
            print("Navigation request to: ${request.url}");

            // Başarılı ödeme URL'lerini kontrol et
            final isSuccessUrl = _checkForSuccessUrls(request.url);
            if (isSuccessUrl) {
              return NavigationDecision.navigate;
            }

            // 3D Secure yönlendirmelerinde özel işlem
            if (request.url.contains('3dsecure') ||
                request.url.contains('secure.kapitalbank.az')) {
              print("3D Secure navigation detected, allowing navigation");
              return NavigationDecision.navigate;
            }

            return NavigationDecision.navigate;
          },
        ),
      );

    _loadUrl();
  }

  void _startTimeoutTimer() {
    _timeoutTimer?.cancel();

    _timeoutTimer = Timer(const Duration(minutes: 3), () {
      if (mounted && !_hasNavigatedAway) {
        _handlePaymentError(
            'Ödeme işlemi zaman aşımına uğradı. Lütfen tekrar deneyin.',
            isTimeout: true);
      }
    });
  }

  @override
  void dispose() {
    print("WebViewScreen dispose called");
    _timeoutTimer?.cancel();
    super.dispose();
  }

  void _loadUrl() {
    try {
      _controller.loadRequest(Uri.parse(widget.paymentUrl));
    } catch (e) {
      print("URL loading error: $e");
      _handlePaymentError('An error occurred while loading payment page');
    }
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

      // Yanıtın yapısını detaylı olarak logla
      final dynamic payload = statusResponse['payload'];
      print('Response payload: $payload');

      // Null kontrolü ve paymentStatus'ın çıkarılması
      if (payload == null) {
        throw Exception('Payment payload is null');
      }

      final paymentStatus = payload['paymentStatus'];
      print('Raw payment status: $paymentStatus');

      // Büyük küçük harf normalizasyonu ve null kontrolü
      final String normalizedStatus =
          paymentStatus?.toString().toUpperCase() ?? '';
      print('Normalized payment status: $normalizedStatus');

      if (mounted) {
        _timeoutTimer?.cancel();

        // APPROVED kontrolü büyük-küçük harf dikkate alınmadan yapılıyor
        if (normalizedStatus == 'APPROVED') {
          print('Payment is successful, navigating to success screen');

          if (!_hasNavigatedAway) {
            _hasNavigatedAway = true;

            // WebView'ı temizle ve sayfadan çıkmadan önce kısa bir gecikme ekle
            _cleanupWebView();

            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const BookingSuccessScreen()),
                  (route) => false,
                );
              }
            });
          }
        } else {
          print('Payment failed with status: $normalizedStatus');
          String errorMessage = 'Ödeme işlemi başarısız oldu.';

          // Duruma göre özel hata mesajları (büyük-küçük harf dikkate alınmadan)
          if (normalizedStatus == 'DECLINED') {
            errorMessage =
                'Ödeme reddedildi. Lütfen başka bir kart ile tekrar deneyin.';
          } else if (normalizedStatus == 'PENDING') {
            errorMessage =
                'Ödeme işlemi beklemede. Lütfen daha sonra tekrar deneyin.';
          } else if (normalizedStatus == 'CANCELLED') {
            errorMessage = 'Ödeme işlemi iptal edildi.';
          } else if (normalizedStatus == 'FAILED') {
            errorMessage =
                'Ödeme işlemi başarısız oldu. Lütfen tekrar deneyin.';
          } else if (normalizedStatus.isEmpty) {
            errorMessage = 'Ödeme durumu alınamadı. Lütfen tekrar deneyin.';
          }

          if (!_hasNavigatedAway) {
            _hasNavigatedAway = true;

            // WebView'ı temizle ve sayfadan çıkmadan önce kısa bir gecikme ekle
            _cleanupWebView();

            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentErrorScreen(
                      errorMessage: errorMessage,
                      isTimeout: false,
                    ),
                  ),
                  (route) => false,
                );
              }
            });
          }
        }
      }
    } catch (e) {
      print('Error checking payment status: $e');

      _timeoutTimer?.cancel();

      if (mounted && !_hasNavigatedAway) {
        _hasNavigatedAway = true;

        // WebView'ı temizle ve sayfadan çıkmadan önce kısa bir gecikme ekle
        _cleanupWebView();

        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const PaymentErrorScreen(
                  errorMessage:
                      'An error occurred while checking payment status.',
                  isTimeout: false,
                ),
              ),
              (route) => false,
            );
          }
        });
      }
    }
  }

  // Başarılı URL kontrolü
  bool _checkForSuccessUrls(String url) {
    // Zaten yönlendirildiyse, başka işlem yapma
    if (_hasNavigatedAway) {
      return false;
    }

    bool isSuccess = false;

    for (final successUrl in widget.successUrls) {
      if (url.contains(successUrl)) {
        print("Success URL detected: $url");
        isSuccess = true;

        // payment-status URL'ini görürsek ödeme durumunu kontrol et
        if ((url.contains('payment-status') || url.contains('success')) &&
            !_hasNavigatedAway) {
          print("Checking payment status from URL: $url");
          _checkPaymentStatus();
        }

        break;
      }
    }

    if (url.contains('payment-error') || url.contains('payment-failed')) {
      print('Payment error page detected: $url');
      if (!_hasNavigatedAway) {
        _hasNavigatedAway = true;
        _cleanupWebView();
        _handlePaymentError('An error occurred during payment process.');
      }
    }

    return isSuccess;
  }

  @override
  Widget build(BuildContext context) {
    // Eğer zaten başka bir sayfaya yönlendirildiyse boş bir widget döndür
    if (_hasNavigatedAway) {
      return Container(color: Colors.white);
    }

    return WillPopScope(
      onWillPop: () async {
        if (!_hasNavigatedAway) {
          if (await _controller.canGoBack()) {
            await _controller.goBack();
            return false;
          }
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Payment'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              if (!_hasNavigatedAway) {
                _cleanupWebView();
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading && !_hasNavigatedAway)
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
