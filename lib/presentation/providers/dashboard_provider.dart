import 'package:flutter/material.dart';
import 'package:bhada24_sp/data/models/membership_model.dart';
import 'package:bhada24_sp/domain/repositories/i_service_provider_repository.dart';
import 'package:bhada24_sp/domain/repositories/i_membership_repository.dart';

class DashboardProvider extends ChangeNotifier {
  final IServiceProviderRepository _spRepo;
  final IMembershipRepository _membershipRepo;

  DashboardProvider(this._spRepo, this._membershipRepo);

  double _averageRating = 0;
  MembershipModel? _membership;
  bool _isLoading = false;

  double get averageRating => _averageRating;
  MembershipModel? get membership => _membership;
  bool get isLoading => _isLoading;

  Future<void> prefetchData(int spId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _spRepo.getAverageRating(spId),
        _membershipRepo.getStatus(spId),
      ]);
      _averageRating = results[0] as double;
      _membership = results[1] as MembershipModel?;
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }
}
