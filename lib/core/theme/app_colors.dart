import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette
  static const Color primary = Color(0xFF0B74DE);
  static const Color primaryLight = Color(0xFF667EEA);
  static const Color primaryDark = Color(0xFF0F172A);

  // Accent
  static const Color accent = Color(0xFF8B5CF6);
  static const Color accentLight = Color(0xFF06B6D4);

  // Background
  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color darkBg = Color(0xFF181B21);

  // Text
  static const Color textPrimary = Color(0xFF232B35);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textLight = Color(0xFFB2B7BE);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Borders & dividers
  static const Color border = Color(0xFFE0E3E7);
  static const Color divider = Color(0xFFE5E7EB);

  // Bottom Nav
  static const Color bottomNavBg = Color(0xFF181B21);
  static const Color bottomNavActive = Color(0xFF0B74DE);
  static const Color bottomNavInactive = Color(0xFFFFFFFF);
  static const Color bottomNavGray = Color(0xFFB2B7BE);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient welcomeGradient = LinearGradient(
    colors: [Color(0xFF667EEA), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
