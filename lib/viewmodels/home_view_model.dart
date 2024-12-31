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
  bool _isUserLoaded =
      false; // Kullanıcının yüklenip yüklenmediğini kontrol etmek için flag

  HomeViewModel(this._repo) {
    // ViewModel ilk oluşturulduğunda kullanıcı bilgilerini yükle
    loadUser();
  }

  Future<void> loadTours() async {
    try {
      isLoading = true;
      notifyListeners();

      tours = await _repo.getTours();
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
      return; // Kullanıcı zaten yüklendiyse fonksiyonu sonlandır.
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
      _isUserLoaded = true; // Kullanıcının yüklendiğini işaretle
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
        //  Resim yüklendikten sonra, güncellenmiş kullanıcı bilgilerini çek
        final fetchedUser = await _repo.getUser();
        user = fetchedUser;

        await prefs.setString('user_name', user!.userName!);
        if (user!.profileImageUrl != null) {
          await prefs.setString('profile_image_url', user!.profileImageUrl!);
        }
        print('Profile image updated');
        notifyListeners(); // Notify listeners after updating user
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
}
