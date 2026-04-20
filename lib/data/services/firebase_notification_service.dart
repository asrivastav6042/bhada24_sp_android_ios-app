import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:bhada24_sp/core/config/api_config.dart';
import 'package:bhada24_sp/core/network/api_client.dart';

bool _ok(dynamic data) =>
    data is Map && (data['responseCode'] == 200 || data['responseCode'] == 0);

/// Wraps Firebase Cloud Messaging (FCM) operations
class FirebaseNotificationService {
  final ApiClient _api;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  FirebaseNotificationService(this._api);

  Future<String?> requestPermissionAndGetToken() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      try {
        // Web uses VAPID key; mobile uses default
        if (kIsWeb) {
          return await _fcm.getToken(
            vapidKey:
                'BLBz-example-vapid-key-replace-with-real-one',
          );
        }
        return await _fcm.getToken();
      } catch (e) {
        debugPrint('FCM getToken error: $e');
        return null;
      }
    }
    return null;
  }

  Future<bool> registerToken(int userId, String token) async {
    final res = await _api.post(ApiConfig.registerFcmToken, data: {
      'userId': userId,
      'token': token,
      'platform': kIsWeb ? 'web' : defaultTargetPlatform.name.toLowerCase(),
    });
    return _ok(res.data);
  }

  Future<bool> updateToken(int userId, String token) async {
    final res = await _api.post(ApiConfig.updateFcmToken, data: {
      'userId': userId,
      'token': token,
      'platform': kIsWeb ? 'web' : defaultTargetPlatform.name.toLowerCase(),
    });
    return _ok(res.data);
  }

  /// Listen for foreground messages
  Stream<RemoteMessage> get onForegroundMessage =>
      FirebaseMessaging.onMessage;

  /// Called when app is opened from a background notification
  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  /// Get the initial message if app was opened from terminated state
  Future<RemoteMessage?> getInitialMessage() =>
      _fcm.getInitialMessage();

  /// Subscribe to a topic (e.g. 'all_providers')
  Future<void> subscribeToTopic(String topic) =>
      _fcm.subscribeToTopic(topic);
}
