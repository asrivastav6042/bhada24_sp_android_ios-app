/// Service provider user model matching backend response
class ServiceProviderModel {
  final int? spId;
  final String? name;
  final String? email;
  final String? phone;
  final String? role;
  final bool? verified;
  final String? imageUrl;
  final String? gender;
  final String? dateOfBirth;
  final String? status;
  final bool? mobileNotification;
  final bool? emailNotification;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? businessName;
  final String? description;
  final double? latitude;
  final double? longitude;
  final String? language;
  final bool? active;
  final String? createdAt;
  final String? updatedAt;

  const ServiceProviderModel({
    this.spId,
    this.name,
    this.email,
    this.phone,
    this.role,
    this.verified,
    this.imageUrl,
    this.gender,
    this.dateOfBirth,
    this.status,
    this.mobileNotification,
    this.emailNotification,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.businessName,
    this.description,
    this.latitude,
    this.longitude,
    this.language,
    this.active,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceProviderModel.fromJson(Map<String, dynamic> json) {
    // spId may come as int or String like "SP0002"
    int? parseSpId(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is String) {
        final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
        return digits.isEmpty ? null : int.tryParse(digits);
      }
      return null;
    }

    return ServiceProviderModel(
      spId: parseSpId(json['spId'] ?? json['id'] ?? json['providerId']),
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as String?,
      verified: json['verified'] as bool?,
      imageUrl: json['imageUrl'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      status: json['status'] as String?,
      mobileNotification: json['mobile_notification'] as bool?,
      emailNotification: json['email_notification'] as bool?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
      businessName: json['businessName'] as String?,
      description: json['description'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      language: json['language'] as String?,
      active: json['active'] as bool?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (spId != null) 'spId': spId,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (role != null) 'role': role,
      if (verified != null) 'verified': verified,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (gender != null) 'gender': gender,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
      if (status != null) 'status': status,
      if (mobileNotification != null) 'mobile_notification': mobileNotification,
      if (emailNotification != null) 'email_notification': emailNotification,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (pincode != null) 'pincode': pincode,
      if (businessName != null) 'businessName': businessName,
      if (description != null) 'description': description,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (language != null) 'language': language,
      if (active != null) 'active': active,
    };
  }

  ServiceProviderModel copyWith({
    int? spId,
    String? name,
    String? email,
    String? phone,
    String? role,
    bool? verified,
    String? imageUrl,
    String? gender,
    String? dateOfBirth,
    String? status,
    bool? mobileNotification,
    bool? emailNotification,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? businessName,
    String? description,
    double? latitude,
    double? longitude,
    String? language,
    bool? active,
    String? createdAt,
    String? updatedAt,
  }) {
    return ServiceProviderModel(
      spId: spId ?? this.spId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      verified: verified ?? this.verified,
      imageUrl: imageUrl ?? this.imageUrl,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      status: status ?? this.status,
      mobileNotification: mobileNotification ?? this.mobileNotification,
      emailNotification: emailNotification ?? this.emailNotification,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      businessName: businessName ?? this.businessName,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      language: language ?? this.language,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get spCode {
    if (spId == null) return '';
    return 'SP${spId!.toString().padLeft(4, '0')}';
  }
}
