import 'package:flutter/material.dart';
import 'package:bhada24_sp/data/models/event_service_model.dart';
import 'package:bhada24_sp/domain/repositories/i_event_service_repository.dart';

class EventServiceProvider extends ChangeNotifier {
  final IEventServiceRepository _repo;
  EventServiceProvider(this._repo);

  List<EventServiceModel> _services = [];
  EventServiceModel? _selectedService;
  bool _isLoading = false;
  String? _error;

  List<EventServiceModel> get services => _services;
  EventServiceModel? get selectedService => _selectedService;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadServices(int spId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _services = await _repo.getBySpId(spId);
    } catch (e) {
      _error = 'Failed to load services';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadServiceById(int esId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _selectedService = await _repo.getById(esId);
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createService(Map<String, dynamic> payload) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _repo.create(payload);
      return success;
    } catch (_) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateService(Map<String, dynamic> payload) async {
    _isLoading = true;
    notifyListeners();
    try {
      return await _repo.update(payload);
    } catch (_) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteService(int esId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _repo.delete(esId);
      if (success) {
        _services.removeWhere((s) => s.esId == esId);
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
