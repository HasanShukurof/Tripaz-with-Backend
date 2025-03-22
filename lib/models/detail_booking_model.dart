class DetailBookingModel {
  final int tourId;
  final String tourName;
  final double tourPrice;
  final double tourNightPrice;
  final double tourAirportPrice;
  final String tourAbout;
  final List<TourImage> tourImages;

  DetailBookingModel({
    required this.tourId,
    required this.tourName,
    required this.tourPrice,
    this.tourNightPrice = 0.0,
    this.tourAirportPrice = 0.0,
    required this.tourAbout,
    required this.tourImages,
  });

  factory DetailBookingModel.fromJson(Map<String, dynamic> json) {
    return DetailBookingModel(
      tourId: json['tourId'],
      tourName: json['tourName'] ?? 'Tur Adı Belirtilmemiş',
      tourPrice: (json['tourPrice'] as num).toDouble(),
      tourNightPrice: json['tourNightPrice'] != null
          ? (json['tourNightPrice'] as num).toDouble()
          : 0.0,
      tourAirportPrice: json['tourAirportPrice'] != null
          ? (json['tourAirportPrice'] as num).toDouble()
          : 0.0,
      tourAbout: json['tourAbout'] ?? 'Açıklama Yok',
      tourImages: (json['tourImages'] as List<dynamic>)
          .map((image) => TourImage.fromJson(image))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tourId': tourId,
      'tourName': tourName,
      'tourPrice': tourPrice,
      'tourNightPrice': tourNightPrice,
      'tourAirportPrice': tourAirportPrice,
      'tourAbout': tourAbout,
      'tourImages': tourImages.map((image) => image.toJson()).toList(),
    };
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
      tourImageName: json['tourImgageName'] ?? 'Resim Adı Belirtilmemiş',
      isMainImage: json['isMainImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tourImagesId': tourImagesId,
      'tourImgageName': tourImageName,
      'isMainImage': isMainImage,
    };
  }
}
