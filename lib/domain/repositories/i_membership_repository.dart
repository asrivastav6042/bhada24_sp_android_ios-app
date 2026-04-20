import 'package:bhada24_sp/data/models/membership_model.dart';

/// Membership repository interface
abstract class IMembershipRepository {
  Future<MembershipModel?> getStatus(int spId);
  Future<bool> activateFreeMembership(int spId);
}
