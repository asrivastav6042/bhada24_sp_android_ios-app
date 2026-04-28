import 'package:flutter/material.dart';
import 'package:bhada24_sp/core/localization/app_localizations.dart';

extension StringExtension on String {
  String get initials {
    if (isEmpty) return 'U';
    return split(
      ' ',
    ).where((w) => w.isNotEmpty).take(2).map((w) => w[0].toUpperCase()).join();
  }

  bool get isUrl =>
      startsWith('http://') || startsWith('https://') || startsWith('//');
}

extension ContextExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;
  bool get isDesktop => screenWidth >= 1024;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String t(String key, {String? fallback, Map<String, dynamic>? args}) {
    final value = AppLocalizations.of(this).tr(key, args);
    if (value == key && fallback != null) return fallback;
    return value;
  }
}

extension DateTimeExtension on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }
}
