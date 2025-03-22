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
    try {
      TourModel? tourModel;
      String tourName = "";
      String tourImageName = "";

      if (json["tour"] != null && json["tour"] is Map<String, dynamic>) {
        try {
          tourModel = TourModel.fromJson(json["tour"]);
          tourName = tourModel.tourName;

          if (tourModel.tourImages.isNotEmpty) {
            tourImageName = tourModel.tourImages.first.tourImgageName;
          }
        } catch (e) {
          print('Tour model ayrıştırma hatası: $e');
        }
      }

      double safeParseDouble(dynamic value) {
        if (value == null) return 0.0;
        if (value is double) return value;
        if (value is int) return value.toDouble();
        try {
          return double.parse(value.toString());
        } catch (e) {
          return 0.0;
        }
      }

      int safeParseInt(dynamic value) {
        if (value == null) return 0;
        if (value is int) return value;
        try {
          return int.parse(value.toString());
        } catch (e) {
          return 0;
        }
      }

      return BookingModel(
        orderId: json["orderId"]?.toString() ?? "",
        guestName: json["guestName"]?.toString() ?? "",
        phoneNumber: json["phoneNumber"]?.toString() ?? "",
        autoType: safeParseInt(json["autoType"]),
        airportPickupEnabled: safeParseInt(json["airportPickupEnabled"]),
        pickupDate: json["pickupDate"]?.toString() ?? "",
        pickupTime: json["pickupTime"]?.toString() ?? "",
        comment: json["comment"]?.toString() ?? "",
        tourStartDate: json["tourStartDate"]?.toString() ?? "",
        tourEndDate: json["tourEndDate"]?.toString() ?? "",
        nightCount: safeParseInt(json["nightCount"]),
        totalPrice: safeParseDouble(json["totalPrice"]),
        cashOrCahless: safeParseInt(json["cashOrCahless"]),
        payAmount: safeParseDouble(json["payAmount"]),
        orderDate: json["orderDate"]?.toString() ?? "",
        tour: tourModel,
        tourName: json["tourName"]?.toString() ?? tourName,
        tourImageName: tourImageName,
        status: json["status"]?.toString() ?? "Pending",
        tourId: safeParseInt(json["tourId"]),
        guestCount: safeParseInt(json["guestCount"]),
      );
    } catch (e) {
      print('BookingModel.fromJson ayrıştırma hatası: $e');
      return BookingModel(
        orderId: json["orderId"]?.toString() ?? "hata-id",
        guestName: "Ayrıştırma hatası",
        phoneNumber: "",
        autoType: 0,
        airportPickupEnabled: 0,
        pickupDate: "",
        pickupTime: "",
        comment: "",
        tourStartDate: "",
        tourEndDate: "",
        nightCount: 0,
        totalPrice: 0.0,
        cashOrCahless: 0,
        payAmount: 0.0,
        orderDate: "",
        tour: null,
        tourName: "Veri ayrıştırma hatası",
        tourImageName: "",
        status: "Error",
        tourId: 0,
        guestCount: 0,
      );
    }
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
    try {
      List<TourImage> images = [];
      if (json["tourImages"] != null && json["tourImages"] is List) {
        try {
          images = (json["tourImages"] as List)
              .map((image) => TourImage.fromJson(image))
              .toList();
        } catch (e) {
          print('TourImages ayrıştırma hatası: $e');
          // Hata durumunda boş liste kullan
        }
      }

      // Sayısal alanlarda güvenli dönüşüm
      double safeParseDouble(dynamic value) {
        if (value == null) return 0.0;
        if (value is double) return value;
        if (value is int) return value.toDouble();
        try {
          return double.parse(value.toString());
        } catch (e) {
          return 0.0;
        }
      }

      int safeParseInt(dynamic value) {
        if (value == null) return 0;
        if (value is int) return value;
        try {
          return int.parse(value.toString());
        } catch (e) {
          return 0;
        }
      }

      return TourModel(
        tourId: safeParseInt(json["tourId"]),
        tourName: json["tourName"]?.toString() ?? "",
        tourPrice: safeParseDouble(json["tourPrice"]),
        tourNightPrice: safeParseDouble(json["tourNightPrice"]),
        tourAirportPrice: safeParseDouble(json["tourAirportPrice"]),
        tourStartDate: json["tourStartDate"]?.toString(),
        tourPopularStatus: safeParseInt(json["tourPopularStatus"]),
        tourAbout: json["tourAbout"]?.toString(),
        tourImages: images,
      );
    } catch (e) {
      print('TourModel.fromJson ayrıştırma hatası: $e');
      // Kritik hata durumunda minimal bir model döndür
      return TourModel(
        tourId: 0,
        tourName: "Ayrıştırma hatası",
        tourPrice: 0.0,
        tourNightPrice: 0.0,
        tourAirportPrice: 0.0,
        tourPopularStatus: 0,
        tourImages: [],
      );
    }
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
    try {
      int safeParseInt(dynamic value) {
        if (value == null) return 0;
        if (value is int) return value;
        try {
          return int.parse(value.toString());
        } catch (e) {
          return 0;
        }
      }

      return TourImage(
        tourImagesId: safeParseInt(json["tourImagesId"]),
        tourImgageName: json["tourImgageName"]?.toString() ?? "",
      );
    } catch (e) {
      print('TourImage.fromJson ayrıştırma hatası: $e');
      return TourImage(
        tourImagesId: 0,
        tourImgageName: "",
      );
    }
  }

  Map<String, dynamic> toJson() => {
        "tourImagesId": tourImagesId,
        "tourImgageName": tourImgageName,
      };
}
