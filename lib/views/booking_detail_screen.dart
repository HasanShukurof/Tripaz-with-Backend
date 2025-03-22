import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../viewmodels/booking_view_model.dart';

import 'confirm_booking_screen.dart';

class BookingDetailScreen extends StatefulWidget {
  final String orderId;

  const BookingDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch booking detail when page loads
    _loadBookingDetail();
  }

  void _loadBookingDetail() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingViewModel =
          Provider.of<BookingViewModel>(context, listen: false);

      // If already has a selected booking, return without making API call again
      if (bookingViewModel.selectedBooking != null &&
          bookingViewModel.selectedBooking!.orderId == widget.orderId) {
        print('Selected booking already exists, no API call will be made');
        return;
      }

      // Otherwise, fetch booking details
      bookingViewModel.fetchBookingDetail(widget.orderId);
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
      body: Consumer<BookingViewModel>(
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
                      if (viewModel.selectedBooking != null) {
                        // Eğer zaten seçili bir rezervasyon varsa, API'ye tekrar istek yapmadan geri dön
                        setState(() {}); // UI'ı yenile
                      } else {
                        // Değilse detayları tekrar getir
                        viewModel.fetchBookingDetail(widget.orderId);
                      }
                    },
                    child: const Text('Try Again'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final booking = viewModel.selectedBooking;
          if (booking == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Booking details not found.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          // Tarih formatlarını düzenle
          String formattedStartDate = '';
          String formattedEndDate = '';
          String formattedPickupDate = '';
          String formattedOrderDate = '';

          try {
            final startDate = DateTime.parse(booking.tourStartDate);
            formattedStartDate = DateFormat('dd MMM yyyy').format(startDate);

            final endDate = DateTime.parse(booking.tourEndDate);
            formattedEndDate = DateFormat('dd MMM yyyy').format(endDate);

            final orderDate = DateTime.parse(booking.orderDate);
            formattedOrderDate =
                DateFormat('dd MMM yyyy, HH:mm').format(orderDate);

            if (booking.airportPickupEnabled == 1) {
              final pickupDate = DateTime.parse(booking.pickupDate);
              formattedPickupDate =
                  '${DateFormat('dd MMM yyyy').format(pickupDate)}, ${booking.pickupTime}';
            }
          } catch (e) {
            print('Date parsing error: $e');
            formattedStartDate = booking.tourStartDate;
            formattedEndDate = booking.tourEndDate;
            formattedPickupDate = booking.pickupDate;
            formattedOrderDate = booking.orderDate;
          }

          // Base64 resim verisini kontrol et
          Widget tourImage = _getTourImageWidget(booking);

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  child: tourImage,
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tour Name - first check tour object, then tour name from booking
                      Text(
                        booking.tour?.tourName.isNotEmpty == true
                            ? booking.tour!.tourName
                            : booking.tourName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // ID and Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              'ID: ${booking.orderId}',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                booking.status == "Pending"
                                    ? "APPROVED"
                                    : booking.status,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                        ],
                      ),

                      const SizedBox(height: 20),
                      // Kişisel Bilgiler
                      const Text(
                        'PERSONAL INFORMATION',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      const Divider(),

                      _buildDetailItem(
                        icon: Icons.person_outline,
                        title: 'Guest Name',
                        value: booking.guestName,
                      ),
                      _buildDetailItem(
                        icon: Icons.phone_outlined,
                        title: 'Phone',
                        value: booking.phoneNumber,
                      ),
                      _buildDetailItem(
                        icon: Icons.group_outlined,
                        title: 'Guest Count',
                        value: '${getCarCapacity(booking.autoType)}',
                      ),

                      // Tur Bilgileri
                      const SizedBox(height: 12),
                      const Text(
                        'TOUR INFORMATION',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      const Divider(),

                      _buildDetailItem(
                        icon: Icons.directions_car_outlined,
                        title: 'Auto Type',
                        value: getAutoTypeName(booking.autoType),
                      ),
                      if (booking.airportPickupEnabled == 1)
                        _buildDetailItem(
                          icon: Icons.flight_land,
                          title: 'Airport Pick-up',
                          value: formattedPickupDate,
                        ),
                      _buildDetailItem(
                        icon: Icons.calendar_today,
                        title: 'Tour Start Date',
                        value: formattedStartDate,
                      ),
                      _buildDetailItem(
                        icon: Icons.calendar_today,
                        title: 'Tour End Date',
                        value: formattedEndDate,
                      ),
                      _buildDetailItem(
                        icon: Icons.nights_stay,
                        title: 'Night Count',
                        value: '${booking.nightCount} Nights',
                      ),

                      // Ödeme Bilgileri
                      const SizedBox(height: 12),
                      const Text(
                        'PAYMENT INFORMATION',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      const Divider(),

                      _buildDetailItem(
                        icon: Icons.payment,
                        title: 'Payment Type',
                        value: getPaymentTypeName(booking.cashOrCahless),
                      ),

                      // Total Price - artık _buildDetailItem ile gösteriliyor
                      _buildDetailItem(
                        icon: Icons.calculate,
                        title: 'Total Price',
                        value: '${booking.totalPrice.toStringAsFixed(2)} AZN',
                        isHighlighted: false,
                      ),

                      _buildDetailItem(
                        icon: Icons.money,
                        title: 'Paid Amount',
                        value: '${booking.payAmount.toStringAsFixed(2)} AZN',
                      ),
                      _buildDetailItem(
                        icon: Icons.receipt_long,
                        title: 'Order Date',
                        value: formattedOrderDate,
                      ),

                      // Comment
                      if (booking.comment.isNotEmpty)
                        _buildDetailItem(
                          icon: Icons.comment,
                          title: 'Comment',
                          value: booking.comment,
                        ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String getAutoTypeName(int autoType) {
    switch (autoType) {
      case 0:
        return 'Sedan';
      case 1:
        return 'SUV';
      case 2:
        return 'Van';
      case 3:
        return 'Minibus';
      default:
        return 'Unknown';
    }
  }

  String getPaymentTypeName(int paymentType) {
    switch (paymentType) {
      case 1:
        return 'Cash Payment';
      case 2:
        return 'Cashless Payment';
      default:
        return 'Unknown';
    }
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

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
    bool isHighlighted = false,
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isHighlighted ? Colors.blue : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getTourImageWidget(dynamic booking) {
    // Önce tour nesnesindeki resmi kontrol et
    String imageData = '';
    if (booking.tour != null && booking.tour!.tourImages.isNotEmpty) {
      imageData = booking.tour!.tourImages.first.tourImgageName;
      print('Tour image found from booking.tour');
    } else if (booking.tourImageName.isNotEmpty) {
      imageData = booking.tourImageName;
      print('Tour image found from booking.tourImageName');
    }

    if (imageData.startsWith('http')) {
      // HTTP URL ise NetworkImage kullan
      return Image.network(
        imageData,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Image load error: $error');
          return Container(
            color: Colors.grey.shade200,
            child: const Center(child: Icon(Icons.error)),
          );
        },
      );
    } else if (imageData.isNotEmpty &&
        (imageData.startsWith('/9j/') || imageData.startsWith('data:image'))) {
      // Base64 encoded image
      try {
        String base64String = imageData;
        // If data:image starts with prefix, extract only base64 part
        if (base64String.contains(',')) {
          base64String = base64String.split(',')[1];
        }

        return Image.memory(
          base64Decode(base64String),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Base64 image decode error: $error');
            return Container(
              color: Colors.grey.shade200,
              child: const Center(child: Icon(Icons.broken_image)),
            );
          },
        );
      } catch (e) {
        print('Base64 decode error: $e');
        return Container(
          color: Colors.grey.shade200,
          child: const Center(child: Icon(Icons.image_not_supported)),
        );
      }
    }

    // Varsayılan resim
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.image, size: 48, color: Colors.grey),
      ),
    );
  }
}
