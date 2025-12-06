/// Service untuk handle notification operations
/// CRUD operations untuk notifications dari Supabase
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';

class NotificationService {
  final _supabase = Supabase.instance.client;

  /// Get all notifications for current user
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        print('⚠️ No user logged in');
        return [];
      }

      print('🔍 Loading notifications for user: $userId');

      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      print('📦 Loaded ${response.length} notifications');

      return response
          .map((json) => NotificationModel.fromMap(json))
          .toList();
    } catch (e) {
      print('❌ Failed to load notifications: $e');
      rethrow;
    }
  }

  /// Get unread notifications count
  Future<int> getUnreadCount() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return 0;

      final response = await _supabase
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false);

      return response.length;
    } catch (e) {
      print('❌ Failed to get unread count: $e');
      return 0;
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);

      print('✅ Notification marked as read: $notificationId');
    } catch (e) {
      print('❌ Failed to mark notification as read: $e');
      rethrow;
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);

      print('✅ All notifications marked as read');
    } catch (e) {
      print('❌ Failed to mark all as read: $e');
      rethrow;
    }
  }

  /// Create a new notification (admin only)
  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? relatedId,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'message': message,
        'type': type,
        'related_id': relatedId,
      });

      print('✅ Notification created successfully');
    } catch (e) {
      print('❌ Failed to create notification: $e');
      rethrow;
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('id', notificationId);

      print('✅ Notification deleted: $notificationId');
    } catch (e) {
      print('❌ Failed to delete notification: $e');
      rethrow;
    }
  }
}
