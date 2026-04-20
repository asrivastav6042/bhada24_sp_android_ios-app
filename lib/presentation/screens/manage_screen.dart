import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bhada24_sp/core/theme/app_colors.dart';
import 'package:bhada24_sp/presentation/widgets/common/app_header.dart';
import 'package:bhada24_sp/presentation/widgets/common/bottom_nav.dart';
import 'package:bhada24_sp/presentation/widgets/common/menu_card.dart';

class ManageScreen extends StatelessWidget {
  const ManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Manage', showBack: false),
      bottomNavigationBar: const BottomNav(),
      body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Manage Your Business', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text('Access all management tools here', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                const SizedBox(height: 24),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    MenuCard(icon: Icons.list_alt_rounded, iconColor: AppColors.primaryLight, label: 'Listing Services', onTap: () => context.push('/manage-listing-services')),
                    MenuCard(icon: Icons.visibility, iconColor: AppColors.accent, label: 'View My Services', onTap: () => context.push('/view-my-services')),
                    MenuCard(icon: Icons.event_busy_rounded, iconColor: AppColors.warning, label: 'Mark Busy', onTap: () => context.push('/mark-busy')),
                    MenuCard(icon: Icons.calendar_month_rounded, iconColor: AppColors.info, label: 'Booking Calendar', onTap: () => context.push('/booking-calendar')),
                    MenuCard(icon: Icons.person_outline, iconColor: AppColors.accentLight, label: 'Profile', onTap: () => context.push('/profile')),
                    MenuCard(icon: Icons.settings_outlined, iconColor: AppColors.textSecondary, label: 'Settings', onTap: () => context.push('/settings')),
                  ],
                ),
              ],
            ),
          ),
    );
  }
}
