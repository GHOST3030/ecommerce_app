import 'package:ecommerce_app/features/wishlist/logic/entities/wishlist_item_entity.dart';

enum WishlistStatus { initial, loading, refreshing, success, failure }

final class WishlistState {
  const WishlistState({
    this.status = WishlistStatus.initial,
    this.items = const [],
    this.mutatingProductIds = const {},
    this.errorMessage,
  });

  const WishlistState.initial() : this();

  final WishlistStatus status;
  final List<WishlistItemEntity> items;
  final Set<String> mutatingProductIds;
  final String? errorMessage;

  bool get isInitial => status == WishlistStatus.initial;
  bool get isLoading => status == WishlistStatus.loading;
  bool get isRefreshing => status == WishlistStatus.refreshing;
  bool get isSuccess => status == WishlistStatus.success;
  bool get isFailure => status == WishlistStatus.failure;
  bool get isEmpty => isSuccess && items.isEmpty;

  Set<String> get productIds => items.map((item) => item.productId).toSet();

  bool containsProduct(String productId) => productIds.contains(productId);

  bool isMutating(String productId) => mutatingProductIds.contains(productId);

  WishlistState copyWith({
    WishlistStatus? status,
    List<WishlistItemEntity>? items,
    Set<String>? mutatingProductIds,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WishlistState(
      status: status ?? this.status,
      items: items ?? this.items,
      mutatingProductIds: mutatingProductIds ?? this.mutatingProductIds,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
