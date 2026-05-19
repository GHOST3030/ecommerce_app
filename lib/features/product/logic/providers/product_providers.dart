import 'package:ecommerce_app/core/supabase/supabase_provider.dart';
import 'package:ecommerce_app/features/product/data/datasources/product_remote_datasource.dart';
import 'package:ecommerce_app/features/product/data/repositories/product_repository_impl.dart';
import 'package:ecommerce_app/features/product/logic/contracts/product_repository.dart';
import 'package:ecommerce_app/features/product/logic/entities/category_entity.dart';
import 'package:ecommerce_app/features/product/logic/entities/product_entity.dart';
import 'package:ecommerce_app/features/product/logic/notifiers/product_detail_notifier.dart';
import 'package:ecommerce_app/features/product/logic/notifiers/product_notifier.dart';
import 'package:ecommerce_app/features/product/logic/state/product_detail_state.dart';
import 'package:ecommerce_app/features/product/logic/state/product_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Infrastructure ───────────────────────────────────────────────────────────

final productDatasourceProvider = Provider<ProductRemoteDatasource>(
  (ref) => ProductRemoteDatasource(ref.watch(supabaseClientProvider)),
  name: 'productDatasourceProvider',
);

final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => ProductRepositoryImpl(ref.watch(productDatasourceProvider)),
  name: 'productRepositoryProvider',
);

// ─── Main Notifiers ───────────────────────────────────────────────────────────

/// Main product list notifier. Manages pagination, filter, and search.
final productNotifierProvider =
    StateNotifierProvider<ProductNotifier, ProductState>(
  (ref) => ProductNotifier(ref.watch(productRepositoryProvider)),
  name: 'productNotifierProvider',
);

/// Per-product detail notifier. Auto-loads when first accessed.
final productDetailProvider = StateNotifierProvider.family<
    ProductDetailNotifier, ProductDetailState, String>(
  (ref, productId) =>
      ProductDetailNotifier(ref.watch(productRepositoryProvider), productId),
  name: 'productDetailProvider',
);

// ─── Derived Selectors ────────────────────────────────────────────────────────
// These fine-grained providers minimise widget rebuilds — each widget only
// subscribes to the exact slice it needs.

final productListProvider = Provider<List<ProductEntity>>(
  (ref) => ref.watch(productNotifierProvider).products,
  name: 'productListProvider',
);

final featuredProductsProvider = Provider<List<ProductEntity>>(
  (ref) => ref.watch(productNotifierProvider).featuredProducts,
  name: 'featuredProductsProvider',
);

final categoriesProvider = Provider<List<CategoryEntity>>(
  (ref) => ref.watch(productNotifierProvider).categories,
  name: 'categoriesProvider',
);

final productStatusProvider = Provider<ProductStatus>(
  (ref) => ref.watch(productNotifierProvider).status,
  name: 'productStatusProvider',
);

final selectedCategoryIdProvider = Provider<String?>(
  (ref) => ref.watch(productNotifierProvider).selectedCategoryId,
  name: 'selectedCategoryIdProvider',
);

final productSearchQueryProvider = Provider<String>(
  (ref) => ref.watch(productNotifierProvider).searchQuery,
  name: 'productSearchQueryProvider',
);

final productErrorProvider = Provider<String?>(
  (ref) => ref.watch(productNotifierProvider).errorMessage,
  name: 'productErrorProvider',
);

final productHasMoreProvider = Provider<bool>(
  (ref) => ref.watch(productNotifierProvider).hasMore,
  name: 'productHasMoreProvider',
);

final productIsLoadingMoreProvider = Provider<bool>(
  (ref) => ref.watch(productNotifierProvider).isLoadingMore,
  name: 'productIsLoadingMoreProvider',
);

final showFeaturedSectionProvider = Provider<bool>(
  (ref) => ref.watch(productNotifierProvider).showFeatured,
  name: 'showFeaturedSectionProvider',
);
