import 'package:flutter/material.dart';
import 'package:bhada24_sp/data/models/category_model.dart';
import 'package:bhada24_sp/domain/repositories/i_category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final ICategoryRepository _repo;
  CategoryProvider(this._repo);

  List<CategoryModel> _categories = [];
  List<SubcategoryModel> _subcategories = [];
  bool _isLoading = false;

  List<CategoryModel> get categories => _categories;
  List<SubcategoryModel> get subcategories => _subcategories;
  bool get isLoading => _isLoading;

  Map<String, List<String>> get categoriesWithSubcategories {
    final map = <String, List<String>>{};
    for (final cat in _categories) {
      final name = cat.name ?? '';
      map[name] = cat.subCategories?.map((s) => s.name ?? '').toList() ?? [];
    }
    return map;
  }

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();
    try {
      _categories = await _repo.getAllCategories();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadSubcategories(int categoryId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _subcategories = await _repo.getSubcategories(categoryId);
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  List<String> getSubcategoriesForCategory(String categoryName) {
    final cat = _categories.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => const CategoryModel(),
    );
    return cat.subCategories?.map((s) => s.name ?? '').toList() ?? [];
  }
}
