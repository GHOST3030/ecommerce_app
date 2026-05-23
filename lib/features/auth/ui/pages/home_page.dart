import 'package:ecommerce_app/core/extensions/context_extension.dart';
import 'package:ecommerce_app/core/router/app_routes.dart';
import 'package:ecommerce_app/core/theme/app_colors.dart';
import 'package:ecommerce_app/core/theme/app_spacing.dart';
import 'package:ecommerce_app/core/theme/app_typography.dart';
import 'package:ecommerce_app/features/auth/logic/provider/auth_providers.dart';
import 'package:ecommerce_app/features/product/logic/entities/category_entity.dart';
import 'package:ecommerce_app/features/product/logic/entities/product_entity.dart';
import 'package:ecommerce_app/features/product/logic/providers/product_providers.dart';
import 'package:ecommerce_app/features/product/logic/state/product_state.dart';
import 'package:ecommerce_app/features/product/ui/widgets/product_card.dart';
import 'package:ecommerce_app/features/wishlist/logic/providers/wishlist_provider.dart';
import 'package:ecommerce_app/features/wishlist/logic/states/wishlist_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(productStatusProvider) == ProductStatus.initial) {
        ref.read(productNotifierProvider.notifier).initialize();
      }
      if (ref.read(wishlistStatusProvider) == WishlistStatus.initial) {
        ref.read(wishlistNotifierProvider.notifier).load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(productStatusProvider);
    final products = ref.watch(productListProvider);
    final featured = ref.watch(featuredProductsProvider);
    final categories = ref.watch(categoriesProvider);
    final error = ref.watch(productErrorProvider);
    final user = ref.watch(currentUserProvider);
    final wishlistedIds = ref.watch(wishlistProductIdsProvider);
    final langCode = context.isRtl ? 'ar' : 'en';

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpacing.md,
        title: _Greeting(fullName: user?.fullName),
        actions: [
          IconButton(
            tooltip: context.l10n.search,
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.push(AppRoutes.search),
          ),
          IconButton(
            tooltip: context.l10n.cart,
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () => context.push(AppRoutes.cart),
          ),
          IconButton(
            tooltip: context.isRtl ? 'المفضلة' : 'Wishlist',
            icon: const Icon(Icons.favorite_border_rounded),
            onPressed: () => context.push(AppRoutes.wishlist),
          ),
          PopupMenuButton<_HomeMenuAction>(
            tooltip: context.l10n.appName,
            onSelected: (action) {
              switch (action) {
                case _HomeMenuAction.logout:
                  ref.read(authNotifierProvider.notifier).signOut();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _HomeMenuAction.logout,
                child: Text(context.l10n.logout),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(productNotifierProvider.notifier).refresh(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _HeroBand(
                onShopTap: () => context.push(AppRoutes.productList),
                onSearchTap: () => context.push(AppRoutes.search),
              ),
            ),
            if (categories.isNotEmpty)
              SliverToBoxAdapter(
                child: _CategoryStrip(
                  categories: categories,
                  languageCode: langCode,
                  onCategoryTap: (category) async {
                    await ref
                        .read(productNotifierProvider.notifier)
                        .filterByCategory(category.id);
                    if (context.mounted) context.push(AppRoutes.productList);
                  },
                ),
              ),
            if (status == ProductStatus.loading && products.isEmpty)
              const SliverPadding(
                padding: EdgeInsets.all(AppSpacing.md),
                sliver: _HomeSkeletonGrid(),
              )
            else if (status == ProductStatus.failure && products.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _HomeError(
                  message: error ?? context.l10n.error,
                  onRetry: () =>
                      ref.read(productNotifierProvider.notifier).refresh(),
                ),
              )
            else ...[
              if (featured.isNotEmpty)
                SliverToBoxAdapter(
                  child: _ProductRail(
                    title: context.isRtl ? 'مختارات مميزة' : 'Featured',
                    products: featured,
                    languageCode: langCode,
                    wishlistedIds: wishlistedIds,
                    onWishlistTap: _toggleWishlist,
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.xl,
                ),
                sliver: SliverMainAxisGroup(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _SectionHeader(
                        title: context.isRtl ? 'وصل حديثا' : 'Fresh arrivals',
                        actionLabel: context.isRtl ? 'عرض الكل' : 'View all',
                        onActionTap: () => context.push(AppRoutes.productList),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.sm),
                    ),
                    if (products.isEmpty)
                      SliverToBoxAdapter(
                        child: _EmptyProducts(message: context.l10n.emptyState),
                      )
                    else
                      SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: AppSpacing.md,
                          crossAxisSpacing: AppSpacing.md,
                          childAspectRatio: 0.68,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (ctx, index) {
                            final product = products[index];
                            return ProductCard(
                              product: product,
                              languageCode: langCode,
                              onTap: () => ctx.push('/product/${product.id}'),
                              isWishlisted: wishlistedIds.contains(product.id),
                              onWishlistTap: () => _toggleWishlist(product),
                            );
                          },
                          childCount: products.length > 6 ? 6 : products.length,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _toggleWishlist(ProductEntity product) {
    ref.read(wishlistNotifierProvider.notifier).toggleProduct(product.id);
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.fullName});

  final String? fullName;

  @override
  Widget build(BuildContext context) {
    final firstName = fullName?.trim().split(' ').first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          firstName == null || firstName.isEmpty
              ? context.l10n.appName
              : 'Hi, $firstName',
          style: AppTypography.titleLarge,
        ),
        Text(
          context.isRtl ? 'تسوق اختيارات اليوم' : 'Shop today\'s picks',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}

class _HeroBand extends StatelessWidget {
  const _HeroBand({
    required this.onShopTap,
    required this.onSearchTap,
  });

  final VoidCallback onShopTap;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.isRtl ? 'اكتشف مجموعتك القادمة' : 'Find your next fit',
                style: AppTypography.headlineLarge.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                context.isRtl
                    ? 'منتجات جديدة، ألوان مختارة، ومقاسات جاهزة للطلب.'
                    : 'New products, curated colors, and sizes ready to order.',
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.72),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: onShopTap,
                    icon: const Icon(Icons.storefront_rounded),
                    label: Text(context.isRtl ? 'تسوق الآن' : 'Shop now'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton.filledTonal(
                    tooltip: context.l10n.search,
                    onPressed: onSearchTap,
                    icon: const Icon(Icons.search_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip({
    required this.categories,
    required this.languageCode,
    required this.onCategoryTap,
  });

  final List<CategoryEntity> categories;
  final String languageCode;
  final ValueChanged<CategoryEntity> onCategoryTap;

  @override
  Widget build(BuildContext context) {
    final visibleCategories = categories.take(8).toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: _SectionHeader(
              title: context.isRtl ? 'الأقسام' : 'Categories',
              actionLabel: context.isRtl ? 'المتجر' : 'Shop',
              onActionTap: () => context.push(AppRoutes.productList),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: visibleCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final category = visibleCategories[index];
                return ActionChip(
                  avatar: const Icon(Icons.category_outlined, size: 18),
                  label: Text(category.localizedName(languageCode)),
                  onPressed: () => onCategoryTap(category),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductRail extends StatelessWidget {
  const _ProductRail({
    required this.title,
    required this.products,
    required this.languageCode,
    required this.wishlistedIds,
    required this.onWishlistTap,
  });

  final String title;
  final List<ProductEntity> products;
  final String languageCode;
  final Set<String> wishlistedIds;
  final ValueChanged<ProductEntity> onWishlistTap;

  @override
  Widget build(BuildContext context) {
    final visibleProducts = products.take(8).toList();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: _SectionHeader(
              title: title,
              actionLabel: context.isRtl ? 'عرض الكل' : 'View all',
              onActionTap: () => context.push(AppRoutes.productList),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 250,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: visibleProducts.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (context, index) {
                final product = visibleProducts[index];
                return SizedBox(
                  width: 160,
                  child: ProductCard(
                    product: product,
                    languageCode: languageCode,
                    onTap: () => context.push('/product/${product.id}'),
                    isWishlisted: wishlistedIds.contains(product.id),
                    onWishlistTap: () => onWishlistTap(product),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onActionTap,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTypography.headlineSmall,
          ),
        ),
        TextButton(
          onPressed: onActionTap,
          child: Text(actionLabel),
        ),
      ],
    );
  }
}

class _HomeSkeletonGrid extends StatelessWidget {
  const _HomeSkeletonGrid();

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.68,
      ),
      delegate: SliverChildBuilderDelegate(
        (_, __) => const ProductCardSkeleton(),
        childCount: 6,
      ),
    );
  }
}

class _HomeError extends StatelessWidget {
  const _HomeError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTypography.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyProducts extends StatelessWidget {
  const _EmptyProducts({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Center(
        child: Text(
          message,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }
}

enum _HomeMenuAction { logout }
