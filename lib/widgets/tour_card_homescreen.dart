import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/tour_model.dart';
import '../viewmodels/home_view_model.dart';
import '../views/detail_tour_screen.dart';
import 'heart_button.dart';

class TourCardHomeScreen extends StatelessWidget {
  final TourModel tour;
  final String defaultImageUrl;

  const TourCardHomeScreen(
      {super.key, required this.tour, required this.defaultImageUrl});

  @override
  Widget build(BuildContext context) {
    final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Container(
        margin: const EdgeInsets.all(5),
        width: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailTourScreen(tourId: tour.tourId),
                        ));
                  },
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: tour.tourImages.isNotEmpty &&
                              tour.tourImages[0].tourImageName.isNotEmpty
                          ? Image.memory(
                              base64Decode(tour.tourImages[0].tourImageName),
                              width: 180,
                              height: 180,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print('Image loading error: $error');
                                return Image.network(
                                  defaultImageUrl,
                                  width: 180,
                                  height: 180,
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                          : Image.network(
                              defaultImageUrl,
                              width: 180,
                              height: 180,
                              fit: BoxFit.cover,
                            )),
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: HeartButton(
                    initialIsFavorite: tour.isFavorite,
                    tourId: tour.tourId,
                    onFavoriteChanged: () {
                      homeViewModel.toggleWishlist(tour.tourId);
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '${tour.tourName} Tour',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '1-3 pax',
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Price: ${tour.tourPrice} AZN',
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
