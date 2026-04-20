import 'package:bhada24_sp/core/config/api_config.dart';
import 'package:bhada24_sp/core/network/api_client.dart';
import 'package:bhada24_sp/data/models/category_model.dart';

dynamic _payload(dynamic data) => data is Map ? data['responseData'] : null;

/// Wraps all /categories REST endpoints with in-memory cache
class CategoryApiService {
  final ApiClient _api;
  CategoryApiService(this._api);

  List<CategoryModel>? _cache;
  DateTime? _cacheTime;
  static const _cacheDuration = Duration(minutes: 5);

  Future<List<CategoryModel>> getAllCategories() async {
    if (_cache != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < _cacheDuration) {
      return _cache!;
    }
    final res = await _api.get(ApiConfig.getAllCategories);
    final raw = _payload(res.data) ?? (res.data is List ? res.data : null);
    List<dynamic> items = [];
    if (raw is List) {
      items = raw;
      if (items.isNotEmpty && items.first is List) items = items.first as List;
    } else if (raw is Map<String, dynamic>) {
      final inner = raw['data'] ?? raw['categories'];
      if (inner is List) items = inner;
    }
    _cache = items
        .whereType<Map<String, dynamic>>()
        .map(CategoryModel.fromJson)
        .toList();
    _cacheTime = DateTime.now();
    return _cache!;
  }

  Future<CategoryModel?> getCategoryById(int id) async {
    final res = await _api.get(ApiConfig.getCategoryById(id));
    final d = _payload(res.data);
    if (d is Map<String, dynamic>) return CategoryModel.fromJson(d);
    return null;
  }

  Future<List<SubcategoryModel>> getSubcategories(int categoryId) async {
    final res = await _api.get(ApiConfig.getSubcategories(categoryId));
    final raw = _payload(res.data) ?? (res.data is List ? res.data : null);
    List<dynamic> items = [];
    if (raw is List) {
      items = raw;
    } else if (raw is Map<String, dynamic>) {
      final inner = raw['data'] ?? raw['subcategories'];
      if (inner is List) items = inner;
    }
    return items
        .whereType<Map<String, dynamic>>()
        .map(SubcategoryModel.fromJson)
        .toList();
  }
}
