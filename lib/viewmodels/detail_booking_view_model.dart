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

  double get tourPrice => _detailBooking?.tourPrice ?? 0.0;
  double get tourNightPrice => _detailBooking?.tourNightPrice ?? 0.0;
  double get tourAirportPrice => _detailBooking?.tourAirportPrice ?? 0.0;

  double get carPrice {
    if (_selectedCarName == null || _carTypes.isEmpty) {
      return 0.0;
    }
    final selectedCar = _carTypes.firstWhere(
        (element) => element.carName == _selectedCarName,
        orElse: () => CarTypeModel());
    return selectedCar.carPrice ?? 0.0;
  }

  Future<void> fetchDetailBooking(int tourId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    print("fetchDetailBooking metodu başladı");

    try {
      _detailBooking = await _mainRepository.getDetailBooking(tourId);
      print(
          "fetchDetailBooking: _detailBooking alındı. Değerler: ${_detailBooking?.toJson()}");
    } catch (e) {
      _errorMessage = 'Rezervasyon detayları yüklenirken bir hata oluştu: $e';
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
    } catch (e) {
      _errorMessage = 'Araç tipleri yüklenirken bir hata oluştu: $e';
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
