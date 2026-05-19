import 'package:ecommerce_app/core/theme/app_spacing.dart';
import 'package:ecommerce_app/features/product/logic/entities/product_entity.dart';
import 'package:ecommerce_app/features/product/ui/widgets/product_card.dart';
import 'package:flutter/material.dart';

class ProductGrid extends StatefulWidget {
  const ProductGrid({
    super.key,
    required this.products,
    required this.onProductTap,
    this.onLoadMore,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.onWishlistTap,
    this.wishlistedIds = const {},
    this.languageCode = 'en',
    this.padding,
  });

  final List<ProductEntity> products;
  final void Function(ProductEntity) onProductTap;
  final VoidCallback? onLoadMore;
  final bool isLoadingMore;
  final bool hasMore;
  final void Function(ProductEntity)? onWishlistTap;
  final Set<String> wishlistedIds;
  final String languageCode;
  final EdgeInsetsGeometry? padding;

  @override
  State<ProductGrid> createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    // Trigger 300px before the bottom edge.
    if (pos.pixels >= pos.maxScrollExtent - 300 &&
        widget.hasMore &&
        !widget.isLoadingMore) {
      widget.onLoadMore?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: widget.padding ??
              const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.68,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product = widget.products[index];
                return ProductCard(
                  product: product,
                  onTap: () => widget.onProductTap(product),
                  isWishlisted: widget.wishlistedIds.contains(product.id),
                  onWishlistTap: widget.onWishlistTap != null
                      ? () => widget.onWishlistTap!(product)
                      : null,
                  languageCode: widget.languageCode,
                );
              },
              childCount: widget.products.length,
            ),
          ),
        ),

        // Loading footer while fetching next page.
        if (widget.isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Skeleton grid shown during initial load ────────────────────────────────────

class ProductGridSkeleton extends StatelessWidget {
  const ProductGridSkeleton({super.key, this.itemCount = 6});

  final int itemCount;

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
      itemCount: itemCount,
      itemBuilder: (_, __) => const ProductCardSkeleton(),
    );
  }
}
