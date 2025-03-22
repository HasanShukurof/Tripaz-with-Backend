class BookingRequestModel {
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
  final String tourName;
  final String tourImageName;

  BookingRequestModel({
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
    required this.tourName,
    required this.tourImageName,
  });

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
        "tourName": tourName,
        "tourImageName": tourImageName,
      };

  // JSON'dan model oluşturmak için factory constructor
  factory BookingRequestModel.fromJson(Map<String, dynamic> json) {
    return BookingRequestModel(
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
      tourName: json["tourName"] ?? "",
      tourImageName: json["tourImageName"] ?? "",
    );
  }
}
