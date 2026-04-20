import 'package:bhada24_sp/data/models/event_service_model.dart';

/// Event/Listing service repository interface
abstract class IEventServiceRepository {
  Future<bool> create(Map<String, dynamic> payload);
  Future<bool> update(Map<String, dynamic> payload);
  Future<List<EventServiceModel>> getBySpId(int spId);
  Future<EventServiceModel?> getById(int esId);
  Future<bool> delete(int esId);
  Future<bool> updateBookingStatus(Map<String, dynamic> payload);
}
