import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bhada24_sp/core/theme/app_colors.dart';
import 'package:bhada24_sp/core/di/service_locator.dart';
import 'package:bhada24_sp/core/utils/extensions.dart';
import 'package:bhada24_sp/domain/repositories/i_service_provider_repository.dart';
import 'package:bhada24_sp/presentation/providers/auth_provider.dart';
import 'package:bhada24_sp/presentation/providers/notification_provider.dart';
import 'package:bhada24_sp/presentation/providers/locale_provider.dart';
import 'package:bhada24_sp/presentation/widgets/common/bottom_nav.dart';
import 'package:bhada24_sp/presentation/widgets/common/user_sidebar.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _sidebarOpen = false;
  bool _animateIn = false;

  Future<void> _switchLanguage(String languageCode) async {
    final localeProvider = context.read<LocaleProvider>();
    await localeProvider.setLocale(languageCode);

    final spId = context.read<AuthProvider>().user?.spId;
    if (spId != null) {
      await getIt<IServiceProviderRepository>().updateLanguage(
        spId,
        languageCode,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _animateIn = true);
      }
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
    final userImage =
        (user?.imageUrl != null &&
                user!.imageUrl != 'null' &&
                user.imageUrl!.isNotEmpty)
            ? user.imageUrl
            : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const BottomNav(),
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: Stack(
                children: [
                  Positioned(
                    top: -80,
                    right: -70,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF7C4DFF).withValues(alpha: 0.16),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 240,
                    left: -90,
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF3B82F6).withValues(alpha: 0.12),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _sidebarOpen = true),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color(0xFFF2F5FA),
                        backgroundImage:
                            userImage != null
                                ? CachedNetworkImageProvider(userImage)
                                : null,
                        child:
                            userImage == null
                                ? Text(
                                  userName.initials,
                                  style: const TextStyle(
                                    color: Color(0xFF7A1F4A),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                )
                                : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        userName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Language switcher
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF2F7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _LangBtn(
                            label: 'EN',
                            isActive: localeProvider.isEnglish,
                            onTap: () => _switchLanguage('en'),
                          ),
                          _LangBtn(
                            label: 'हिं',
                            isActive: localeProvider.isHindi,
                            onTap: () => _switchLanguage('hi'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Notification bell
                    GestureDetector(
                      onTap: () => context.push('/notifications'),
                      child: Container(
                        height: 44,
                        width: 44,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEFF2F7),
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          children: [
                            const Center(
                              child: Icon(
                                Icons.notifications,
                                color: Color(0xFF1F2937),
                                size: 24,
                              ),
                            ),
                            if (notifProvider.unreadCount > 0)
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    color: AppColors.error,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    notifProvider.unreadCount > 99
                                        ? '99+'
                                        : '${notifProvider.unreadCount}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
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
              ),

              // Expanded scroll content - add bottom padding to avoid content hiding behind nav
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome card
                      _AnimatedEntrance(
                        index: 0,
                        animate: _animateIn,
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                          padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
                          decoration: BoxDecoration(
                            gradient: AppColors.welcomeGradient,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryLight.withValues(
                                  alpha: 0.24,
                                ),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${context.t('dashboard.welcome', fallback: 'Welcome')}, ${userName.split(' ').first}! 👋',
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      context.t(
                                        'dashboard.welcome_message',
                                        fallback:
                                            'Manage services, bookings, and grow your business effortlessly.',
                                      ),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white.withValues(alpha: 0.88),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.auto_awesome,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Quick Actions
                      _AnimatedEntrance(
                        index: 1,
                        animate: _animateIn,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: Text(
                            context.t(
                              'dashboard.quick_actions',
                              fallback: 'Quick Actions',
                            ),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            _AnimatedEntrance(
                              index: 2,
                              animate: _animateIn,
                              child: _QuickActionCard(
                                icon: Icons.add_circle,
                                iconColor: AppColors.primaryLight,
                                label: context.t(
                                  'services.add_service',
                                  fallback: 'Add Service',
                                ),
                                subtitle: context.t(
                                  'dashboard.add_new_service',
                                  fallback: 'Create and publish a new listing',
                                ),
                                onTap: () => context.push('/add-service'),
                              ),
                            ),
                            const SizedBox(height: 10),
                            _AnimatedEntrance(
                              index: 3,
                              animate: _animateIn,
                              child: _QuickActionCard(
                                icon: Icons.handyman,
                                iconColor: AppColors.accent,
                                label: context.t(
                                  'manage.title',
                                  fallback: 'Manage',
                                ),
                                subtitle: context.t(
                                  'dashboard.manage_services',
                                  fallback: 'Update or edit your listed services',
                                ),
                                onTap: () => context.push('/manage'),
                              ),
                            ),
                            const SizedBox(height: 10),
                            _AnimatedEntrance(
                              index: 4,
                              animate: _animateIn,
                              child: _QuickActionCard(
                                icon: Icons.calendar_month,
                                iconColor: AppColors.info,
                                label: context.t(
                                  'dashboard.update_calendar',
                                  fallback: 'Update Booking Dates',
                                ),
                                subtitle: context.t(
                                  'dashboard.mark_busy_dates',
                                  fallback: 'Mark availability and blocked days',
                                ),
                                onTap: () => context.push('/mark-busy'),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Leads Card
                      _AnimatedEntrance(
                        index: 5,
                        animate: _animateIn,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                          child: Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            child: InkWell(
                              onTap: () => context.push('/leads'),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 44,
                                      width: 44,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEAF0FA),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        '🎯',
                                        style: TextStyle(fontSize: 19),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            context.t(
                                              'leads.title',
                                              fallback: 'Leads',
                                            ),
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Text(
                                            context.t(
                                              'dashboard.open_leads_page',
                                              fallback:
                                                  'Tap to view all customer leads',
                                            ),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5FB),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.arrow_forward_ios,
                                        color: AppColors.textSecondary,
                                        size: 13,
                                      ),
                                    ),
                                  ],
                                ),
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
  const _LangBtn({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1A2232) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isActive ? Colors.white : const Color(0xFF1A2232),
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.of(context).size.width < 400;
    final iconSize = narrow ? 22.0 : 24.0;
    final labelSize = narrow ? 14.0 : 15.0;
    final tileHeight = narrow ? 78.0 : 84.0;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: tileHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: iconSize, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: labelSize,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5FB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    size: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedEntrance extends StatelessWidget {
  final int index;
  final bool animate;
  final Widget child;

  const _AnimatedEntrance({
    required this.index,
    required this.animate,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final duration = Duration(milliseconds: 360 + (index * 90));

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: animate ? 1 : 0),
      duration: duration,
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 18),
            child: child,
          ),
        );
      },
    );
  }
}
