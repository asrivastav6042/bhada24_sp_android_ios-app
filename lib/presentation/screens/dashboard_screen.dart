import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bhada24_sp/core/theme/app_colors.dart';
import 'package:bhada24_sp/core/utils/extensions.dart';
import 'package:bhada24_sp/presentation/providers/auth_provider.dart';
import 'package:bhada24_sp/presentation/providers/notification_provider.dart';
import 'package:bhada24_sp/presentation/providers/locale_provider.dart';
import 'package:bhada24_sp/presentation/widgets/common/bottom_nav.dart';
import 'package:bhada24_sp/presentation/widgets/common/user_sidebar.dart';
import 'package:bhada24_sp/presentation/widgets/common/menu_card.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _sidebarOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final user = auth.user;
      if (user?.spId != null) {
        context.read<NotificationProvider>().listen(user!.spId!);
        context.read<NotificationProvider>().setupFcm(user.spId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final notifProvider = context.watch<NotificationProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final user = auth.user;
    final userName = user?.name ?? 'User';
    final userImage = (user?.imageUrl != null && user!.imageUrl != 'null' && user.imageUrl!.isNotEmpty)
        ? user.imageUrl
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const BottomNav(),
      body: Stack(
        children: [
          Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: 16,
                  right: 16,
                  bottom: 12,
                ),
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _sidebarOpen = true),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        backgroundImage: userImage != null ? CachedNetworkImageProvider(userImage) : null,
                        child: userImage == null
                            ? Text(userName.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        userName,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Language switcher
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _LangBtn(label: 'EN', isActive: localeProvider.isEnglish,
                              onTap: () => localeProvider.setLocale('en')),
                          _LangBtn(label: 'हिं', isActive: localeProvider.isHindi,
                              onTap: () => localeProvider.setLocale('hi')),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Notification bell
                    GestureDetector(
                      onTap: () => context.push('/notifications'),
                      child: Stack(
                        children: [
                          const Icon(Icons.notifications, color: Colors.white, size: 26),
                          if (notifProvider.unreadCount > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                                child: Text(
                                  notifProvider.unreadCount > 99 ? '99+' : '${notifProvider.unreadCount}',
                                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

          // Expanded scroll content - add bottom padding to avoid content hiding behind nav
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome card
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: AppColors.welcomeGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryLight.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, ${userName.split(' ').first}! 👋',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Manage your services, bookings, and grow your business effortlessly.',
                              style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.85)),
                            ),
                          ],
                        ),
                      ),

                      // Quick Actions
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Quick Actions',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.9,
                          children: [
                            MenuCard(icon: Icons.add_circle_outline, iconColor: AppColors.primaryLight, label: 'Add Service', onTap: () => context.push('/add-service')),
                            MenuCard(icon: Icons.build_outlined, iconColor: AppColors.accent, label: 'Manage', onTap: () => context.push('/manage')),
                            MenuCard(icon: Icons.list_alt, iconColor: AppColors.primaryDark, label: 'My Services', onTap: () => context.push('/view-my-services')),
                            MenuCard(icon: Icons.calendar_month, iconColor: AppColors.info, label: 'Update Calendar', onTap: () => context.push('/mark-busy')),
                            MenuCard(icon: Icons.card_membership, iconColor: AppColors.accentLight, label: 'Membership', onTap: () => context.push('/membership')),
                            MenuCard(icon: Icons.settings, iconColor: AppColors.textSecondary, label: 'Settings', onTap: () => context.push('/settings')),
                          ],
                        ),
                      ),

                      // Leads Card
                      Container(
                        margin: const EdgeInsets.all(16),
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          elevation: 2,
                          shadowColor: Colors.black.withValues(alpha: 0.06),
                          child: InkWell(
                            onTap: () => context.push('/leads'),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  const Text('🎯', style: TextStyle(fontSize: 28)),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Leads', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                        SizedBox(height: 2),
                                        Text('Tap to view all customer leads',
                                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward, color: AppColors.primary),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),


          // Sidebar overlay
          if (_sidebarOpen) ...[
            GestureDetector(
              onTap: () => setState(() => _sidebarOpen = false),
              child: Container(color: Colors.black.withValues(alpha: 0.5)),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: UserSidebar(
                user: user!,
                onLogout: () async {
                  setState(() => _sidebarOpen = false);
                  await auth.logout();
                  if (mounted) context.go('/login');
                },
                onClose: () => setState(() => _sidebarOpen = false),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LangBtn extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _LangBtn({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isActive ? AppColors.primary : Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
