import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// AppLocalizations - loads en.json / hi.json from assets/translations/
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('hi'),
  ];

  Map<String, dynamic> _strings = {};

  Future<bool> load() async {
    final jsonString = await rootBundle.loadString(
        'assets/translations/${locale.languageCode}.json');
    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    _strings = _flatten(jsonMap);
    return true;
  }

  /// Flatten nested JSON to dot-notation keys e.g. "auth.login"
  Map<String, dynamic> _flatten(Map<String, dynamic> map,
      [String prefix = '']) {
    final result = <String, dynamic>{};
    map.forEach((key, value) {
      final newKey = prefix.isEmpty ? key : '$prefix.$key';
      if (value is Map<String, dynamic>) {
        result.addAll(_flatten(value, newKey));
      } else {
        result[newKey] = value;
      }
    });
    return result;
  }

  /// Translate a key (dot notation). Supports {placeholder} substitution.
  String tr(String key, [Map<String, String>? args]) {
    String text = (_strings[key] ?? key) as String;
    if (args != null) {
      args.forEach((k, v) {
        text = text.replaceAll('{$k}', v);
      });
    }
    return text;
  }

  // ── Convenience getters ──────────────────────────────────────────────────

  String get appName => tr('app_name');
  String get appTagline => tr('app_tagline');

  // common
  String get ok => tr('common.ok');
  String get cancel => tr('common.cancel');
  String get save => tr('common.save');
  String get delete => tr('common.delete');
  String get edit => tr('common.edit');
  String get back => tr('common.back');
  String get next => tr('common.next');
  String get submit => tr('common.submit');
  String get loading => tr('common.loading');
  String get error => tr('common.error');
  String get success => tr('common.success');
  String get retry => tr('common.retry');
  String get confirm => tr('common.confirm');
  String get yes => tr('common.yes');
  String get no => tr('common.no');
  String get close => tr('common.close');
  String get search => tr('common.search');
  String get noData => tr('common.no_data');
  String get somethingWentWrong => tr('common.something_went_wrong');

  // auth
  String get login => tr('auth.login');
  String get logout => tr('auth.logout');
  String get register => tr('auth.register');
  String get phoneNumber => tr('auth.phone_number');
  String get phoneHint => tr('auth.phone_hint');
  String get sendOtp => tr('auth.send_otp');
  String get resendOtp => tr('auth.resend_otp');
  String get verifyOtp => tr('auth.verify_otp');
  String resendIn(int seconds) =>
      tr('auth.resend_in', {'seconds': seconds.toString()});
  String get otpSent => tr('auth.otp_sent');
  String get loginFailed => tr('auth.login_failed');
  String get registerSuccess => tr('auth.register_success');
  String get registerFailed => tr('auth.register_failed');
  String get forgotPassword => tr('auth.forgot_password');
  String get welcomeBack => tr('auth.welcome_back');
  String get name => tr('auth.name');
  String get email => tr('auth.email');

  // dashboard
  String get dashboardTitle => tr('dashboard.title');
  String get welcome => tr('dashboard.welcome');
  String get yourRating => tr('dashboard.your_rating');
  String get membershipStatus => tr('dashboard.membership_status');
  String get quickActions => tr('dashboard.quick_actions');

  // profile
  String get profileTitle => tr('profile.title');
  String get editProfile => tr('profile.edit_profile');
  String get profileUpdated => tr('profile.profile_updated');

  // services
  String get servicesTitle => tr('services.title');
  String get addService => tr('services.add_service');
  String get serviceAdded => tr('services.service_added');
  String get serviceUpdated => tr('services.service_updated');
  String get serviceDeleted => tr('services.service_deleted');
  String get deleteConfirm => tr('services.delete_confirm');
  String get noServices => tr('services.no_services');

  // notifications
  String get notificationsTitle => tr('notifications.title');
  String get noNotifications => tr('notifications.no_notifications');
  String get markAllRead => tr('notifications.mark_all_read');
  String get clearAll => tr('notifications.clear_all');

  // leads
  String get leadsTitle => tr('leads.title');
  String get noLeads => tr('leads.no_leads');

  // settings
  String get settingsTitle => tr('settings.title');
  String get language => tr('settings.language');
  String get english => tr('settings.english');
  String get hindi => tr('settings.hindi');
  String get deactivateAccount => tr('settings.deactivate_account');
  String get deactivateConfirm => tr('settings.deactivate_confirm');

  // membership
  String get membershipTitle => tr('membership.title');
  String get activateFree => tr('membership.activate_free');
  String get activateSuccess => tr('membership.activate_success');
  String daysRemaining(int days) =>
      tr('membership.days_remaining', {'days': days.toString()});

  // errors
  String get networkError => tr('errors.network');
  String get timeoutError => tr('errors.timeout');
  String get unauthorizedError => tr('errors.unauthorized');
  String get serverError => tr('errors.server');
  String get validationPhone => tr('errors.validation_phone');
  String get validationEmail => tr('errors.validation_email');
  String get validationName => tr('errors.validation_name');
  String get validationOtp => tr('errors.validation_otp');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'hi'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
