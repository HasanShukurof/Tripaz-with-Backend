class CarTypeModel {
  int? carId;
  String? carName;
  double? carPrice;
  String? carPersonCount;

  CarTypeModel({
    this.carId,
    this.carName,
    this.carPrice,
    this.carPersonCount,
  });

  factory CarTypeModel.fromJson(Map<String, dynamic> json) => CarTypeModel(
        carId: json["carId"],
        carName: json["carName"],
        carPrice: json["carPrice"]
            ?.toDouble(), // Burada double'a dönüştürme yapıyoruz
        carPersonCount: json["carPersonCount"],
      );

  Map<String, dynamic> toJson() => {
        "carId": carId,
        "carName": carName,
        "carPrice": carPrice,
        "carPersonCount": carPersonCount,
      };
}
