import 'package:ecommerce_app/core/extensions/context_extension.dart';
import 'package:ecommerce_app/core/theme/app_colors.dart';
import 'package:ecommerce_app/core/theme/app_spacing.dart';
import 'package:ecommerce_app/core/theme/app_typography.dart';
import 'package:ecommerce_app/core/widgets/app_error_widget.dart';
import 'package:ecommerce_app/core/widgets/app_loading.dart';
import 'package:ecommerce_app/features/product/logic/entities/product_entity.dart';
import 'package:ecommerce_app/features/product/logic/providers/product_providers.dart';
import 'package:ecommerce_app/features/product/logic/state/product_detail_state.dart';
import 'package:ecommerce_app/features/product/ui/widgets/image_carousel.dart';
import 'package:ecommerce_app/features/product/ui/widgets/price_display.dart';
import 'package:ecommerce_app/features/product/ui/widgets/variant_selector.dart';
import 'package:ecommerce_app/features/wishlist/logic/providers/wishlist_provider.dart';
import 'package:ecommerce_app/features/wishlist/logic/states/wishlist_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productDetailProvider(productId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: switch (state.status) {
        DetailStatus.loading => const AppLoading(),
        DetailStatus.failure => AppErrorWidget(
            message: state.errorMessage ?? 'Failed to load product.',
            onRetry: () =>
                ref.read(productDetailProvider(productId).notifier).retry(),
          ),
        DetailStatus.initial => const AppLoading(),
        DetailStatus.success => _DetailBody(
            productId: productId,
            state: state,
          ),
      },
    );
  }
}

// ── Main body ──────────────────────────────────────────────────────────────────

class _DetailBody extends ConsumerWidget {
  const _DetailBody({
    required this.productId,
    required this.state,
  });

  final String productId;
  final ProductDetailState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final langCode = context.isRtl ? 'ar' : 'en';
    final product = state.product!;

    if (ref.read(wishlistStatusProvider) == WishlistStatus.initial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(wishlistNotifierProvider.notifier).load();
      });
    }

    return Stack(
      children: [
        // Scrollable content.
        CustomScrollView(
          slivers: [
            // ── App bar over image ───────────────────────────────
            _DetailAppBar(product: product, langCode: langCode),

            // ── Image carousel ───────────────────────────────────
            SliverToBoxAdapter(
              child: ImageCarousel(imageUrls: product.images),
            ),

            // ── Product info ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name.
                    Text(
                      product.localizedName(langCode),
                      style: AppTypography.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Price.
                    PriceDisplay(
                      price: product.basePrice,
                      discountPrice: product.discountPrice,
                      size: PriceSize.large,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Divider.
                    const Divider(),
                    const SizedBox(height: AppSpacing.md),

                    // Variant selector.
                    if (state.variants.isNotEmpty) ...[
                      VariantSelector(
                        detailState: state,
                        onColorSelected: (hex) => ref
                            .read(productDetailProvider(productId).notifier)
                            .selectColor(hex),
                        onSizeSelected: (size) => ref
                            .read(productDetailProvider(productId).notifier)
                            .selectSize(size),
                        languageCode: langCode,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const Divider(),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // Description.
                    Text(
                      langCode == 'ar' ? 'الوصف' : 'Description',
                      style: AppTypography.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      product.localizedDescription(langCode),
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondaryLight,
                        height: 1.7,
                      ),
                    ),

                    // Space for the floating CTA button.
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),

        // ── Floating CTA ─────────────────────────────────────────
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _AddToCartBar(
            state: state,
            langCode: langCode,
            onAddToCart: () => _handleAddToCart(context, ref, langCode),
          ),
        ),
      ],
    );
  }

  void _handleAddToCart(
    BuildContext context,
    WidgetRef ref,
    String langCode,
  ) {
    final variant = state.selectedVariant;
    if (variant == null) {
      // Prompt user to select variant.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            langCode == 'ar'
                ? 'يرجى اختيار اللون والمقاس'
                : 'Please select color and size',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    // Cart integration will be wired when Cart feature is complete.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          langCode == 'ar' ? 'تمت الإضافة إلى السلة' : 'Added to cart',
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ── App bar with transparent-to-white scroll effect ───────────────────────────

class _DetailAppBar extends ConsumerWidget {
  const _DetailAppBar({required this.product, required this.langCode});

  final ProductEntity product;
  final String langCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistedIds = ref.watch(wishlistProductIdsProvider);
    final isWishlisted = wishlistedIds.contains(product.id);

    return SliverAppBar(
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      elevation: 0,
      title: Text(
        product.localizedName(langCode),
        style: AppTypography.titleLarge,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        IconButton(
          icon: Icon(
            isWishlisted
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
          ),
          color: isWishlisted ? AppColors.secondary : null,
          onPressed: () => ref
              .read(wishlistNotifierProvider.notifier)
              .toggleProduct(product.id),
        ),
        IconButton(
          icon: const Icon(Icons.share_outlined),
          onPressed: () {},
        ),
      ],
    );
  }
}

// ── Add-to-cart bottom bar ─────────────────────────────────────────────────────

class _AddToCartBar extends StatelessWidget {
  const _AddToCartBar({
    required this.state,
    required this.langCode,
    required this.onAddToCart,
  });

  final ProductDetailState state;
  final String langCode;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canAdd = state.canAddToCart;
    final variant = state.selectedVariant;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: theme.brightness == Brightness.light
                ? AppColors.dividerLight
                : AppColors.dividerDark,
          ),
        ),
      ),
      child: Row(
        children: [
          // Stock indicator.
          if (variant != null)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    langCode == 'ar' ? 'المخزون' : 'Stock',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  Text(
                    variant.inStock
                        ? '${variant.stock} ${langCode == 'ar' ? 'متوفر' : 'left'}'
                        : langCode == 'ar'
                            ? 'نفذ'
                            : 'Out of stock',
                    style: AppTypography.labelMedium.copyWith(
                      color:
                          variant.inStock ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

          // CTA button.
          Expanded(
            child: SizedBox(
              height: AppSpacing.buttonHeight,
              child: ElevatedButton.icon(
                onPressed: canAdd ? onAddToCart : null,
                icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                label: Text(
                  langCode == 'ar' ? 'أضف إلى السلة' : 'Add to Cart',
                  style: AppTypography.labelLarge,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
