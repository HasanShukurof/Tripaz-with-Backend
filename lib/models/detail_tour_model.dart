class DetailTourModel {
  int? tourId;
  String? tourName;
  double? tourPrice; // Veri tipi double? olarak değiştirildi
  String? tourAbout;
  List<TourImage>? tourImages;

  DetailTourModel({
    this.tourId,
    this.tourName,
    this.tourPrice,
    this.tourAbout,
    this.tourImages,
  });

  factory DetailTourModel.fromJson(Map<String, dynamic> json) {
    return DetailTourModel(
      tourId: json['tourId'],
      tourName: json['tourName'],
      tourPrice: json['tourPrice'] is int
          ? json['tourPrice'].toDouble()
          : json['tourPrice'],
      tourAbout: json['tourAbout'],
      tourImages: (json['tourImages'] as List<dynamic>?)
          ?.map((e) => TourImage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TourImage {
  int? tourImagesId;
  String? tourImgageName;
  dynamic tour;
  dynamic tourId;
  int? isMainImage;

  TourImage({
    this.tourImagesId,
    this.tourImgageName,
    this.tour,
    this.tourId,
    this.isMainImage,
  });

  factory TourImage.fromJson(Map<String, dynamic> json) {
    return TourImage(
      tourImagesId: json['tourImagesId'],
      tourImgageName: json['tourImgageName'],
      tour: json['tour'],
      tourId: json['tourId'],
      isMainImage: json['isMainImage'],
    );
  }
}
