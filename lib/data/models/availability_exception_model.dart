/// Availability exception model for Mark Busy feature
class AvailabilityExceptionModel {
  final int? exceptionId;
  final String? serviceType;
  final int? serviceId;
  final String? startDate;
  final String? endDate;
  final String? reason;
  final String? createdAt;

  const AvailabilityExceptionModel({
    this.exceptionId,
    this.serviceType,
    this.serviceId,
    this.startDate,
    this.endDate,
    this.reason,
    this.createdAt,
  });

  factory AvailabilityExceptionModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityExceptionModel(
      exceptionId: json['exceptionId'] as int?,
      serviceType: json['serviceType'] as String?,
      serviceId: json['serviceId'] as int?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      reason: json['reason'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
      if (reason != null) 'reason': reason,
    };
  }
}
