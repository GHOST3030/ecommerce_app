import 'package:ecommerce_app/core/error/app_exception.dart';
import 'package:ecommerce_app/core/error/failure.dart';
import 'package:ecommerce_app/features/product/logic/contracts/product_repository.dart';
import 'package:ecommerce_app/features/product/logic/entities/product_variant_entity.dart';
import 'package:ecommerce_app/features/product/logic/state/product_detail_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductDetailNotifier extends StateNotifier<ProductDetailState> {
  ProductDetailNotifier(this._repository, this._productId)
      : super(const ProductDetailState.initial()) {
    _load();
  }

  final ProductRepository _repository;
  final String _productId;

  // ─── Public API ───────────────────────────────────────────────────────────

  Future<void> retry() => _load();

  void selectColor(String colorHex) {
    if (state.selectedColorHex == colorHex) return;
    // Changing color resets size — the combination may not exist.
    state = state.copyWith(
      selectedColorHex: colorHex,
      clearSize: true,
    );
  }

  void selectSize(ProductSize size) {
    state = state.copyWith(selectedSize: size);
  }

  // ─── Private ──────────────────────────────────────────────────────────────

  Future<void> _load() async {
    state = state.copyWith(status: DetailStatus.loading, clearError: true);

    try {
      // Fetch product details and variants in parallel.
      final productFuture = _repository.getProductById(_productId);
      final variantsFuture = _repository.getVariantsByProductId(_productId);

      final product = await productFuture;
      final variants = await variantsFuture;

      // Default to the first variant's color.
      final firstColorHex =
          variants.isNotEmpty ? variants.first.colorHex : null;

      if (mounted) {
        state = state.copyWith(
          status: DetailStatus.success,
          product: product,
          variants: variants,
          selectedColorHex: firstColorHex,
        );
      }
    } on AppException catch (e) {
      if (mounted) {
        state = state.copyWith(
          status: DetailStatus.failure,
          errorMessage: Failure.fromException(e).message,
        );
      }
    } catch (_) {
      if (mounted) {
        state = state.copyWith(
          status: DetailStatus.failure,
          errorMessage: const UnknownFailure().message,
        );
      }
    }
  }
}
