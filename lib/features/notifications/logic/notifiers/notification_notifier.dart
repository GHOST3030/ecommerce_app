import 'dart:async';

import 'package:ecommerce_app/features/notifications/logic/contracts/notification_repository.dart';
import 'package:ecommerce_app/features/notifications/logic/entities/notification_entity.dart';
import 'package:ecommerce_app/features/notifications/logic/states/notification_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier(this._repository)
      : super(const NotificationState.initial());

  final INotificationRepository _repository;
  StreamSubscription<List<NotificationEntity>>? _subscription;

  Future<void> load() async {
    if (state.isLoading) return;

    state = state.copyWith(
      status: state.isInitial
          ? NotificationStatus.loading
          : NotificationStatus.refreshing,
      clearError: true,
    );

    try {
      final notifications = await _repository.getNotifications();
      state = state.copyWith(
        status: NotificationStatus.success,
        notifications: notifications,
        clearError: true,
      );
      _subscribeRealtime();
    } catch (e) {
      state = state.copyWith(
        status: NotificationStatus.failure,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refresh() => load();

  Future<void> markAsRead(String notificationId) async {
    final notification = state.notifications
        .where((item) => item.id == notificationId)
        .firstOrNull;
    if (notification == null || notification.isRead) return;

    final previous = state.notifications;
    state = state.copyWith(
      notifications: _replaceNotification(
        notification.copyWith(isRead: true),
      ),
      clearError: true,
    );

    try {
      await _repository.markAsRead(notificationId: notificationId);
    } catch (e) {
      state = state.copyWith(
        notifications: previous,
        status: NotificationStatus.failure,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> markAllAsRead() async {
    if (state.unreadCount == 0 || state.isMarkingAllRead) return;

    final previous = state.notifications;
    state = state.copyWith(
      notifications: [
        for (final notification in state.notifications)
          notification.copyWith(isRead: true),
      ],
      isMarkingAllRead: true,
      clearError: true,
    );

    try {
      await _repository.markAllAsRead();
      state = state.copyWith(isMarkingAllRead: false);
    } catch (e) {
      state = state.copyWith(
        notifications: previous,
        isMarkingAllRead: false,
        status: NotificationStatus.failure,
        errorMessage: e.toString(),
      );
    }
  }

  void _subscribeRealtime() {
    if (_subscription != null) return;

    _subscription = _repository.watchNotifications().listen(
      (notifications) {
        state = state.copyWith(
          status: NotificationStatus.success,
          notifications: notifications,
          clearError: true,
        );
      },
      onError: (Object error) {
        state = state.copyWith(errorMessage: error.toString());
      },
    );
  }

  List<NotificationEntity> _replaceNotification(
    NotificationEntity notification,
  ) {
    return [
      for (final item in state.notifications)
        if (item.id == notification.id) notification else item,
    ];
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
