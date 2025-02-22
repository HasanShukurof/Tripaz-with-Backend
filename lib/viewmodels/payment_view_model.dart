import 'package:flutter/material.dart';
import '../models/payment_request_model.dart';
import '../models/payment_response_model.dart';
import '../repositories/main_repository.dart';

class PaymentViewModel extends ChangeNotifier {
  final MainRepository _repository;
  bool _isLoading = false;
  String? _error;
  String? _orderId;

  PaymentViewModel(this._repository);

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get orderId => _orderId;

  void setOrderId(String orderId) {
    _orderId = orderId;
    notifyListeners();
  }

  Future<PaymentResponseModel?> createPayment(
      PaymentRequestModel request) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _repository.createPayment(request);
      _orderId = response.payload.orderId;
      print('OrderId saved: $_orderId');

      print('Payment Response Details:');
      print('Order ID: ${response.payload.orderId}');
      print('Transaction ID: ${response.payload.transactionId}');
      print('Payment URL: ${response.payload.paymentUrl}');
      print('Response Code: ${response.code}');
      print('Response Message: ${response.message}');

      return response;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<dynamic> checkPaymentStatus() async {
    try {
      if (_orderId == null) {
        throw Exception('No order ID available');
      }

      print('Checking payment status for orderId: $_orderId');

      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _repository.checkPaymentStatus(_orderId!);

      print('Payment Status Response in ViewModel:');
      print('OrderId: $_orderId');
      print('Response: $response');

      return response;
    } catch (e) {
      print('Error in ViewModel while checking payment status: $e');
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
