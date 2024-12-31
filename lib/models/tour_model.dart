class TourModel {
  final int tourId;
  final String tourName;
  final double tourPrice;
  final int tourPopularStatus;
  final List<TourImage> tourImages;
  final String? tourAbout; // Eksik alan eklendi

  TourModel({
    required this.tourId,
    required this.tourName,
    required this.tourPrice,
    required this.tourPopularStatus,
    required this.tourImages,
    this.tourAbout, // Optional olarak eklendi
  });

  factory TourModel.fromJson(Map<String, dynamic> json) {
    return TourModel(
      tourId: json['tourId'],
      tourName: json['tourName'] ?? 'No Name',
      tourPrice: (json['tourPrice'] as num).toDouble(),
      tourPopularStatus: json['tourPopularStatus'],
      tourImages: (json['tourImages'] as List<dynamic>)
          .map((image) => TourImage.fromJson(image))
          .toList(),
      tourAbout: json['tourAbout'], // Nullable olarak işleniyor
    );
  }
}

class TourImage {
  final int tourImagesId;
  final String tourImageName;
  final int isMainImage;

  TourImage({
    required this.tourImagesId,
    required this.tourImageName,
    required this.isMainImage,
  });

  factory TourImage.fromJson(Map<String, dynamic> json) {
    return TourImage(
      tourImagesId: json['tourImagesId'],
      tourImageName: json['tourImgageName'], // Doğru JSON anahtarı kullanılmalı
      isMainImage: json['isMainImage'],
    );
  }
}
