import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Centralised navigation helper for programmatic navigation
/// without requiring a BuildContext at call sites.
///
/// Usage: inject NavigationService and call push/go/replace.
class NavigationService {
  /// Global navigator key - must be provided to GoRouter.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  NavigatorState? get _navigator => navigatorKey.currentState;

  BuildContext? get _context => _navigator?.context;

  // ── GoRouter-backed navigation ─────────────────────────────────────────

  void goTo(String path) {
    final ctx = _context;
    if (ctx != null) ctx.go(path);
  }

  void pushTo(String path, {Object? extra}) {
    final ctx = _context;
    if (ctx != null) ctx.push(path, extra: extra);
  }

  void replaceTo(String path, {Object? extra}) {
    final ctx = _context;
    if (ctx != null) ctx.replace(path, extra: extra);
  }

  void pop([Object? result]) {
    final ctx = _context;
    if (ctx != null && ctx.canPop()) ctx.pop(result);
  }

  // ── Common named routes ────────────────────────────────────────────────

  void toDashboard() => goTo('/dashboard');
  void toLogin() => goTo('/login');
  void toRegister() => pushTo('/register');
  void toProfile() => pushTo('/profile');
  void toAddService() => pushTo('/add-service');
  void toManage() => pushTo('/manage');
  void toNotifications() => pushTo('/notifications');
  void toLeads() => pushTo('/leads');
  void toMembership() => pushTo('/membership');
  void toSettings() => pushTo('/settings');
  void toBookingCalendar() => pushTo('/booking-calendar');
  void toMarkBusy() => pushTo('/mark-busy');
}
