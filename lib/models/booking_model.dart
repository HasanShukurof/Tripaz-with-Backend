class BookingModel {
  final String orderId;
  final String guestName;
  final String phoneNumber;
  final int autoType;
  final int airportPickupEnabled;
  final String pickupDate;
  final String pickupTime;
  final String comment;
  final String tourStartDate;
  final String tourEndDate;
  final int nightCount;
  final double totalPrice;
  final int cashOrCahless;
  final double payAmount;
  final String orderDate;
  final TourModel? tour;
  final String tourName;
  final String tourImageName;
  final String status;
  final int tourId;
  final int guestCount;

  BookingModel({
    required this.orderId,
    required this.guestName,
    required this.phoneNumber,
    required this.autoType,
    required this.airportPickupEnabled,
    required this.pickupDate,
    required this.pickupTime,
    required this.comment,
    required this.tourStartDate,
    required this.tourEndDate,
    required this.nightCount,
    required this.totalPrice,
    required this.cashOrCahless,
    required this.payAmount,
    required this.orderDate,
    this.tour,
    required this.tourName,
    required this.tourImageName,
    required this.status,
    required this.tourId,
    required this.guestCount,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    TourModel? tourModel;
    String tourName = "";
    String tourImageName = "";

    if (json["tour"] != null && json["tour"] is Map<String, dynamic>) {
      tourModel = TourModel.fromJson(json["tour"]);
      tourName = tourModel.tourName;

      if (tourModel.tourImages != null && tourModel.tourImages.isNotEmpty) {
        tourImageName = tourModel.tourImages.first.tourImgageName;
      }
    }

    return BookingModel(
      orderId: json["orderId"] ?? "",
      guestName: json["guestName"] ?? "",
      phoneNumber: json["phoneNumber"] ?? "",
      autoType: json["autoType"] ?? 0,
      airportPickupEnabled: json["airportPickupEnabled"] ?? 0,
      pickupDate: json["pickupDate"] ?? "",
      pickupTime: json["pickupTime"] ?? "",
      comment: json["comment"] ?? "",
      tourStartDate: json["tourStartDate"] ?? "",
      tourEndDate: json["tourEndDate"] ?? "",
      nightCount: json["nightCount"] ?? 0,
      totalPrice: (json["totalPrice"] ?? 0).toDouble(),
      cashOrCahless: json["cashOrCahless"] ?? 0,
      payAmount: (json["payAmount"] ?? 0).toDouble(),
      orderDate: json["orderDate"] ?? "",
      tour: tourModel,
      tourName: tourName,
      tourImageName: tourImageName,
      status: json["status"] ?? "Pending",
      tourId: json["tourId"] ?? 0,
      guestCount: json["guestCount"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        "orderId": orderId,
        "guestName": guestName,
        "phoneNumber": phoneNumber,
        "autoType": autoType,
        "airportPickupEnabled": airportPickupEnabled,
        "pickupDate": pickupDate,
        "pickupTime": pickupTime,
        "comment": comment,
        "tourStartDate": tourStartDate,
        "tourEndDate": tourEndDate,
        "nightCount": nightCount,
        "totalPrice": totalPrice,
        "cashOrCahless": cashOrCahless,
        "payAmount": payAmount,
        "orderDate": orderDate,
        "tour": tour?.toJson(),
        "tourName": tourName,
        "tourImageName": tourImageName,
        "status": status,
        "tourId": tourId,
        "guestCount": guestCount,
      };
}

class TourModel {
  final int tourId;
  final String tourName;
  final double tourPrice;
  final double tourNightPrice;
  final double tourAirportPrice;
  final String? tourStartDate;
  final int tourPopularStatus;
  final String? tourAbout;
  final List<TourImage> tourImages;

  TourModel({
    required this.tourId,
    required this.tourName,
    required this.tourPrice,
    required this.tourNightPrice,
    required this.tourAirportPrice,
    this.tourStartDate,
    required this.tourPopularStatus,
    this.tourAbout,
    required this.tourImages,
  });

  factory TourModel.fromJson(Map<String, dynamic> json) {
    List<TourImage> images = [];
    if (json["tourImages"] != null && json["tourImages"] is List) {
      images = (json["tourImages"] as List)
          .map((image) => TourImage.fromJson(image))
          .toList();
    }

    return TourModel(
      tourId: json["tourId"] ?? 0,
      tourName: json["tourName"] ?? "",
      tourPrice: (json["tourPrice"] ?? 0).toDouble(),
      tourNightPrice: (json["tourNightPrice"] ?? 0).toDouble(),
      tourAirportPrice: (json["tourAirportPrice"] ?? 0).toDouble(),
      tourStartDate: json["tourStartDate"],
      tourPopularStatus: json["tourPopularStatus"] ?? 0,
      tourAbout: json["tourAbout"],
      tourImages: images,
    );
  }

  Map<String, dynamic> toJson() => {
        "tourId": tourId,
        "tourName": tourName,
        "tourPrice": tourPrice,
        "tourNightPrice": tourNightPrice,
        "tourAirportPrice": tourAirportPrice,
        "tourStartDate": tourStartDate,
        "tourPopularStatus": tourPopularStatus,
        "tourAbout": tourAbout,
        "tourImages": tourImages.map((image) => image.toJson()).toList(),
      };
}

class TourImage {
  final int tourImagesId;
  final String tourImgageName;

  TourImage({
    required this.tourImagesId,
    required this.tourImgageName,
  });

  factory TourImage.fromJson(Map<String, dynamic> json) {
    return TourImage(
      tourImagesId: json["tourImagesId"] ?? 0,
      tourImgageName: json["tourImgageName"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "tourImagesId": tourImagesId,
        "tourImgageName": tourImgageName,
      };
}
