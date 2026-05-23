import 'package:ecommerce_app/features/notifications/logic/entities/notification_entity.dart';

enum NotificationStatus { initial, loading, refreshing, success, failure }

final class NotificationState {
  const NotificationState({
    this.status = NotificationStatus.initial,
    this.notifications = const [],
    this.errorMessage,
    this.isMarkingAllRead = false,
  });

  const NotificationState.initial() : this();

  final NotificationStatus status;
  final List<NotificationEntity> notifications;
  final String? errorMessage;
  final bool isMarkingAllRead;

  bool get isInitial => status == NotificationStatus.initial;
  bool get isLoading => status == NotificationStatus.loading;
  bool get isRefreshing => status == NotificationStatus.refreshing;
  bool get isSuccess => status == NotificationStatus.success;
  bool get isFailure => status == NotificationStatus.failure;
  bool get isEmpty => isSuccess && notifications.isEmpty;

  int get unreadCount =>
      notifications.where((notification) => !notification.isRead).length;

  NotificationState copyWith({
    NotificationStatus? status,
    List<NotificationEntity>? notifications,
    String? errorMessage,
    bool? isMarkingAllRead,
    bool clearError = false,
  }) {
    return NotificationState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isMarkingAllRead: isMarkingAllRead ?? this.isMarkingAllRead,
    );
  }
}
