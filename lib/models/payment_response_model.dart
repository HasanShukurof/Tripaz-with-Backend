class PaymentResponseModel {
  final String orderId;
  final String code;
  final double amount;
  final String currency;
  final String message;
  final String route;
  final String internalMessage;
  final String responseId;
  final PaymentPayload payload;

  PaymentResponseModel({
    required this.orderId,
    required this.code,
    required this.amount,
    required this.currency,
    required this.message,
    required this.route,
    required this.internalMessage,
    required this.responseId,
    required this.payload,
  });

  factory PaymentResponseModel.fromJson(Map<String, dynamic> json) {
    return PaymentResponseModel(
      orderId: json['orderId'] ?? '',
      code: json['code'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? '',
      message: json['message'] ?? '',
      route: json['route'] ?? '',
      internalMessage: json['internalMessage'] ?? '',
      responseId: json['responseId'] ?? '',
      payload: PaymentPayload.fromJson(json['payload'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'code': code,
        'amount': amount,
        'currency': currency,
        'message': message,
        'route': route,
        'internalMessage': internalMessage,
        'responseId': responseId,
        'payload': {
          'orderId': payload.orderId,
          'paymentUrl': payload.paymentUrl,
          'transactionId': payload.transactionId,
        },
      };
}

class PaymentPayload {
  final String orderId;
  final String paymentUrl;
  final int transactionId;

  PaymentPayload({
    required this.orderId,
    required this.paymentUrl,
    required this.transactionId,
  });

  factory PaymentPayload.fromJson(Map<String, dynamic> json) {
    return PaymentPayload(
      orderId: json['orderId'] ?? '',
      paymentUrl: json['paymentUrl'] ?? '',
      transactionId: json['transactionId'] ?? 0,
    );
  }
}
