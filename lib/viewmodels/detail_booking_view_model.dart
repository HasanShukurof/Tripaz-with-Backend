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
  String? _selectedCarName;

  DetailBookingViewModel(this._mainRepository);

  DetailBookingModel? get detailBooking => _detailBooking;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  List<CarTypeModel> get carTypes => _carTypes;
  String? get selectedCarName => _selectedCarName;

  Future<void> fetchDetailBooking(int tourId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _detailBooking = await _mainRepository.getDetailBooking(tourId);
    } catch (e) {
      _errorMessage = 'Rezervasyon detayları yüklenirken bir hata oluştu: $e';
    } finally {
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
