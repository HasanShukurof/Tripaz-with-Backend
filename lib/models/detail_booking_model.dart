class DetailBookingModel {
  int? tourId;
  double? tourPrice;
  double? tourNightPrice;
  double? tourAirportPrice;
  String? tourStartDate;

  DetailBookingModel({
    this.tourId,
    this.tourPrice,
    this.tourNightPrice,
    this.tourAirportPrice,
    this.tourStartDate,
  });

  factory DetailBookingModel.fromJson(Map<String, dynamic> json) =>
      DetailBookingModel(
        tourId: json["tourId"],
        tourPrice: json["tourPrice"],
        tourNightPrice: json["tourNightPrice"],
        tourAirportPrice: json["tourAirportPrice"],
        tourStartDate: json["tourStartDate"],
      );

  Map<String, dynamic> toJson() => {
        "tourId": tourId,
        "tourPrice": tourPrice,
        "tourNightPrice": tourNightPrice,
        "tourAirportPrice": tourAirportPrice,
        "tourStartDate": tourStartDate,
      };
}
