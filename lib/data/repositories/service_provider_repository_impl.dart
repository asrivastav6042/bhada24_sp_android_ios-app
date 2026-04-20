import 'package:bhada24_sp/core/config/api_config.dart';
import 'package:bhada24_sp/core/network/api_client.dart';
import 'package:bhada24_sp/data/models/service_provider_model.dart';
import 'package:bhada24_sp/domain/repositories/i_service_provider_repository.dart';

class ServiceProviderRepositoryImpl implements IServiceProviderRepository {
  final ApiClient _api;
  ServiceProviderRepositoryImpl(this._api);

  @override
  Future<ServiceProviderModel?> getById(int id) async {
    try {
      final response = await _api.get(ApiConfig.getSpById(id));
      final data = response.data;
      if (data['responseCode'] == 200 && data['responseData'] != null) {
        final rd = data['responseData'];
        if (rd is List && rd.isNotEmpty) {
          return ServiceProviderModel.fromJson(rd[0]);
        } else if (rd is Map<String, dynamic>) {
          return ServiceProviderModel.fromJson(rd);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<ServiceProviderModel?> getByMobile(String mobile) async {
    try {
      final response = await _api.get(ApiConfig.getSpByMobile(mobile));
      final data = response.data;
      if (data['responseCode'] == 200 &&
          data['responseData'] is List &&
          (data['responseData'] as List).isNotEmpty) {
        return ServiceProviderModel.fromJson(data['responseData'][0]);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<ServiceProviderModel?> getByEmail(String email) async {
    try {
      final response = await _api.get(ApiConfig.getSpByEmail(email));
      final data = response.data;
      if (data['responseCode'] == 200 && data['responseData'] != null) {
        final rd = data['responseData'];
        if (rd is List && rd.isNotEmpty) {
          return ServiceProviderModel.fromJson(rd[0]);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> update(Map<String, dynamic> payload) async {
    try {
      final response = await _api.patch(ApiConfig.updateSp, data: payload);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> updateLanguage(int spId, String language) async {
    try {
      final normalizedLang = language == 'hi' ? 'hindi' : 'english';
      final response =
          await _api.put(ApiConfig.updateSpLanguage(spId, normalizedLang));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deactivate(int spId) async {
    try {
      final response = await _api.put(ApiConfig.deactivateSp(spId));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deleteAccount(int spId) async {
    try {
      final response = await _api.delete(ApiConfig.deleteSp(spId));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<double> getAverageRating(int spId) async {
    try {
      final response =
          await _api.get(ApiConfig.getProviderAverageRating(spId));
      final data = response.data;
      if (data['responseCode'] == 200) {
        return (data['responseData'] as num?)?.toDouble() ?? 0.0;
      }
      return 0.0;
    } catch (_) {
      return 0.0;
    }
  }

  @override
  Future<String?> uploadImage(int userId, String base64) async {
    try {
      final response = await _api.post(
        ApiConfig.uploadBase64Image,
        data: {'userId': userId, 'base64Image': base64},
      );
      final data = response.data;
      if (data is Map && data.containsKey('responseData')) {
        return data['responseData']?.toString();
      }
      return data?.toString();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> updateNotificationSettings(
      int spId, bool mobile, bool email) async {
    try {
      final response = await _api.patch(
          ApiConfig.updateNotificationSettings(spId, mobile, email));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
