import 'package:flutter/material.dart';
import '../models/wishlist_tour_model.dart';
import '../repositories/main_repository.dart';

class WishlistViewModel extends ChangeNotifier {
  final MainRepository _repo;
  List<WishlistTourModel> wishlistTours = [];
  bool isLoading = false;
  String? errorMessage;

  WishlistViewModel(this._repo);

  Future<void> loadWishlistTours() async {
    try {
      isLoading = true;
      notifyListeners();
      wishlistTours = await _repo.getWishlistTours();
      print('Yüklenen favori turlar: $wishlistTours');
    } catch (e) {
      errorMessage = 'Favori turlar yüklenirken hata oluştu: $e';
      debugPrint('Error loading wishlist tours: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
