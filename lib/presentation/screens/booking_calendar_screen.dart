import 'package:flutter/material.dart';
import 'package:bhada24_sp/core/theme/app_colors.dart';
import 'package:bhada24_sp/presentation/widgets/common/app_header.dart';
import 'package:bhada24_sp/presentation/widgets/common/bottom_nav.dart';

class BookingCalendarScreen extends StatelessWidget {
  const BookingCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Booking Calendar', showBack: false),
      bottomNavigationBar: const BottomNav(),
      body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.calendar_month, size: 64, color: AppColors.primary),
                ),
                const SizedBox(height: 20),
                const Text('Booking Calendar', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'View and manage your booking calendar here. Upcoming bookings will appear in this section.',
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
