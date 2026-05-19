import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_app/core/theme/app_colors.dart';
import 'package:ecommerce_app/core/theme/app_spacing.dart';
import 'package:ecommerce_app/core/theme/app_typography.dart';
import 'package:ecommerce_app/features/product/logic/entities/product_entity.dart';
import 'package:ecommerce_app/features/product/ui/widgets/price_display.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onWishlistTap,
    this.isWishlisted = false,
    this.languageCode = 'en',
  });

  final ProductEntity product;
  final VoidCallback onTap;
  final VoidCallback? onWishlistTap;
  final bool isWishlisted;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = product.localizedName(languageCode);

    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: theme.brightness == Brightness.light
                ? AppColors.dividerLight
                : AppColors.dividerDark,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ──────────────────────────────────────────────
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusLg),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _ProductImage(imageUrl: product.thumbnailUrl),
                    if (product.hasDiscount)
                      Positioned(
                        top: AppSpacing.sm,
                        left: AppSpacing.sm,
                        child: _DiscountChip(
                          percent: product.discountPercent,
                        ),
                      ),
                    if (onWishlistTap != null)
                      Positioned(
                        top: AppSpacing.xs,
                        right: AppSpacing.xs,
                        child: _WishlistButton(
                          isWishlisted: isWishlisted,
                          onTap: onWishlistTap!,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ── Info ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  PriceDisplay(
                    price: product.basePrice,
                    discountPrice: product.discountPrice,
                    size: PriceSize.small,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shimmer skeleton for ProductCard ──────────────────────────────────────────

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.dividerDark : AppColors.shimmerBase,
      highlightColor:
          isDark ? AppColors.surfaceDark : AppColors.shimmerHighlight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusLg),
                ),
                child: ColoredBox(
                  color:
                      isDark ? AppColors.dividerDark : AppColors.shimmerBase,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBox(width: double.infinity, height: 12),
                  const SizedBox(height: AppSpacing.xs),
                  _ShimmerBox(width: 80, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
    );
  }
}

// ── Private sub-widgets ────────────────────────────────────────────────────────

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) return const _ImagePlaceholder();

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (_, __) => const _ImagePlaceholder(),
      errorWidget: (_, __, ___) => const _ImagePlaceholder(),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).brightness == Brightness.light
          ? AppColors.shimmerBase
          : AppColors.dividerDark,
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.white54,
          size: AppSpacing.iconMd,
        ),
      ),
    );
  }
}

class _DiscountChip extends StatelessWidget {
  const _DiscountChip({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        '-$percent%',
        style: AppTypography.labelSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _WishlistButton extends StatelessWidget {
  const _WishlistButton({
    required this.isWishlisted,
    required this.onTap,
  });

  final bool isWishlisted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.9),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: Icon(
            isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: AppSpacing.iconSm,
            color: isWishlisted ? AppColors.secondary : AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }
}
