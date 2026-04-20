import 'package:bhada24_sp/core/config/api_config.dart';
import 'package:bhada24_sp/core/network/api_client.dart';
import 'package:bhada24_sp/data/models/event_service_model.dart';

bool _ok(dynamic data) =>
    data is Map && (data['responseCode'] == 200 || data['responseCode'] == 0);
dynamic _payload(dynamic data) => data is Map ? data['responseData'] : null;

/// Wraps all /listing-services REST endpoints
class EventApiService {
  final ApiClient _api;
  EventApiService(this._api);

  Future<List<EventServiceModel>> getServicesBySpId(int spId) async {
    final res = await _api.get(ApiConfig.getListingServicesBySpId(spId));
    final raw = _payload(res.data) ?? (res.data is List ? res.data : null);
    List<dynamic> items = [];
    if (raw is List) {
      items = raw;
    } else if (raw is Map<String, dynamic>) {
      final inner = raw['data'] ?? raw['services'] ?? raw['listingServices'];
      if (inner is List) items = inner;
    }
    return items
        .whereType<Map<String, dynamic>>()
        .map(EventServiceModel.fromJson)
        .toList();
  }

  Future<EventServiceModel?> getServiceById(int esId) async {
    final res = await _api.get(ApiConfig.getListingServiceById(esId));
    final d = _payload(res.data);
    if (d is Map<String, dynamic>) return EventServiceModel.fromJson(d);
    return null;
  }

  Future<bool> createService(Map<String, dynamic> body) async {
    final res = await _api.post(ApiConfig.addListingService, data: body);
    return _ok(res.data);
  }

  Future<bool> updateService(int esId, Map<String, dynamic> body) async {
    final res =
        await _api.put(ApiConfig.updateListingService(esId), data: body);
    return _ok(res.data);
  }

  Future<bool> deleteService(int esId) async {
    final res = await _api.delete(ApiConfig.deleteListingService(esId));
    return _ok(res.data);
  }

  Future<bool> updateBookingStatus(int bookingId, String status) async {
    final res = await _api.put(ApiConfig.updateBookingStatus,
        data: {'bookingId': bookingId, 'status': status});
    return _ok(res.data);
  }
}
