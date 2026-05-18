import 'package:ecommerce_app/features/product/logic/entities/category_entity.dart';
import 'package:ecommerce_app/features/product/logic/entities/product_entity.dart';

abstract interface class ProductRepository {
  /// Fetch paginated products, optionally filtered by category.
  Future<List<ProductEntity>> getProducts({
    String? categoryId,
    int page = 0,
    int pageSize = 20,
  });

  /// Fetch a single product by its ID.
  Future<ProductEntity> getProductById(String id);

  /// Fetch products belonging to a specific category.
  Future<List<ProductEntity>> getProductsByCategory(
    String categoryId, {
    int page = 0,
    int pageSize = 20,
  });

  /// Full-text search over product names.
  Future<List<ProductEntity>> searchProducts(
    String query, {
    int page = 0,
    int pageSize = 20,
  });

  /// Fetch all active root-level categories.
  Future<List<CategoryEntity>> getCategories();

  /// Fetch featured products (isFeatured == true).
  Future<List<ProductEntity>> getFeaturedProducts({int limit = 10});
}