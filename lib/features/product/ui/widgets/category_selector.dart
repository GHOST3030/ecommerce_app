import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_app/core/theme/app_colors.dart';
import 'package:ecommerce_app/core/theme/app_spacing.dart';
import 'package:ecommerce_app/core/theme/app_typography.dart';
import 'package:ecommerce_app/features/product/logic/entities/category_entity.dart';
import 'package:flutter/material.dart';

class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelect,
    this.languageCode = 'en',
  });

  final List<CategoryEntity> categories;
  final String? selectedId;
  final void Function(String? id) onSelect;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: categories.length + 1, // +1 for "All"
        separatorBuilder: (_, __) =>
            const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _CategoryChip(
              label: languageCode == 'ar' ? 'الكل' : 'All',
              isSelected: selectedId == null,
              isDark: isDark,
              onTap: () => onSelect(null),
            );
          }

          final category = categories[index - 1];
          return _CategoryChip(
            label: category.localizedName(languageCode),
            imageUrl: category.imageUrl,
            isSelected: selectedId == category.id,
            isDark: isDark,
            onTap: () => onSelect(category.id),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
    this.imageUrl,
  });

  final String label;
  final String? imageUrl;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondary
              : isDark
                  ? AppColors.surfaceDark
                  : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: isSelected
                ? AppColors.secondary
                : isDark
                    ? AppColors.dividerDark
                    : AppColors.dividerLight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imageUrl != null && imageUrl!.isNotEmpty) ...[
              ClipOval(
                child: CachedNetworkImage(
                  imageUrl: imageUrl!,
                  width: 20,
                  height: 20,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected
                    ? Colors.white
                    : isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
