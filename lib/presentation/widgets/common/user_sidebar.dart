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
    return Container(
      width: 280,
      height: double.infinity,
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // User header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: onClose,
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    backgroundImage: user.imageUrl != null &&
                            user.imageUrl!.isNotEmpty &&
                            user.imageUrl != 'null'
                        ? CachedNetworkImageProvider(user.imageUrl!)
                        : null,
                    child: user.imageUrl == null ||
                            user.imageUrl!.isEmpty ||
                            user.imageUrl == 'null'
                        ? Text(
                            (user.name ?? 'U').initials,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.name ?? 'User',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  if (user.phone != null)
                    Text(
                      '+91 ${user.phone}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                ],
              ),
            ),
            // Menu items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _MenuItem(
                    icon: Icons.person_outline,
                    label: 'Profile',
                    onTap: () {
                      onClose();
                      context.push('/profile');
                    },
                  ),
                  _MenuItem(
                    icon: Icons.card_membership,
                    label: 'Membership',
                    onTap: () {
                      onClose();
                      context.push('/membership');
                    },
                  ),
                  _MenuItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: () {
                      onClose();
                      context.push('/settings');
                    },
                  ),
                  _MenuItem(
                    icon: Icons.support_agent,
                    label: 'Contact',
                    onTap: () {
                      onClose();
                      context.push('/contact');
                    },
                  ),
                  _MenuItem(
                    icon: Icons.privacy_tip_outlined,
                    label: 'Privacy Policy',
                    onTap: () {
                      onClose();
                      context.push('/privacy-policy');
                    },
                  ),
                  _MenuItem(
                    icon: Icons.description_outlined,
                    label: 'Terms & Conditions',
                    onTap: () {
                      onClose();
                      context.push('/terms-and-conditions');
                    },
                  ),
                  const Divider(),
                  _MenuItem(
                    icon: Icons.logout,
                    label: 'Logout',
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
      leading: Icon(icon, color: color ?? AppColors.textSecondary),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: color ?? AppColors.textPrimary,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }
}
