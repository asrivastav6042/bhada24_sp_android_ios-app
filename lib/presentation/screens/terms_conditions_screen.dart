import 'package:flutter/material.dart';
import 'package:bhada24_sp/presentation/widgets/common/app_header.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Terms & Conditions'),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(
          'Terms & Conditions\n\nLast Updated: January 2025\n\n'
          '1. Acceptance of Terms\n'
          'By using Bhada24, you agree to these terms and conditions.\n\n'
          '2. Service Provider Responsibilities\n'
          'As a service provider, you are responsible for the accuracy of your listing information, responding to customer inquiries, and fulfilling booked services.\n\n'
          '3. Membership\n'
          'Free membership provides access to basic features. Premium features may require paid membership in the future.\n\n'
          '4. Content\n'
          'You retain ownership of content you upload. By uploading, you grant Bhada24 license to display it on the platform.\n\n'
          '5. Prohibited Activities\n'
          'You may not use the platform for illegal activities, spam, or misleading information.\n\n'
          '6. Termination\n'
          'We reserve the right to suspend or terminate accounts that violate these terms.\n\n'
          '7. Limitation of Liability\n'
          'Bhada24 is a platform that connects service providers with customers. We are not liable for disputes between parties.\n\n'
          '8. Changes to Terms\n'
          'We may update these terms at any time. Continued use constitutes acceptance.\n\n'
          '© 2025 Bhada24. All rights reserved.',
          style: TextStyle(fontSize: 14, height: 1.7),
        ),
      ),
    );
  }
}
