import 'package:ecommerce_app/features/product/data/models/category_model.dart';
import 'package:ecommerce_app/features/product/data/models/product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductRemoteDatasource {
  const ProductRemoteDatasource(this._client);

  final SupabaseClient _client;

  static const String _productsTable = 'products';
  static const String _categoriesTable = 'categories';

  // ─── Products ────────────────────────────────────────────────────────────

  Future<List<ProductModel>> getProducts({
    String? categoryId,
    int page = 0,
    int pageSize = 20,
  }) async {
    var query = _client
        .from(_productsTable)
        .select()
        .eq('is_active', true)
        .order('sort_order')
        .range(page * pageSize, (page + 1) * pageSize - 1);

    if (categoryId != null) {
      query = _client
          .from(_productsTable)
          .select()
          .eq('is_active', true)
          .eq('category_id', categoryId)
          .order('sort_order')
          .range(page * pageSize, (page + 1) * pageSize - 1);
    }

    final response = await query;
    return (response as List<dynamic>)
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ProductModel> getProductById(String id) async {
    final response = await _client
        .from(_productsTable)
        .select()
        .eq('id', id)
        .single();

    return ProductModel.fromJson(response);
  }

  Future<List<ProductModel>> getProductsByCategory(
    String categoryId, {
    int page = 0,
    int pageSize = 20,
  }) async {
    final response = await _client
        .from(_productsTable)
        .select()
        .eq('is_active', true)
        .eq('category_id', categoryId)
        .order('sort_order')
        .range(page * pageSize, (page + 1) * pageSize - 1);

    return (response as List<dynamic>)
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ProductModel>> searchProducts(
    String query, {
    int page = 0,
    int pageSize = 20,
  }) async {
    final response = await _client
        .from(_productsTable)
        .select()
        .eq('is_active', true)
        .or('name_en.ilike.%$query%,name_ar.ilike.%$query%')
        .order('sort_order')
        .range(page * pageSize, (page + 1) * pageSize - 1);

    return (response as List<dynamic>)
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ProductModel>> getFeaturedProducts({int limit = 10}) async {
    final response = await _client
        .from(_productsTable)
        .select()
        .eq('is_active', true)
        .eq('is_featured', true)
        .order('sort_order')
        .limit(limit);

    return (response as List<dynamic>)
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ─── Categories ──────────────────────────────────────────────────────────

  Future<List<CategoryModel>> getCategories() async {
    final response = await _client
        .from(_categoriesTable)
        .select()
        .eq('is_active', true)
        .isFilter('parent_id', null)
        .order('sort_order');

    return (response as List<dynamic>)
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}