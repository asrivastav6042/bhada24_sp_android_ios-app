import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bhada24_sp/core/theme/app_colors.dart';
import 'package:bhada24_sp/presentation/widgets/common/app_header.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Contact Us'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12)]),
            child: Column(children: [
              const Icon(Icons.support_agent, size: 48, color: AppColors.primary),
              const SizedBox(height: 12),
              const Text('Need Help?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text('We\'re here to assist you.', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              _contactItem(Icons.email, 'Email', 'support@bhada24.com', () => launchUrl(Uri.parse('mailto:support@bhada24.com'))),
              _contactItem(Icons.phone, 'Phone', '+91 9876543210', () => launchUrl(Uri.parse('tel:+919876543210'))),
              _contactItem(Icons.language, 'Website', 'www.bhada24.com', () => launchUrl(Uri.parse('https://www.bhada24.com'))),
            ]),
          ),
        ]),
      ),
    );
  }

  static Widget _contactItem(IconData icon, String label, String value, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primary)),
          ]),
        ]),
      ),
    );
  }
}
