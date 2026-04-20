import 'package:bhada24_sp/core/config/api_config.dart';
import 'package:bhada24_sp/core/network/api_client.dart';
import 'package:bhada24_sp/data/models/availability_exception_model.dart';
import 'package:bhada24_sp/domain/repositories/i_availability_repository.dart';

class AvailabilityRepositoryImpl implements IAvailabilityRepository {
  final ApiClient _api;
  AvailabilityRepositoryImpl(this._api);

  @override
  Future<bool> addException(
      String serviceType, int serviceId, Map<String, dynamic> data) async {
    try {
      final response = await _api.post(
        ApiConfig.addAvailabilityException(serviceType, serviceId),
        data: data,
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<AvailabilityExceptionModel>> getExceptions(
      String serviceType, int serviceId) async {
    try {
      final response = await _api.get(
        ApiConfig.getAvailabilityExceptions(serviceType, serviceId),
      );
      final data = response.data;
      if (data is Map && data['responseData'] is List) {
        return (data['responseData'] as List)
            .where((e) => e is Map<String, dynamic>)
            .map((e) =>
                AvailabilityExceptionModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (data is List) {
        return data
            .where((e) => e is Map<String, dynamic>)
            .map((e) =>
                AvailabilityExceptionModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<bool> deleteException(int exceptionId) async {
    try {
      final response = await _api.delete(
        ApiConfig.deleteAvailabilityException(exceptionId),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
