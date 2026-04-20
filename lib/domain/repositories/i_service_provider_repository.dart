import 'package:bhada24_sp/data/models/service_provider_model.dart';

/// Service Provider repository interface
abstract class IServiceProviderRepository {
  Future<ServiceProviderModel?> getById(int id);
  Future<ServiceProviderModel?> getByMobile(String mobile);
  Future<ServiceProviderModel?> getByEmail(String email);
  Future<bool> update(Map<String, dynamic> payload);
  Future<bool> updateLanguage(int spId, String language);
  Future<bool> deactivate(int spId);
  Future<bool> deleteAccount(int spId);
  Future<double> getAverageRating(int spId);
  Future<String?> uploadImage(int userId, String base64);
  Future<bool> updateNotificationSettings(int spId, bool mobile, bool email);
}
