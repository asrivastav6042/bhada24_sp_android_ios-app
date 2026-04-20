import 'package:flutter/material.dart';
import 'package:bhada24_sp/data/models/lead_model.dart';
import 'package:bhada24_sp/domain/repositories/i_lead_repository.dart';

class LeadProvider extends ChangeNotifier {
  final ILeadRepository _repo;
  LeadProvider(this._repo);

  List<LeadModel> _leads = [];
  bool _isLoading = false;
  String? _error;

  List<LeadModel> get leads => _leads;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadLeads(int spId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _leads = await _repo.getLeadsBySpId(spId);
    } catch (e) {
      _error = 'Failed to load leads';
    }
    _isLoading = false;
    notifyListeners();
  }
}
