import 'package:ecommerce_app/core/extensions/context_extension.dart';
import 'package:ecommerce_app/core/theme/app_spacing.dart';
import 'package:ecommerce_app/features/product/ui/widgets/product_card.dart';
import 'package:ecommerce_app/features/wishlist/logic/entities/wishlist_item_entity.dart';
import 'package:flutter/material.dart';

class WishlistProductCard extends StatelessWidget {
  const WishlistProductCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onRemove,
    required this.languageCode,
  });

  final WishlistItemEntity item;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final product = item.product;

    if (product == null) {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              const Icon(Icons.favorite_border_rounded),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  context.isRtl
                      ? 'هذا المنتج غير متاح حاليا'
                      : 'This product is not available right now',
                  style: context.textTheme.bodyMedium,
                ),
              ),
              IconButton(
                tooltip: context.isRtl ? 'إزالة' : 'Remove',
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
        ),
      );
    }

    return ProductCard(
      product: product,
      onTap: onTap,
      onWishlistTap: onRemove,
      isWishlisted: true,
      languageCode: languageCode,
    );
  }
}
