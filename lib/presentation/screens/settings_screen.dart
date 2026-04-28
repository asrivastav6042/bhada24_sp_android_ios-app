import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bhada24_sp/core/theme/app_colors.dart';
import 'package:bhada24_sp/core/theme/app_text_styles.dart';
import 'package:bhada24_sp/core/di/service_locator.dart';
import 'package:bhada24_sp/core/utils/extensions.dart';
import 'package:bhada24_sp/domain/repositories/i_service_provider_repository.dart';
import 'package:bhada24_sp/presentation/providers/auth_provider.dart';
import 'package:bhada24_sp/presentation/providers/locale_provider.dart';
import 'package:bhada24_sp/presentation/widgets/common/bottom_nav.dart';
import 'package:bhada24_sp/presentation/widgets/common/confirm_popup.dart';

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
    final user = auth.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          context.t('settings.title', fallback: 'Settings'),
          style: AppTextStyles.labelLarge.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          Container(
            decoration: _cardDecor(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFF7466D7),
                    child: Text(
                      (user?.name?.isNotEmpty == true)
                          ? user!.name!.substring(0, 1).toUpperCase()
                          : 'U',
                      style: AppTextStyles.headingSmall.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'User',
                          style: AppTextStyles.labelLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? '',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/profile'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF7466D7),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: Text(
                      context.t('common.edit', fallback: 'Edit'),
                      style: AppTextStyles.labelLarge.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF7466D7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _section(context.t('settings.account', fallback: 'ACCOUNT')),
          Container(
            decoration: _cardDecor(),
            child: Column(
              children: [
                _settingsRow(
                  icon: Icons.delete,
                  iconBg: const Color(0xFFFFEBEB),
                  iconColor: AppColors.error,
                  label: context.t(
                    'settings.deactivate_account',
                    fallback: 'Deactivate Account',
                  ),
                  onTap: () async {
                    final confirm = await ConfirmPopup.show(
                      context,
                      title: context.t(
                        'settings.deactivate_account',
                        fallback: 'Confirm Account Deactivation',
                      ),
                      message: context.t(
                        'settings.deactivate_confirm',
                        fallback:
                            'Your account will be temporarily deactivated.',
                      ),
                      confirmColor: AppColors.warning,
                    );
                    if (confirm == true) {
                      final spId = auth.user?.spId;
                      if (spId != null) {
                        await getIt<IServiceProviderRepository>().deactivate(
                          spId,
                        );
                        if (mounted) {
                          await auth.logout();
                          context.go('/login');
                        }
                      }
                    }
                  },
                ),
                const Divider(height: 1),
                _settingsRow(
                  icon: Icons.logout,
                  iconBg: const Color(0xFFFFEBEB),
                  iconColor: AppColors.error,
                  label: context.t('auth.logout', fallback: 'Logout'),
                  onTap: () async {
                    await auth.logout();
                    if (mounted) context.go('/login');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _section(context.t('settings.preferences', fallback: 'PREFERENCES')),
          Container(
            decoration: _cardDecor(),
            child: Column(
              children: [
                _settingsRow(
                  icon: Icons.translate,
                  iconBg: const Color(0xFFF1EDFF),
                  iconColor: const Color(0xFF7A65D4),
                  label: context.t('settings.language', fallback: 'Language'),
                  trailing: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F7),
                      borderRadius: BorderRadius.circular(0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _langToggle(
                          label: 'EN',
                          active: localeProvider.isEnglish,
                          onTap: () async {
                            await localeProvider.setLocale('en');
                            final spId = auth.user?.spId;
                            if (spId != null) {
                              await getIt<IServiceProviderRepository>()
                                  .updateLanguage(spId, 'en');
                            }
                          },
                        ),
                        _langToggle(
                          label: 'हिन्दी',
                          active: localeProvider.isHindi,
                          onTap: () async {
                            await localeProvider.setLocale('hi');
                            final spId = auth.user?.spId;
                            if (spId != null) {
                              await getIt<IServiceProviderRepository>()
                                  .updateLanguage(spId, 'hi');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  onTap: () {},
                ),
                const Divider(height: 1),
                _settingsRow(
                  icon: Icons.email,
                  iconBg: const Color(0xFFF1EDFF),
                  iconColor: const Color(0xFF7A65D4),
                  label: context.t(
                    'settings.email_notifications',
                    fallback: 'Email Notifications',
                  ),
                  trailing: Switch(
                    value: _emailNotif,
                    onChanged: (v) async {
                      setState(() => _emailNotif = v);
                      final spId = auth.user?.spId;
                      if (spId != null) {
                        await getIt<IServiceProviderRepository>()
                            .updateNotificationSettings(
                              spId,
                              _mobileNotif,
                              _emailNotif,
                            );
                      }
                    },
                  ),
                  onTap: () => setState(() => _emailNotif = !_emailNotif),
                ),
                const Divider(height: 1),
                _settingsRow(
                  icon: Icons.phone_android,
                  iconBg: const Color(0xFFF1EDFF),
                  iconColor: const Color(0xFF7A65D4),
                  label: context.t(
                    'settings.mobile_notifications',
                    fallback: 'Mobile Notifications',
                  ),
                  trailing: Switch(
                    value: _mobileNotif,
                    onChanged: (v) async {
                      setState(() => _mobileNotif = v);
                      final spId = auth.user?.spId;
                      if (spId != null) {
                        await getIt<IServiceProviderRepository>()
                            .updateNotificationSettings(
                              spId,
                              _mobileNotif,
                              _emailNotif,
                            );
                      }
                    },
                  ),
                  onTap: () => setState(() => _mobileNotif = !_mobileNotif),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _section(context.t('settings.support', fallback: 'SUPPORT')),
          Container(
            decoration: _cardDecor(),
            child: Column(
              children: [
                _settingsRow(
                  icon: Icons.email,
                  iconBg: const Color(0xFFF1EDFF),
                  iconColor: const Color(0xFF7A65D4),
                  label: context.t(
                    'settings.contact_support',
                    fallback: 'Contact Support',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/contact'),
                ),
                const Divider(height: 1),
                _settingsRow(
                  icon: Icons.info,
                  iconBg: const Color(0xFFF1EDFF),
                  iconColor: const Color(0xFF7A65D4),
                  label: context.t(
                    'settings.privacy_policy',
                    fallback: 'Privacy Policy',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/privacy-policy'),
                ),
                const Divider(height: 1),
                _settingsRow(
                  icon: Icons.info,
                  iconBg: const Color(0xFFF1EDFF),
                  iconColor: const Color(0xFF7A65D4),
                  label: context.t(
                    'settings.terms_conditions',
                    fallback: 'Terms & Conditions',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/terms-and-conditions'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              '${context.t('settings.version', fallback: 'Version')} 1.0.0',
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFFA0A8B8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 6, left: 2),
    child: Text(
      title,
      style: AppTextStyles.caption.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    ),
  );

  Widget _settingsRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.center,
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _langToggle({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF7466D7) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: active ? Colors.white : const Color(0xFF68768E),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  BoxDecoration _cardDecor() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10),
    boxShadow: [
      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
    ],
  );
}
