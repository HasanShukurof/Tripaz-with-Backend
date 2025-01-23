import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../models/tour_model.dart';
import '../models/user_login_model.dart';
import '../models/detail_tour_model.dart';
import '../models/user_model.dart';
import '../models/wishlist_tour_model.dart';
import '../models/detail_booking_model.dart';
import '../models/car_type_model.dart'; // CarTypeModel import edildi

class MainApiService {
  final Dio _dio = Dio();

  Future<UserLoginModel> login(String username, String password) async {
    try {
      print("Login attempt - Email: $username");

      // API'nin beklediği formatta request body
      Map<String, dynamic> requestBody = {
        "Email": username, // "email" yerine "Email"
        "Password": password, // "password" yerine "Password"
      };

      print("Login request body: $requestBody");

      final response = await _dio.post(
        'https://tripaz.az/api/Authentication/login',
        data: requestBody,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => true,
        ),
      );

      print("Login response status: ${response.statusCode}");
      print("Login response data: ${response.data}");

      if (response.statusCode == 200) {
        String token = response.data['accessToken'];
        await saveToken(token);
        print("Login successful - Token saved");
        return UserLoginModel.fromJson(response.data);
      } else {
        final errorMessage = response.data['errors']?['Email']?.first ??
            response.data['message'] ??
            'Login failed';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print("Login error: ${e.toString()}");
      rethrow;
    }
  }

  Future<List<TourModel>> fetchTours(String token) async {
    final response = await _dio.get(
      'https://tripaz.az/api/Tour/tours',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      }),
    );

    print('API Yanıtı: ${response.data}');

    if (response.statusCode == 200) {
      List<dynamic> data = response.data;
      final tourList = data.map((tour) => TourModel.fromJson(tour)).toList();
      return tourList;
    } else {
      throw Exception('Failed to load tours');
    }
  }

  Future<TourModel> fetchTour(int tourId, String token) async {
    final response = await _dio.get(
      'https://tripaz.az/api/Tour/tours/$tourId',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      }),
    );

    if (response.statusCode == 200) {
      print("Tour data for tourId ($tourId): ${response.data}");
      return TourModel.fromJson(response.data);
    } else {
      print('API Error: ${response.statusCode} - ${response.statusMessage}');
      throw Exception('Failed to load tour');
    }
  }

  Future<DetailBookingModel> fetchDetailBooking(
      int tourId, String token) async {
    final response = await _dio.get(
      'https://tripaz.az/api/Tour/tours/$tourId',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      }),
    );

    if (response.statusCode == 200) {
      print("Detail booking data for tourId ($tourId): ${response.data}");
      final bookingModel = DetailBookingModel.fromJson(response.data[0]);
      print(
          "Detail booking data after model conversion: ${bookingModel.toJson()}");
      return bookingModel;
    } else {
      print('API Error: ${response.statusCode} - ${response.statusMessage}');
      throw Exception('Failed to load detail booking');
    }
  }

  Future<List<CarTypeModel>> fetchCarTypes(int tourId, String token) async {
    final response = await _dio.get(
      'https://tripaz.az/api/Tour/cars/$tourId',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'accept': 'text/plain',
      }),
    );

    if (response.statusCode == 200) {
      print("Car types for tourId ($tourId): ${response.data}");
      if (response.data is List) {
        List<dynamic> data = response.data;
        final carTypeList =
            data.map((carType) => CarTypeModel.fromJson(carType)).toList();
        return carTypeList;
      } else {
        throw Exception(
            'Unexpected JSON format: Expected a list of car types.');
      }
    } else {
      print('API Error: ${response.statusCode} - ${response.statusMessage}');
      throw Exception('Failed to load car types');
    }
  }

  Future<DetailTourModel> fetchTourDetails(int tourId, String token) async {
    final response = await _dio.post(
      'https://tripaz.az/api/Tour/$tourId',
      options: Options(headers: {
        'accept': 'text/plain',
        'Authorization': 'Bearer $token',
      }),
    );

    if (response.statusCode == 200) {
      print("Tour details: ${response.data}");
      return DetailTourModel.fromJson(response.data);
    } else {
      print('API Error: ${response.statusCode} - ${response.statusMessage}');
      throw Exception('Failed to load tour details');
    }
  }

  Future<UserModel> fetchUser(String token) async {
    final response = await _dio.get(
      'https://tripaz.az/api/Users/user',
      options: Options(headers: {
        'accept': 'text/plain',
        'Authorization': 'Bearer $token',
      }),
    );

    if (response.statusCode == 200) {
      print("User datas: ${response.data}");
      return UserModel.fromJson(response.data);
    } else {
      print('API Error: ${response.statusCode} - ${response.statusMessage}');
      throw Exception('Failed to load user data');
    }
  }

  Future<void> uploadProfileImage(File imageFile, String token) async {
    String fileName = imageFile.path.split('/').last;
    FormData formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
      ),
    });

    final response = await _dio.post(
      'https://tripaz.az/api/Users/upload-profile-image',
      data: formData,
      options: Options(headers: {
        'Authorization': 'Bearer $token',
      }),
    );

    if (response.statusCode == 200) {
      print('Profile image uploaded successfully');
    } else {
      print('API Error: ${response.statusCode} - ${response.statusMessage}');
      throw Exception('Failed to upload profile image');
    }
  }

  Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  Future<void> addTourToWishlist(int tourId, String token) async {
    final response = await _dio.post(
      'https://tripaz.az/api/Tour/wishlist/$tourId',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      }),
    );

    if (response.statusCode == 200) {
      print("Successfully added to wishlist tourId : $tourId");
    } else {
      print('API Error: ${response.statusCode} - ${response.statusMessage}');
      throw Exception('Failed to add tour to wishlist');
    }
  }

  Future<void> removeTourFromWishlist(int tourId, String token) async {
    final response = await _dio.post(
      'https://tripaz.az/api/Tour/wishlist/$tourId',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      }),
    );

    if (response.statusCode == 200) {
      print("Successfully removed from wishlist tourId : $tourId");
    } else {
      print('API Error: ${response.statusCode} - ${response.statusMessage}');
      throw Exception('Failed to remove tour from wishlist');
    }
  }

  Future<List<WishlistTourModel>> fetchWishlistTours(String token) async {
    final response = await _dio.get(
      'https://tripaz.az/api/Tour/wishlist',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      }),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = response.data;
      final tourList =
          data.map((tour) => WishlistTourModel.fromJson(tour)).toList();
      print("Wishlist api datas : $tourList");
      return tourList;
    } else {
      print('API Error: ${response.statusCode} - ${response.statusMessage}');
      throw Exception('Failed to load wishlist tours');
    }
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      print("Registration attempt - Username: $username, Email: $email");

      final response = await _dio.post(
        'https://tripaz.az/api/Authentication/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => true, // Tüm status kodlarını kabul et
        ),
      );

      print("Registration response status: ${response.statusCode}");
      print("Registration response data: ${response.data}");

      if (response.statusCode == 200) {
        print("Registration successful");
      } else {
        throw Exception(response.data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      print("Registration error: ${e.toString()}");
      rethrow;
    }
  }
}
