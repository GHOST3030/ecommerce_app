import 'package:ecommerce_app/core/extensions/context_extension.dart';
import 'package:ecommerce_app/core/theme/app_colors.dart';
import 'package:ecommerce_app/core/theme/app_spacing.dart';
import 'package:ecommerce_app/features/notifications/logic/entities/notification_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final NotificationEntity notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _iconColor(notification.type);
    final date = DateFormat.yMMMd().add_jm().format(notification.createdAt);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(_icon(notification.type), color: color),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: notification.isRead
                                  ? FontWeight.w600
                                  : FontWeight.w800,
                            ),
                          ),
                        ),
                        if (!notification.isRead) ...[
                          const SizedBox(width: AppSpacing.sm),
                          const _UnreadDot(),
                        ],
                      ],
                    ),
                    if (notification.body.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        notification.body,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.theme.hintColor,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      date,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _icon(NotificationType type) {
    return switch (type) {
      NotificationType.orderConfirmed => Icons.check_circle_outline_rounded,
      NotificationType.orderShipped => Icons.local_shipping_outlined,
      NotificationType.orderDelivered => Icons.inventory_2_outlined,
      NotificationType.orderCancelled => Icons.cancel_outlined,
      NotificationType.promo => Icons.local_offer_outlined,
      NotificationType.general => Icons.notifications_none_rounded,
    };
  }

  Color _iconColor(NotificationType type) {
    return switch (type) {
      NotificationType.orderConfirmed => AppColors.success,
      NotificationType.orderShipped => AppColors.info,
      NotificationType.orderDelivered => AppColors.primary,
      NotificationType.orderCancelled => AppColors.error,
      NotificationType.promo => AppColors.secondary,
      NotificationType.general => AppColors.textSecondaryLight,
    };
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.secondary,
        shape: BoxShape.circle,
      ),
      child: SizedBox(width: 10, height: 10),
    );
  }
}
