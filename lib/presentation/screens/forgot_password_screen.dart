import 'package:flutter/material.dart';
import 'package:bhada24_sp/presentation/widgets/common/app_header.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Forgot Password'),
      body: const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Password reset is handled through Firebase Phone Auth.\nPlease login using your phone number with OTP.', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, height: 1.6)))),
    );
  }
}
