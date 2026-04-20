import 'package:bhada24_sp/data/models/category_model.dart';

/// Category repository interface
abstract class ICategoryRepository {
  Future<List<CategoryModel>> getAllCategories();
  Future<CategoryModel?> getCategoryById(int categoryId);
  Future<List<SubcategoryModel>> getSubcategories(int categoryId);
  void clearCache();
}
