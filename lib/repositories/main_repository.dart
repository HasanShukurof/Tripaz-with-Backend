import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tour_model.dart';
import '../models/user_login_model.dart';
import '../services/main_api_service.dart';
import '../services/cache_service.dart';
import '../models/detail_tour_model.dart';
import '../models/user_model.dart';
import '../models/wishlist_tour_model.dart';
import '../models/detail_booking_model.dart';
import '../models/car_type_model.dart';
import '../models/payment_request_model.dart';
import '../models/payment_response_model.dart';
import '../models/booking_model.dart' hide TourModel;

class MainRepository {
  final MainApiService _mainApiService;
  final CacheService _cacheService;
  String? _lastOrderId;

  MainRepository(this._mainApiService, this._cacheService);

  String? get lastOrderId => _lastOrderId;

  Future<UserLoginModel> login(String username, String password) async {
    return await _mainApiService.login(username, password);
  }

  Future<List<TourModel>> getTours() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      // Token yoksa login olmamış kullanıcılar için public API kullan
      return await getPublicTours();
    }

    List<TourModel>? cachedTours = await _cacheService.getDataList<TourModel>(
      CacheService.KEY_TOURS,
      (json) => TourModel.fromJson(json),
    );

    if (cachedTours != null) {
      print('Turlar önbellekten alındı');
      return cachedTours;
    }

    final tours = await _mainApiService.fetchTours(token);

    if (tours.isNotEmpty) {
      final toursJson = tours.map((tourItem) => tourItem.toJson()).toList();
      await _cacheService.saveData(CacheService.KEY_TOURS, toursJson);
      print('Turlar API\'den alındı ve önbelleğe kaydedildi');
    }

    return tours;
  }

  Future<List<TourModel>> getPublicTours() async {
    List<TourModel>? cachedTours = await _cacheService.getDataList<TourModel>(
      CacheService.KEY_PUBLIC_TOURS,
      (json) => TourModel.fromJson(json),
    );

    if (cachedTours != null) {
      print('Public turlar önbellekten alındı');
      return cachedTours;
    }

    try {
      final tours = await _mainApiService.fetchPublicTours();

      if (tours.isNotEmpty) {
        final toursJson = tours.map((tourItem) => tourItem.toJson()).toList();
        await _cacheService.saveData(CacheService.KEY_PUBLIC_TOURS, toursJson);
        print('Public turlar API\'den alındı ve önbelleğe kaydedildi');
      }

      return tours;
    } catch (e) {
      print('Public tours error: $e');
      // Hata durumunda boş liste döndür
      return [];
    }
  }

  Future<TourModel> getTour(int tourId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Token not found. User may not be logged in.');
    }

    TourModel? cachedTour = await _cacheService.getData<TourModel>(
      CacheService.KEY_TOUR_DETAILS + tourId.toString(),
      (json) => TourModel.fromJson(json),
    );

    if (cachedTour != null) {
      print('Tur detayı önbellekten alındı: $tourId');
      return cachedTour;
    }

    final tour = await _mainApiService.fetchTour(tourId, token);

    await _cacheService.saveData(
        CacheService.KEY_TOUR_DETAILS + tourId.toString(), tour.toJson());
    print('Tur detayı API\'den alındı ve önbelleğe kaydedildi: $tourId');

    return tour;
  }

  Future<DetailBookingModel> getDetailBooking(int tourId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Token not found. User may not be logged in.');
    }

    DetailBookingModel? cachedBooking =
        await _cacheService.getData<DetailBookingModel>(
      'cached_detail_booking_$tourId',
      (json) => DetailBookingModel.fromJson(json),
    );

    if (cachedBooking != null) {
      print('Detaylı rezervasyon bilgileri önbellekten alındı: $tourId');
      return cachedBooking;
    }

    final booking = await _mainApiService.fetchDetailBooking(tourId, token);

    await _cacheService.saveData(
        'cached_detail_booking_$tourId', booking.toJson());
    print(
        'Detaylı rezervasyon bilgileri API\'den alındı ve önbelleğe kaydedildi: $tourId');

    return booking;
  }

  Future<List<CarTypeModel>> getCarTypes(int tourId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Token not found. User may not be logged in.');
    }

    List<CarTypeModel>? cachedCarTypes =
        await _cacheService.getDataList<CarTypeModel>(
      'cached_car_types_$tourId',
      (json) => CarTypeModel.fromJson(json),
    );

    if (cachedCarTypes != null) {
      print('Araç tipleri önbellekten alındı: $tourId');
      return cachedCarTypes;
    }

    final carTypes = await _mainApiService.fetchCarTypes(tourId, token);

    if (carTypes.isNotEmpty) {
      final carTypesJson = carTypes.map((carType) => carType.toJson()).toList();
      await _cacheService.saveData('cached_car_types_$tourId', carTypesJson);
      print('Araç tipleri API\'den alındı ve önbelleğe kaydedildi: $tourId');
    }

    return carTypes;
  }

  Future<DetailTourModel> getTourDetails(int tourId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      // Token yoksa login olmamış kullanıcılar için public API kullan
      return await getPublicTourDetails(tourId);
    }

    DetailTourModel? cachedTourDetails =
        await _cacheService.getData<DetailTourModel>(
      CacheService.KEY_TOUR_DETAILS + tourId.toString() + '_details',
      (json) => DetailTourModel.fromJson(json),
    );

    if (cachedTourDetails != null) {
      print('Tur detayları önbellekten alındı: $tourId');
      return cachedTourDetails;
    }

    final tourDetails = await _mainApiService.fetchTourDetails(tourId, token);

    await _cacheService.saveData(
        CacheService.KEY_TOUR_DETAILS + tourId.toString() + '_details',
        tourDetails.toJson());
    print('Tur detayları API\'den alındı ve önbelleğe kaydedildi: $tourId');

    return tourDetails;
  }

  Future<DetailTourModel> getPublicTourDetails(int tourId) async {
    DetailTourModel? cachedTourDetails =
        await _cacheService.getData<DetailTourModel>(
      CacheService.KEY_PUBLIC_TOUR_DETAILS + tourId.toString(),
      (json) => DetailTourModel.fromJson(json),
    );

    if (cachedTourDetails != null) {
      print('Public tur detayları önbellekten alındı: $tourId');
      return cachedTourDetails;
    }

    try {
      final tourDetails = await _mainApiService.fetchPublicTourDetails(tourId);

      await _cacheService.saveData(
          CacheService.KEY_PUBLIC_TOUR_DETAILS + tourId.toString(),
          tourDetails.toJson());
      print(
          'Public tur detayları API\'den alındı ve önbelleğe kaydedildi: $tourId');

      return tourDetails;
    } catch (e) {
      print('Public tour details error: $e');
      throw e;
    }
  }

  Future<UserModel> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Token not found. User may not be logged in.');
    }

    UserModel? cachedUser = await _cacheService.getData<UserModel>(
      CacheService.KEY_USER_DATA,
      (json) => UserModel.fromJson(json),
    );

    if (cachedUser != null) {
      print('Kullanıcı bilgileri önbellekten alındı');
      return cachedUser;
    }

    final user = await _mainApiService.fetchUser(token);

    await _cacheService.saveData(CacheService.KEY_USER_DATA, user.toJson());
    print('Kullanıcı bilgileri API\'den alındı ve önbelleğe kaydedildi');

    return user;
  }

  Future<void> uploadProfileImage(File imageFile, String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Token not found. User may not be logged in.');
    }

    await _mainApiService.uploadProfileImage(imageFile, token);

    await _cacheService.clearCache(CacheService.KEY_USER_DATA);
  }

  Future<void> addTourToWishlist(int tourId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Token not found. User may not be logged in.');
    }

    await _mainApiService.addTourToWishlist(tourId, token);

    await _cacheService.clearCache(CacheService.KEY_WISHLIST);
  }

  Future<void> removeTourFromWishlist(int tourId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Token not found. User may not be logged in.');
    }

    await _mainApiService.removeTourFromWishlist(tourId, token);

    await _cacheService.clearCache(CacheService.KEY_WISHLIST);
  }

  Future<List<WishlistTourModel>> getWishlistTours() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Token not found. User may not be logged in.');
    }

    print('Wishlist verisi için önbellek kontrolü yapılıyor...');

    try {
      // Önbellekte veri kontrolü
      List<WishlistTourModel>? cachedWishlist =
          await _cacheService.getDataList<WishlistTourModel>(
        CacheService.KEY_WISHLIST,
        (json) => WishlistTourModel.fromJson(json),
      );

      // Önbellekte veri varsa onu döndür
      if (cachedWishlist != null && cachedWishlist.isNotEmpty) {
        print('İstek listesi önbellekten alındı: ${cachedWishlist.length} öğe');
        return cachedWishlist;
      } else {
        print('Önbellekte wishlist verisi bulunamadı veya boş');
      }
    } catch (e) {
      print('Wishlist önbellek okuma hatası: $e');
      // Hata durumunda önbelleği temizle
      await _cacheService.clearCache(CacheService.KEY_WISHLIST);
    }

    // Önbellekte veri yoksa veya hata oluştuysa API'den al
    print('Wishlist verisi API\'den alınıyor...');
    try {
      final wishlist = await _mainApiService.fetchWishlistTours(token);

      // API'den gelen verileri önbelleğe kaydet
      if (wishlist.isNotEmpty) {
        try {
          // Modelleri JSON'a çevirirken null kontrolü yapılmalı
          final wishlistJson = wishlist
              .map((item) {
                try {
                  return item.toJson();
                } catch (e) {
                  print('Wishlist item toJson hatası: $e');
                  return null;
                }
              })
              .where((item) => item != null)
              .toList();

          if (wishlistJson.isNotEmpty) {
            await _cacheService.saveData(
                CacheService.KEY_WISHLIST, wishlistJson);
            print(
                'İstek listesi API\'den alındı ve önbelleğe kaydedildi: ${wishlist.length} öğe');
          } else {
            print(
                'Wishlist verisi JSON\'a dönüştürülemedi, önbelleğe kaydedilemedi');
          }
        } catch (e) {
          print('Wishlist önbelleğe kaydetme hatası: $e');
        }
      } else {
        print('API\'den gelen wishlist verisi boş');
      }

      return wishlist;
    } catch (e) {
      print('Wishlist API hatası: $e');
      throw Exception('İstek listesi alınamadı: $e');
    }
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

  Future<void> deleteUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Token not found. User may not be logged in.');
    }

    await _mainApiService.deleteUser(token);

    await _cacheService.clearAllCache();
  }

  Future<List<BookingModel>> getBookings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Token not found. User may not be logged in.');
    }

    try {
      List<BookingModel>? cachedBookings =
          await _cacheService.getDataList<BookingModel>(
        CacheService.KEY_BOOKINGS,
        (json) => BookingModel.fromJson(json),
      );

      if (cachedBookings != null) {
        print('Rezervasyonlar önbellekten alındı');
        return cachedBookings;
      }

      final bookings = await _mainApiService.fetchBookings(token);

      if (bookings.isNotEmpty) {
        final bookingsJson =
            bookings.map((booking) => booking.toJson()).toList();
        await _cacheService.saveData(CacheService.KEY_BOOKINGS, bookingsJson);
        print('Rezervasyonlar API\'den alındı ve önbelleğe kaydedildi');
      } else {
        print('No bookings found or empty list returned.');
      }

      return bookings;
    } catch (e) {
      print('Repository - Booking retrieval error: $e');
      return [];
    }
  }

  Future<BookingModel> getBookingDetail(String orderId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Token not found. User may not be logged in.');
    }

    BookingModel? cachedBooking = await _cacheService.getData<BookingModel>(
      'cached_booking_detail_$orderId',
      (json) => BookingModel.fromJson(json),
    );

    if (cachedBooking != null) {
      print('Rezervasyon detayları önbellekten alındı: $orderId');
      return cachedBooking;
    }

    final bookings = await _mainApiService.fetchBookings(token);

    final booking = bookings.firstWhere(
      (booking) => booking.orderId == orderId,
      orElse: () => throw Exception('Booking not found: $orderId'),
    );

    await _cacheService.saveData(
        'cached_booking_detail_$orderId', booking.toJson());
    print(
        'Rezervasyon detayları API\'den alındı ve önbelleğe kaydedildi: $orderId');

    return booking;
  }

  Future<void> clearCache() async {
    await _cacheService.clearAllCache();
    print('Tüm önbellek temizlendi');
  }
}
