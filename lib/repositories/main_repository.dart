import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tour_model.dart';
import '../models/user_login_model.dart';
import '../services/main_api_service.dart';
import '../models/detail_tour_model.dart';
import '../models/user_model.dart';
import '../models/wishlist_tour_model.dart';
import '../models/detail_booking_model.dart';
import '../models/car_type_model.dart'; // CarTypeModel import edildi

class MainRepository {
  final MainApiService _mainApiService;

  MainRepository(this._mainApiService);

  Future<UserLoginModel> login(String username, String password) async {
    return await _mainApiService.login(username, password);
  }

  Future<List<TourModel>> getTours() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Token bulunamadı. Kullanıcı giriş yapmamış olabilir.');
    }
    return await _mainApiService.fetchTours(token);
  }

  Future<TourModel> getTour(int tourId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Token bulunamadı. Kullanıcı giriş yapmamış olabilir.');
    }
    return await _mainApiService.fetchTour(tourId, token);
  }

  Future<DetailBookingModel> getDetailBooking(int tourId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Token bulunamadı. Kullanıcı giriş yapmamış olabilir.');
    }
    return await _mainApiService.fetchDetailBooking(tourId, token);
  }

  Future<List<CarTypeModel>> getCarTypes(int tourId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Token bulunamadı. Kullanıcı giriş yapmamış olabilir.');
    }
    return await _mainApiService.fetchCarTypes(tourId, token);
  }

  Future<DetailTourModel> getTourDetails(int tourId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Token bulunamadı. Kullanıcı giriş yapmamış olabilir.');
    }
    return await _mainApiService.fetchTourDetails(tourId, token);
  }

  Future<UserModel> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Token bulunamadı. Kullanıcı giriş yapmamış olabilir.');
    }
    return await _mainApiService.fetchUser(token);
  }

  Future<void> uploadProfileImage(File imageFile, String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Token bulunamadı. Kullanıcı giriş yapmamış olabilir.');
    }
    return await _mainApiService.uploadProfileImage(imageFile, token);
  }

  Future<void> addTourToWishlist(int tourId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Token bulunamadı. Kullanıcı giriş yapmamış olabilir.');
    }
    return await _mainApiService.addTourToWishlist(tourId, token);
  }

  Future<void> removeTourFromWishlist(int tourId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Token bulunamadı. Kullanıcı giriş yapmamış olabilir.');
    }
    return await _mainApiService.removeTourFromWishlist(tourId, token);
  }

  Future<List<WishlistTourModel>> getWishlistTours() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Token bulunamadı. Kullanıcı giriş yapmamış olabilir.');
    }
    return await _mainApiService.fetchWishlistTours(token);
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    await _mainApiService.register(
      username: username,
      email: email,
      password: password,
    );
  }
}
