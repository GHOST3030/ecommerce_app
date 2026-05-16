import 'package:ecommerce_app/features/wishlist/data/models/wishlist_item_model.dart';
import 'package:ecommerce_app/features/wishlist/logic/entities/wishlist_item_entity.dart';

class WishlistItemMapper {
  const WishlistItemMapper._();

  static WishlistItemEntity toEntity(WishlistItemModel model) {
    return WishlistItemEntity(
      id:        model.id,
      userId:    model.userId,
      productId: model.productId,
      createdAt: model.createdAt,
    );
  }

  static WishlistItemModel toModel(WishlistItemEntity entity) {
    return WishlistItemModel(
      id:        entity.id,
      userId:    entity.userId,
      productId: entity.productId,
      createdAt: entity.createdAt,
    );
  }

  static List<WishlistItemEntity> toEntityList(
    List<WishlistItemModel> models,
  ) =>
      models.map(toEntity).toList();
}
