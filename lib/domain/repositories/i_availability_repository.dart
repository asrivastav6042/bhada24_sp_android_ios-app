import 'package:bhada24_sp/data/models/availability_exception_model.dart';

/// Availability repository interface
abstract class IAvailabilityRepository {
  Future<bool> addException(
      String serviceType, int serviceId, Map<String, dynamic> data);
  Future<List<AvailabilityExceptionModel>> getExceptions(
      String serviceType, int serviceId);
  Future<bool> deleteException(int exceptionId);
}
