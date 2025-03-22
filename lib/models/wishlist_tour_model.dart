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
    try {
      // Zorunlu alanlar için null check ve varsayılan değerler ekliyoruz
      final int tourId = json['tourId'] ?? 0;
      final String tourName = json['tourName'] ?? 'No Name';

      // Tour price için güvenli dönüşüm
      double tourPrice = 0.0;
      if (json['tourPrice'] != null) {
        tourPrice = (json['tourPrice'] is num)
            ? (json['tourPrice'] as num).toDouble()
            : 0.0;
      }

      // Tour images için güvenli dönüşüm
      List<WishlistTourImage> tourImages = [];
      if (json['tourImages'] != null && json['tourImages'] is List) {
        tourImages = (json['tourImages'] as List<dynamic>).map((image) {
          try {
            return WishlistTourImage.fromJson(image);
          } catch (e) {
            print('WishlistTourImage oluşturma hatası: $e');
            // Hatalı resim olursa boş bir resim döndür
            return WishlistTourImage(
              tourImagesId: 0,
              tourImageName: '',
              isMainImage: 0,
            );
          }
        }).toList();
      }

      return WishlistTourModel(
        tourId: tourId,
        tourName: tourName,
        tourPrice: tourPrice,
        tourImages: tourImages,
        isFavorite: json['isFavorite'] ?? false,
      );
    } catch (e) {
      print('WishlistTourModel oluşturma hatası: $e');
      // Herhangi bir hata durumunda varsayılan bir model döndür
      return WishlistTourModel(
        tourId: 0,
        tourName: 'Error',
        tourPrice: 0.0,
        tourImages: [],
        isFavorite: false,
      );
    }
  }

  Map<String, dynamic> toJson() {
    try {
      return {
        'tourId': tourId,
        'tourName': tourName,
        'tourPrice': tourPrice,
        'tourImages': tourImages.map((image) {
          try {
            return image.toJson();
          } catch (e) {
            print('WishlistTourImage toJson hatası: $e');
            return {}; // Hata durumunda boş obje döndür
          }
        }).toList(),
        'isFavorite': isFavorite,
      };
    } catch (e) {
      print('WishlistTourModel toJson hatası: $e');
      // Hata durumunda minimum geçerli bir JSON döndür
      return {
        'tourId': tourId,
        'tourName': tourName ?? '',
        'tourPrice': tourPrice,
        'tourImages': [],
        'isFavorite': isFavorite,
      };
    }
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
    try {
      // tourImgageName veya tourImageName alanını kontrol et
      String imageName = '';
      if (json['tourImgageName'] != null) {
        imageName = json['tourImgageName'].toString();
      } else if (json['tourImageName'] != null) {
        imageName = json['tourImageName'].toString();
      }

      return WishlistTourImage(
        tourImagesId: json['tourImagesId'] ?? 0,
        tourImageName: imageName,
        isMainImage: json['isMainImage'] ?? 0,
      );
    } catch (e) {
      print('WishlistTourImage.fromJson hatası: $e, JSON: $json');
      return WishlistTourImage(
        tourImagesId: 0,
        tourImageName: '',
        isMainImage: 0,
      );
    }
  }

  Map<String, dynamic> toJson() {
    try {
      return {
        'tourImagesId': tourImagesId,
        'tourImgageName': tourImageName, // API'deki isim ile eşleştiriyoruz
        'isMainImage': isMainImage,
      };
    } catch (e) {
      print('WishlistTourImage.toJson hatası: $e');
      return {
        'tourImagesId': 0,
        'tourImgageName': '',
        'isMainImage': 0,
      };
    }
  }
}
