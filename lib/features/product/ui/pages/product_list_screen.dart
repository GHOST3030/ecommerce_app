import 'package:ecommerce_app/core/extensions/context_extension.dart';
import 'package:ecommerce_app/core/theme/app_colors.dart';
import 'package:ecommerce_app/core/theme/app_spacing.dart';
import 'package:ecommerce_app/core/theme/app_typography.dart';
import 'package:ecommerce_app/core/widgets/app_error_widget.dart';
import 'package:ecommerce_app/features/product/logic/entities/product_entity.dart';
import 'package:ecommerce_app/features/product/logic/providers/product_providers.dart';
import 'package:ecommerce_app/features/product/logic/state/product_state.dart';
import 'package:ecommerce_app/features/product/ui/widgets/category_selector.dart';
import 'package:ecommerce_app/features/product/ui/widgets/featured_products_row.dart';
import 'package:ecommerce_app/features/product/ui/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() =>
      _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final status = ref.read(productStatusProvider);
      if (status == ProductStatus.initial) {
        ref.read(productNotifierProvider.notifier).initialize();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  String get _langCode => context.isRtl ? 'ar' : 'en';

  void _onSearch(String value) =>
      ref.read(productNotifierProvider.notifier).search(value);

  void _onCategorySelected(String? id) {
    _searchController.clear();
    _searchFocus.unfocus();
    ref.read(productNotifierProvider.notifier).filterByCategory(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _langCode == 'ar' ? 'المتجر' : 'Shop',
          style: AppTypography.headlineSmall,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(productNotifierProvider.notifier).refresh(),
        child: Column(
          children: [
            // Search bar.
            _SearchBar(
              controller: _searchController,
              focusNode: _searchFocus,
              onChanged: _onSearch,
              langCode: _langCode,
            ),

            // Category chips.
            Consumer(
              builder: (_, ref, __) {
                final cats = ref.watch(categoriesProvider);
                final sel = ref.watch(selectedCategoryIdProvider);
                if (cats.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: CategorySelector(
                    categories: cats,
                    selectedId: sel,
                    onSelect: _onCategorySelected,
                    languageCode: _langCode,
                  ),
                );
              },
            ),

            // Main body.
            const Expanded(child: _ProductBody()),
          ],
        ),
      ),
    );
  }
}

// ── Body ───────────────────────────────────────────────────────────────────────

class _ProductBody extends ConsumerWidget {
  const _ProductBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final langCode =
        Directionality.of(context) == TextDirection.rtl ? 'ar' : 'en';
    final status = ref.watch(productStatusProvider);
    final products = ref.watch(productListProvider);
    final featured = ref.watch(featuredProductsProvider);
    final showFeatured = ref.watch(showFeaturedSectionProvider);
    final hasMore = ref.watch(productHasMoreProvider);
    final isLoadingMore = ref.watch(productIsLoadingMoreProvider);
    final error = ref.watch(productErrorProvider);

    if (status == ProductStatus.loading && products.isEmpty) {
      return const SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: _GridSkeleton(),
      );
    }

    if (status == ProductStatus.failure && products.isEmpty) {
      return AppErrorWidget(
        message: error ?? 'Something went wrong.',
        onRetry: () =>
            ref.read(productNotifierProvider.notifier).refresh(),
      );
    }

    if (status == ProductStatus.success && products.isEmpty) {
      return _EmptyState(langCode: langCode);
    }

    return CustomScrollView(
      slivers: [
        if (showFeatured && featured.isNotEmpty)
          _FeaturedSliver(
            featured: featured,
            langCode: langCode,
          ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          sliver: SliverGrid(
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.68,
            ),
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => ProductCard(
                product: products[i],
                onTap: () => ctx.push('/product/${products[i].id}'),
                languageCode: langCode,
              ),
              childCount: products.length,
            ),
          ),
        ),

        if (isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ),

        if (hasMore && !isLoadingMore)
          SliverToBoxAdapter(
            child: _LoadMoreTrigger(
              onVisible: () => ref
                  .read(productNotifierProvider.notifier)
                  .loadNextPage(),
            ),
          ),

        const SliverPadding(
          padding: EdgeInsets.only(bottom: AppSpacing.xl),
        ),
      ],
    );
  }
}

// ── Featured sliver ────────────────────────────────────────────────────────────

class _FeaturedSliver extends StatelessWidget {
  const _FeaturedSliver({
    required this.featured,
    required this.langCode,
  });

  final List<ProductEntity> featured;
  final String langCode;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Text(
              langCode == 'ar' ? 'مميز' : 'Featured',
              style: AppTypography.titleLarge,
            ),
          ),
          FeaturedProductsRow(
            products: featured,
            onProductTap: (p) => context.push('/product/${p.id}'),
            languageCode: langCode,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Text(
              langCode == 'ar' ? 'جميع المنتجات' : 'All Products',
              style: AppTypography.titleLarge,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Supporting widgets ─────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.langCode,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String) onChanged;
  final String langCode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: langCode == 'ar'
              ? 'ابحث عن منتجات...'
              : 'Search products...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: AnimatedBuilder(
            animation: controller,
            builder: (_, __) => controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.langCode});

  final String langCode;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 64,
            color: AppColors.textSecondaryLight,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            langCode == 'ar' ? 'لا توجد منتجات' : 'No products found',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _GridSkeleton extends StatelessWidget {
  const _GridSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.68,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => const ProductCardSkeleton(),
    );
  }
}

class _LoadMoreTrigger extends StatefulWidget {
  const _LoadMoreTrigger({required this.onVisible});

  final VoidCallback onVisible;

  @override
  State<_LoadMoreTrigger> createState() => _LoadMoreTriggerState();
}

class _LoadMoreTriggerState extends State<_LoadMoreTrigger> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.onVisible());
  }

  @override
  Widget build(BuildContext context) => const SizedBox(height: 1);
}
