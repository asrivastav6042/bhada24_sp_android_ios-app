import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bhada24_sp/core/config/api_config.dart';
import 'package:bhada24_sp/core/config/firebase_config.dart';
import 'package:bhada24_sp/core/network/api_client.dart';
import 'package:bhada24_sp/data/models/service_provider_model.dart';
import 'package:bhada24_sp/domain/repositories/i_auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final ApiClient _api;
  ServiceProviderModel? _currentUser;

  AuthRepositoryImpl(this._api) {
    _loadUserFromPrefs();
  }

  Future<void> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      _currentUser =
          ServiceProviderModel.fromJson(jsonDecode(userJson));
    }
  }

  Future<void> _saveUserToPrefs(ServiceProviderModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
    _currentUser = user;
  }

  @override
  bool get isAuthenticated =>
      FirebaseConfig.auth.currentUser != null && _currentUser != null;

  @override
  ServiceProviderModel? get currentUser => _currentUser;

  @override
  Future<String> getFirebaseToken() async {
    try {
      final user = FirebaseConfig.auth.currentUser;
      if (user == null) return '';
      return await user.getIdToken() ?? '';
    } catch (_) {
      return '';
    }
  }

  @override
  Future<bool> validateMobile(String mobile) async {
    try {
      final response = await _api.get(ApiConfig.validateMobile(mobile));
      final data = response.data;
      if (data['responseCode'] == 200) {
        final list = data['responseData'];
        if (list is List && list.isNotEmpty) {
          return list[0] == true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String?> sendOtp(String phone) async {
    // Firebase phone auth is handled on the provider/screen level
    // This method is not directly used but kept for interface compliance
    return null;
  }

  @override
  Future<ServiceProviderModel?> verifyOtpAndLogin(
      String verificationId, String otp) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      final result =
          await FirebaseConfig.auth.signInWithCredential(credential);
      if (result.user == null) return null;
      return _currentUser;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<ServiceProviderModel?> getUserByMobile(String mobile) async {
    ServiceProviderModel? extractUser(dynamic data) {
      if (data is! Map) return null;
      final code = data['responseCode'];
      if (code != 200 && code != 0) return null;
      final payload = data['responseData'];
      if (payload is List && payload.isNotEmpty && payload.first is Map<String, dynamic>) {
        return ServiceProviderModel.fromJson(payload.first as Map<String, dynamic>);
      }
      if (payload is Map<String, dynamic>) {
        return ServiceProviderModel.fromJson(payload);
      }
      return null;
    }

    Future<ServiceProviderModel?> fetch() async {
      final response = await _api.get(ApiConfig.getSpByMobile(mobile));
      final user = extractUser(response.data);
      if (user != null) {
        await _saveUserToPrefs(user);
      }
      return user;
    }

    try {
      return await fetch();
    } catch (_) {
      try {
        // Retry once after forcing token refresh for protected endpoint calls.
        final user = FirebaseConfig.auth.currentUser;
        if (user == null) return null;
        await user.getIdToken(true);
        return await fetch();
      } catch (_) {
        return null;
      }
    }
  }

  @override
  Future<bool> registerUser(Map<String, dynamic> form) async {
    try {
      final response = await _api.post(ApiConfig.registerSp, data: form);
      final data = response.data;
      return (data['responseCode'] == 0 || data['responseCode'] == 200) &&
          data['responseMessage'] == 'success';
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> logout() async {
    await FirebaseConfig.auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('fcmToken');
    await prefs.remove('fcmTokenRegistered');
    _currentUser = null;
  }
}
