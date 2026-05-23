import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_app/core/theme/app_colors.dart';
import 'package:ecommerce_app/core/theme/app_spacing.dart';
import 'package:ecommerce_app/core/theme/app_typography.dart';
import 'package:ecommerce_app/features/product/logic/entities/product_entity.dart';
import 'package:ecommerce_app/features/product/ui/widgets/price_display.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class FeaturedProductsRow extends StatelessWidget {
  const FeaturedProductsRow({
    super.key,
    required this.products,
    required this.onProductTap,
    this.languageCode = 'en',
    this.onWishlistTap,
    this.wishlistedIds = const {},
  });

  final List<ProductEntity> products;
  final void Function(ProductEntity) onProductTap;
  final String languageCode;
  final void Function(ProductEntity)? onWishlistTap;
  final Set<String> wishlistedIds;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (_, i) => _FeaturedCard(
          product: products[i],
          onTap: () => onProductTap(products[i]),
          languageCode: languageCode,
          isWishlisted: wishlistedIds.contains(products[i].id),
          onWishlistTap:
              onWishlistTap != null ? () => onWishlistTap!(products[i]) : null,
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({
    required this.product,
    required this.onTap,
    required this.languageCode,
    required this.isWishlisted,
    required this.onWishlistTap,
  });

  final ProductEntity product;
  final VoidCallback onTap;
  final String languageCode;
  final bool isWishlisted;
  final VoidCallback? onWishlistTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 160,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image.
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppSpacing.radiusLg),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      product.thumbnailUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: product.thumbnailUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => const ColoredBox(
                                  color: AppColors.shimmerBase),
                              errorWidget: (_, __, ___) => const ColoredBox(
                                  color: AppColors.shimmerBase),
                            )
                          : const ColoredBox(color: AppColors.shimmerBase),
                      if (product.hasDiscount)
                        Positioned(
                          top: AppSpacing.xs,
                          left: AppSpacing.xs,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            child: Text(
                              '-${product.discountPercent}%',
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      if (onWishlistTap != null)
                        Positioned(
                          top: AppSpacing.xs,
                          right: AppSpacing.xs,
                          child: Material(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: const CircleBorder(),
                            child: InkWell(
                              onTap: onWishlistTap,
                              customBorder: const CircleBorder(),
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.xs),
                                child: Icon(
                                  isWishlisted
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  size: AppSpacing.iconSm,
                                  color: isWishlisted
                                      ? AppColors.secondary
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Name + price.
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.localizedName(languageCode),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    PriceDisplay(
                      price: product.basePrice,
                      discountPrice: product.discountPrice,
                      size: PriceSize.small,
                      showBadge: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Skeleton ───────────────────────────────────────────────────────────────────

class FeaturedProductsSkeleton extends StatelessWidget {
  const FeaturedProductsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 230,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (_, __) => Shimmer.fromColors(
          baseColor: isDark ? AppColors.dividerDark : AppColors.shimmerBase,
          highlightColor:
              isDark ? AppColors.surfaceDark : AppColors.shimmerHighlight,
          child: Container(
            width: 160,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
          ),
        ),
      ),
    );
  }
}
