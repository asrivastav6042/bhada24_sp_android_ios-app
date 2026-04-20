import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bhada24_sp/core/theme/app_colors.dart';
import 'package:bhada24_sp/core/di/service_locator.dart';
import 'package:bhada24_sp/domain/repositories/i_service_provider_repository.dart';
import 'package:bhada24_sp/presentation/providers/auth_provider.dart';
import 'package:bhada24_sp/presentation/providers/locale_provider.dart';
import 'package:bhada24_sp/presentation/widgets/common/app_header.dart';
import 'package:bhada24_sp/presentation/widgets/common/confirm_popup.dart';
import 'package:bhada24_sp/presentation/widgets/common/toast_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _mobileNotif = true;
  bool _emailNotif = true;

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: const AppHeader(title: 'Settings'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('Language'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _cardDecor(),
            child: Row(
              children: [
                const Icon(Icons.language, color: AppColors.primary),
                const SizedBox(width: 12),
                const Expanded(child: Text('App Language', style: TextStyle(fontWeight: FontWeight.w600))),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'en', label: Text('English')),
                    ButtonSegment(value: 'hi', label: Text('हिंदी')),
                  ],
                  selected: {localeProvider.locale.languageCode},
                  onSelectionChanged: (v) async {
                    localeProvider.setLocale(v.first);
                    final spId = auth.user?.spId;
                    if (spId != null) {
                      await getIt<IServiceProviderRepository>().updateLanguage(spId, v.first);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _section('Notifications'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: _cardDecor(),
            child: Column(children: [
              SwitchListTile(
                title: const Text('Mobile Notifications'),
                value: _mobileNotif,
                onChanged: (v) => setState(() => _mobileNotif = v),
                contentPadding: EdgeInsets.zero,
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Email Notifications'),
                value: _emailNotif,
                onChanged: (v) => setState(() => _emailNotif = v),
                contentPadding: EdgeInsets.zero,
              ),
            ]),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () async {
                final spId = auth.user?.spId;
                if (spId != null) {
                  await getIt<IServiceProviderRepository>().updateNotificationSettings(spId, _mobileNotif, _emailNotif);
                  if (mounted) showAppToast(context, 'Settings saved!');
                }
              },
              child: const Text('Save Notification Settings'),
            ),
          ),
          const SizedBox(height: 16),

          _section('Account'),
          Container(
            decoration: _cardDecor(),
            child: Column(children: [
              ListTile(
                leading: const Icon(Icons.phone_android, color: AppColors.primary),
                title: const Text('Change Mobile'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/change-mobile'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.block, color: AppColors.warning),
                title: const Text('Deactivate Account'),
                onTap: () async {
                  final confirm = await ConfirmPopup.show(context,
                      title: 'Deactivate Account', message: 'Your account will be temporarily deactivated.', confirmColor: AppColors.warning);
                  if (confirm == true) {
                    final spId = auth.user?.spId;
                    if (spId != null) {
                      await getIt<IServiceProviderRepository>().deactivate(spId);
                      if (mounted) {
                        await auth.logout();
                        context.go('/login');
                      }
                    }
                  }
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: AppColors.error),
                title: const Text('Delete Account', style: TextStyle(color: AppColors.error)),
                onTap: () async {
                  final confirm = await ConfirmPopup.show(context,
                      title: 'Delete Account', message: 'This is permanent and cannot be undone!', confirmColor: AppColors.error, confirmText: 'Delete');
                  if (confirm == true) {
                    final spId = auth.user?.spId;
                    if (spId != null) {
                      await getIt<IServiceProviderRepository>().deleteAccount(spId);
                      if (mounted) {
                        await auth.logout();
                        context.go('/login');
                      }
                    }
                  }
                },
              ),
            ]),
          ),
          const SizedBox(height: 16),

          _section('About'),
          Container(
            decoration: _cardDecor(),
            child: Column(children: [
              ListTile(leading: const Icon(Icons.privacy_tip_outlined), title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right), onTap: () => context.push('/privacy-policy')),
              const Divider(height: 1),
              ListTile(leading: const Icon(Icons.description_outlined), title: const Text('Terms & Conditions'),
                  trailing: const Icon(Icons.chevron_right), onTap: () => context.push('/terms-and-conditions')),
            ]),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      );

  BoxDecoration _cardDecor() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      );
}
