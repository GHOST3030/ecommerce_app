import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_app/core/extensions/context_extension.dart';
import 'package:ecommerce_app/core/theme/app_colors.dart';
import 'package:ecommerce_app/core/theme/app_spacing.dart';
import 'package:ecommerce_app/features/cart/logic/entities/cart_item_entity.dart';
import 'package:ecommerce_app/features/cart/logic/providers/cart_provider.dart';
import 'package:ecommerce_app/features/cart/ui/widgets/quantity_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartItemTile extends ConsumerWidget {
  const CartItemTile({super.key, required this.item});

  final CartItemEntity item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final variant = item.variant;
    final locale = Localizations.localeOf(context).languageCode;

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        ref
            .read(cartNotifierProvider.notifier)
            .removeFromCart(cartItemId: item.id);
      },
      background: _DismissBackground(label: context.l10n.removeItem),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProductImage(
              imageUrl: variant?.productThumbnail,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    variant?.localizedProductName(locale) ?? '',
                    style: context.textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _VariantChips(
                    size: variant?.size.displayLabel ?? '',
                    colorName: variant?.localizedColor(locale) ?? '',
                    colorHex: variant?.colorHex ?? '#000000',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _PriceDisplay(
                        effectivePrice: variant?.effectivePrice ?? 0,
                        originalPrice: variant?.hasDiscount == true
                            ? variant!.price
                            : null,
                      ),
                      QuantitySelector(
                        quantity: item.quantity,
                        maxQuantity: variant?.stock ?? 99,
                        size: QuantitySelectorSize.small,
                        onDecrement: () => ref
                            .read(cartNotifierProvider.notifier)
                            .updateQuantity(
                              cartItemId: item.id,
                              quantity: item.quantity - 1,
                            ),
                        onIncrement: () => ref
                            .read(cartNotifierProvider.notifier)
                            .updateQuantity(
                              cartItemId: item.id,
                              quantity: item.quantity + 1,
                            ),
                      ),
                    ],
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

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: SizedBox(
        width: 80,
        height: 96,
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const _ImageFallback(),
              )
            : const _ImageFallback(),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(
        child: Icon(Icons.image_not_supported_outlined, size: 28),
      ),
    );
  }
}

class _VariantChips extends StatelessWidget {
  const _VariantChips({
    required this.size,
    required this.colorName,
    required this.colorHex,
  });

  final String size;
  final String colorName;
  final String colorHex;

  @override
  Widget build(BuildContext context) {
    Color parsedColor;
    try {
      parsedColor = Color(
        int.parse(colorHex.replaceFirst('#', '0xFF')),
      );
    } catch (_) {
      parsedColor = Colors.grey;
    }

    return Wrap(
      spacing: AppSpacing.xs,
      children: [
        if (size.isNotEmpty) _Chip(label: size),
        if (colorName.isNotEmpty)
          _Chip(
            label: colorName,
            leading: CircleAvatar(backgroundColor: parsedColor, radius: 5),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.leading});

  final String label;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: context.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _PriceDisplay extends StatelessWidget {
  const _PriceDisplay({
    required this.effectivePrice,
    required this.originalPrice,
  });

  final double effectivePrice;
  final double? originalPrice;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '\$${effectivePrice.toStringAsFixed(2)}',
          style: context.textTheme.titleMedium?.copyWith(
            color: context.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (originalPrice != null)
          Text(
            '\$${originalPrice!.toStringAsFixed(2)}',
            style: context.textTheme.bodySmall?.copyWith(
              decoration: TextDecoration.lineThrough,
              color: context.theme.hintColor,
            ),
          ),
      ],
    );
  }
}

class _DismissBackground extends StatelessWidget {
  const _DismissBackground({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: AlignmentDirectional.centerEnd,
      padding: const EdgeInsetsDirectional.only(end: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.delete_outline, color: Colors.white),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
