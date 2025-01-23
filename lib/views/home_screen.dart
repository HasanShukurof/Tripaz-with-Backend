import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripaz_app/viewmodels/home_view_model.dart';
import '../models/tour_model.dart';
import '../widgets/tour_card_homescreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<TourModel> filteredTours = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
      homeViewModel.loadTours();
    });
  }

  void _searchTours(String query) {
    final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);

    setState(() {
      if (query.isEmpty) {
        filteredTours = homeViewModel.tours;
      } else {
        // Tüm turlarda arama yap
        filteredTours = homeViewModel.tours.where((tour) {
          return tour.tourName.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeViewModel = Provider.of<HomeViewModel>(context);
    String defaultImageUrl =
        'https://gabalatours.com/wp-content/uploads/2022/07/things-to-do-in-gabala-1.jpg';

    // Arama sonuçlarını göster veya tüm turları göster
    final toursToDisplay =
        _searchController.text.isEmpty ? homeViewModel.tours : filteredTours;

    // Popular turları filtrele - arama yapılmışsa filtrelenmiş listeden, yapılmamışsa tüm listeden
    final popularTours = toursToDisplay
        .where((tour) =>
            tour.tourPopularStatus == 1 || tour.tourPopularStatus == null)
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
                            controller: _searchController,
                            onChanged: _searchTours,
                            decoration: InputDecoration(
                              hintText: 'Search tours...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.blue),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (popularTours.isNotEmpty ||
                            _searchController.text.isEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                            ],
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
                              children:
                                  List.generate(toursToDisplay.length, (index) {
                                final tour = toursToDisplay[index];
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

  Widget _buildTourCard(
      TourModel tour, BuildContext context, String defaultImageUrl) {
    return TourCardHomeScreen(
      tour: tour,
      defaultImageUrl: defaultImageUrl,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
