import 'package:ecommerce_app/features/product/logic/entities/product_entity.dart';
import 'package:ecommerce_app/features/product/logic/entities/product_variant_entity.dart';

enum DetailStatus { initial, loading, success, failure }

/// Represents a unique color option derived from available variants.
typedef ColorOption = ({String hex, String nameEn, String nameAr});

final class ProductDetailState {
  const ProductDetailState({
    this.status = DetailStatus.initial,
    this.product,
    this.variants = const [],
    this.selectedColorHex,
    this.selectedSize,
    this.errorMessage,
  });

  const ProductDetailState.initial() : this();

  final DetailStatus status;
  final ProductEntity? product;
  final List<ProductVariantEntity> variants;
  final String? selectedColorHex;
  final ProductSize? selectedSize;
  final String? errorMessage;

  // ─── Status helpers ───────────────────────────────────────────────────────

  bool get isLoading => status == DetailStatus.loading;
  bool get isSuccess => status == DetailStatus.success;
  bool get isFailure => status == DetailStatus.failure;

  // ─── Computed variant selection ───────────────────────────────────────────

  /// All distinct color options from active variants, preserving insertion order.
  List<ColorOption> get uniqueColors {
    final seen = <String>{};
    final result = <ColorOption>[];
    for (final v in variants) {
      if (seen.add(v.colorHex)) {
        result.add((hex: v.colorHex, nameEn: v.colorEn, nameAr: v.colorAr));
      }
    }
    return result;
  }

  /// Sizes available for the currently selected color (all, in-stock or not).
  List<ProductSize> get availableSizesForColor {
    if (selectedColorHex == null) return [];
    final seen = <ProductSize>{};
    return variants
        .where((v) => v.colorHex == selectedColorHex)
        .where((v) => seen.add(v.size))
        .map((v) => v.size)
        .toList();
  }

  /// Whether a given size is in stock for the selected color.
  bool isSizeInStock(ProductSize size) {
    if (selectedColorHex == null) return false;
    return variants.any(
      (v) => v.colorHex == selectedColorHex && v.size == size && v.inStock,
    );
  }

  /// The exact variant matching selected color + size, null if none.
  ProductVariantEntity? get selectedVariant {
    if (selectedColorHex == null || selectedSize == null) return null;
    try {
      return variants.firstWhere(
        (v) => v.colorHex == selectedColorHex && v.size == selectedSize,
      );
    } catch (_) {
      return null;
    }
  }

  /// True when the user has selected a valid in-stock variant.
  bool get canAddToCart =>
      selectedVariant != null && (selectedVariant!.inStock);

  // ─── CopyWith ─────────────────────────────────────────────────────────────

  ProductDetailState copyWith({
    DetailStatus? status,
    ProductEntity? product,
    List<ProductVariantEntity>? variants,
    String? selectedColorHex,
    ProductSize? selectedSize,
    String? errorMessage,
    bool clearSize = false,
    bool clearError = false,
  }) {
    return ProductDetailState(
      status: status ?? this.status,
      product: product ?? this.product,
      variants: variants ?? this.variants,
      selectedColorHex: selectedColorHex ?? this.selectedColorHex,
      selectedSize: clearSize ? null : (selectedSize ?? this.selectedSize),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
