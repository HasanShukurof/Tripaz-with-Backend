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
    // Daha güvenli sayısal dönüşüm fonksiyonu
    double safeParseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        try {
          return double.parse(value);
        } catch (e) {
          print('Hata: String "$value" double\'a dönüştürülemedi: $e');
          return 0.0;
        }
      }
      print('Desteklenmeyen türde değer: $value (${value.runtimeType})');
      return 0.0;
    }

    print(
        "DetailBookingModel.fromJson çağrıldı - Raw tourPrice: ${json['tourPrice']}");

    return DetailBookingModel(
      tourId: json['tourId'] ?? 0,
      tourName: json['tourName'] ?? 'Tur Adı Belirtilmemiş',
      tourPrice: safeParseDouble(json['tourPrice']),
      tourNightPrice: safeParseDouble(json['tourNightPrice']),
      tourAirportPrice: safeParseDouble(json['tourAirportPrice']),
      tourAbout: json['tourAbout'] ?? 'Açıklama Yok',
      tourImages: json['tourImages'] != null
          ? (json['tourImages'] as List<dynamic>)
              .map((image) => TourImage.fromJson(image))
              .toList()
          : [],
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
