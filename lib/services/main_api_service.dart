import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert'; // jsonDecode için ekledik
import '../models/tour_model.dart' as tour;
import '../models/user_login_model.dart';
import '../models/detail_tour_model.dart';
import '../models/user_model.dart';
import '../models/wishlist_tour_model.dart';
import '../models/detail_booking_model.dart';
import '../models/car_type_model.dart'; // CarTypeModel import edildi
import '../models/payment_request_model.dart';
import '../models/payment_response_model.dart';
import '../models/booking_model.dart'; // BookingModel import edildi

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
        if (response.statusCode == 401) {
          throw Exception(response.data);
        }
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

  Future<List<tour.TourModel>> fetchTours(String token) async {
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
      final tourList =
          data.map((item) => tour.TourModel.fromJson(item)).toList();
      return tourList;
    } else {
      throw Exception('Failed to load tours');
    }
  }

  Future<tour.TourModel> fetchTour(int tourId, String token) async {
    final response = await _dio.get(
      'https://tripaz.az/api/Tour/tours/$tourId',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      }),
    );

    if (response.statusCode == 200) {
      print("Tour data for tourId ($tourId): ${response.data}");
      return tour.TourModel.fromJson(response.data);
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

      if (response.data is List && response.data.isNotEmpty) {
        final bookingModel = DetailBookingModel.fromJson(response.data[0]);
        print(
            "Detail booking data after model conversion: ${bookingModel.toJson()}");
        return bookingModel;
      } else if (response.data is Map) {
        // API yanıtı doğrudan bir nesne ise
        final bookingModel = DetailBookingModel.fromJson(response.data);
        print(
            "Detail booking data after model conversion: ${bookingModel.toJson()}");
        return bookingModel;
      } else {
        print(
            "API yanıtı beklenen formatta değil: ${response.data.runtimeType}");
        throw Exception('API yanıtı uygun formatta değil');
      }
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

  Future<PaymentResponseModel> createPayment(PaymentRequestModel model) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    // Request verilerini logla
    print('========== CREATE PAYMENT REQUEST ==========');
    print('Payment Request Parameters:');
    print('guestName: ${model.guestName}');
    print('phoneNumber: ${model.phoneNumber}');
    print('autoType: ${model.autoType}');
    print('airportPickupEnabled: ${model.airportPickupEnabled}');
    print('pickupDate: ${model.pickupDate}');
    print('pickupTime: ${model.pickupTime}');
    print('comment: ${model.comment}');
    print('tourStartDate: ${model.tourStartDate}');
    print('tourEndDate: ${model.tourEndDate}');
    print('nightCount: ${model.nightCount}');
    print('totalPrice: ${model.totalPrice}');
    print('tourId: ${model.tourId}');
    print('carId: ${model.carId}');
    print('orderDate: ${model.orderDate}');
    print('cashOrCahless: ${model.cashOrCahless}');
    print('payAmount: ${model.payAmount}');
    print('Payment Request JSON:');
    print(model.toJson());
    print('=========================================');

    final response = await _dio.post(
      'https://tripaz.az/api/Payriff/create-payment',
      data: model.toJson(),
      options: Options(
        headers: {
          'accept': 'text/plain',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    // Response verilerini logla
    print('========== CREATE PAYMENT RESPONSE ==========');
    print('Status code: ${response.statusCode}');
    print('Raw response data: ${response.data}');
    print('============================================');

    if (response.statusCode == 200) {
      final result = PaymentResponseModel.fromJson(response.data);
      print('Parsed PaymentResponseModel:');
      print('orderId: ${result.orderId}');
      print('code: ${result.code}');
      print('amount: ${result.amount}');
      print('paymentUrl: ${result.payload.paymentUrl}');
      print('============================================');
      return result;
    } else {
      throw Exception('Payment creation failed');
    }
  }

  Future<dynamic> checkPaymentStatus(String orderId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      print('Checking payment status with orderId: $orderId');
      print('Using token: $token');

      final response = await _dio.get(
        'https://tripaz.az/api/Payriff/check-payment-status/$orderId',
        options: Options(
          headers: {
            'accept': 'text/plain',
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => true, // Tüm status kodlarını kabul et
        ),
      );

      print('API Response Status Code: ${response.statusCode}');
      print('API Response Data: ${response.data}');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
            'Payment status check failed with status ${response.statusCode}');
      }
    } catch (e) {
      print('Check Payment Status Error in API: $e');
      rethrow;
    }
  }

  Future<void> deleteUser(String token) async {
    try {
      final response = await _dio.post(
        'https://tripaz.az/api/Users/deleteUser',
        options: Options(
          headers: {
            'accept': 'text/plain',
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Hesap silme işlemi başarısız oldu');
      }
    } catch (e) {
      print('Delete User Error: $e');
      rethrow;
    }
  }

  Future<List<tour.TourModel>> fetchPublicTours() async {
    try {
      final response = await _dio.get(
        'https://tripaz.az/api/Tour/ios/tours',
        options: Options(headers: {
          'Content-Type': 'application/json',
        }),
      );

      print('Public API Yanıtı: ${response.data}');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        final tourList =
            data.map((item) => tour.TourModel.fromJson(item)).toList();
        return tourList;
      } else {
        throw Exception('Failed to load tours');
      }
    } catch (e) {
      print('Public tour fetch error: $e');
      throw Exception('Failed to load tours: $e');
    }
  }

  Future<DetailTourModel> fetchPublicTourDetails(int tourId) async {
    try {
      final response = await _dio.post(
        'https://tripaz.az/api/Tour/ios/$tourId',
        options: Options(headers: {
          'accept': 'text/plain',
          'Content-Type': 'application/json',
        }),
      );

      if (response.statusCode == 200) {
        print("Public Tour details: ${response.data}");
        return DetailTourModel.fromJson(response.data);
      } else {
        print('API Error: ${response.statusCode} - ${response.statusMessage}');
        throw Exception('Failed to load tour details');
      }
    } catch (e) {
      print('Public tour detail fetch error: $e');
      throw Exception('Failed to load tour details: $e');
    }
  }

  // Get user bookings
  Future<List<BookingModel>> fetchBookings(String token) async {
    try {
      // Dio'nun zaman aşımı süresini ve alma tamponunu arttır
      final options = Options(
        headers: {
          'accept': 'text/plain',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        receiveTimeout: const Duration(minutes: 2),
        sendTimeout: const Duration(minutes: 1),
      );

      print('========== FETCH BOOKINGS REQUEST ==========');
      print('Fetching booking data...');
      print('Request Headers:');
      print('Authorization: Bearer ${token.substring(0, 15)}...');
      print('Content-Type: application/json');
      print('accept: text/plain');

      // API'ye sayfalama parametreleri ekleyerek veri miktarını sınırla
      // Not: API'nin bu parametreleri desteklemesi gerekir, eğer desteklemiyorsa
      // backend tarafında değişiklik yapılması gerekecektir
      Map<String, dynamic> queryParams = {
        'pageSize': 10, // Sayfa başına 10 kayıt
        'pageNumber': 1, // İlk sayfa
        'sortBy': 'orderDate', // Tarihe göre sırala
        'sortDir': 'desc' // Yeniden eskiye
      };

      print('Request Query Parameters:');
      print(queryParams);
      print('Request URL: https://tripaz.az/api/Tour/orders');
      print('============================================');

      try {
        final response = await _dio.get(
          'https://tripaz.az/api/Tour/orders',
          options: options,
          queryParameters: queryParams,
        );

        print('========== FETCH BOOKINGS RESPONSE ==========');
        // Yanıt boyutu kontrolü
        final responseSize = response.data.toString().length;
        print('Status Code: ${response.statusCode}');
        print('Booking API Response Size: $responseSize bytes');

        if (response.statusCode == 200) {
          if (response.data is List) {
            print('Response is a list with ${response.data.length} items');
            // Sadece ilk birkaç öğeyi göster, tam veriyi göstermek çok fazla log oluşturabilir
            if (response.data.isNotEmpty) {
              print('Sample first booking item:');
              print(response.data[0]);
            }

            List<dynamic> data = response.data;
            print('Converting ${data.length} items to BookingModel objects');
            List<BookingModel> bookings = [];

            for (var i = 0; i < data.length; i++) {
              try {
                final booking = BookingModel.fromJson(data[i]);
                bookings.add(booking);
              } catch (e) {
                print('Error parsing booking at index $i: $e');
              }
            }

            print('Successfully parsed ${bookings.length} bookings');
            print('==============================================');
            return bookings;
          } else {
            throw Exception('Beklenmedik yanıt formatı: Liste bekleniyor');
          }
        } else {
          throw Exception('Failed to load bookings: ${response.statusCode}');
        }
      } catch (e) {
        // API sayfalama desteği yoksa veya hata durumunda alternatif yöntem dene
        print(
            'Sayfalama desteği yok veya hata oluştu, alternatif yöntem deneniyor...');

        // API'yi yine çağırmayı dene ama bu sefer tüm veriyi çekmek yerine
        // maksimum boyut limitli olarak çalış
        try {
          print('Son çare: Sınırlı veri transferi ile deneme...');

          // Veri boyutunu sınırla
          _dio.options.receiveDataWhenStatusError = true;
          _dio.options.responseType =
              ResponseType.bytes; // Yanıtı byte olarak al

          final bytesResponse = await _dio.get(
            'https://tripaz.az/api/Tour/orders',
            options: options,
          );

          if (bytesResponse.statusCode == 200) {
            // Yanıtı byte olarak aldık, şimdi JSON'a çevirelim
            // Ancak veri çok büyükse önce keselim
            final bytes = bytesResponse.data as List<int>;
            print('Alınan veri boyutu: ${bytes.length} bytes');

            // 1MB üzerindeyse kırp (1048576 bytes = 1MB)
            List<int> truncatedBytes = bytes;
            if (bytes.length > 1048576) {
              print('Çok büyük veri, 1MB\'a kırpılıyor...');
              truncatedBytes = bytes.sublist(0, 1048576);
            }

            try {
              final jsonString = String.fromCharCodes(truncatedBytes);
              // JSON olarak ayrıştır - listeden emin değilsek ilk önce kontrol et
              final jsonData = jsonDecode(jsonString);

              if (jsonData is List) {
                List<dynamic> dataList = jsonData;
                print('Manual trimming with booking count: ${dataList.length}');

                // En fazla 20 kayıt al
                if (dataList.length > 20) {
                  dataList = dataList.sublist(0, 20);
                }

                List<BookingModel> bookings = [];
                for (var bookingData in dataList) {
                  try {
                    final booking = BookingModel.fromJson(bookingData);
                    bookings.add(booking);
                  } catch (parseError) {
                    print(
                        'Manuel kırpmalı veri ayrıştırma hatası: $parseError');
                  }
                }

                if (bookings.isEmpty) {
                  print('No bookings found or empty list returned.');
                } else {
                  print(
                      'Total ${bookings.length} bookings fetched successfully.');
                }

                return bookings;
              }
            } catch (jsonError) {
              print('Kırpılmış veri JSON hatası: $jsonError');
            }
          }
        } catch (bytesError) {
          print('Byte sınırlı sorgu hatası: $bytesError');
        }

        // Son çare: Boş liste dön
        print('Tüm yöntemler başarısız oldu, boş liste dönülüyor.');
        return [];
      }
    } catch (e) {
      print('Error fetching bookings: $e');
      // Boş liste dön, uygulama çökmesini önle
      return [];
    }
  }

  // Get details of a specific booking - uses the same API
  Future<BookingModel> fetchBookingDetail(String token, String orderId) async {
    try {
      // Get all bookings and find the one matching the ID
      final allBookings = await fetchBookings(token);

      // OrderId ile eşleşen rezervasyonu bul
      final booking = allBookings.firstWhere(
        (booking) => booking.orderId == orderId,
        orElse: () => throw Exception('Booking not found: $orderId'),
      );

      print('Booking detail found from list: ${booking.tourName}');
      return booking;
    } catch (e) {
      print('Error fetching booking detail: $e');
      rethrow;
    }
  }
}
