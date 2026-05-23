import 'package:ecommerce_app/features/order/data/models/order_model.dart';
import 'package:ecommerce_app/features/order/logic/entities/order_entity.dart';

class OrderMapper {
  const OrderMapper._();

  static OrderItemEntity toItemEntity(OrderItemModel model) {
    return OrderItemEntity(
      id: model.id,
      orderId: model.orderId,
      variantId: model.variantId,
      quantity: model.quantity,
      unitPrice: model.unitPrice,
      createdAt: model.createdAt,
    );
  }

  static OrderItemModel toItemModel(OrderItemEntity entity) {
    return OrderItemModel(
      id: entity.id,
      orderId: entity.orderId,
      variantId: entity.variantId,
      quantity: entity.quantity,
      unitPrice: entity.unitPrice,
      createdAt: entity.createdAt,
    );
  }

  static OrderEntity toEntity(OrderModel model) {
    return OrderEntity(
      id: model.id,
      userId: model.userId,
      status: OrderStatus.fromString(model.status),
      totalAmount: model.totalAmount,
      shippingAddress: model.shippingAddress,
      notes: model.notes,
      createdAt: model.createdAt,
      items: model.items.map(toItemEntity).toList(),
    );
  }

  static OrderModel toModel(OrderEntity entity) {
    return OrderModel(
      id: entity.id,
      userId: entity.userId,
      status: entity.status.toDbString(),
      totalAmount: entity.totalAmount,
      shippingAddress: entity.shippingAddress,
      notes: entity.notes,
      createdAt: entity.createdAt,
      items: entity.items.map(toItemModel).toList(),
    );
  }

  static List<OrderEntity> toEntityList(List<OrderModel> models) =>
      models.map(toEntity).toList();
}
