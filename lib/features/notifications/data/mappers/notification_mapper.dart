import 'package:ecommerce_app/features/notifications/data/models/notification_model.dart';
import 'package:ecommerce_app/features/notifications/logic/entities/notification_entity.dart';

class NotificationMapper {
  const NotificationMapper._();

  static NotificationEntity toEntity(NotificationModel model) {
    return NotificationEntity(
      id: model.id,
      userId: model.userId,
      title: model.title,
      body: model.body,
      type: NotificationType.fromString(model.type),
      isRead: model.isRead,
      createdAt: model.createdAt,
      orderId: model.orderId,
    );
  }

  static NotificationModel toModel(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      body: entity.body,
      type: entity.type.toDbString(),
      isRead: entity.isRead,
      createdAt: entity.createdAt,
      orderId: entity.orderId,
    );
  }

  static List<NotificationEntity> toEntityList(
    List<NotificationModel> models,
  ) =>
      models.map(toEntity).toList();
}
