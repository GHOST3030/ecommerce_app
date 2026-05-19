import 'package:ecommerce_app/features/cart/data/models/cart_item_model.dart';
import 'package:ecommerce_app/features/cart/logic/entities/cart_item_entity.dart';
import 'package:ecommerce_app/features/product/data/mappers/product_variant_mapper.dart';

class CartItemMapper {
  const CartItemMapper._();

  static CartItemEntity toEntity(CartItemModel model) {
    return CartItemEntity(
      id: model.id,
      userId: model.userId,
      variantId: model.variantId,
      quantity: model.quantity,
      createdAt: model.createdAt,
      variant: model.variant != null
          ? ProductVariantMapper.toEntity(model.variant!)
          : null,
    );
  }

  static CartItemModel toModel(CartItemEntity entity) {
    return CartItemModel(
      id: entity.id,
      userId: entity.userId,
      variantId: entity.variantId,
      quantity: entity.quantity,
      createdAt: entity.createdAt,
    );
  }

  static List<CartItemEntity> toEntityList(List<CartItemModel> models) =>
      models.map(toEntity).toList();
}
