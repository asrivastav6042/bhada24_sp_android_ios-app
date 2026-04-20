import 'package:flutter/material.dart';
import 'package:bhada24_sp/data/models/booking_model.dart';
import 'package:bhada24_sp/domain/repositories/i_booking_repository.dart';

class BookingProvider extends ChangeNotifier {
  final IBookingRepository _repo;
  BookingProvider(this._repo);

  List<BookingModel> _bookings = [];
  bool _isLoading = false;
  String? _error;

  List<BookingModel> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Filter helpers
  List<BookingModel> get upcomingBookings {
    final now = DateTime.now();
    return _bookings.where((b) {
      if (b.bookingDate == null) return false;
      final date = DateTime.tryParse(b.bookingDate!);
      return date != null && date.isAfter(now);
    }).toList();
  }

  List<BookingModel> get pastBookings {
    final now = DateTime.now();
    return _bookings.where((b) {
      if (b.bookingDate == null) return true;
      final date = DateTime.tryParse(b.bookingDate!);
      return date == null || !date.isAfter(now);
    }).toList();
  }

  Future<void> loadBySpId(int spId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _bookings = await _repo.getBookingsBySpId(spId);
    } catch (e) {
      _error = 'Failed to load bookings.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadByEsId(int esId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _bookings = await _repo.getBookingsByEsId(esId);
    } catch (e) {
      _error = 'Failed to load bookings.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStatus(int bookingId, String status) async {
    try {
      final ok = await _repo.updateBookingStatus(bookingId, status);
      if (ok) {
        _bookings = _bookings.map((b) {
          if (b.bookingId == bookingId) return b.copyWith(status: status);
          return b;
        }).toList();
        notifyListeners();
      }
      return ok;
    } catch (e) {
      return false;
    }
  }
}
