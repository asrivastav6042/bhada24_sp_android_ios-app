import 'package:flutter/material.dart';
import 'package:bhada24_sp/presentation/widgets/common/app_header.dart';

class ChangeMobileScreen extends StatelessWidget {
  const ChangeMobileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Change Mobile'),
      body: const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Contact support to change your registered mobile number.\n\nEmail: support@bhada24.com', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, height: 1.6)))),
    );
  }
}
