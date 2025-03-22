import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../viewmodels/booking_view_model.dart';
import 'booking_detail_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  @override
  void initState() {
    super.initState();
    // Sayfa yüklendiğinde rezervasyonları çek
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingViewModel>(context, listen: false).fetchBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          'My Bookings',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              Provider.of<BookingViewModel>(context, listen: false)
                  .fetchBookings();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rezervasyonlar yenileniyor...')),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<BookingViewModel>(context, listen: false)
              .fetchBookings();
        },
        child: Consumer<BookingViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Bir hata oluştu: ${viewModel.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        viewModel.fetchBookings();
                      },
                      child: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              );
            }

            if (viewModel.bookings.isEmpty) {
              return const Center(
                child: Text(
                  'Henüz rezervasyonunuz bulunmamaktadır.',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.bookings.length,
              itemBuilder: (context, index) {
                final booking = viewModel.bookings[index];

                // Tarih formatını günlük kullanıma uygun hale getir
                String formattedDate = '';
                try {
                  final parsedDate = DateTime.parse(booking.tourStartDate);
                  formattedDate = DateFormat('dd MMM yyyy').format(parsedDate);
                } catch (e) {
                  formattedDate = booking.tourStartDate;
                }

                return GestureDetector(
                  onTap: () {
                    // Rezervasyon detayını manuel olarak ayarla ve detay sayfasına git
                    try {
                      // Önce mevcut verilerden rezervasyonu seç
                      viewModel.setSelectedBooking(booking);
                      print(
                          'Booking selected for detail view: ${booking.orderId}');

                      // Sonra detay sayfasına yönlendir
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingDetailScreen(
                            orderId: booking.orderId,
                          ),
                        ),
                      );
                    } catch (e) {
                      print('Navigation error: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Rezervasyon detayları yüklenirken bir hata oluştu')),
                      );
                    }
                  },
                  child: Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                              image: DecorationImage(
                                image: booking.tourImageName.isNotEmpty &&
                                        booking.tourImageName.startsWith('http')
                                    ? NetworkImage(booking.tourImageName)
                                    : const NetworkImage(
                                        'https://gabalatours.com/wp-content/uploads/2022/07/things-to-do-in-gabala-1.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      booking.tourName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        booking.status,
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today,
                                        size: 16, color: Colors.grey.shade600),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Date: $formattedDate',
                                      style: TextStyle(
                                          color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.person_outline,
                                        size: 16, color: Colors.grey.shade600),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Guests: ${booking.guestCount} Adults',
                                      style: TextStyle(
                                          color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total Price:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${booking.totalPrice.toStringAsFixed(0)} AZN',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
