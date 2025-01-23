import 'package:flutter/material.dart';
import 'empty_screen.dart';

class PaymentStyleScreen extends StatefulWidget {
  const PaymentStyleScreen({super.key});

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
                        'You must pay 10% in advance for booking',
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
                    : () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EmptyScreen(),
                          ),
                        );
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
