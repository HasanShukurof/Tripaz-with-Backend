import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/detail_tour_model.dart';
import '../repositories/main_repository.dart';

class DetailTourViewModel extends ChangeNotifier {
  final MainRepository _mainRepository;
  DetailTourModel? _tourDetails;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isUserLoggedIn = false;

  DetailTourViewModel(this._mainRepository) {
    _checkLoginStatus();
  }

  DetailTourModel? get tourDetails => _tourDetails;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isUserLoggedIn => _isUserLoggedIn;

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isUserLoggedIn = prefs.getString('access_token') != null;
    notifyListeners();
  }

  Future<void> fetchTourDetails(int tourId) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Eğer kullanıcı giriş yapmışsa yetkili endpoint'i kullan
      if (_isUserLoggedIn) {
        _tourDetails = await _mainRepository.getTourDetails(tourId);
      } else {
        // Giriş yapmamışsa, public endpoint'i kullan
        _tourDetails = await _mainRepository.getPublicTourDetails(tourId);
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load tour details: $e';
      print("Error fetching tour details: $e");
      _tourDetails = null;
    }
    _isLoading = false;
    notifyListeners();
  }
}
