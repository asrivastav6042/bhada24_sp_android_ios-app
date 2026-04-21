import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bhada24_sp/core/theme/app_colors.dart';
import 'package:bhada24_sp/presentation/widgets/common/bottom_nav.dart';

class ManageScreen extends StatelessWidget {
  const ManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Manage Services',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(0),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF7084F4), Color(0xFF7A4BC6)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7A4BC6).withValues(alpha: 0.16),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -18,
                    top: -36,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: -30,
                    bottom: -34,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manage Your Services',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Edit, update, or delete your services and\nresources from one place.',
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Your Services',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _ManageServiceTile(
              icon: Icons.calendar_month,
              iconBg: const Color(0xFFFF4DA0),
              title: 'Manage Listings',
              subtitle: 'Manage all your service listings',
              centerContent: true,
              onTap: () => context.push('/manage-listing-services'),
            ),
            const SizedBox(height: 18),
            _ManageServiceTile(
              icon: Icons.visibility,
              iconBg: const Color(0xFF8B5CF6),
              title: 'View My Services',
              subtitle: 'Check all published services and review how your listings appear.',
              onTap: () => context.push('/view-my-services'),
            ),
            const SizedBox(height: 18),
            _ManageServiceTile(
              icon: Icons.event_busy,
              iconBg: const Color(0xFFF59E0B),
              title: 'Mark Busy',
              subtitle: 'Block unavailable dates and avoid unwanted bookings on busy days.',
              onTap: () => context.push('/mark-busy'),
            ),
            const SizedBox(height: 18),
            _ManageServiceTile(
              icon: Icons.calendar_today,
              iconBg: const Color(0xFF3B82F6),
              title: 'Booking Calendar',
              subtitle: 'Track schedules, manage booking activity, and stay organized.',
              onTap: () => context.push('/booking-calendar'),
            ),
            const SizedBox(height: 18),
            _ManageServiceTile(
              icon: Icons.person_outline,
              iconBg: const Color(0xFF06B6D4),
              title: 'Profile',
              subtitle: 'Update your personal and business information whenever needed.',
              onTap: () => context.push('/profile'),
            ),
            const SizedBox(height: 18),
            _ManageServiceTile(
              icon: Icons.settings_outlined,
              iconBg: const Color(0xFF64748B),
              title: 'Settings',
              subtitle: 'Manage app preferences, notifications, and account configuration.',
              onTap: () => context.push('/settings'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManageServiceTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool centerContent;

  const _ManageServiceTile({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.centerContent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: centerContent
              ? Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: iconBg.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: iconBg, size: 26),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: iconBg,
                      ),
                      child: Icon(icon, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
