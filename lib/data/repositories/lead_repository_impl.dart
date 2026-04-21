import 'package:bhada24_sp/core/config/api_config.dart';
import 'package:bhada24_sp/core/network/api_client.dart';
import 'package:bhada24_sp/data/models/lead_model.dart';
import 'package:bhada24_sp/domain/repositories/i_lead_repository.dart';

class LeadRepositoryImpl implements ILeadRepository {
  final ApiClient _api;
  LeadRepositoryImpl(this._api);

  @override
  Future<List<LeadModel>> getLeadsBySpId(int spId) async {
    try {
      final response = await _api.get(ApiConfig.getLeadsBySpId(spId));
      final data = response.data;
      if (data['responseCode'] == 200 && data['responseData'] is List) {
        return (data['responseData'] as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => LeadModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
