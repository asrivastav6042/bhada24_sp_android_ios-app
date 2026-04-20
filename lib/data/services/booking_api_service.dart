import 'package:bhada24_sp/core/config/api_config.dart';
import 'package:bhada24_sp/core/network/api_client.dart';
import 'package:bhada24_sp/data/models/booking_model.dart';

bool _ok(dynamic data) =>
    data is Map && (data['responseCode'] == 200 || data['responseCode'] == 0);
dynamic _payload(dynamic data) => data is Map ? data['responseData'] : null;

/// Wraps booking-related REST endpoints
class BookingApiService {
  final ApiClient _api;
  BookingApiService(this._api);

  Future<List<BookingModel>> getBookingsBySpId(int spId) async {
    final res = await _api
        .get('${ApiConfig.baseUrl}/listing-services/bookings/sp/$spId');
    final raw = _payload(res.data) ?? (res.data is List ? res.data : null);
    List<dynamic> items = [];
    if (raw is List) {
      items = raw;
    } else if (raw is Map<String, dynamic>) {
      final inner = raw['data'] ?? raw['bookings'];
      if (inner is List) items = inner;
    }
    return items
        .whereType<Map<String, dynamic>>()
        .map(BookingModel.fromJson)
        .toList();
  }

  Future<List<BookingModel>> getBookingsByEsId(int esId) async {
    final res = await _api
        .get('${ApiConfig.baseUrl}/listing-services/$esId/bookings');
    final raw = _payload(res.data) ?? (res.data is List ? res.data : null);
    List<dynamic> items = [];
    if (raw is List) {
      items = raw;
    } else if (raw is Map<String, dynamic>) {
      final inner = raw['data'] ?? raw['bookings'];
      if (inner is List) items = inner;
    }
    return items
        .whereType<Map<String, dynamic>>()
        .map(BookingModel.fromJson)
        .toList();
  }

  Future<bool> updateBookingStatus(int bookingId, String status) async {
    final res = await _api.put(ApiConfig.updateBookingStatus,
        data: {'bookingId': bookingId, 'status': status});
    return _ok(res.data);
  }
}
