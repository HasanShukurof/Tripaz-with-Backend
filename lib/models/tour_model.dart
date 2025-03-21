class TourModel {
  final int tourId;
  final String tourName;
  final double tourPrice;
  final int tourPopularStatus;
  final List<TourImage> tourImages;
  final String? tourAbout;
  final List<Wishlist> wishlists;
  final List<Car> cars;
  bool isFavorite;

  TourModel(
      {required this.tourId,
      required this.tourName,
      required this.tourPrice,
      required this.tourPopularStatus,
      required this.tourImages,
      this.tourAbout,
      required this.wishlists,
      required this.cars,
      this.isFavorite = false});

  factory TourModel.fromJson(Map<String, dynamic> json) {
    return TourModel(
      tourId: json['tourId'],
      tourName: json['tourName'] ?? 'No Name',
      tourPrice: (json['tourPrice'] as num).toDouble(),
      tourPopularStatus: json['tourPopularStatus'],
      tourImages: (json['tourImages'] as List<dynamic>)
          .map((image) => TourImage.fromJson(image))
          .toList(),
      tourAbout: json['tourAbout'],
      wishlists: (json['wishlists'] as List<dynamic>?)
              ?.map((wishlist) => Wishlist.fromJson(wishlist))
              .toList() ??
          [],
      cars: (json['cars'] as List<dynamic>?)
              ?.map((car) => Car.fromJson(car))
              .toList() ??
          [],
    );
  }
}

class TourImage {
  final int tourImagesId;
  final String tourImageName;
  final int isMainImage;
  final int? tourId;

  TourImage({
    required this.tourImagesId,
    required this.tourImageName,
    required this.isMainImage,
    this.tourId,
  });

  factory TourImage.fromJson(Map<String, dynamic> json) {
    return TourImage(
      tourImagesId: json['tourImagesId'],
      tourImageName: json['tourImgageName'],
      isMainImage: json['isMainImage'],
      tourId: json['tourId'],
    );
  }
}

class Wishlist {
  final int wishlistId;
  final int tourId;
  final int userId;

  Wishlist({
    required this.wishlistId,
    required this.tourId,
    required this.userId,
  });

  factory Wishlist.fromJson(Map<String, dynamic> json) {
    return Wishlist(
      wishlistId: json['wishlistId'],
      tourId: json['tourId'],
      userId: json['userId'],
    );
  }
}

class Car {
  final int carId;
  final String carName;
  final double carPrice;
  final String carPersonCount;
  final int tourId;
  final int carStatus;

  Car({
    required this.carId,
    required this.carName,
    required this.carPrice,
    required this.carPersonCount,
    required this.tourId,
    required this.carStatus,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      carId: json['carId'],
      carName: json['carName'],
      carPrice: (json['carPrice'] as num).toDouble(),
      carPersonCount: json['carPersonCount'],
      tourId: json['tourId'],
      carStatus: json['carStatus'],
    );
  }
}
