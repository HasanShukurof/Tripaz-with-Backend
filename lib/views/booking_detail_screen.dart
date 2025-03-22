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
    // Sayfa yüklendiğinde rezervasyon detayını çek
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingViewModel =
          Provider.of<BookingViewModel>(context, listen: false);

      // Eğer zaten seçili bir rezervasyon varsa, API'ye istek yapmadan onu kullan
      // Bu, rezervasyon listesinden tıklandığında gereksiz API çağrısını önler
      if (bookingViewModel.selectedBooking != null &&
          bookingViewModel.selectedBooking!.orderId == widget.orderId) {
        print('Seçili rezervasyon zaten mevcut, API çağrısı yapılmayacak');
        return;
      }

      // Değilse detayları getir
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
                    'Bir hata oluştu: ${viewModel.error}',
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
                    child: const Text('Tekrar Dene'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50),
                    child: const Text('Geri Dön'),
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
                    'Rezervasyon detayları bulunamadı.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Geri Dön'),
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
          Widget tourImage;

          // Önce tour nesenesi kontrolü
          String imageData = '';
          if (booking.tour != null && booking.tour!.tourImages.isNotEmpty) {
            // Tour nesnesinden resim verisi
            imageData = booking.tour!.tourImages.first.tourImgageName;
            print('Tour nesnesinden resim bulundu');
          } else if (booking.tourImageName.isNotEmpty) {
            // Doğrudan booking model üzerindeki veri
            imageData = booking.tourImageName;
            print('Booking modelinden resim bulundu');
          }

          if (imageData.startsWith('http')) {
            // HTTP URL ise NetworkImage kullan
            tourImage = Image.network(
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
              (imageData.startsWith('/9j/') ||
                  imageData.startsWith('data:image'))) {
            // Base64 encoded image
            try {
              String base64String = imageData;
              // Eğer data:image ile başlıyorsa, sadece base64 kısmını al
              if (base64String.contains(',')) {
                base64String = base64String.split(',')[1];
              }

              tourImage = Image.memory(
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
              tourImage = Container(
                color: Colors.grey.shade200,
                child: const Center(child: Icon(Icons.image_not_supported)),
              );
            }
          } else {
            // Varsayılan resim
            tourImage = Image.network(
              'https://gabalatours.com/wp-content/uploads/2022/07/things-to-do-in-gabala-1.jpg',
              fit: BoxFit.cover,
            );
          }

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
                      // Tour Name - önce tour nesnesini, sonra normal tour name'i kontrol et
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

                      // ID ve Durum
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('ID: ${booking.orderId.substring(0, 8)}...',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12)),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              booking.status,
                              style: TextStyle(color: Colors.blue),
                            ),
                          )
                        ],
                      ),

                      const SizedBox(height: 20),
                      // Kişisel Bilgiler
                      const Text(
                        'KİŞİSEL BİLGİLER',
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
                        value: '${booking.guestCount} Adults',
                      ),

                      // Tur Bilgileri
                      const SizedBox(height: 12),
                      const Text(
                        'TUR BİLGİLERİ',
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
                        'ÖDEME BİLGİLERİ',
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

                      // Yorum
                      if (booking.comment.isNotEmpty)
                        _buildDetailItem(
                          icon: Icons.comment,
                          title: 'Comment',
                          value: booking.comment,
                        ),

                      const SizedBox(height: 20),
                      // Toplam Fiyat
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.blue.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Price',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${booking.totalPrice.toStringAsFixed(2)} AZN',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
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
