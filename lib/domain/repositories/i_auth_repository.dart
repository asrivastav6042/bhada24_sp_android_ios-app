import 'package:bhada24_sp/data/models/service_provider_model.dart';

/// Auth repository interface - Single Responsibility: Authentication only
abstract class IAuthRepository {
  Future<bool> validateMobile(String mobile);
  Future<String?> sendOtp(String phone);
  Future<ServiceProviderModel?> verifyOtpAndLogin(
      String verificationId, String otp);
  Future<ServiceProviderModel?> getUserByMobile(String mobile);
  Future<bool> registerUser(Map<String, dynamic> form);
  Future<void> logout();
  bool get isAuthenticated;
  ServiceProviderModel? get currentUser;
  Future<String> getFirebaseToken();
}
