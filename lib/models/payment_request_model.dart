class PaymentRequestModel {
  final String guestName;
  final String phoneNumber;
  final int autoType;
  final int airportPickupEnabled;
  final DateTime pickupDate;
  final String pickupTime;
  final String comment;
  final DateTime tourStartDate;
  final DateTime tourEndDate;
  final int nightCount;
  final double totalPrice;
  final int tourId;
  final DateTime orderDate;

  PaymentRequestModel({
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
    required this.tourId,
    required this.orderDate,
  });

  Map<String, dynamic> toJson() => {
        "guestName": guestName,
        "phoneNumber": phoneNumber,
        "autoType": autoType,
        "airportPickupEnabled": airportPickupEnabled,
        "pickupDate": pickupDate.toIso8601String(),
        "pickupTime": pickupTime,
        "comment": comment,
        "tourStartDate": tourStartDate.toIso8601String(),
        "tourEndDate": tourEndDate.toIso8601String(),
        "nightCount": nightCount,
        "totalPrice": totalPrice,
        "tourId": tourId,
        "orderDate": DateTime.now().toIso8601String(),
      };
}
