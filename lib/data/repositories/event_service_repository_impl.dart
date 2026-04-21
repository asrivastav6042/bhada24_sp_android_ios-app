import 'package:bhada24_sp/core/config/api_config.dart';
import 'package:bhada24_sp/core/network/api_client.dart';
import 'package:bhada24_sp/data/models/event_service_model.dart';
import 'package:bhada24_sp/domain/repositories/i_event_service_repository.dart';

class EventServiceRepositoryImpl implements IEventServiceRepository {
  final ApiClient _api;
  EventServiceRepositoryImpl(this._api);

  @override
  Future<bool> create(Map<String, dynamic> payload) async {
    try {
      final response =
          await _api.post(ApiConfig.addListingService, data: payload);
      final data = response.data;
      return response.statusCode == 200 && data['responseCode'] == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> update(Map<String, dynamic> payload) async {
    try {
      final esId = payload['esId'] as int;
      final response = await _api.put(
        ApiConfig.updateListingService(esId),
        data: payload,
      );
      final data = response.data;
      return response.statusCode == 200 && data['responseCode'] == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<EventServiceModel>> getBySpId(int spId) async {
    try {
      final response =
          await _api.get(ApiConfig.getListingServicesBySpId(spId));
      final data = response.data;
      if (data['responseCode'] == 200 && data['responseData'] != null) {
        final list = data['responseData'];
        if (list is List) {
          final flat = list.expand((e) => e is List ? e : [e]).toList();
          return flat
              .whereType<Map<String, dynamic>>()
              .map((e) =>
                  EventServiceModel.fromJson(e as Map<String, dynamic>))
              .where((e) => e.esId != null)
              .toList();
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<EventServiceModel?> getById(int esId) async {
    try {
      final response =
          await _api.get(ApiConfig.getListingServiceById(esId));
      final data = response.data;
      if (data['responseCode'] == 200 && data['responseData'] != null) {
        final rd = data['responseData'];
        if (rd is Map<String, dynamic>) {
          return EventServiceModel.fromJson(rd);
        } else if (rd is List && rd.isNotEmpty) {
          return EventServiceModel.fromJson(rd[0]);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> delete(int esId) async {
    try {
      final response =
          await _api.delete(ApiConfig.deleteListingService(esId));
      final data = response.data;
      return response.statusCode == 200 && data['responseCode'] == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> updateBookingStatus(Map<String, dynamic> payload) async {
    try {
      final response =
          await _api.put(ApiConfig.updateBookingStatus, data: payload);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
