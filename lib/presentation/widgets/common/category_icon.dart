import 'package:flutter/material.dart';
import 'package:bhada24_sp/core/theme/app_colors.dart';

/// Displays a category icon by category name.
/// Falls back to a generic icon if no match is found.
class CategoryIcon extends StatelessWidget {
  final String? categoryName;
  final double size;
  final Color? color;
  final Color? backgroundColor;
  final bool showBackground;

  const CategoryIcon({
    super.key,
    this.categoryName,
    this.size = 28,
    this.color,
    this.backgroundColor,
    this.showBackground = false,
  });

  static IconData _iconForCategory(String? name) {
    if (name == null) return Icons.category;
    final lower = name.toLowerCase();
    if (lower.contains('photo') || lower.contains('wedding')) {
      return Icons.camera_alt;
    } else if (lower.contains('music') || lower.contains('dj')) {
      return Icons.music_note;
    } else if (lower.contains('catering') || lower.contains('food')) {
      return Icons.restaurant;
    } else if (lower.contains('decor') || lower.contains('flower')) {
      return Icons.local_florist;
    } else if (lower.contains('venue') || lower.contains('hall')) {
      return Icons.location_city;
    } else if (lower.contains('mehendi') || lower.contains('henna')) {
      return Icons.brush;
    } else if (lower.contains('makeup') || lower.contains('beauty')) {
      return Icons.face_retouching_natural;
    } else if (lower.contains('transport') || lower.contains('car')) {
      return Icons.directions_car;
    } else if (lower.contains('tent') || lower.contains('canopy')) {
      return Icons.umbrella;
    } else if (lower.contains('invit') || lower.contains('card')) {
      return Icons.mail;
    } else if (lower.contains('light') || lower.contains('sound')) {
      return Icons.lightbulb;
    } else if (lower.contains('event') || lower.contains('plan')) {
      return Icons.event;
    }
    return Icons.category;
  }

  @override
  Widget build(BuildContext context) {
    final icon = _iconForCategory(categoryName);
    final iconColor = color ?? AppColors.primary;

    if (showBackground) {
      return Container(
        padding: EdgeInsets.all(size * 0.3),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.primary.withAlpha(25),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: size, color: iconColor),
      );
    }
    return Icon(icon, size: size, color: iconColor);
  }
}
