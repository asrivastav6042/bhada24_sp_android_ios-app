import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bhada24_sp/data/models/notification_model.dart';
import 'package:bhada24_sp/domain/repositories/i_notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  final INotificationRepository _repo;
  NotificationProvider(this._repo);

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = true;
  StreamSubscription? _subscription;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  void listen(int userId) {
    _subscription?.cancel();
    _subscription = _repo.getNotifications(userId).listen((list) {
      _notifications = list;
      _unreadCount = list.where((n) => !n.isRead).length;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> markAsRead(int userId, NotificationModel n) async {
    if (n.isRead || n.id == null) return;
    await _repo.markAsRead(userId, n.id!);
  }

  Future<void> markAllAsRead(int userId) async {
    await _repo.markAllAsRead(userId, _notifications);
  }

  Future<void> clearAll(int userId) async {
    await _repo.clearAll(userId);
    _notifications = [];
    _unreadCount = 0;
    notifyListeners();
  }

  Future<void> setupFcm(int userId) async {
    final token = await _repo.requestPermissionAndGetToken();
    if (token != null) {
      final registered = await _repo.registerFcmToken(userId, token);
      if (!registered) {
        await _repo.updateFcmToken(userId, token);
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
