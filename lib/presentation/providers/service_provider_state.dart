import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bhada24_sp/data/models/service_provider_model.dart';
import 'package:bhada24_sp/domain/repositories/i_service_provider_repository.dart';

/// Manages the currently-logged-in service provider's profile state
class ServiceProviderState extends ChangeNotifier {
  final IServiceProviderRepository _repo;
  ServiceProviderState(this._repo);

  ServiceProviderModel? _sp;
  bool _isLoading = false;
  String? _error;

  ServiceProviderModel? get sp => _sp;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load SP from SharedPreferences cache
  Future<void> loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('sp_profile');
    if (json != null) {
      _sp = ServiceProviderModel.fromJson(jsonDecode(json));
      notifyListeners();
    }
  }

  /// Fetch fresh SP data from server and update cache
  Future<void> fetchById(int spId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _repo.getById(spId);
      if (result != null) {
        _sp = result;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('sp_profile', jsonEncode(result.toJson()));
      }
    } catch (e) {
      _error = 'Failed to load profile.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final ok = await _repo.update(data);
      if (ok && _sp?.spId != null) {
        await fetchById(_sp!.spId!);
      }
      return ok;
    } catch (e) {
      _error = 'Failed to update profile.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadImage(String base64Image) async {
    try {
      if (_sp?.spId == null) return false;
      final url = await _repo.uploadImage(_sp!.spId!, base64Image);
      if (url != null) {
        await updateProfile({'spId': _sp!.spId, 'imageUrl': url});
      }
      return url != null;
    } catch (e) {
      return false;
    }
  }

  void update(ServiceProviderModel sp) {
    _sp = sp;
    notifyListeners();
  }

  void clear() {
    _sp = null;
    notifyListeners();
  }
}
