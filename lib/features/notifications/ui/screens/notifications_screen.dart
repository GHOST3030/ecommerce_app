import 'package:ecommerce_app/core/extensions/context_extension.dart';
import 'package:ecommerce_app/core/router/app_routes.dart';
import 'package:ecommerce_app/core/theme/app_colors.dart';
import 'package:ecommerce_app/core/theme/app_spacing.dart';
import 'package:ecommerce_app/core/widgets/app_button.dart';
import 'package:ecommerce_app/core/widgets/app_error_widget.dart';
import 'package:ecommerce_app/core/widgets/app_loading.dart';
import 'package:ecommerce_app/features/notifications/logic/providers/notification_provider.dart';
import 'package:ecommerce_app/features/notifications/logic/states/notification_state.dart';
import 'package:ecommerce_app/features/notifications/ui/widgets/notification_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(notificationStatusProvider) == NotificationStatus.initial) {
        ref.read(notificationNotifierProvider.notifier).load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.isRtl ? 'الإشعارات' : 'Notifications'),
        actions: [
          if (state.unreadCount > 0)
            TextButton(
              onPressed: state.isMarkingAllRead
                  ? null
                  : () => ref
                      .read(notificationNotifierProvider.notifier)
                      .markAllAsRead(),
              child: Text(context.isRtl ? 'قراءة الكل' : 'Mark all read'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(notificationNotifierProvider.notifier).refresh(),
        child: switch (state.status) {
          NotificationStatus.initial => const AppLoading(),
          NotificationStatus.loading => const AppLoading(),
          NotificationStatus.failure when state.notifications.isEmpty =>
            AppErrorWidget(
              message: state.errorMessage ??
                  (context.isRtl
                      ? 'تعذر تحميل الإشعارات'
                      : 'Failed to load notifications'),
              onRetry: () =>
                  ref.read(notificationNotifierProvider.notifier).load(),
            ),
          _ when state.notifications.isEmpty => const _EmptyNotifications(),
          _ => _NotificationList(state: state),
        },
      ),
    );
  }
}

class _NotificationList extends ConsumerWidget {
  const _NotificationList({required this.state});

  final NotificationState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: state.notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final notification = state.notifications[index];
        return NotificationTile(
          notification: notification,
          onTap: () {
            ref
                .read(notificationNotifierProvider.notifier)
                .markAsRead(notification.id);

            final orderId = notification.orderId;
            if (orderId != null && orderId.isNotEmpty) {
              context.push(AppRoutes.orderDetailPath(orderId));
            }
          },
        );
      },
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        SizedBox(height: context.screenHeight * 0.18),
        const Icon(
          Icons.notifications_none_rounded,
          size: 72,
          color: AppColors.textSecondaryLight,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          context.isRtl ? 'لا توجد إشعارات' : 'No notifications yet',
          textAlign: TextAlign.center,
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          context.isRtl
              ? 'ستظهر تحديثات الطلبات والعروض هنا.'
              : 'Order updates and offers will appear here.',
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.theme.hintColor,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: AppButton(
            label: context.isRtl ? 'تصفح المتجر' : 'Browse shop',
            icon: Icons.storefront_rounded,
            isExpanded: false,
            onPressed: () => context.go(AppRoutes.productList),
          ),
        ),
      ],
    );
  }
}
