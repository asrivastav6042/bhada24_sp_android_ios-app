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
    int? asInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }

    return AvailabilityExceptionModel(
      exceptionId: asInt(json['id'] ?? json['exceptionId']),
      serviceType: json['serviceType'] as String?,
      serviceId: asInt(json['serviceId']),
      startDate:
          (json['unavailableFrom'] ?? json['startDate'] ?? json['from'])
              as String?,
      endDate:
          (json['unavailableTo'] ?? json['endDate'] ?? json['to']) as String?,
      reason: json['reason'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (startDate != null) 'unavailableFrom': startDate,
      if (endDate != null) 'unavailableTo': endDate,
      if (reason != null) 'reason': reason,
    };
  }
}
