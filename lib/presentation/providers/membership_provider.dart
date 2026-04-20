import 'package:flutter/material.dart';
import 'package:bhada24_sp/data/models/membership_model.dart';
import 'package:bhada24_sp/domain/repositories/i_membership_repository.dart';

class MembershipProvider extends ChangeNotifier {
  final IMembershipRepository _repo;
  MembershipProvider(this._repo);

  MembershipModel? _membership;
  bool _isLoading = false;
  String? _error;

  MembershipModel? get membership => _membership;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isActive => _membership?.isActive ?? false;

  Future<void> loadStatus(int spId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _membership = await _repo.getStatus(spId);
    } catch (e) {
      _error = 'Failed to load membership status';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> activateFree(int spId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _repo.activateFreeMembership(spId);
      if (success) {
        await loadStatus(spId);
      }
      return success;
    } catch (_) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
