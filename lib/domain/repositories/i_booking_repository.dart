import 'package:bhada24_sp/data/models/booking_model.dart';

/// Booking repository interface - Single Responsibility: Booking management only
abstract class IBookingRepository {
  Future<List<BookingModel>> getBookingsBySpId(int spId);
  Future<List<BookingModel>> getBookingsByEsId(int esId);
  Future<bool> updateBookingStatus(int bookingId, String status);
}
