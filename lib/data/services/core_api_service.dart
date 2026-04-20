import 'package:bhada24_sp/core/config/api_config.dart';
import 'package:bhada24_sp/core/network/api_client.dart';
import 'package:bhada24_sp/data/models/service_provider_model.dart';

bool _ok(dynamic data) =>
    data is Map && (data['responseCode'] == 200 || data['responseCode'] == 0);

dynamic _payload(dynamic data) =>
    data is Map ? data['responseData'] : null;

/// Wraps all /service-provider REST endpoints
class CoreApiService {
  final ApiClient _api;
  CoreApiService(this._api);

  Future<ServiceProviderModel?> getSpById(int id) async {
    final res = await _api.get(ApiConfig.getSpById(id));
    final d = _payload(res.data);
    if (d is Map<String, dynamic>) return ServiceProviderModel.fromJson(d);
    return null;
  }

  Future<ServiceProviderModel?> getSpByMobile(String mobile) async {
    final res = await _api.get(ApiConfig.getSpByMobile(mobile));
    final d = _payload(res.data);
    if (d is Map<String, dynamic>) return ServiceProviderModel.fromJson(d);
    return null;
  }

  Future<ServiceProviderModel?> getSpByEmail(String email) async {
    final res = await _api.get(ApiConfig.getSpByEmail(email));
    final d = _payload(res.data);
    if (d is Map<String, dynamic>) return ServiceProviderModel.fromJson(d);
    return null;
  }

  Future<bool> validateMobile(String mobile) async {
    final res = await _api.get(ApiConfig.validateMobile(mobile));
    return _ok(res.data);
  }

  Future<bool> registerSp(Map<String, dynamic> body) async {
    final res = await _api.post(ApiConfig.registerSp, data: body);
    return _ok(res.data);
  }

  Future<bool> updateSp(Map<String, dynamic> body) async {
    final res = await _api.patch(ApiConfig.updateSp, data: body);
    return _ok(res.data);
  }

  Future<bool> updateSpLanguage(int spId, String language) async {
    final res =
        await _api.put(ApiConfig.updateSpLanguage(spId, language), data: {});
    return _ok(res.data);
  }

  Future<bool> deactivateSp(int spId) async {
    final res = await _api.put(ApiConfig.deactivateSp(spId), data: {});
    return _ok(res.data);
  }

  Future<bool> deleteSp(int spId) async {
    final res = await _api.delete(ApiConfig.deleteSp(spId));
    return _ok(res.data);
  }

  Future<bool> updateNotificationSettings(
      int spId, bool mobile, bool email) async {
    final res = await _api
        .patch(ApiConfig.updateNotificationSettings(spId, mobile, email));
    return _ok(res.data);
  }

  Future<double?> getAverageRating(int spId) async {
    final res = await _api.get(ApiConfig.getProviderAverageRating(spId));
    final d = _payload(res.data);
    if (d is Map<String, dynamic>) {
      return (d['averageRating'] as num?)?.toDouble();
    }
    if (d is num) return d.toDouble();
    return null;
  }
}
