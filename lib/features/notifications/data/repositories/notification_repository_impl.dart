import 'package:ecommerce_app/core/error/app_exception.dart';
import 'package:ecommerce_app/features/notifications/data/datasource/notification_remote_datasource.dart';
import 'package:ecommerce_app/features/notifications/data/mappers/notification_mapper.dart';
import 'package:ecommerce_app/features/notifications/logic/contracts/notification_repository.dart';
import 'package:ecommerce_app/features/notifications/logic/entities/notification_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class NotificationRepositoryImpl implements INotificationRepository {
  NotificationRepositoryImpl(this._datasource);

  final INotificationRemoteDatasource _datasource;

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    try {
      final models = await _datasource.getNotifications();
      return NotificationMapper.toEntityList(models);
    } on supabase.PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<void> markAsRead({required String notificationId}) async {
    try {
      await _datasource.markAsRead(notificationId: notificationId);
    } on supabase.PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await _datasource.markAllAsRead();
    } on supabase.PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Stream<List<NotificationEntity>> watchNotifications() {
    return _datasource.watchNotifications().map(
          NotificationMapper.toEntityList,
        );
  }
}

final notificationRepositoryProvider = Provider<INotificationRepository>((ref) {
  final datasource = ref.watch(notificationRemoteDatasourceProvider);
  return NotificationRepositoryImpl(datasource);
});
