import 'package:ecommerce_app/core/theme/app_colors.dart';
import 'package:ecommerce_app/core/theme/app_spacing.dart';
import 'package:ecommerce_app/core/theme/app_typography.dart';
import 'package:ecommerce_app/features/product/logic/entities/product_variant_entity.dart';
import 'package:ecommerce_app/features/product/logic/state/product_detail_state.dart';
import 'package:flutter/material.dart';

class VariantSelector extends StatelessWidget {
  const VariantSelector({
    super.key,
    required this.detailState,
    required this.onColorSelected,
    required this.onSizeSelected,
    this.languageCode = 'en',
  });

  final ProductDetailState detailState;
  final void Function(String colorHex) onColorSelected;
  final void Function(ProductSize size) onSizeSelected;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ColorSection(
          colors: detailState.uniqueColors,
          selectedHex: detailState.selectedColorHex,
          languageCode: languageCode,
          onSelect: onColorSelected,
        ),
        const SizedBox(height: AppSpacing.md),
        _SizeSection(
          sizes: detailState.availableSizesForColor,
          selectedSize: detailState.selectedSize,
          isSizeInStock: detailState.isSizeInStock,
          onSelect: onSizeSelected,
        ),
      ],
    );
  }
}

// ── Color swatches ─────────────────────────────────────────────────────────────

class _ColorSection extends StatelessWidget {
  const _ColorSection({
    required this.colors,
    required this.selectedHex,
    required this.languageCode,
    required this.onSelect,
  });

  final List<ColorOption> colors;
  final String? selectedHex;
  final String languageCode;
  final void Function(String) onSelect;

  @override
  Widget build(BuildContext context) {
    if (colors.isEmpty) return const SizedBox.shrink();

    final selectedName = colors
        .where((c) => c.hex == selectedHex)
        .map((c) => languageCode == 'ar' ? c.nameAr : c.nameEn)
        .firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              languageCode == 'ar' ? 'اللون:' : 'Color:',
              style: AppTypography.titleMedium,
            ),
            if (selectedName != null) ...[
              const SizedBox(width: AppSpacing.xs),
              Text(
                selectedName,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: colors
              .map(
                (c) => _ColorSwatch(
                  colorOption: c,
                  isSelected: selectedHex == c.hex,
                  onTap: () => onSelect(c.hex),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.colorOption,
    required this.isSelected,
    required this.onTap,
  });

  final ColorOption colorOption;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color color;
    try {
      color = Color(
        int.parse(colorOption.hex.replaceFirst('#', '0xFF')),
      );
    } catch (_) {
      color = Colors.grey;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 6,
                spreadRadius: 1,
              ),
          ],
        ),
        child: isSelected
            ? Icon(
                Icons.check_rounded,
                size: 18,
                color: color.computeLuminance() > 0.5
                    ? Colors.black87
                    : Colors.white,
              )
            : null,
      ),
    );
  }
}

// ── Size chips ─────────────────────────────────────────────────────────────────

class _SizeSection extends StatelessWidget {
  const _SizeSection({
    required this.sizes,
    required this.selectedSize,
    required this.isSizeInStock,
    required this.onSelect,
  });

  final List<ProductSize> sizes;
  final ProductSize? selectedSize;
  final bool Function(ProductSize) isSizeInStock;
  final void Function(ProductSize) onSelect;

  @override
  Widget build(BuildContext context) {
    if (sizes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Size:',
          style: AppTypography.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: sizes
              .map(
                (s) => _SizeChip(
                  size: s,
                  isSelected: selectedSize == s,
                  inStock: isSizeInStock(s),
                  onTap: isSizeInStock(s) ? () => onSelect(s) : null,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _SizeChip extends StatelessWidget {
  const _SizeChip({
    required this.size,
    required this.isSelected,
    required this.inStock,
    this.onTap,
  });

  final ProductSize size;
  final bool isSelected;
  final bool inStock;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        constraints: const BoxConstraints(minWidth: 48),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : inStock
                  ? (isDark ? AppColors.surfaceDark : AppColors.surfaceLight)
                  : (isDark
                      ? AppColors.dividerDark.withOpacity(0.3)
                      : AppColors.shimmerBase),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : isDark
                    ? AppColors.dividerDark
                    : AppColors.dividerLight,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              size.displayLabel,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected
                    ? Colors.white
                    : !inStock
                        ? AppColors.textSecondaryLight
                        : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            // Strike-through line for out-of-stock.
            if (!inStock)
              Positioned.fill(
                child: CustomPaint(painter: _StrikethroughPainter()),
              ),
          ],
        ),
      ),
    );
  }
}

class _StrikethroughPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textSecondaryLight.withOpacity(0.5)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, 0),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
