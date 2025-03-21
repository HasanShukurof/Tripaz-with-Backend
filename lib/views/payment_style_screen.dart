import 'package:flutter/material.dart';
import 'empty_screen.dart';
import 'webview_screen.dart';
import '../models/payment_request_model.dart';
import 'package:provider/provider.dart';
import '../viewmodels/payment_view_model.dart';

class PaymentStyleScreen extends StatefulWidget {
  final String guestName;
  final String phone;
  final int autoType;
  final bool isAirportPickup;
  final DateTime airportPickup;
  final TimeOfDay? pickupTime;
  final String comment;
  final DateTime startDate;
  final DateTime endDate;
  final int nightCount;
  final double totalPrice;
  final int tourId;

  const PaymentStyleScreen({
    super.key,
    required this.guestName,
    required this.phone,
    required this.autoType,
    required this.isAirportPickup,
    required this.airportPickup,
    this.pickupTime,
    required this.comment,
    required this.startDate,
    required this.endDate,
    required this.nightCount,
    required this.totalPrice,
    required this.tourId,
  });

  @override
  State<PaymentStyleScreen> createState() => _PaymentStyleScreenState();
}

class _PaymentStyleScreenState extends State<PaymentStyleScreen> {
  String? selectedPaymentMethod;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Payment Method',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            _buildPaymentOption(
              'Cash',
              Icons.money,
              'cash',
            ),
            const SizedBox(height: 16),
            _buildPaymentOption(
              'Cashless',
              Icons.credit_card,
              'cashless',
            ),
            if (selectedPaymentMethod == 'cash') ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You must pay 30% in advance for booking',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: selectedPaymentMethod == null
                    ? null
                    : () async {
                        try {
                          // Ödeme türüne göre değerleri ayarla
                          int cashOrCahless = 0;
                          double payAmount = 0;

                          if (selectedPaymentMethod == 'cash') {
                            // Nakit ödeme: toplam tutarın %30'u
                            cashOrCahless = 1;
                            payAmount = widget.totalPrice * 0.3;
                          } else {
                            // Nakitsiz ödeme: toplam tutarın %100'ü
                            cashOrCahless = 2;
                            payAmount = widget.totalPrice;
                          }

                          final paymentViewModel =
                              Provider.of<PaymentViewModel>(context,
                                  listen: false);
                          final response = await paymentViewModel.createPayment(
                            PaymentRequestModel(
                              guestName: widget.guestName,
                              phoneNumber: widget.phone,
                              autoType: widget.autoType,
                              airportPickupEnabled:
                                  widget.isAirportPickup ? 1 : 0,
                              pickupDate: widget.airportPickup,
                              pickupTime:
                                  widget.pickupTime?.format(context) ?? "",
                              comment: widget.comment,
                              tourStartDate: widget.startDate,
                              tourEndDate: widget.endDate,
                              nightCount: widget.nightCount,
                              totalPrice: widget.totalPrice,
                              tourId: widget.tourId,
                              carId: 1,
                              orderDate: DateTime.now(),
                              cashOrCahless: cashOrCahless,
                              payAmount: payAmount,
                            ),
                          );

                          if (response != null) {
                            paymentViewModel
                                .setOrderId(response.payload.orderId);

                            if (mounted) {
                              print("Payment response: ${response.toJson()}");
                              if (response.payload.paymentUrl.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WebViewScreen(
                                      paymentUrl: response.payload.paymentUrl,
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Invalid payment URL received')),
                                );
                              }
                            }
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Payment error: $e')),
                          );
                        }
                      },
                child: const Text(
                  'Next',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String title, IconData icon, String value) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedPaymentMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedPaymentMethod == value
                ? Colors.blue
                : Colors.grey.shade300,
          ),
          color: selectedPaymentMethod == value
              ? Colors.blue.withOpacity(0.1)
              : Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selectedPaymentMethod == value
                  ? Colors.blue
                  : Colors.grey.shade600,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color:
                    selectedPaymentMethod == value ? Colors.blue : Colors.black,
              ),
            ),
            const Spacer(),
            if (selectedPaymentMethod == value)
              const Icon(Icons.check_circle, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}
