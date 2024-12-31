import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tour_model.dart';
import '../models/user_model.dart';
import '../repositories/main_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final MainRepository _repo;
  List<TourModel> tours = [];
  bool isLoading = false;
  String? errorMessage;
  UserModel? user;
  bool isUserLoading = false;
  bool _isUserLoaded = false;
  Set<int> _favoriteTourIds = {};

  HomeViewModel(this._repo) {
    loadUser();
    _loadFavoriteTours();
  }

  Future<void> loadTours() async {
    try {
      isLoading = true;
      notifyListeners();

      tours = await _repo.getTours();
      _updateTourFavoriteStatus();
      print('Yüklenen turlar: $tours');
    } catch (e) {
      errorMessage = 'Turlar yüklenirken hata oluştu: $e';
      debugPrint('Error loading tours: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUser() async {
    if (_isUserLoaded) {
      print("Kullanıcı bilgisi daha önce yuklendi. Tekrar yüklenmeyecek.");
      return;
    }

    try {
      isUserLoading = true;
      notifyListeners();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cachedUserName = prefs.getString('user_name');
      String? cachedProfileImageUrl = prefs.getString('profile_image_url');

      if (cachedUserName != null) {
        user = UserModel(
            userName: cachedUserName, profileImageUrl: cachedProfileImageUrl);
        print(
            'Kullanıcı bilgileri SharedPreferences\'dan alındı: ${user?.userName}');
        notifyListeners();
      }

      try {
        final fetchedUser = await _repo.getUser();
        user = fetchedUser;

        await prefs.setString('user_name', user!.userName!);
        if (user!.profileImageUrl != null) {
          await prefs.setString('profile_image_url', user!.profileImageUrl!);
        }

        print(
            'Kullanıcı bilgileri API\'den alındı ve SharedPreferences\'a kaydedildi: ${user?.userName}');
        notifyListeners();
      } catch (e) {
        errorMessage = 'Kullanıcı bilgileri yüklenirken hata oluştu: $e';
        debugPrint('Error fetching user: $e');
        notifyListeners();
      }
    } finally {
      isUserLoading = false;
      _isUserLoaded = true;
      notifyListeners();
    }
  }

  Future<void> uploadNewProfileImage(File imageFile) async {
    try {
      isUserLoading = true;
      notifyListeners();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token != null) {
        await _repo.uploadProfileImage(imageFile, token);
        final fetchedUser = await _repo.getUser();
        user = fetchedUser;

        await prefs.setString('user_name', user!.userName!);
        if (user!.profileImageUrl != null) {
          await prefs.setString('profile_image_url', user!.profileImageUrl!);
        }
        print('Profile image updated');
        notifyListeners();
      } else {
        errorMessage = "Token not found";
        print("Token Not found");
        notifyListeners();
      }
    } catch (e) {
      errorMessage = 'Profil resmi yüklenirken hata oluştu: $e';
      print("Error upload image : ${e}");
      notifyListeners();
    } finally {
      isUserLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTourToWishlist(int tourId) async {
    try {
      _favoriteTourIds.add(tourId);
      _saveFavoriteTours();
      await _repo.addTourToWishlist(tourId);
      _updateTourFavoriteStatus(tourId);
    } catch (e) {
      errorMessage = 'Favorilere eklenirken hata oluştu: $e';
      print("Error adding to wishlist : ${e}");
      notifyListeners();
    }
  }

  Future<void> removeTourFromWishlist(int tourId) async {
    try {
      _favoriteTourIds.remove(tourId);
      _saveFavoriteTours();
      await _repo.removeTourFromWishlist(tourId);
      _updateTourFavoriteStatus(tourId);
    } catch (e) {
      errorMessage = 'Favorilerden çıkarılırken hata oluştu: $e';
      print("Error removing from wishlist : ${e}");
      notifyListeners();
    }
  }

  void _updateTourFavoriteStatus([int? tourId]) {
    if (tourId == null) {
      for (var tour in tours) {
        if (_favoriteTourIds.contains(tour.tourId)) {
          tour.isFavorite = true;
        } else {
          tour.isFavorite = false;
        }
      }
    } else {
      final tour = tours.firstWhere((element) => element.tourId == tourId);
      if (_favoriteTourIds.contains(tour.tourId)) {
        tour.isFavorite = true;
      } else {
        tour.isFavorite = false;
      }
    }

    notifyListeners();
  }

  Future<void> _loadFavoriteTours() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList('favorite_tour_ids');
    if (favoriteIds != null) {
      _favoriteTourIds = favoriteIds.map(int.parse).toSet();
      print("Favorite tours loaded : ${_favoriteTourIds}");
    }
  }

  Future<void> _saveFavoriteTours() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final favoriteIds = _favoriteTourIds.map((id) => id.toString()).toList();
    await prefs.setStringList('favorite_tour_ids', favoriteIds);
    print("Favorite tours saved : $_favoriteTourIds");
  }
}
