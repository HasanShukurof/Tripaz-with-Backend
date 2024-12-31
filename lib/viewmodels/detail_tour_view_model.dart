import 'package:flutter/material.dart';
import '../models/detail_tour_model.dart';
import '../repositories/main_repository.dart';

class DetailTourViewModel extends ChangeNotifier {
  final MainRepository _mainRepository;
  DetailTourModel? _tourDetails;
  bool _isLoading = false;
  String? _errorMessage;

  DetailTourViewModel(this._mainRepository);

  DetailTourModel? get tourDetails => _tourDetails;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchTourDetails(int tourId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _tourDetails = await _mainRepository.getTourDetails(tourId);
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
