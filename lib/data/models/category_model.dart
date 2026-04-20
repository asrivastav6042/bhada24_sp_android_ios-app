/// Category model matching API response
class CategoryModel {
  final int? id;
  final String? name;
  final String? icon;
  final int? displayOrder;
  final bool? active;
  final List<SubcategoryModel>? subCategories;

  const CategoryModel({
    this.id,
    this.name,
    this.icon,
    this.displayOrder,
    this.active,
    this.subCategories,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int?,
      name: (json['name'] ?? json['category']) as String?,
      icon: json['icon'] as String?,
      displayOrder: json['displayOrder'] as int?,
      active: json['active'] as bool?,
      subCategories: (json['subCategories'] as List?)
          ?.map((e) => e is Map<String, dynamic>
              ? SubcategoryModel.fromJson(e)
              : null)
          .whereType<SubcategoryModel>()
          .toList(),
    );
  }
}

/// Subcategory model
class SubcategoryModel {
  final int? id;
  final int? categoryId;
  final String? name;
  final String? icon;
  final int? displayOrder;
  final bool? active;
  final String? description;

  const SubcategoryModel({
    this.id,
    this.categoryId,
    this.name,
    this.icon,
    this.displayOrder,
    this.active,
    this.description,
  });

  factory SubcategoryModel.fromJson(Map<String, dynamic> json) {
    return SubcategoryModel(
      id: json['id'] as int?,
      categoryId: json['categoryId'] as int?,
      name: (json['name'] ?? json['subcategory']) as String?,
      icon: json['icon'] as String?,
      displayOrder: json['displayOrder'] as int?,
      active: json['active'] as bool?,
      description: json['description'] as String?,
    );
  }
}
