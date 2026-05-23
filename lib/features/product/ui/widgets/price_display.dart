import 'package:ecommerce_app/core/theme/app_colors.dart';
import 'package:ecommerce_app/core/theme/app_spacing.dart';
import 'package:ecommerce_app/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

class PriceDisplay extends StatelessWidget {
  const PriceDisplay({
    super.key,
    required this.price,
    this.discountPrice,
    this.currencySymbol = '\$',
    this.size = PriceSize.medium,
    this.showBadge = true,
  });

  final double price;
  final double? discountPrice;
  final String currencySymbol;
  final PriceSize size;
  final bool showBadge;

  bool get _hasDiscount => discountPrice != null && discountPrice! < price;

  double get _effectivePrice => _hasDiscount ? discountPrice! : price;

  int get _discountPercent {
    if (!_hasDiscount) return 0;
    return (((price - discountPrice!) / price) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Effective price.
        Text(
          '$currencySymbol${_effectivePrice.toStringAsFixed(2)}',
          style: _effectivePriceStyle(colorScheme),
        ),

        // Original price struck through.
        if (_hasDiscount) ...[
          Text(
            '$currencySymbol${price.toStringAsFixed(2)}',
            style: _originalPriceStyle,
          ),

          // Discount badge.
          if (showBadge) _DiscountBadge(percent: _discountPercent, size: size),
        ],
      ],
    );
  }

  TextStyle _effectivePriceStyle(ColorScheme scheme) {
    switch (size) {
      case PriceSize.small:
        return AppTypography.titleMedium.copyWith(
          color: _hasDiscount ? AppColors.secondary : scheme.onSurface,
          fontWeight: FontWeight.w700,
        );
      case PriceSize.medium:
        return AppTypography.titleLarge.copyWith(
          color: _hasDiscount ? AppColors.secondary : scheme.onSurface,
          fontWeight: FontWeight.w700,
        );
      case PriceSize.large:
        return AppTypography.headlineMedium.copyWith(
          color: _hasDiscount ? AppColors.secondary : scheme.onSurface,
          fontWeight: FontWeight.w700,
        );
    }
  }

  TextStyle get _originalPriceStyle => AppTypography.bodySmall.copyWith(
        color: AppColors.textSecondaryLight,
        decoration: TextDecoration.lineThrough,
        decorationColor: AppColors.textSecondaryLight,
      );
}

enum PriceSize { small, medium, large }

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.percent, required this.size});

  final int percent;
  final PriceSize size;

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
