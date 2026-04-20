/// Domain entity representing a listing service (pure Dart, no JSON logic)
class ServiceEntity {
  final int id;
  final int spId;
  final String name;
  final String? description;
  final double? price;
  final String? priceUnit;
  final String? category;
  final String? subcategory;
  final String? city;
  final String? state;
  final List<String> imageUrls;
  final double? averageRating;
  final bool isActive;
  final String? createdAt;

  const ServiceEntity({
    required this.id,
    required this.spId,
    required this.name,
    this.description,
    this.price,
    this.priceUnit,
    this.category,
    this.subcategory,
    this.city,
    this.state,
    this.imageUrls = const [],
    this.averageRating,
    this.isActive = true,
    this.createdAt,
  });
}
