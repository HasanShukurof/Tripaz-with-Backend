import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tour_model.dart' as tour;
import '../models/user_login_model.dart';
import '../services/main_api_service.dart';
import '../models/detail_tour_model.dart';
import '../models/user_model.dart';
import '../models/wishlist_tour_model.dart';
import '../models/detail_booking_model.dart';
import '../models/car_type_model.dart'; // CarTypeModel import edildi
import '../models/payment_request_model.dart';
import '../models/payment_response_model.dart';
import '../models/booking_request_model.dart'; // Yeni model import edildi
import '../models/booking_model.dart'; // BookingModel import edildi

class MainRepository {
  final MainApiService _mainApiService;
  String? _lastOrderId; // OrderId'yi saklamak için

  MainRepository(this._mainApiService);

  String? get lastOrderId => _lastOrderId;

  Future<UserLoginModel> login(String username, String password) async {
    return await _mainApiService.login(username, password);
  }

  Future<List<tour.TourModel>> getTours() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Token not found. User may not be logged in.');
    }
    return await _mainApiService.fetchTours(token);
  }

  Future<tour.TourModel> getTour(int tourId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Token not found. User may not be logged in.');
    }
    return await _mainApiService.fetchTour(tourId, token);
  }

  Future<DetailBookingModel> getDetailBooking(int tourId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Token not found. User may not be logged in.');
    }
    return await _mainApiService.fetchDetailBooking(tourId, token);
  }

  Future<List<CarTypeModel>> getCarTypes(int tourId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Token not found. User may not be logged in.');
    }
    return await _mainApiService.fetchCarTypes(tourId, token);
  }

  Future<DetailTourModel> getTourDetails(int tourId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Token not found. User may not be logged in.');
    }
    return await _mainApiService.fetchTourDetails(tourId, token);
  }

  Future<UserModel> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Token not found. User may not be logged in.');
    }
    return await _mainApiService.fetchUser(token);
  }

  Future<void> uploadProfileImage(File imageFile, String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Token not found. User may not be logged in.');
    }
    return await _mainApiService.uploadProfileImage(imageFile, token);
  }

  Future<void> addTourToWishlist(int tourId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Token not found. User may not be logged in.');
    }
    return await _mainApiService.addTourToWishlist(tourId, token);
  }

  Future<void> removeTourFromWishlist(int tourId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Token not found. User may not be logged in.');
    }
    return await _mainApiService.removeTourFromWishlist(tourId, token);
  }

  Future<List<WishlistTourModel>> getWishlistTours() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Token not found. User may not be logged in.');
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

  Future<PaymentResponseModel> createPayment(PaymentRequestModel model) async {
    try {
      final response = await _mainApiService.createPayment(model);
      // OrderId'yi sakla
      _lastOrderId = response.payload.orderId;
      print('Payment OrderId saved: $_lastOrderId');
      return response;
    } catch (e) {
      print('Payment creation error in repository: $e');
      throw Exception('Payment creation failed: $e');
    }
  }

  Future<dynamic> checkPaymentStatus(String orderId) async {
    try {
      final response = await _mainApiService.checkPaymentStatus(orderId);
      print('Payment status checked for orderId: $orderId');
      print('Payment status response: $response');
      return response;
    } catch (e) {
      print('Payment status check error in repository: $e');
      throw Exception('Payment status check failed: $e');
    }
  }

  Future<dynamic> createBooking(BookingRequestModel model) async {
    try {
      final response = await _mainApiService.createBooking(model);
      print('Booking created successfully');
      return response;
    } catch (e) {
      print('Booking creation error in repository: $e');
      throw Exception('Booking creation failed: $e');
    }
  }

  Future<void> deleteUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Token not found. User may not be logged in.');
    }
    return await _mainApiService.deleteUser(token);
  }

  Future<List<tour.TourModel>> getPublicTours() async {
    return await _mainApiService.fetchPublicTours();
  }

  Future<DetailTourModel> getPublicTourDetails(int tourId) async {
    return await _mainApiService.fetchPublicTourDetails(tourId);
  }

  // Get user bookings
  Future<List<BookingModel>> getBookings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Token not found. User may not be logged in.');
    }

    try {
      final bookings = await _mainApiService.fetchBookings(token);

      if (bookings.isEmpty) {
        print('No bookings found or empty list returned.');
      } else {
        print('Total ${bookings.length} bookings successfully fetched.');
      }

      return bookings;
    } catch (e) {
      print('Repository - Booking retrieval error: $e');
      // Return empty list to prevent app crash
      return [];
    }
  }

  // Get details of a specific booking
  Future<BookingModel> getBookingDetail(String orderId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Token not found. User may not be logged in.');
    }

    // Instead of fetching details individually, get all bookings and find the relevant one
    final bookings = await _mainApiService.fetchBookings(token);

    final booking = bookings.firstWhere(
      (booking) => booking.orderId == orderId,
      orElse: () => throw Exception('Booking not found: $orderId'),
    );

    return booking;
  }
}
