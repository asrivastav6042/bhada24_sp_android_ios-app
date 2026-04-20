import 'package:bhada24_sp/core/config/api_config.dart';
import 'package:bhada24_sp/core/network/api_client.dart';
import 'package:bhada24_sp/data/models/membership_model.dart';
import 'package:bhada24_sp/domain/repositories/i_membership_repository.dart';

class MembershipRepositoryImpl implements IMembershipRepository {
  final ApiClient _api;
  MembershipRepositoryImpl(this._api);

  @override
  Future<MembershipModel?> getStatus(int spId) async {
    try {
      final response = await _api.get(ApiConfig.getMembershipStatus(spId));
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return MembershipModel.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> activateFreeMembership(int spId) async {
    try {
      final response = await _api.post(
        ApiConfig.activateFreeMembership(spId),
        data: '',
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
