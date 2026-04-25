import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:bhada24_sp/core/config/firebase_config.dart';
import 'package:bhada24_sp/data/models/notification_model.dart';

/// Wraps Firebase Realtime Database operations for notifications
class FirebaseDatabaseService {
  final FirebaseDatabase _db = FirebaseConfig.database;

  DatabaseReference _notificationsRef(int userId) =>
      _db.ref('notifications/$userId');

  Stream<List<NotificationModel>> streamNotifications(int userId) {
    return _notificationsRef(userId).onValue.map((event) {
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
        final aT = a.dateTime ?? DateTime(2000);
        final bT = b.dateTime ?? DateTime(2000);
        return bT.compareTo(aT);
      });
      return list;
    });
  }

  Future<void> markAsRead(int userId, String notificationId) async {
    try {
      await _notificationsRef(userId).child(notificationId).update(
          {'isRead': true});
    } catch (e) {
      debugPrint('FirebaseDatabaseService.markAsRead error: $e');
    }
  }

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
        await _db.ref().update(updates);
      }
    } catch (e) {
      debugPrint('FirebaseDatabaseService.markAllAsRead error: $e');
    }
  }

  Future<void> clearAll(int userId) async {
    try {
      await _notificationsRef(userId).remove();
    } catch (e) {
      debugPrint('FirebaseDatabaseService.clearAll error: $e');
    }
  }
}
