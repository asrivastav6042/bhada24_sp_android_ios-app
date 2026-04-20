import 'package:flutter/material.dart';
import 'package:bhada24_sp/core/theme/app_colors.dart';

/// Info/alert dialog popup
Future<void> showInfoPopup(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmLabel,
  IconData? icon,
  Color? iconColor,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => InfoPopup(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      icon: icon,
      iconColor: iconColor,
    ),
  );
}

class InfoPopup extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmLabel;
  final IconData? icon;
  final Color? iconColor;

  const InfoPopup({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 48,
              color: iconColor ?? AppColors.primary,
            ),
            const SizedBox(height: 12),
          ],
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            confirmLabel ?? 'OK',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
