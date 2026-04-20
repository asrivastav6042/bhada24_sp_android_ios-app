import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:bhada24_sp/core/theme/app_colors.dart';

class OtpInput extends StatelessWidget {
  final TextEditingController controller;
  final int length;
  final void Function(String)? onCompleted;

  const OtpInput({
    super.key,
    required this.controller,
    this.length = 6,
    this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 52,
      textStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
    );

    return Pinput(
      controller: controller,
      length: length,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: defaultPinTheme.copyDecorationWith(
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      submittedPinTheme: defaultPinTheme.copyDecorationWith(
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
      ),
      onCompleted: onCompleted,
      pinAnimationType: PinAnimationType.fade,
      keyboardType: TextInputType.number,
      autofocus: true,
    );
  }
}
