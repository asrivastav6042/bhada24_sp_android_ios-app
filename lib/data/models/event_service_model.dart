/// Listing/Event service model
class EventServiceModel {
  final int? esId;
  final int? spId;
  final String? serviceName;
  final String? category;
  final String? subCategory;
  final String? description;
  final double? price;
  final double? priceMin;
  final double? priceMax;
  final String? pricingType;
  final String? city;
  final String? state;
  final String? address;
  final double? latitude;
  final double? longitude;
  final List<String>? imageUrls;
  final String? experience;
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
    this.serviceName,
    this.category,
    this.subCategory,
    this.description,
    this.price,
    this.priceMin,
    this.priceMax,
    this.pricingType,
    this.city,
    this.state,
    this.address,
    this.latitude,
    this.longitude,
    this.imageUrls,
    this.experience,
    this.availability,
    this.active,
    this.createdAt,
    this.updatedAt,
    this.ratings,
    this.ratingCount,
    this.averageRating,
  });

  factory EventServiceModel.fromJson(Map<String, dynamic> json) {
    // Handle nested wrapper: { listingService: {...}, ratings: [...] }
    final service = json.containsKey('listingService') &&
            json['listingService'] is Map<String, dynamic>
        ? json['listingService'] as Map<String, dynamic>
        : json;

    final rawRatings = (json['ratings'] ?? service['ratings']) as List?;
    final ratingsList = rawRatings
            ?.map((r) =>
                r is Map<String, dynamic> ? RatingModel.fromJson(r) : null)
            .whereType<RatingModel>()
            .toList() ??
        [];

    final ratingValues = ratingsList
        .map((r) => r.ratingValue)
        .whereType<double>()
        .where((v) => v > 0)
        .toList();
    final count = ratingValues.length;
    final avg = count > 0
        ? ratingValues.reduce((a, b) => a + b) / count
        : 0.0;

    List<String>? images;
    if (service['imageUrls'] != null) {
      if (service['imageUrls'] is List) {
        images = (service['imageUrls'] as List)
            .map((e) => e.toString())
            .toList();
      } else if (service['imageUrls'] is String) {
        images = [service['imageUrls'] as String];
      }
    }

    return EventServiceModel(
      esId: service['esId'] as int?,
      spId: service['spId'] as int?,
      serviceName: service['serviceName'] as String?,
      category: service['category'] as String?,
      subCategory: service['subCategory'] as String?,
      description: service['description'] as String?,
      price: (service['price'] as num?)?.toDouble(),
      priceMin: (service['priceMin'] as num?)?.toDouble(),
      priceMax: (service['priceMax'] as num?)?.toDouble(),
      pricingType: service['pricingType'] as String?,
      city: service['city'] as String?,
      state: service['state'] as String?,
      address: service['address'] as String?,
      latitude: (service['latitude'] as num?)?.toDouble(),
      longitude: (service['longitude'] as num?)?.toDouble(),
      imageUrls: images,
      experience: service['experience']?.toString(),
      availability: service['availability'] as String?,
      active: service['active'] as bool?,
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
      if (serviceName != null) 'serviceName': serviceName,
      if (category != null) 'category': category,
      if (subCategory != null) 'subCategory': subCategory,
      if (description != null) 'description': description,
      if (price != null) 'price': price,
      if (priceMin != null) 'priceMin': priceMin,
      if (priceMax != null) 'priceMax': priceMax,
      if (pricingType != null) 'pricingType': pricingType,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (address != null) 'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (imageUrls != null) 'imageUrls': imageUrls,
      if (experience != null) 'experience': experience,
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
      ratingId: json['ratingId'] as int?,
      ratingValue: (json['ratingValue'] as num?)?.toDouble(),
      review: json['review'] as String?,
      userName: json['userName'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }
}
