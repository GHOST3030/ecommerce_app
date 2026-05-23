import 'package:ecommerce_app/features/notifications/logic/entities/notification_entity.dart';

abstract interface class INotificationRepository {
  Future<List<NotificationEntity>> getNotifications();
  Future<void> markAsRead({required String notificationId});
  Future<void> markAllAsRead();
  Stream<List<NotificationEntity>> watchNotifications();
}
