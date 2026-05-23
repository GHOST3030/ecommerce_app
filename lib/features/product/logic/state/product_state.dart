import 'package:ecommerce_app/features/product/logic/entities/category_entity.dart';
import 'package:ecommerce_app/features/product/logic/entities/product_entity.dart';

enum ProductStatus {
  initial,
  loading,
  refreshing,
  loadingMore,
  success,
  failure
}

final class ProductState {
  const ProductState({
    this.status = ProductStatus.initial,
    this.products = const [],
    this.featuredProducts = const [],
    this.categories = const [],
    this.selectedCategoryId,
    this.searchQuery = '',
    this.currentPage = 0,
    this.hasMore = true,
    this.errorMessage,
  });

  const ProductState.initial() : this();

  final ProductStatus status;
  final List<ProductEntity> products;
  final List<ProductEntity> featuredProducts;
  final List<CategoryEntity> categories;
  final String? selectedCategoryId;
  final String searchQuery;
  final int currentPage;
  final bool hasMore;
  final String? errorMessage;

  bool get isInitial => status == ProductStatus.initial;
  bool get isLoading => status == ProductStatus.loading;
  bool get isRefreshing => status == ProductStatus.refreshing;
  bool get isLoadingMore => status == ProductStatus.loadingMore;
  bool get isSuccess => status == ProductStatus.success;
  bool get isFailure => status == ProductStatus.failure;
  bool get isEmpty => isSuccess && products.isEmpty;
  bool get isSearchActive => searchQuery.isNotEmpty;
  bool get isCategoryActive => selectedCategoryId != null;
  bool get showFeatured => !isSearchActive && !isCategoryActive;

  ProductState copyWith({
    ProductStatus? status,
    List<ProductEntity>? products,
    List<ProductEntity>? featuredProducts,
    List<CategoryEntity>? categories,
    String? selectedCategoryId,
    String? searchQuery,
    int? currentPage,
    bool? hasMore,
    String? errorMessage,
    bool clearError = false,
    bool clearCategory = false,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      featuredProducts: featuredProducts ?? this.featuredProducts,
      categories: categories ?? this.categories,
      selectedCategoryId: clearCategory
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductState &&
        other.status == status &&
        other.products == products &&
        other.featuredProducts == featuredProducts &&
        other.categories == categories &&
        other.selectedCategoryId == selectedCategoryId &&
        other.searchQuery == searchQuery &&
        other.currentPage == currentPage &&
        other.hasMore == hasMore &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(
        status,
        products,
        featuredProducts,
        categories,
        selectedCategoryId,
        searchQuery,
        currentPage,
        hasMore,
        errorMessage,
      );
}
