import 'package:bhada24_sp/core/config/api_config.dart';
import 'package:bhada24_sp/core/network/api_client.dart';
import 'package:bhada24_sp/data/models/category_model.dart';
import 'package:bhada24_sp/domain/repositories/i_category_repository.dart';

class CategoryRepositoryImpl implements ICategoryRepository {
  final ApiClient _api;
  List<CategoryModel>? _cache;
  DateTime? _cacheTime;
  static const _cacheDuration = Duration(minutes: 5);

  CategoryRepositoryImpl(this._api);

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    // Check cache
    if (_cache != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < _cacheDuration) {
      return _cache!;
    }

    try {
      final response = await _api.get(ApiConfig.getAllCategories);
      final data = response.data;
      if (data['responseCode'] == 200 && data['responseData'] != null) {
        List rawList;
        if (data['responseData'] is List &&
            (data['responseData'] as List).isNotEmpty &&
            (data['responseData'] as List)[0] is List) {
          rawList = (data['responseData'] as List)[0] as List;
        } else {
          rawList = data['responseData'] as List;
        }
        _cache = rawList
            .whereType<Map<String, dynamic>>()
            .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
        _cacheTime = DateTime.now();
        return _cache!;
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<CategoryModel?> getCategoryById(int categoryId) async {
    try {
      final response = await _api.get(ApiConfig.getCategoryById(categoryId));
      final data = response.data;
      if (data['responseCode'] == 200 && data['responseData'] != null) {
        final rd = data['responseData'];
        if (rd is Map<String, dynamic>) {
          return CategoryModel.fromJson(rd);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<SubcategoryModel>> getSubcategories(int categoryId) async {
    try {
      final response =
          await _api.get(ApiConfig.getSubcategories(categoryId));
      final data = response.data;
      if (data['responseCode'] == 200 && data['responseData'] is List) {
        return (data['responseData'] as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => SubcategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  void clearCache() {
    _cache = null;
    _cacheTime = null;
  }
}
