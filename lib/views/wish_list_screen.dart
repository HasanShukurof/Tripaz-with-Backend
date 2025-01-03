import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripaz_app/views/detail_tour_screen.dart';
import 'dart:convert';

import '../viewmodels/wish_list_view_model.dart';

class WishListScreen extends StatefulWidget {
  const WishListScreen({super.key});

  @override
  State<WishListScreen> createState() => _WishListScreenState();
}

class _WishListScreenState extends State<WishListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wishlistViewModel =
          Provider.of<WishlistViewModel>(context, listen: false);
      wishlistViewModel.loadWishlistTours();
    });
  }

  @override
  Widget build(BuildContext context) {
    final wishlistViewModel = Provider.of<WishlistViewModel>(context);
    String defaultImageUrl =
        'https://gabalatours.com/wp-content/uploads/2022/07/things-to-do-in-gabala-1.jpg';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Wishlist',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: wishlistViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : wishlistViewModel.wishlistTours.isEmpty
              ? const Center(child: Text('Favori tur bulunamadı.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(10),
                  itemCount: wishlistViewModel.wishlistTours.length,
                  separatorBuilder: (context, index) =>
                      Image.asset("assets/images/divider.png"), // Ayraç ekleme
                  itemBuilder: (context, index) {
                    final tour = wishlistViewModel.wishlistTours[index];
                    return _buildTourCard(tour, context, defaultImageUrl);
                  },
                ),
    );
  }

  Widget _buildTourCard(tour, context, defaultImageUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailTourScreen(tourId: tour.tourId),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sol taraf: Tur resmi
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: tour.tourImages.isNotEmpty &&
                        tour.tourImages[0].tourImageName.isNotEmpty
                    ? Image.memory(
                        base64Decode(tour.tourImages[0].tourImageName),
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('Image loading error: $error');
                          return Image.network(
                            defaultImageUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.network(
                        defaultImageUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(width: 15),
              // Sağ taraf: Tur bilgileri
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 13),
                      Text(
                        "${tour.tourName} Tour",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '1-3 Pax',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${tour.tourPrice} AZN',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
