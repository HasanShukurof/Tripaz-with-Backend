import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../viewmodels/booking_view_model.dart';
import '../widgets/bottom_navigation_bar.dart';
import 'booking_detail_screen.dart';
import 'dart:convert';
import 'profile_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch bookings when page loads
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
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // Tüm sayfaları temizle ve ana sayfaya dön
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const BottomNavBar()),
                (route) => false,
              );
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              Provider.of<BookingViewModel>(context, listen: false)
                  .fetchBookings();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refreshing bookings...')),
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
                      'An error occurred: ${viewModel.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        viewModel.fetchBookings();
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            }

            if (viewModel.bookings.isEmpty) {
              return const Center(
                child: Text(
                  'You don\'t have any bookings yet.',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.bookings.length,
              itemBuilder: (context, index) {
                final booking = viewModel.bookings[index];

                // Format date for daily use
                String formattedDate = '';
                try {
                  final parsedDate = DateTime.parse(booking.tourStartDate);
                  formattedDate = DateFormat('dd MMM yyyy').format(parsedDate);
                } catch (e) {
                  formattedDate = booking.tourStartDate;
                }

                return GestureDetector(
                  onTap: () {
                    // Manually set booking detail and go to detail page
                    try {
                      // First select booking from existing data
                      viewModel.setSelectedBooking(booking);
                      print(
                          'Booking selected for detail view: ${booking.orderId}');

                      // Then go to detail page
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
                                'An error occurred while loading booking details')),
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
                                image: _getBookingImage(booking),
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
                                        booking.status == "Pending"
                                            ? "APPROVED"
                                            : booking.status,
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
                                      'Guests: ${getCarCapacity(booking.autoType)}',
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
                                      '${booking.totalPrice.toStringAsFixed(2)} AZN',
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

  String getCarCapacity(int autoType) {
    switch (autoType) {
      case 0:
        return '1-3 Pax';
      case 1:
        return '1-4 Pax';
      case 2:
        return '1-6 Pax';
      case 3:
        return '1-12 Pax';
      default:
        return 'Unknown';
    }
  }

  ImageProvider _getBookingImage(dynamic booking) {
    // İlk olarak tour nesnesindeki resimleri kontrol et
    if (booking.tour != null &&
        booking.tour.tourImages != null &&
        booking.tour.tourImages.isNotEmpty &&
        booking.tour.tourImages.first.tourImgageName.isNotEmpty) {
      String imageUrl = booking.tour.tourImages.first.tourImgageName;

      if (imageUrl.startsWith('http')) {
        return NetworkImage(imageUrl);
      } else if (imageUrl.isNotEmpty &&
          (imageUrl.startsWith('/9j/') || imageUrl.startsWith('data:image'))) {
        // Base64 formatındaki resmi işle
        try {
          String base64String = imageUrl;
          // Eğer data:image ile başlıyorsa, sadece base64 kısmını çıkar
          if (base64String.contains(',')) {
            base64String = base64String.split(',')[1];
          }

          return MemoryImage(base64Decode(base64String));
        } catch (e) {
          print('Base64 decode error: $e');
        }
      }
    }

    // Sonra doğrudan booking nesnesindeki tourImageName'i kontrol et
    if (booking.tourImageName.isNotEmpty) {
      if (booking.tourImageName.startsWith('http')) {
        return NetworkImage(booking.tourImageName);
      } else if (booking.tourImageName.startsWith('/9j/') ||
          booking.tourImageName.startsWith('data:image')) {
        // Base64 formatındaki resmi işle
        try {
          String base64String = booking.tourImageName;
          // Eğer data:image ile başlıyorsa, sadece base64 kısmını çıkar
          if (base64String.contains(',')) {
            base64String = base64String.split(',')[1];
          }

          return MemoryImage(base64Decode(base64String));
        } catch (e) {
          print('Base64 decode error: $e');
        }
      }
    }

    // Varsayılan resim - sadece hiçbir resim bulunamadığında placeholder göster
    return NetworkImage(
        'https://tripazapp.s3.amazonaws.com/placeholder-image.jpg');
  }
}
