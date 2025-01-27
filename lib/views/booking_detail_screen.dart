import 'package:flutter/material.dart';

import 'confirm_booking_screen.dart';

class BookingDetailScreen extends StatelessWidget {
  const BookingDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Booking Details',
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
        child: Column(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://gabalatours.com/wp-content/uploads/2022/07/things-to-do-in-gabala-1.jpg',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gabala Tour',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDetailItem(
                    icon: Icons.person_outline,
                    title: 'Guest Name',
                    value: 'John Doe',
                  ),
                  _buildDetailItem(
                    icon: Icons.phone_outlined,
                    title: 'Phone',
                    value: '+994 50 123 45 67',
                  ),
                  _buildDetailItem(
                    icon: Icons.group_outlined,
                    title: 'Guest Count',
                    value: '2 Adults',
                  ),
                  _buildDetailItem(
                    icon: Icons.directions_car_outlined,
                    title: 'Auto Type',
                    value: 'Sedan',
                  ),
                  _buildDetailItem(
                    icon: Icons.flight_land,
                    title: 'Airport Pick-up',
                    value: '15 Mar 2024, 14:30',
                  ),
                  _buildDetailItem(
                    icon: Icons.calendar_today,
                    title: 'Tour Start Date',
                    value: '16 Mar 2024',
                  ),
                  _buildDetailItem(
                    icon: Icons.calendar_today,
                    title: 'Tour End Date',
                    value: '18 Mar 2024',
                  ),
                  _buildDetailItem(
                    icon: Icons.nights_stay,
                    title: 'Night Count',
                    value: '2 Nights',
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Price',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '150 AZN',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
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
                            builder: (context) => ConfirmBookingScreen(
                              guestName: 'John Doe',
                              phone: '+994 50 123 45 67',
                              guestCount: '2',
                              autoType: 'Sedan',
                              airportPickup: DateTime(2024, 3, 15, 14, 30),
                              startDate: DateTime(2024, 3, 16),
                              endDate: DateTime(2024, 3, 18),
                              nightCount: 2,
                              totalPrice: 150,
                              isAirportPickup: true,
                              pickupTime: TimeOfDay(hour: 14, minute: 30),
                              comment: 'Terminal A',
                            ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
