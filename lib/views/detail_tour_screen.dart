import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripaz_app/models/detail_tour_model.dart';
import 'package:tripaz_app/repositories/main_repository.dart';
import 'package:tripaz_app/services/main_api_service.dart';
import 'package:tripaz_app/viewmodels/detail_tour_view_model.dart';
import 'package:tripaz_app/views/detail_booking_screen.dart';
import 'package:tripaz_app/views/full_screen_image.dart';
import 'dart:convert';

class DetailTourScreen extends StatefulWidget {
  final int tourId;

  const DetailTourScreen({Key? key, required this.tourId}) : super(key: key);

  @override
  _DetailTourScreenState createState() => _DetailTourScreenState();
}

class _DetailTourScreenState extends State<DetailTourScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mainRepository = MainRepository(MainApiService());
      Provider.of<DetailTourViewModel>(context, listen: false)
          .fetchTourDetails(widget.tourId);
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
          "Tour Detail",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
        ),
      ),
      body: Consumer<DetailTourViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (viewModel.errorMessage != null) {
            return Center(child: Text(viewModel.errorMessage!));
          } else if (viewModel.tourDetails == null) {
            return const Center(child: Text("No tour data available"));
          } else {
            return _buildTourDetailView(viewModel.tourDetails!);
          }
        },
      ),
    );
  }

  Widget _buildTourDetailView(DetailTourModel tourDetails) {
    String defaultImageUrl = 'https://via.placeholder.com/400x200';
    String mainImageUrl = defaultImageUrl;
    if (tourDetails.tourImages != null && tourDetails.tourImages!.isNotEmpty) {
      final mainImage = tourDetails.tourImages!.firstWhere(
        (image) => image.isMainImage == 1,
        orElse: () =>
            TourImage(tourImgageName: defaultImageUrl), // Default resim adresi
      );
      if (mainImage.tourImgageName != null &&
          mainImage.tourImgageName != 'https://via.placeholder.com/400x200') {
        mainImageUrl = mainImage.tourImgageName!;
      }
    }

    return Center(
      child: Column(
        children: [
          Expanded(
            child: Container(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      child: Stack(
                        children: [
                          mainImageUrl != defaultImageUrl
                              ? Image.memory(
                                  base64Decode(mainImageUrl),
                                  height: 400,
                                  fit: BoxFit.fill,
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
                                  height: 400,
                                  fit: BoxFit.fill,
                                ),
                          Positioned(
                            bottom: 25,
                            left: 45,
                            child: Text(
                              tourDetails.tourName ?? 'No Name',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "About",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Text(tourDetails.tourAbout ?? 'No Description'),
                          const SizedBox(
                            height: 35,
                          ),
                          Image.asset(
                            "assets/images/divider.png",
                            errorBuilder: (context, error, stackTrace) {
                              print('Image loading error: $error');
                              return const SizedBox.shrink();
                            },
                          ),
                          const SizedBox(
                            height: 35,
                          ),
                          const Text(
                            "What is included",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 160,
                                    decoration: BoxDecoration(
                                      border: Border.all(width: 0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.directions_car,
                                            size: 35,
                                          ),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Comfortable Car ",
                                                  style:
                                                      TextStyle(fontSize: 13.5),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Container(
                                      width: 160,
                                      decoration: BoxDecoration(
                                        border: Border.all(width: 0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.group_outlined,
                                              size: 35,
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Proffetional guide ",
                                                    style: TextStyle(
                                                        fontSize: 13.5),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 25,
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 160,
                                    decoration: BoxDecoration(
                                      border: Border.all(width: 0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.hotel_rounded,
                                            size: 35,
                                          ),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Pickup hotel / Drop hotel ",
                                                  style:
                                                      TextStyle(fontSize: 13.5),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Container(
                                      width: 160,
                                      decoration: BoxDecoration(
                                        border: Border.all(width: 0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.water_drop_rounded,
                                              size: 35,
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Free water during the trip",
                                                    style: TextStyle(
                                                        fontSize: 13.5),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 43,
                          ),
                          Image.asset("assets/images/divider.png",
                              errorBuilder: (context, error, stackTrace) {
                            print('Image loading error: $error');
                            return const SizedBox.shrink();
                          }),
                          const SizedBox(
                            height: 47,
                          ),
                          SizedBox(
                            height: 400,
                            child: GridView.builder(
                              padding: const EdgeInsets.all(5.0),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10.0,
                                mainAxisSpacing: 10.0,
                              ),
                              itemCount: tourDetails.tourImages?.length ?? 0,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FullscreenImage(
                                          images: tourDetails.tourImages
                                                  ?.map(
                                                      (e) => e.tourImgageName!)
                                                  .toList() ??
                                              [],
                                          initialIndex: index,
                                        ),
                                      ),
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(
                                          index % 2 == 0 ? 10 : 0),
                                      bottomLeft: Radius.circular(
                                          index % 2 == 0 ? 10 : 0),
                                      topRight: Radius.circular(
                                          index % 2 == 1 ? 10 : 0),
                                      bottomRight: Radius.circular(
                                          index % 2 == 1 ? 10 : 0),
                                    ),
                                    child: Image.memory(
                                        base64Decode(tourDetails
                                                .tourImages?[index]
                                                .tourImgageName ??
                                            'https://via.placeholder.com/200x200'),
                                        fit: BoxFit.cover, errorBuilder:
                                            (context, error, stackTrace) {
                                      print('Image loading error: $error');
                                      return Image.network(
                                        defaultImageUrl,
                                        width: 180,
                                        height: 180,
                                        fit: BoxFit.cover,
                                      );
                                    }),
                                  ),
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                  bottom: 10, top: 10, left: 16, right: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          "\$${tourDetails.tourPrice ?? '0'}",
                          style: const TextStyle(
                              color: Color(0XFFF0A7BAB),
                              fontSize: 21,
                              fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          "/ 1-3 pax",
                          style: TextStyle(color: Color(0XFFF0A7BAB)),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailBookingScreen(tourId: widget.tourId),
                        ),
                      ),
                      child: const Card(
                        color: Color(0XFFF0FA3E2),
                        child: SizedBox(
                          height: 50,
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Book Now",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 15),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
