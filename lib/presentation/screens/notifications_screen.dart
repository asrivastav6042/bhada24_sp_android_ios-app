import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bhada24_sp/core/theme/app_colors.dart';
import 'package:bhada24_sp/core/utils/date_utils.dart' as app_date;
import 'package:bhada24_sp/presentation/providers/auth_provider.dart';
import 'package:bhada24_sp/presentation/providers/notification_provider.dart';
import 'package:bhada24_sp/presentation/widgets/common/app_header.dart';
import 'package:bhada24_sp/presentation/widgets/common/bottom_nav.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifProvider = context.watch<NotificationProvider>();
    final userId = context.read<AuthProvider>().user?.spId;
    final notifications = notifProvider.notifications;

    // Group by date
    final grouped = <String, List<dynamic>>{};
    for (final n in notifications) {
      final dt = n.dateTime;
      final label = dt != null ? app_date.AppDateUtils.getDateLabel(dt) : 'Other';
      grouped.putIfAbsent(label, () => []).add(n);
    }

    return Scaffold(
      appBar: AppHeader(
        title: 'Notifications',
        actions: [
          if (notifications.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Mark all read',
              onPressed: () => userId != null ? notifProvider.markAllAsRead(userId) : null,
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear all',
              onPressed: () => userId != null ? notifProvider.clearAll(userId) : null,
            ),
          ],
        ],
      ),
      bottomNavigationBar: const BottomNav(),
      body: notifProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : notifications.isEmpty
                  ? Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(color: AppColors.background, shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8)]),
                          child: const Icon(Icons.notifications_none, color: AppColors.textLight),
                        ),
                        const SizedBox(height: 12),
                        const Text('No notifications yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      ]),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                      children: grouped.entries.map((entry) {
                        return Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border)),
                              child: Text(entry.key, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
                            ),
                            ...entry.value.map((n) {
                              final timeStr = n.dateTime != null
                                  ? '${n.dateTime!.hour.toString().padLeft(2, '0')}:${n.dateTime!.minute.toString().padLeft(2, '0')}'
                                  : '';
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: n.isRead ? AppColors.border : AppColors.primary, width: n.isRead ? 1 : 2),
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4)],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      if (userId != null) notifProvider.markAsRead(userId, n);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(children: [
                                            Expanded(child: Text(n.displayTitle, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14))),
                                            if (!n.isRead)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
                                                child: const Text('New', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                                              ),
                                          ]),
                                          const SizedBox(height: 4),
                                          Text(n.displayBody, style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
                                          const SizedBox(height: 6),
                                          Text(timeStr, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        );
                      }).toList(),
                    ),
    );
  }
}
