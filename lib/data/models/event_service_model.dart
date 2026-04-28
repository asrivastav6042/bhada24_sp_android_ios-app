/// Listing/Event service model
class EventServiceModel {
  final int? esId;
  final int? spId;
  final String? spCode;
  final String? ownerName;
  final String? primaryContact;
  final String? whatsappNumber;
  final String? businessName;
  final String? serviceName;
  final String? category;
  final String? subCategory;
  final String? pincode;
  final String? description;
  final String? serviceDescription;
  final double? price;
  final double? minPrice;
  final double? maxPrice;
  final double? priceMin;
  final double? priceMax;
  final String? pricingType;
  final String? city;
  final String? state;
  final String? address;
  final double? latitude;
  final double? longitude;
  final List<String>? imageUrls;
  final String? serviceImageUrls;
  final String? approvalStatus;
  final String? adminComment;
  final String? status;
  final String? experience;
  final int? advanceBookingDays;
  final bool? availableOnWeekends;
  final String? ownerIdProofType;
  final String? ownerIdProofNumber;
  final String? ownerIdProofUrl;
  final String? gstNumber;
  final String? businessRegistrationNumber;
  final String? businessLicenseUrl;
  final String? fssaiLicenseNumber;
  final String? fssaiLicenseUrl;
  final String? insuranceCertificateUrl;
  final int? radius;
  final String? availability;
  final bool? active;
  final String? createdAt;
  final String? updatedAt;
  final List<RatingModel>? ratings;
  final int? ratingCount;
  final double? averageRating;

  const EventServiceModel({
    this.esId,
    this.spId,
    this.spCode,
    this.ownerName,
    this.primaryContact,
    this.whatsappNumber,
    this.businessName,
    this.serviceName,
    this.category,
    this.subCategory,
    this.pincode,
    this.description,
    this.serviceDescription,
    this.price,
    this.minPrice,
    this.maxPrice,
    this.priceMin,
    this.priceMax,
    this.pricingType,
    this.city,
    this.state,
    this.address,
    this.latitude,
    this.longitude,
    this.imageUrls,
    this.serviceImageUrls,
    this.approvalStatus,
    this.adminComment,
    this.status,
    this.experience,
    this.advanceBookingDays,
    this.availableOnWeekends,
    this.ownerIdProofType,
    this.ownerIdProofNumber,
    this.ownerIdProofUrl,
    this.gstNumber,
    this.businessRegistrationNumber,
    this.businessLicenseUrl,
    this.fssaiLicenseNumber,
    this.fssaiLicenseUrl,
    this.insuranceCertificateUrl,
    this.radius,
    this.availability,
    this.active,
    this.createdAt,
    this.updatedAt,
    this.ratings,
    this.ratingCount,
    this.averageRating,
  });

  factory EventServiceModel.fromJson(Map<String, dynamic> json) {
    int? asInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      final raw = value.toString();
      final parsed = int.tryParse(raw);
      if (parsed != null) return parsed;
      final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
      return digits.isEmpty ? null : int.tryParse(digits);
    }

    double? asDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    // Handle nested wrapper: { listingService: {...}, ratings: [...] }
    final service =
        json.containsKey('listingService') &&
                json['listingService'] is Map<String, dynamic>
            ? json['listingService'] as Map<String, dynamic>
            : json;

    final rawRatings = (json['ratings'] ?? service['ratings']) as List?;
    final ratingsList =
        rawRatings
            ?.map(
              (r) => r is Map<String, dynamic> ? RatingModel.fromJson(r) : null,
            )
            .whereType<RatingModel>()
            .toList() ??
        [];

    final ratingValues =
        ratingsList
            .map((r) => r.ratingValue)
            .whereType<double>()
            .where((v) => v > 0)
            .toList();
    final count = ratingValues.length;
    final avg = count > 0 ? ratingValues.reduce((a, b) => a + b) / count : 0.0;

    List<String>? images;
    if (service['imageUrls'] != null) {
      if (service['imageUrls'] is List) {
        images =
            (service['imageUrls'] as List).map((e) => e.toString()).toList();
      } else if (service['imageUrls'] is String) {
        images = [service['imageUrls'] as String];
      }
    }

    final serviceImageUrls = service['serviceImageUrls'] as String?;
    if ((images == null || images.isEmpty) &&
        serviceImageUrls != null &&
        serviceImageUrls.trim().isNotEmpty) {
      images =
          serviceImageUrls
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
    }

    final statusRaw = (service['status'] as String?)?.toLowerCase();
    final isActive = service['active'] as bool? ?? statusRaw == 'active';

    return EventServiceModel(
      esId: asInt(service['esId']),
      spId: asInt(service['spId']),
      spCode: service['spId']?.toString(),
      ownerName: service['ownerName'] as String?,
      primaryContact: service['primaryContact'] as String?,
      whatsappNumber: service['whatsappNumber'] as String?,
      businessName: service['businessName'] as String?,
      serviceName:
          (service['serviceName'] as String?) ??
          (service['businessName'] as String?) ??
          (service['subCategory'] as String?),
      category: service['category'] as String?,
      subCategory: service['subCategory'] as String?,
      pincode: service['pincode'] as String?,
      description: service['description'] as String?,
      serviceDescription: service['serviceDescription'] as String?,
      price: asDouble(service['price']) ?? asDouble(service['minPrice']),
      minPrice: asDouble(service['minPrice']),
      maxPrice: asDouble(service['maxPrice']),
      priceMin: asDouble(service['priceMin']),
      priceMax: asDouble(service['priceMax']),
      pricingType: service['pricingType'] as String?,
      city: service['city'] as String?,
      state: service['state'] as String?,
      address: service['address'] as String?,
      latitude: asDouble(service['latitude']),
      longitude: asDouble(service['longitude']),
      imageUrls: images,
      serviceImageUrls: serviceImageUrls,
      approvalStatus: service['approvalStatus'] as String?,
      adminComment: service['adminComment'] as String?,
      status: service['status'] as String?,
      experience: service['experience']?.toString(),
      advanceBookingDays: asInt(service['advanceBookingDays']),
      availableOnWeekends: service['availableOnWeekends'] as bool?,
      ownerIdProofType: service['ownerIdProofType'] as String?,
      ownerIdProofNumber: service['ownerIdProofNumber'] as String?,
      ownerIdProofUrl: service['ownerIdProofUrl'] as String?,
      gstNumber: service['gstNumber'] as String?,
      businessRegistrationNumber:
          service['businessRegistrationNumber'] as String?,
      businessLicenseUrl: service['businessLicenseUrl'] as String?,
      fssaiLicenseNumber: service['fssaiLicenseNumber'] as String?,
      fssaiLicenseUrl: service['fssaiLicenseUrl'] as String?,
      insuranceCertificateUrl: service['insuranceCertificateUrl'] as String?,
      radius: asInt(service['radius']),
      availability: service['availability'] as String?,
      active: isActive,
      createdAt: service['createdAt'] as String?,
      updatedAt: service['updatedAt'] as String?,
      ratings: ratingsList,
      ratingCount: count,
      averageRating: avg,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (esId != null) 'esId': esId,
      if (spId != null) 'spId': spId,
      if (spCode != null) 'spIdCode': spCode,
      if (ownerName != null) 'ownerName': ownerName,
      if (primaryContact != null) 'primaryContact': primaryContact,
      if (whatsappNumber != null) 'whatsappNumber': whatsappNumber,
      if (businessName != null) 'businessName': businessName,
      if (serviceName != null) 'serviceName': serviceName,
      if (category != null) 'category': category,
      if (subCategory != null) 'subCategory': subCategory,
      if (pincode != null) 'pincode': pincode,
      if (description != null) 'description': description,
      if (serviceDescription != null) 'serviceDescription': serviceDescription,
      if (price != null) 'price': price,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (priceMin != null) 'priceMin': priceMin,
      if (priceMax != null) 'priceMax': priceMax,
      if (pricingType != null) 'pricingType': pricingType,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (address != null) 'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (imageUrls != null) 'imageUrls': imageUrls,
      if (serviceImageUrls != null) 'serviceImageUrls': serviceImageUrls,
      if (approvalStatus != null) 'approvalStatus': approvalStatus,
      if (adminComment != null) 'adminComment': adminComment,
      if (status != null) 'status': status,
      if (experience != null) 'experience': experience,
      if (advanceBookingDays != null) 'advanceBookingDays': advanceBookingDays,
      if (availableOnWeekends != null)
        'availableOnWeekends': availableOnWeekends,
      if (ownerIdProofType != null) 'ownerIdProofType': ownerIdProofType,
      if (ownerIdProofNumber != null) 'ownerIdProofNumber': ownerIdProofNumber,
      if (ownerIdProofUrl != null) 'ownerIdProofUrl': ownerIdProofUrl,
      if (gstNumber != null) 'gstNumber': gstNumber,
      if (businessRegistrationNumber != null)
        'businessRegistrationNumber': businessRegistrationNumber,
      if (businessLicenseUrl != null) 'businessLicenseUrl': businessLicenseUrl,
      if (fssaiLicenseNumber != null) 'fssaiLicenseNumber': fssaiLicenseNumber,
      if (fssaiLicenseUrl != null) 'fssaiLicenseUrl': fssaiLicenseUrl,
      if (insuranceCertificateUrl != null)
        'insuranceCertificateUrl': insuranceCertificateUrl,
      if (radius != null) 'radius': radius,
      if (availability != null) 'availability': availability,
      if (active != null) 'active': active,
    };
  }
}

class RatingModel {
  final int? ratingId;
  final double? ratingValue;
  final String? review;
  final String? userName;
  final String? createdAt;

  const RatingModel({
    this.ratingId,
    this.ratingValue,
    this.review,
    this.userName,
    this.createdAt,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      ratingId: (json['ratingId'] as int?) ?? (json['id'] as int?),
      ratingValue: (json['ratingValue'] as num?)?.toDouble(),
      review: (json['review'] as String?) ?? (json['comment'] as String?),
      userName: json['userName'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }
}
