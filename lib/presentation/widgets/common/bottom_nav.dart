import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bhada24_sp/core/theme/app_colors.dart';
import 'package:bhada24_sp/core/utils/extensions.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final items = [
      _NavItem(
        icon: Icons.home_rounded,
        label: context.t('bottom_nav.home', fallback: 'Home'),
        path: '/dashboard',
      ),
      _NavItem(
        icon: Icons.add_circle_rounded,
        label: context.t('services.add_service', fallback: 'Add Service'),
        path: '/add-service',
      ),
      _NavItem(
        icon: Icons.build_rounded,
        label: context.t('bottom_nav.manage', fallback: 'Manage'),
        path: '/manage',
      ),
      _NavItem(
        icon: Icons.calendar_month_rounded,
        label: context.t('bottom_nav.bookings', fallback: 'Bookings'),
        path: '/booking-calendar',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bottomNavBg,
        border: Border(
          top: BorderSide(
            color: AppColors.bottomNavGray.withValues(alpha: 0.18),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:
                items.map((item) {
                  final isActive = location == item.path;
                  return Expanded(
                    child: InkWell(
                      onTap: () => context.go(item.path),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color:
                              isActive
                                  ? const Color(0xFF303542)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              item.icon,
                              size: isActive ? 26 : 22,
                              color:
                                  isActive
                                      ? AppColors.bottomNavActive
                                      : AppColors.bottomNavInactive,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 13 * 0.75,
                                fontWeight:
                                    isActive
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                color:
                                    isActive
                                        ? AppColors.bottomNavActive
                                        : AppColors.bottomNavGray,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String path;
  const _NavItem({required this.icon, required this.label, required this.path});
}
