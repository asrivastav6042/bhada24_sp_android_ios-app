import 'package:flutter/material.dart';
import 'package:bhada24_sp/presentation/widgets/common/app_header.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Privacy Policy'),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(
          'Privacy Policy\n\nLast Updated: January 2025\n\n'
          '1. Information We Collect\n'
          'We collect information you provide directly, including your name, email, phone number, business details, and service information.\n\n'
          '2. How We Use Information\n'
          'We use your data to provide our services, match you with customers, send notifications about bookings, and improve our platform.\n\n'
          '3. Information Sharing\n'
          'We share your business information with potential customers on our platform. We do not sell personal data to third parties.\n\n'
          '4. Data Security\n'
          'We implement industry-standard security measures to protect your data including encryption and secure authentication.\n\n'
          '5. Your Rights\n'
          'You can access, update, or delete your account data at any time through the app settings.\n\n'
          '6. Contact Us\n'
          'For privacy concerns, contact us at support@bhada24.com\n\n'
          '© 2025 Bhada24. All rights reserved.',
          style: TextStyle(fontSize: 14, height: 1.7),
        ),
      ),
    );
  }
}
