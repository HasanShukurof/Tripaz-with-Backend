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

      // Tüm turları al (token olmadan)
      tours = await _repo.getPublicTours();

      // Kullanıcı giriş yapmışsa wishlist durumunu kontrol et
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token != null && token.isNotEmpty) {
        try {
          // Wishlist turlarını al
          final wishlistTours = await _repo.getWishlistTours();
          final wishlistTourIds =
              wishlistTours.map((tour) => tour.tourId).toSet();

          // Her turun wishlist durumunu API'den gelen bilgiye göre güncelle
          for (var tour in tours) {
            tour.isFavorite = wishlistTourIds.contains(tour.tourId);
          }
        } catch (e) {
          // Wishlist hatası olsa bile turları göstermeye devam et
          print('Wishlist yüklenirken hata: $e');
        }
      }
    } catch (e) {
      errorMessage = 'Error loading tours: $e';
      debugPrint(errorMessage);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUser() async {
    try {
      isUserLoading = true;
      notifyListeners();

      // Kullanıcının giriş yapıp yapmadığını kontrol et
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null || token.isEmpty) {
        // Token yoksa kullanıcı misafir demektir
        user = null;
        _isUserLoaded = false;
        isUserLoading = false;
        notifyListeners();
        return;
      }

      // Token varsa kullanıcı bilgilerini yükle
      user = await _repo.getUser();
      _isUserLoaded = true;
    } catch (e) {
      errorMessage = 'Error loading user: $e';
      debugPrint(errorMessage);
    } finally {
      isUserLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteUser() async {
    try {
      isUserLoading = true;
      notifyListeners();
      await _repo.deleteUser();
      user = null;
      _isUserLoaded = false;
    } catch (e) {
      errorMessage = 'Hesap silme işlemi başarısız oldu: $e';
      debugPrint(errorMessage);
      rethrow;
    } finally {
      isUserLoading = false;
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

  Future<void> toggleWishlist(int tourId) async {
    try {
      // Önce kullanıcının giriş yapıp yapmadığını kontrol et
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token == null || token.isEmpty) {
        // Kullanıcı giriş yapmamışsa işlem yapma
        return;
      }

      // API çağrısını yap ama UI'ı güncellemek için bekleme
      if (_favoriteTourIds.contains(tourId)) {
        _repo.removeTourFromWishlist(tourId).then((_) {
          _favoriteTourIds.remove(tourId);
        });
      } else {
        _repo.addTourToWishlist(tourId).then((_) {
          _favoriteTourIds.add(tourId);
        });
      }
    } catch (e) {
      print('Wishlist toggle error: $e');
    }
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
