import 'package:flutter/material.dart';
import '../models/booking_request_model.dart';
import '../models/booking_model.dart';
import '../repositories/main_repository.dart';

class BookingViewModel extends ChangeNotifier {
  final MainRepository _repository;
  bool _isLoading = false;
  String? _error;
  dynamic _bookingResponse;
  List<BookingModel> _bookings = [];
  BookingModel? _selectedBooking;

  BookingViewModel(this._repository);

  bool get isLoading => _isLoading;
  String? get error => _error;
  dynamic get bookingResponse => _bookingResponse;
  List<BookingModel> get bookings => _bookings;
  BookingModel? get selectedBooking => _selectedBooking;

  Future<dynamic> createBooking(BookingRequestModel request) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _repository.createBooking(request);
      _bookingResponse = response;
      print('Booking Response: $_bookingResponse');

      return response;
    } catch (e) {
      _error = e.toString();
      print('Booking Error in ViewModel: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Kullanıcının rezervasyonlarını getir
  Future<void> fetchBookings() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      try {
        _bookings = await _repository.getBookings();
        print('Bookings fetched: ${_bookings.length}');

        // Eğer daha önce bir rezervasyon seçilmişse ve liste içinde varsa, onu güncelle
        if (_selectedBooking != null) {
          final updatedIndex = _bookings.indexWhere(
              (booking) => booking.orderId == _selectedBooking!.orderId);

          if (updatedIndex >= 0) {
            _selectedBooking = _bookings[updatedIndex];
            print('Selected booking updated from fresh data');
          }
        }
      } catch (e) {
        print('Rezervasyonları getirme hatası: $e');
        throw Exception('Rezervasyonlar yüklenemedi: $e');
      }
    } catch (e) {
      _error = e.toString();
      print('Fetch Bookings Error in ViewModel: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Belirli bir rezervasyonun detaylarını getir
  Future<void> fetchBookingDetail(String orderId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Önce mevcut listedeki rezervasyonu kontrol et
      if (_bookings.isNotEmpty) {
        // OrderId ile eşleşen rezervasyonu bul
        final bookingIndex =
            _bookings.indexWhere((booking) => booking.orderId == orderId);

        if (bookingIndex >= 0) {
          _selectedBooking = _bookings[bookingIndex];
          print(
              'Booking detail found from local list: ${_selectedBooking?.tourName}');
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      // Mevcut listede bulamazsa API'den tüm listeyi yeniden çek
      await fetchBookings();

      // Yenilenen listeden tekrar ara
      if (_bookings.isNotEmpty) {
        final bookingIndex =
            _bookings.indexWhere((booking) => booking.orderId == orderId);

        if (bookingIndex >= 0) {
          _selectedBooking = _bookings[bookingIndex];
          print(
              'Booking detail found after refresh: ${_selectedBooking?.tourName}');
        } else {
          throw Exception('Rezervasyon bulunamadı: $orderId');
        }
      } else {
        throw Exception('Rezervasyon listesi boş, detay bulunamadı');
      }
    } catch (e) {
      _error = e.toString();
      print('Fetch Booking Detail Error in ViewModel: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Seçilen rezervasyon detayını manuel olarak ayarla
  void setSelectedBooking(BookingModel booking) {
    _selectedBooking = booking;
    notifyListeners();
  }
}
