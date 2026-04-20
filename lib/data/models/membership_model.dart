/// Membership status model
class MembershipModel {
  final int? membershipId;
  final int? spId;
  final String? plan;
  final String? status;
  final String? startDate;
  final String? endDate;
  final bool? hasMembership;
  final int? responseCode;
  final String? responseMessage;

  const MembershipModel({
    this.membershipId,
    this.spId,
    this.plan,
    this.status,
    this.startDate,
    this.endDate,
    this.hasMembership,
    this.responseCode,
    this.responseMessage,
  });

  factory MembershipModel.fromJson(Map<String, dynamic> json) {
    final data = json['responseData'];
    if (data is Map<String, dynamic>) {
      return MembershipModel(
        membershipId: data['membershipId'] as int?,
        spId: data['spId'] as int?,
        plan: data['plan'] as String?,
        status: data['status'] as String?,
        startDate: data['startDate'] as String?,
        endDate: data['endDate'] as String?,
        hasMembership: json['hasMembership'] as bool? ?? data['active'] as bool?,
        responseCode: json['responseCode'] as int?,
        responseMessage: json['responseMessage'] as String?,
      );
    }
    return MembershipModel(
      hasMembership: json['hasMembership'] as bool? ?? false,
      responseCode: json['responseCode'] as int?,
      responseMessage: json['responseMessage'] as String?,
    );
  }

  bool get isActive => hasMembership == true || status == 'ACTIVE';
}
