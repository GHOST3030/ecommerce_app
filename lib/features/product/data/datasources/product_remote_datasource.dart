import 'package:ecommerce_app/features/product/data/models/category_model.dart';
import 'package:ecommerce_app/features/product/data/models/product_model.dart';
import 'package:ecommerce_app/features/product/data/models/product_variant_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductRemoteDatasource {
  const ProductRemoteDatasource(this._client);

  final SupabaseClient _client;

  static const String _products = 'products';
  static const String _categories = 'categories';
  static const String _variants = 'product_variants';

  // ─── Products ─────────────────────────────────────────────────────────────

  Future<List<ProductModel>> getProducts({
    String? categoryId,
    int page = 0,
    int pageSize = 20,
  }) async {
    var query = _client.from(_products).select().eq('is_active', true);

    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }

    final response = await query
        .order('sort_order', ascending: true)
        .range(page * pageSize, (page + 1) * pageSize - 1);

    return _parseProductList(response);
  }

  Future<ProductModel> getProductById(String id) async {
    final response =
        await _client.from(_products).select().eq('id', id).single();

    return ProductModel.fromJson(response);
  }

  Future<List<ProductModel>> searchProducts(
    String query, {
    int page = 0,
    int pageSize = 20,
  }) async {
    final response = await _client
        .from(_products)
        .select()
        .eq('is_active', true)
        .or('name_en.ilike.%$query%,name_ar.ilike.%$query%')
        .order('sort_order', ascending: true)
        .range(page * pageSize, (page + 1) * pageSize - 1);

    return _parseProductList(response);
  }

  Future<List<ProductModel>> getFeaturedProducts({int limit = 10}) async {
    final response = await _client
        .from(_products)
        .select()
        .eq('is_active', true)
        .eq('is_featured', true)
        .order('sort_order', ascending: true)
        .limit(limit);

    return _parseProductList(response);
  }

  // ─── Categories ───────────────────────────────────────────────────────────

  Future<List<CategoryModel>> getCategories() async {
    final response = await _client
        .from(_categories)
        .select()
        .eq('is_active', true)
        .isFilter('parent_id', null)
        .order('sort_order', ascending: true);

    return (response as List<dynamic>)
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ─── Variants ─────────────────────────────────────────────────────────────

  Future<List<ProductVariantModel>> getVariantsByProductId(
    String productId,
  ) async {
    final response = await _client
        .from(_variants)
        .select()
        .eq('product_id', productId)
        .eq('is_active', true)
        .order('sort_order', ascending: true);

    return (response as List<dynamic>)
        .map((e) => ProductVariantModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  List<ProductModel> _parseProductList(dynamic response) {
    return (response as List<dynamic>)
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
