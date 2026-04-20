/// Lead/user interaction model
class LeadModel {
  final int? interactionId;
  final int? spId;
  final int? userId;
  final String? userName;
  final String? userPhone;
  final String? userEmail;
  final String? interactionType;
  final String? serviceName;
  final String? category;
  final String? city;
  final String? createdAt;
  final Map<String, dynamic>? additionalData;

  const LeadModel({
    this.interactionId,
    this.spId,
    this.userId,
    this.userName,
    this.userPhone,
    this.userEmail,
    this.interactionType,
    this.serviceName,
    this.category,
    this.city,
    this.createdAt,
    this.additionalData,
  });

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    return LeadModel(
      interactionId: json['interactionId'] as int?,
      spId: json['spId'] as int?,
      userId: json['userId'] as int?,
      userName: json['userName'] as String?,
      userPhone: json['userPhone'] as String?,
      userEmail: json['userEmail'] as String?,
      interactionType: json['interactionType'] as String?,
      serviceName: json['serviceName'] as String?,
      category: json['category'] as String?,
      city: json['city'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }
}
