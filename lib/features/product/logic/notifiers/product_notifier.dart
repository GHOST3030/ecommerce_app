import 'package:ecommerce_app/core/error/app_exception.dart';
import 'package:ecommerce_app/core/error/failure.dart';
import 'package:ecommerce_app/features/product/logic/contracts/product_repository.dart';
import 'package:ecommerce_app/features/product/logic/entities/product_entity.dart';
import 'package:ecommerce_app/features/product/logic/state/product_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductNotifier extends StateNotifier<ProductState> {
  ProductNotifier(this._repository) : super(const ProductState.initial());

  final ProductRepository _repository;

  static const int _pageSize = 20;

  // ─── Public API ───────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (state.isLoading) return;
    state = state.copyWith(status: ProductStatus.loading, clearError: true);
    await _reload();
  }

  Future<void> refresh() async {
    state = state.copyWith(
      status: ProductStatus.refreshing,
      clearError: true,
      currentPage: 0,
      hasMore: true,
    );
    await _reload();
  }

  Future<void> loadNextPage() async {
    if (!state.hasMore || state.isLoadingMore) return;
    state = state.copyWith(status: ProductStatus.loadingMore);

    try {
      final next = state.currentPage + 1;
      final more = await _fetchCurrentPage(page: next);
      state = state.copyWith(
        status: ProductStatus.success,
        products: [...state.products, ...more],
        currentPage: next,
        hasMore: more.length >= _pageSize,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        status: ProductStatus.failure,
        errorMessage: Failure.fromException(e).message,
      );
    } catch (_) {
      state = state.copyWith(
        status: ProductStatus.failure,
        errorMessage: const UnknownFailure().message,
      );
    }
  }

  Future<void> filterByCategory(String? categoryId) async {
    if (state.selectedCategoryId == categoryId) return;

    state = ProductState(
      status: ProductStatus.loading,
      categories: state.categories,
      featuredProducts: state.featuredProducts,
      selectedCategoryId: categoryId,
    );

    try {
      final products = await _fetchCurrentPage(page: 0);
      state = state.copyWith(
        status: ProductStatus.success,
        products: products,
        currentPage: 0,
        hasMore: products.length >= _pageSize,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        status: ProductStatus.failure,
        errorMessage: Failure.fromException(e).message,
      );
    } catch (_) {
      state = state.copyWith(
        status: ProductStatus.failure,
        errorMessage: const UnknownFailure().message,
      );
    }
  }

  Future<void> search(String query) async {
    final trimmed = query.trim();
    if (trimmed == state.searchQuery) return;

    state = ProductState(
      status: ProductStatus.loading,
      categories: state.categories,
      featuredProducts: state.featuredProducts,
      searchQuery: trimmed,
    );

    try {
      final products = trimmed.isEmpty
          ? await _repository.getProducts(page: 0, pageSize: _pageSize)
          : await _repository.searchProducts(
              trimmed,
              page: 0,
              pageSize: _pageSize,
            );

      state = state.copyWith(
        status: ProductStatus.success,
        products: products,
        currentPage: 0,
        hasMore: products.length >= _pageSize,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        status: ProductStatus.failure,
        errorMessage: Failure.fromException(e).message,
      );
    } catch (_) {
      state = state.copyWith(
        status: ProductStatus.failure,
        errorMessage: const UnknownFailure().message,
      );
    }
  }

  void clearError() => state = state.copyWith(clearError: true);

  // ─── Private ──────────────────────────────────────────────────────────────

  Future<void> _reload() async {
    await Future.wait([
      _loadCategories(),
      _loadFeaturedProducts(),
      _loadFirstPage(),
    ]);
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _repository.getCategories();
      state = state.copyWith(categories: cats);
    } catch (_) {}
  }

  Future<void> _loadFeaturedProducts() async {
    try {
      final featured = await _repository.getFeaturedProducts();
      state = state.copyWith(featuredProducts: featured);
    } catch (_) {}
  }

  Future<void> _loadFirstPage() async {
    try {
      final products = await _fetchCurrentPage(page: 0);
      state = state.copyWith(
        status: ProductStatus.success,
        products: products,
        currentPage: 0,
        hasMore: products.length >= _pageSize,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        status: ProductStatus.failure,
        errorMessage: Failure.fromException(e).message,
      );
    } catch (_) {
      state = state.copyWith(
        status: ProductStatus.failure,
        errorMessage: const UnknownFailure().message,
      );
    }
  }

  Future<List<ProductEntity>> _fetchCurrentPage({required int page}) {
    final query = state.searchQuery;
    final categoryId = state.selectedCategoryId;

    if (query.isNotEmpty) {
      return _repository.searchProducts(query, page: page, pageSize: _pageSize);
    }
    if (categoryId != null) {
      return _repository.getProductsByCategory(
        categoryId,
        page: page,
        pageSize: _pageSize,
      );
    }
    return _repository.getProducts(page: page, pageSize: _pageSize);
  }
}