import 'package:bhada24_sp/data/models/notification_model.dart';

/// Notification repository interface
abstract class INotificationRepository {
  Stream<List<NotificationModel>> getNotifications(int userId);
  Future<void> markAsRead(int userId, String notificationId);
  Future<void> markAllAsRead(int userId, List<NotificationModel> notifications);
  Future<void> clearAll(int userId);
  Future<bool> registerFcmToken(int userId, String token);
  Future<bool> updateFcmToken(int userId, String token);
  Future<String?> requestPermissionAndGetToken();
}
