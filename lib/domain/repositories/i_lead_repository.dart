import 'package:bhada24_sp/data/models/lead_model.dart';

/// Lead repository interface
abstract class ILeadRepository {
  Future<List<LeadModel>> getLeadsBySpId(int spId);
}
