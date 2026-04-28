import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bhada24_sp/core/config/firebase_config.dart';
import 'package:bhada24_sp/data/models/service_provider_model.dart';
import 'package:bhada24_sp/domain/repositories/i_auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final IAuthRepository _authRepo;

  AuthProvider(this._authRepo);

  ServiceProviderModel? _user;
  bool _isLoading = false;
  String? _error;
  String? _verificationId;
  int _resendTimer = 0;

  ServiceProviderModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _authRepo.isAuthenticated;
  String? get verificationId => _verificationId;
  int get resendTimer => _resendTimer;

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('user');
    if (json != null) {
      _user = ServiceProviderModel.fromJson(jsonDecode(json));
      notifyListeners();
    }
  }

  Future<void> saveUser(ServiceProviderModel user) async {
    _user = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
    notifyListeners();
  }

  Future<bool> validateMobile(String mobile) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final valid = await _authRepo.validateMobile(mobile);
      if (!valid) {
        _error = 'Mobile number not registered. Please sign up first.';
      }
      return valid;
    } catch (e) {
      _error = 'Failed to validate mobile number.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ConfirmationResult? _webConfirmationResult;

  Future<bool> sendOtp(String phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      if (kIsWeb) {
        _webConfirmationResult = await FirebaseConfig.auth.signInWithPhoneNumber(
          '+91$phone',
        );
        _resendTimer = 30;
        _startResendTimer();
        return true;
      }

      final completer = _OtpCompleter();
      await FirebaseConfig.auth.verifyPhoneNumber(
        phoneNumber: '+91$phone',
        timeout: const Duration(seconds: 60),
        verificationCompleted: (cred) async {
          await FirebaseConfig.auth.signInWithCredential(cred);
          completer.complete(true);
        },
        verificationFailed: (e) {
          _error = _mapOtpError(e);
          completer.complete(false);
        },
        codeSent: (vid, resendToken) {
          _verificationId = vid;
          _resendTimer = 30;
          _startResendTimer();
          completer.complete(true);
        },
        codeAutoRetrievalTimeout: (vid) {
          _verificationId = vid;
        },
      );
      final result = await completer.future;
      return result;
    } on FirebaseAuthException catch (e) {
      _error = _mapOtpError(e);
      return false;
    } catch (e) {
      _error = 'Failed to send OTP. ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _mapOtpError(FirebaseAuthException e) {
    switch (e.code) {
      case 'too-many-requests':
        return 'Too many OTP requests. Please wait 15-20 minutes before trying again, or use a different phone number.';
      case 'invalid-phone-number':
        return 'Invalid phone number.';
      case 'captcha-check-failed':
        return 'Security verification failed. Please try again.';
      case 'app-not-authorized':
        return 'This app is not authorized for Firebase Phone Auth. Add SHA-1 in Firebase and download fresh google-services.json.';
      case 'invalid-app-credential':
        if (kIsWeb) {
          return 'OTP setup error (INVALID_APP_CREDENTIAL). Add domain in Firebase Auth > Settings > Authorized domains.';
        }
        return 'Invalid app credential for Phone Auth. Add SHA-1 in Firebase and rebuild the app.';
      case 'network-request-failed':
        return 'Network error while sending OTP. Check internet connection.';
      default:
        final details = e.message?.trim();
        if (details != null && details.isNotEmpty) {
          return 'Failed to send OTP (${e.code}): $details';
        }
        return 'Failed to send OTP (${e.code}).';
    }
  }

  void _startResendTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (_resendTimer > 0) {
        _resendTimer--;
        notifyListeners();
        return true;
      }
      return false;
    });
  }

  Future<bool> verifyOtp(String otp, String phone) async {
    if (!kIsWeb && _verificationId == null) {
      _error = 'Verification session expired. Please resend OTP.';
      notifyListeners();
      return false;
    }
    if (kIsWeb && _webConfirmationResult == null) {
      _error = 'Verification session expired. Please resend OTP.';
      notifyListeners();
      return false;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      UserCredential result;
      if (kIsWeb) {
        result = await _webConfirmationResult!.confirm(otp);
      } else {
        final credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: otp,
        );
        result = await FirebaseConfig.auth.signInWithCredential(credential);
      }
      if (result.user == null) {
        _error = 'Verification failed. Try again.';
        return false;
      }
      // Ensure a fresh ID token is available before hitting protected APIs.
      await result.user!.getIdToken(true);

      // Fetch user data from backend. Some records are stored with +91 prefix.
      ServiceProviderModel? user = await _authRepo.getUserByMobile(phone);
      if (user == null && !phone.startsWith('+91')) {
        user = await _authRepo.getUserByMobile('+91$phone');
      }
      if (user == null && phone.startsWith('+91') && phone.length > 3) {
        user = await _authRepo.getUserByMobile(phone.substring(3));
      }
      if (user != null) {
        await saveUser(user);
        return true;
      } else {
        _error = 'User not found. Please register.';
        return false;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        _error = 'Invalid OTP. Please check.';
      } else if (e.code == 'session-expired') {
        _error = 'OTP expired. Request new one.';
      } else {
        _error = 'Verification failed.';
      }
      return false;
    } catch (e) {
      _error = 'Verification failed.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(Map<String, dynamic> form) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final success = await _authRepo.registerUser(form);
      if (!success) {
        _error = 'Registration failed. Please try again.';
      }
      return success;
    } catch (e) {
      _error = 'Registration failed.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authRepo.logout();
    _user = null;
    _verificationId = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

/// Simple future completer helper
class _OtpCompleter {
  late final Future<bool> future;
  late final void Function(bool) _complete;
  bool _isCompleted = false;

  _OtpCompleter() {
    future = Future<bool>(() async {
      final completer = await _waitForResult();
      return completer;
    });
  }

  Future<bool> _waitForResult() async {
    bool? result;
    _complete = (v) {
      if (!_isCompleted) {
        _isCompleted = true;
        result = v;
      }
    };
    // Poll until completed
    while (result == null) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    return result!;
  }

  void complete(bool value) => _complete(value);
}
