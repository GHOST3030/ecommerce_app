import 'package:ecommerce_app/core/supabase/supabase_provider.dart';
import 'package:ecommerce_app/features/notifications/data/models/notification_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class INotificationRemoteDatasource {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead({required String notificationId});
  Future<void> markAllAsRead();
  Stream<List<NotificationModel>> watchNotifications();
}

class NotificationRemoteDatasource implements INotificationRemoteDatasource {
  NotificationRemoteDatasource(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final response = await _supabase
        .from('notifications')
        .select()
        .order('created_at', ascending: false)
        .limit(50);

    return response.map(NotificationModel.fromJson).toList();
  }

  @override
  Future<void> markAsRead({required String notificationId}) async {
    await _supabase
        .from('notifications')
        .update({'is_read': true}).eq('id', notificationId);
  }

  @override
  Future<void> markAllAsRead() async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  @override
  Stream<List<NotificationModel>> watchNotifications() {
    final userId = _supabase.auth.currentUser!.id;

    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((rows) => rows.map(NotificationModel.fromJson).toList());
  }
}

final notificationRemoteDatasourceProvider =
    Provider<INotificationRemoteDatasource>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return NotificationRemoteDatasource(supabase);
});
