import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bhada24_sp/core/theme/app_colors.dart';
import 'package:bhada24_sp/core/utils/extensions.dart';
import 'package:bhada24_sp/data/models/service_provider_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserSidebar extends StatelessWidget {
  final ServiceProviderModel user;
  final VoidCallback onLogout;
  final VoidCallback onClose;

  const UserSidebar({
    super.key,
    required this.user,
    required this.onLogout,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final sidebarWidth = (MediaQuery.of(context).size.width * 0.72).clamp(
      280.0,
      340.0,
    );
    final userCode =
        user.spId != null
            ? 'SP${user.spId.toString().padLeft(4, '0')}'
            : 'SP0000';

    return Container(
      width: sidebarWidth,
      height: double.infinity,
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // User header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: onClose,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F4F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFF64748B),
                      size: 34,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Column(
                children: [
                  Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F9FC),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFD5DFEB),
                        width: 3,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFFE9EFF7),
                      backgroundImage:
                          user.imageUrl != null &&
                                  user.imageUrl!.isNotEmpty &&
                                  user.imageUrl != 'null'
                              ? CachedNetworkImageProvider(user.imageUrl!)
                              : null,
                      child:
                          user.imageUrl == null ||
                                  user.imageUrl!.isEmpty ||
                                  user.imageUrl == 'null'
                              ? Text(
                                (user.name ?? 'U').initials,
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF9AA8BA),
                                ),
                              )
                              : null,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user.name ?? 'User',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24 * 0.75,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if ((user.email ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        user.email!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14 * 0.75,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  if ((user.phone ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '+91 ${user.phone}',
                        style: const TextStyle(
                          fontSize: 14 * 0.75,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F6FA),
                      border: Border.all(color: const Color(0xFFDDE4EE)),
                    ),
                    child: Text(
                      'ID: $userCode',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4A5568),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF6DB),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFF1C54B),
                        width: 1.5,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Color(0xFFE1BF66), size: 18),
                        SizedBox(width: 4),
                        Icon(Icons.star, color: Color(0xFFE1BF66), size: 18),
                        SizedBox(width: 4),
                        Icon(Icons.star, color: Color(0xFFE1BF66), size: 18),
                        SizedBox(width: 4),
                        Icon(Icons.star, color: Color(0xFFE1BF66), size: 18),
                        SizedBox(width: 4),
                        Icon(Icons.star, color: Color(0xFFE1BF66), size: 18),
                        SizedBox(width: 8),
                        Text(
                          '0.0/5',
                          style: TextStyle(
                            color: Color(0xFF8B4B1B),
                            fontSize: 16 * 0.75,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),
            // Menu items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  _MenuItem(
                    icon: Icons.manage_accounts,
                    label: context.t(
                      'user_sidebar.manage_profile',
                      fallback: 'Manage Profile',
                    ),
                    onTap: () {
                      onClose();
                      context.push('/profile');
                    },
                  ),
                  _MenuItem(
                    icon: Icons.add_circle,
                    label: context.t(
                      'services.add_service',
                      fallback: 'Add Service',
                    ),
                    onTap: () {
                      onClose();
                      context.push('/add-service');
                    },
                  ),
                  _MenuItem(
                    icon: Icons.handyman,
                    label: context.t(
                      'manage.manage_services',
                      fallback: 'Manage Services',
                    ),
                    onTap: () {
                      onClose();
                      context.push('/manage');
                    },
                  ),
                  _MenuItem(
                    icon: Icons.card_membership,
                    label: context.t(
                      'user_sidebar.membership',
                      fallback: 'Membership',
                    ),
                    onTap: () {
                      onClose();
                      context.push('/membership');
                    },
                  ),
                  _MenuItem(
                    icon: Icons.support_agent,
                    label: context.t(
                      'user_sidebar.customer_support',
                      fallback: 'Customer Support',
                    ),
                    onTap: () {
                      onClose();
                      context.push('/contact');
                    },
                  ),
                  _MenuItem(
                    icon: Icons.settings,
                    label: context.t(
                      'user_sidebar.settings',
                      fallback: 'Settings',
                    ),
                    onTap: () {
                      onClose();
                      context.push('/settings');
                    },
                  ),
                  const SizedBox(height: 14),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(color: AppColors.divider),
                  ),
                  _MenuItem(
                    icon: Icons.logout,
                    label: context.t('user_sidebar.logout', fallback: 'Logout'),
                    color: AppColors.error,
                    onTap: onLogout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? const Color(0xFF71839E),
        size: 34 * 0.75,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 22 * 0.75,
          fontWeight: FontWeight.w700,
          color: color ?? AppColors.textPrimary,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 2),
    );
  }
}
