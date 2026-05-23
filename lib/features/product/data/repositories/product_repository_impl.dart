import 'dart:io';
import 'package:ecommerce_app/core/error/app_exception.dart';
import 'package:ecommerce_app/features/product/data/datasources/product_remote_datasource.dart';
import 'package:ecommerce_app/features/product/data/mappers/category_mapper.dart';
import 'package:ecommerce_app/features/product/data/mappers/product_mapper.dart';
import 'package:ecommerce_app/features/product/data/mappers/product_variant_mapper.dart';
import 'package:ecommerce_app/features/product/logic/contracts/product_repository.dart';
import 'package:ecommerce_app/features/product/logic/entities/category_entity.dart';
import 'package:ecommerce_app/features/product/logic/entities/product_entity.dart';
import 'package:ecommerce_app/features/product/logic/entities/product_variant_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl(this._datasource);

  final ProductRemoteDatasource _datasource;

  @override
  Future<List<ProductEntity>> getProducts({
    String? categoryId,
    int page = 0,
    int pageSize = 20,
  }) =>
      _execute(
        () async {
          final models = await _datasource.getProducts(
            categoryId: categoryId,
            page: page,
            pageSize: pageSize,
          );
          return ProductMapper.toEntityList(models);
        },
      );

  @override
  Future<ProductEntity> getProductById(String id) => _execute(
        () async {
          final model = await _datasource.getProductById(id);
          return ProductMapper.toEntity(model);
        },
      );

  @override
  Future<List<ProductEntity>> searchProducts(
    String query, {
    int page = 0,
    int pageSize = 20,
  }) =>
      _execute(
        () async {
          final models = await _datasource.searchProducts(
            query,
            page: page,
            pageSize: pageSize,
          );
          return ProductMapper.toEntityList(models);
        },
      );

  @override
  Future<List<ProductEntity>> getFeaturedProducts({int limit = 10}) => _execute(
        () async {
          final models = await _datasource.getFeaturedProducts(limit: limit);
          return ProductMapper.toEntityList(models);
        },
      );

  @override
  Future<List<CategoryEntity>> getCategories() => _execute(
        () async {
          final models = await _datasource.getCategories();
          return models.map(CategoryMapper.toEntity).toList();
        },
      );

  @override
  Future<List<ProductVariantEntity>> getVariantsByProductId(
    String productId,
  ) =>
      _execute(
        () async {
          final models = await _datasource.getVariantsByProductId(productId);
          return ProductVariantMapper.toEntityList(models);
        },
      );

  // ─── Error Handling ───────────────────────────────────────────────────────

  Future<T> _execute<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on PostgrestException catch (e) {
      // PGRST116 = "Results contain 0 rows" — single() with no match.
      if (e.code == 'PGRST116') throw const NotFoundException();
      throw ServerException(e.message);
    } on SocketException {
      throw const NetworkException();
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }
}
