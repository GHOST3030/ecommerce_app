import 'package:ecommerce_app/core/supabase/supabase_provider.dart';
import 'package:ecommerce_app/features/product/data/datasources/product_remote_datasource.dart';
import 'package:ecommerce_app/features/product/data/repositories/product_repository_impl.dart';
import 'package:ecommerce_app/features/product/logic/contracts/product_repository.dart';
import 'package:ecommerce_app/features/product/logic/entities/category_entity.dart';
import 'package:ecommerce_app/features/product/logic/entities/product_entity.dart';
import 'package:ecommerce_app/features/product/logic/notifiers/product_notifier.dart';
import 'package:ecommerce_app/features/product/logic/state/product_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Infrastructure ───────────────────────────────────────────────────────────

final productDatasourceProvider = Provider<ProductRemoteDatasource>(
  (ref) => ProductRemoteDatasource(ref.watch(supabaseClientProvider)),
);

final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => ProductRepositoryImpl(ref.watch(productDatasourceProvider)),
);

// ─── Main Notifier ────────────────────────────────────────────────────────────

final productNotifierProvider =
    StateNotifierProvider<ProductNotifier, ProductState>(
  (ref) => ProductNotifier(ref.watch(productRepositoryProvider)),
);

// ─── Derived Selectors (minimize rebuilds) ────────────────────────────────────

final productListProvider = Provider<List<ProductEntity>>(
  (ref) => ref.watch(productNotifierProvider).products,
);

final featuredProductsProvider = Provider<List<ProductEntity>>(
  (ref) => ref.watch(productNotifierProvider).featuredProducts,
);

final categoriesProvider = Provider<List<CategoryEntity>>(
  (ref) => ref.watch(productNotifierProvider).categories,
);

final productStatusProvider = Provider<ProductStatus>(
  (ref) => ref.watch(productNotifierProvider).status,
);

final selectedCategoryProvider = Provider<String?>(
  (ref) => ref.watch(productNotifierProvider).selectedCategoryId,
);

final productErrorProvider = Provider<String?>(
  (ref) => ref.watch(productNotifierProvider).errorMessage,
);

final productHasMoreProvider = Provider<bool>(
  (ref) => ref.watch(productNotifierProvider).hasMore,
);

final productIsLoadingMoreProvider = Provider<bool>(
  (ref) => ref.watch(productNotifierProvider).isLoadingMore,
);

final productSearchQueryProvider = Provider<String>(
  (ref) => ref.watch(productNotifierProvider).searchQuery,
);