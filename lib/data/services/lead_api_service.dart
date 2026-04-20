import 'package:bhada24_sp/core/config/api_config.dart';
import 'package:bhada24_sp/core/network/api_client.dart';
import 'package:bhada24_sp/data/models/lead_model.dart';

dynamic _payload(dynamic data) => data is Map ? data['responseData'] : null;

/// Wraps /interactions/sp lead endpoints
class LeadApiService {
  final ApiClient _api;
  LeadApiService(this._api);

  Future<List<LeadModel>> getLeadsBySpId(int spId) async {
    final res = await _api.get(ApiConfig.getLeadsBySpId(spId));
    final raw = _payload(res.data) ?? (res.data is List ? res.data : null);
    List<dynamic> items = [];
    if (raw is List) {
      items = raw;
    } else if (raw is Map<String, dynamic>) {
      final inner = raw['data'] ?? raw['leads'] ?? raw['interactions'];
      if (inner is List) items = inner;
    }
    return items
        .whereType<Map<String, dynamic>>()
        .map(LeadModel.fromJson)
        .toList();
  }
}
