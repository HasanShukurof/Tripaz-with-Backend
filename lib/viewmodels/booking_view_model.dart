import 'package:flutter/material.dart';
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

  // Get user bookings
  Future<void> fetchBookings() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      try {
        _bookings = await _repository.getBookings();
        print('Bookings fetched: ${_bookings.length}');

        // Repository artık boş liste dönebilir, bu durumu kontrol et
        if (_bookings.isEmpty) {
          print('No bookings found or data could not be retrieved.');
        }

        // Eğer daha önce bir rezervasyon seçilmişse ve liste içinde varsa, onu güncelle
        if (_selectedBooking != null && _bookings.isNotEmpty) {
          final updatedIndex = _bookings.indexWhere(
              (booking) => booking.orderId == _selectedBooking!.orderId);

          if (updatedIndex >= 0) {
            _selectedBooking = _bookings[updatedIndex];
            print('Selected booking updated from fresh data');
          }
        }
      } catch (e) {
        print('Error fetching bookings: $e');
        _isLoading = false;
        _error = 'Failed to load bookings: $e';
      }
    } catch (e) {
      _error = e.toString();
      print('Fetch Bookings Error in ViewModel: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get details of a specific booking
  Future<void> fetchBookingDetail(String orderId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // First check existing booking in the list
      if (_bookings.isNotEmpty) {
        // Find the booking matching the orderId
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
          throw Exception('Booking not found: $orderId');
        }
      } else {
        throw Exception('Booking list is empty, no details found');
      }
    } catch (e) {
      _error = e.toString();
      print('Fetch Booking Detail Error in ViewModel: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Manually set selected booking detail
  void setSelectedBooking(BookingModel booking) {
    _selectedBooking = booking;
    notifyListeners();
  }
}
