import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripaz_app/viewmodels/home_view_model.dart';
import 'package:tripaz_app/views/detail_tour_screen.dart';
import 'dart:convert';
import '../widgets/heart_button.dart';
import '../widgets/tour_card_homescreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
      homeViewModel.loadTours();
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeViewModel = Provider.of<HomeViewModel>(context);
    String defaultImageUrl =
        'https://gabalatours.com/wp-content/uploads/2022/07/things-to-do-in-gabala-1.jpg';

    final popularTours = homeViewModel.tours
        .where((tour) => tour.tourPopularStatus == 1)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (homeViewModel.isUserLoading)
                    const Text("Loading User...")
                  else if (homeViewModel.errorMessage != null)
                    Text("Error: ${homeViewModel.errorMessage}")
                  else if (homeViewModel.user != null)
                    Text(
                      'Welcome, ${homeViewModel.user!.userName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    )
                  else
                    const Text(
                      'Welcome, User',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  const Text(
                    "Let's Discover the best places",
                    style: TextStyle(
                      fontWeight: FontWeight.w200,
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: homeViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : homeViewModel.tours.isEmpty
              ? const Center(child: Text('Henüz tur bulunamadı.'))
              : Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            "Popular Packages",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 19,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 290,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: popularTours.length,
                            itemBuilder: (context, index) {
                              final tour = popularTours[index];
                              return _buildTourCard(
                                  tour, context, defaultImageUrl);
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            "All Tours",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 19,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 300,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(
                                  homeViewModel.tours.length, (index) {
                                final tour = homeViewModel.tours[index];
                                return _buildTourCard(
                                    tour, context, defaultImageUrl);
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildTourCard(tour, context, defaultImageUrl) {
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
                "${tour.tourName} Tour",
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
              padding: EdgeInsets.only(left: 8),
              child: Text(
                "1-3 pax",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black54,
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
