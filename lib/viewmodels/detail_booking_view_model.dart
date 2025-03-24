import 'package:flutter/material.dart';
import '../models/detail_booking_model.dart';
import '../repositories/main_repository.dart';
import '../models/car_type_model.dart';

class DetailBookingViewModel extends ChangeNotifier {
  final MainRepository _mainRepository;
  DetailBookingModel? _detailBooking;
  String? _errorMessage;
  bool _isLoading = false;
  List<CarTypeModel> _carTypes = [];
  String? _selectedCarName; // Başlangıçta null

  DetailBookingViewModel(this._mainRepository);

  DetailBookingModel? get detailBooking => _detailBooking;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  List<CarTypeModel> get carTypes => _carTypes;
  String? get selectedCarName => _selectedCarName;

  double get tourPrice {
    double price = _detailBooking?.tourPrice ?? 0.0;
    print("DetailBookingViewModel.tourPrice getter çağrıldı: $price");
    return price;
  }

  double get tourNightPrice {
    double price = _detailBooking?.tourNightPrice ?? 0.0;
    print("DetailBookingViewModel.tourNightPrice getter çağrıldı: $price");
    return price;
  }

  double get tourAirportPrice {
    double price = _detailBooking?.tourAirportPrice ?? 0.0;
    print("DetailBookingViewModel.tourAirportPrice getter çağrıldı: $price");
    return price;
  }

  double get carPrice {
    if (_selectedCarName == null || _carTypes.isEmpty) {
      return 0.0;
    }
    final selectedCar = _carTypes.firstWhere(
        (element) => element.carName == _selectedCarName,
        orElse: () => CarTypeModel());
    double price = selectedCar.carPrice ?? 0.0;
    print("DetailBookingViewModel.carPrice getter çağrıldı: $price");
    return price;
  }

  Future<void> fetchDetailBooking(int tourId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    print("fetchDetailBooking metodu başladı");

    try {
      _detailBooking = await _mainRepository.getDetailBooking(tourId);
      print(
          "fetchDetailBooking: _detailBooking alındı. Değerler: tourPrice=${_detailBooking?.tourPrice}, tourNightPrice=${_detailBooking?.tourNightPrice}, tourAirportPrice=${_detailBooking?.tourAirportPrice}");
    } catch (e) {
      _errorMessage = 'An error occurred while loading booking details: $e';
      print("fetchDetailBooking hata: $e");
    } finally {
      print("fetchDetailBooking finally çalıştı");
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCarTypes(int tourId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _carTypes = await _mainRepository.getCarTypes(tourId);
      print("Car types: $_carTypes");
    } catch (e) {
      _errorMessage = 'An error occurred while loading car types: $e';
      print("fetchCarTypes hata: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCarName(String carName) {
    _selectedCarName = carName;
    notifyListeners();
  }
}
