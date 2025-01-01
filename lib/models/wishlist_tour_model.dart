class WishlistTourModel {
  final int tourId;
  final String tourName;
  final double tourPrice;
  final List<WishlistTourImage> tourImages;
  bool isFavorite;

  WishlistTourModel(
      {required this.tourId,
      required this.tourName,
      required this.tourPrice,
      required this.tourImages,
      this.isFavorite = false});

  factory WishlistTourModel.fromJson(Map<String, dynamic> json) {
    return WishlistTourModel(
      tourId: json['tourId'],
      tourName: json['tourName'] ?? 'No Name',
      tourPrice: (json['tourPrice'] as num).toDouble(),
      tourImages: (json['tourImages'] as List<dynamic>)
          .map((image) => WishlistTourImage.fromJson(image))
          .toList(),
    );
  }
}

class WishlistTourImage {
  final int tourImagesId;
  final String tourImageName;
  final int isMainImage;

  WishlistTourImage({
    required this.tourImagesId,
    required this.tourImageName,
    required this.isMainImage,
  });

  factory WishlistTourImage.fromJson(Map<String, dynamic> json) {
    return WishlistTourImage(
      tourImagesId: json['tourImagesId'],
      tourImageName: json['tourImgageName'],
      isMainImage: json['isMainImage'],
    );
  }
}
