import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:bhada24_sp/core/config/api_config.dart';
import 'package:bhada24_sp/core/config/firebase_config.dart';
import 'package:bhada24_sp/core/network/api_client.dart';
import 'package:bhada24_sp/data/models/notification_model.dart';
import 'package:bhada24_sp/domain/repositories/i_notification_repository.dart';

class NotificationRepositoryImpl implements INotificationRepository {
  final ApiClient _api;
  NotificationRepositoryImpl(this._api);

  @override
  Stream<List<NotificationModel>> getNotifications(int userId) {
    final ref =
        FirebaseConfig.database.ref('notifications/$userId');
    return ref.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null || data is! Map) return <NotificationModel>[];
      final map = Map<String, dynamic>.from(data);
      final list = map.entries
          .map((e) {
            if (e.value is Map) {
              return NotificationModel.fromJson(
                  e.key, Map<String, dynamic>.from(e.value as Map));
            }
            return null;
          })
          .whereType<NotificationModel>()
          .where((n) => n.hasContent)
          .toList();
      list.sort((a, b) {
        final aTime = a.dateTime ?? DateTime(2000);
        final bTime = b.dateTime ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });
      return list;
    });
  }

  @override
  Future<void> markAsRead(int userId, String notificationId) async {
    try {
      final ref = FirebaseConfig.database
          .ref('notifications/$userId/$notificationId');
      await ref.update({'isRead': true});
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  @override
  Future<void> markAllAsRead(
      int userId, List<NotificationModel> notifications) async {
    try {
      final updates = <String, dynamic>{};
      for (final n in notifications) {
        if (!n.isRead && n.id != null) {
          updates['notifications/$userId/${n.id}/isRead'] = true;
        }
      }
      if (updates.isNotEmpty) {
        await FirebaseConfig.database.ref().update(updates);
      }
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  @override
  Future<void> clearAll(int userId) async {
    try {
      final ref = FirebaseConfig.database.ref('notifications/$userId');
      await ref.remove();
    } catch (e) {
      debugPrint('Error clearing notifications: $e');
    }
  }

  @override
  Future<bool> registerFcmToken(int userId, String token) async {
    try {
      final response = await _api.post(
        ApiConfig.registerFcmToken,
        data: {
          'userId': userId,
          'fcmToken': token,
          'deviceType': kIsWeb ? 'WEB' : 'MOBILE',
          'userType': 'SP',
        },
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> updateFcmToken(int userId, String token) async {
    try {
      final response = await _api.post(
        ApiConfig.updateFcmToken,
        data: {
          'userId': userId,
          'fcmToken': token,
          'deviceType': kIsWeb ? 'WEB' : 'MOBILE',
        },
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String?> requestPermissionAndGetToken() async {
    try {
      final settings = await FirebaseConfig.messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus ==
          AuthorizationStatus.authorized) {
        if (kIsWeb) {
          return await FirebaseConfig.messaging.getToken(
            vapidKey: FirebaseConfig.vapidKey,
          );
        }
        return await FirebaseConfig.messaging.getToken();
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
