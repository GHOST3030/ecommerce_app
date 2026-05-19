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
    state = const ProductState.initial().copyWith(
      status: ProductStatus.loading,
    );
    await _reload();
  }

  Future<void> refresh() async {
    state = state.copyWith(
      status: ProductStatus.refreshing,
      currentPage: 0,
      hasMore: true,
      clearError: true,
    );
    await _reload();
  }

  Future<void> loadNextPage() async {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) return;
    state = state.copyWith(status: ProductStatus.loadingMore);

    try {
      final nextPage = state.currentPage + 1;
      final more = await _fetchPage(page: nextPage);
      state = state.copyWith(
        status: ProductStatus.success,
        products: [...state.products, ...more],
        currentPage: nextPage,
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

    // Reset to a clean state preserving categories + featured.
    state = ProductState(
      status: ProductStatus.loading,
      categories: state.categories,
      featuredProducts: state.featuredProducts,
      selectedCategoryId: categoryId,
    );

    try {
      final products = await _fetchPage(page: 0);
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

    // Reset to a clean state preserving categories + featured.
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
    // Run categories, featured, and first page in parallel.
    await Future.wait([
      _loadCategories(),
      _loadFeaturedProducts(),
      _loadFirstPage(),
    ]);
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _repository.getCategories();
      if (mounted) state = state.copyWith(categories: cats);
    } catch (_) {
      // Non-critical — don't crash the main flow.
    }
  }

  Future<void> _loadFeaturedProducts() async {
    try {
      final featured = await _repository.getFeaturedProducts();
      if (mounted) state = state.copyWith(featuredProducts: featured);
    } catch (_) {
      // Non-critical — don't crash the main flow.
    }
  }

  Future<void> _loadFirstPage() async {
    try {
      final products = await _fetchPage(page: 0);
      if (mounted) {
        state = state.copyWith(
          status: ProductStatus.success,
          products: products,
          currentPage: 0,
          hasMore: products.length >= _pageSize,
        );
      }
    } on AppException catch (e) {
      if (mounted) {
        state = state.copyWith(
          status: ProductStatus.failure,
          errorMessage: Failure.fromException(e).message,
        );
      }
    } catch (_) {
      if (mounted) {
        state = state.copyWith(
          status: ProductStatus.failure,
          errorMessage: const UnknownFailure().message,
        );
      }
    }
  }

  Future<List<ProductEntity>> _fetchPage({required int page}) {
    if (state.searchQuery.isNotEmpty) {
      return _repository.searchProducts(
        state.searchQuery,
        page: page,
        pageSize: _pageSize,
      );
    }
    return _repository.getProducts(
      categoryId: state.selectedCategoryId,
      page: page,
      pageSize: _pageSize,
    );
  }
}
