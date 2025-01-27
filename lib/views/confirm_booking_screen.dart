import 'package:flutter/material.dart';

import 'payment_style_screen.dart';

class ConfirmBookingScreen extends StatelessWidget {
  final String guestName;
  final String phone;
  final String guestCount;
  final String autoType;
  final DateTime airportPickup;
  final DateTime startDate;
  final DateTime endDate;
  final int nightCount;
  final double totalPrice;
  final bool isAirportPickup;
  final TimeOfDay? pickupTime;
  final String comment;

  const ConfirmBookingScreen({
    super.key,
    required this.guestName,
    required this.phone,
    required this.guestCount,
    required this.autoType,
    required this.airportPickup,
    required this.startDate,
    required this.endDate,
    required this.nightCount,
    required this.totalPrice,
    required this.isAirportPickup,
    this.pickupTime,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Confirm Booking',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Booking Summary',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildSummaryItem('Guest Name', guestName),
              _buildSummaryItem('Phone', phone),
              _buildSummaryItem('Guest Count', '$guestCount person'),
              _buildSummaryItem('Auto Type', autoType),
              _buildSummaryItem(
                'Airport Pick-up',
                isAirportPickup
                    ? '${airportPickup.day}/${airportPickup.month}/${airportPickup.year} ${pickupTime?.format(context) ?? ""}'
                    : 'Not selected',
              ),
              _buildSummaryItem(
                'Tour Start Date',
                '${startDate.day}/${startDate.month}/${startDate.year}',
              ),
              _buildSummaryItem(
                'Tour End Date',
                '${endDate.day}/${endDate.month}/${endDate.year}',
              ),
              _buildSummaryItem('Night Count', '$nightCount nights'),
              _buildSummaryItem('Total Price', '$totalPrice AZN'),
              if (isAirportPickup && comment.isNotEmpty)
                _buildSummaryItem(
                  'Comment',
                  comment,
                ),
              const SizedBox(height: 40),
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PaymentStyleScreen(),
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
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
