/// Membership status model
class MembershipModel {
  final int? membershipId;
  final String? spId;
  final int? planId;
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
    this.planId,
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
      final parsedStatus = (data['status'] as String?)?.toUpperCase();
      final parsedPlanId = data['planId'] as int?;
      final parsedPlan = data['plan'] as String?;

      return MembershipModel(
        membershipId: (data['membershipId'] as int?) ?? (data['id'] as int?),
        spId: data['spId']?.toString(),
        planId: parsedPlanId,
        plan:
            parsedPlan ??
            (parsedPlanId == 1
                ? 'Free Plan'
                : (parsedPlanId != null ? 'Plan $parsedPlanId' : null)),
        status: parsedStatus,
        startDate: data['startDate'] as String?,
        endDate: data['endDate'] as String?,
        hasMembership:
            json['hasMembership'] as bool? ??
            data['active'] as bool? ??
            parsedStatus == 'ACTIVE',
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

  bool get isActive => (status ?? '').toUpperCase() == 'ACTIVE';

  String get planLabel {
    if (plan != null && plan!.trim().isNotEmpty) return plan!;
    if (planId == 1) return 'Free Plan';
    if (planId != null) return 'Plan $planId';
    return 'Membership';
  }
}
