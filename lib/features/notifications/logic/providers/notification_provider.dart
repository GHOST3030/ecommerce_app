import 'package:ecommerce_app/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:ecommerce_app/features/notifications/logic/entities/notification_entity.dart';
import 'package:ecommerce_app/features/notifications/logic/notifiers/notification_notifier.dart';
import 'package:ecommerce_app/features/notifications/logic/states/notification_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationNotifierProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationNotifier(repository);
});

final notificationsProvider = Provider<List<NotificationEntity>>((ref) {
  return ref.watch(notificationNotifierProvider).notifications;
});

final notificationStatusProvider = Provider<NotificationStatus>((ref) {
  return ref.watch(notificationNotifierProvider).status;
});

final notificationUnreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationNotifierProvider).unreadCount;
});

final notificationErrorProvider = Provider<String?>((ref) {
  return ref.watch(notificationNotifierProvider).errorMessage;
});
