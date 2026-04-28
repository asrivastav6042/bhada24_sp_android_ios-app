import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bhada24_sp/presentation/providers/auth_provider.dart';

// Screens
import 'package:bhada24_sp/presentation/screens/splash_screen.dart';
import 'package:bhada24_sp/presentation/screens/login_screen.dart';
import 'package:bhada24_sp/presentation/screens/register_screen.dart';
import 'package:bhada24_sp/presentation/screens/forgot_password_screen.dart';
import 'package:bhada24_sp/presentation/screens/dashboard_screen.dart';
import 'package:bhada24_sp/presentation/screens/profile_screen.dart';
import 'package:bhada24_sp/presentation/screens/add_service_screen.dart';
import 'package:bhada24_sp/presentation/screens/add_listing_service_screen.dart';
import 'package:bhada24_sp/presentation/screens/edit_listing_service_screen.dart';
import 'package:bhada24_sp/presentation/screens/manage_screen.dart';
import 'package:bhada24_sp/presentation/screens/manage_listing_services_screen.dart';
import 'package:bhada24_sp/presentation/screens/view_my_services_screen.dart';
import 'package:bhada24_sp/presentation/screens/booking_calendar_screen.dart';
import 'package:bhada24_sp/presentation/screens/mark_busy_screen.dart';
import 'package:bhada24_sp/presentation/screens/membership_screen.dart';
import 'package:bhada24_sp/presentation/screens/settings_screen.dart';
import 'package:bhada24_sp/presentation/screens/notifications_screen.dart';
import 'package:bhada24_sp/presentation/screens/leads_screen.dart';
import 'package:bhada24_sp/presentation/screens/contact_screen.dart';
import 'package:bhada24_sp/presentation/screens/change_mobile_screen.dart';
import 'package:bhada24_sp/presentation/screens/privacy_policy_screen.dart';
import 'package:bhada24_sp/presentation/screens/terms_conditions_screen.dart';

class AppRouter {
  AppRouter._();

  static GoRouter router(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return GoRouter(
      initialLocation: '/login',
      debugLogDiagnostics: true,
      redirect: (context, state) {
        final isLoggedIn = auth.user != null;
        final isAuthRoute = state.uri.path == '/login' ||
            state.uri.path == '/register' ||
            state.uri.path == '/forgot-password' ||
            state.uri.path == '/privacy-policy' ||
            state.uri.path == '/terms-and-conditions';

        if (!isLoggedIn && !isAuthRoute) return '/login';
        if (isLoggedIn && state.uri.path == '/login') {
          return '/dashboard';
        }
        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
        GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
        GoRoute(
          path: '/dashboard',
          pageBuilder: (_, __) => _noTransitionPage(const DashboardScreen()),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (_, __) => _noTransitionPage(const ProfileScreen()),
        ),
        GoRoute(
          path: '/add-service',
          pageBuilder: (_, __) => _noTransitionPage(const AddServiceScreen()),
        ),
        GoRoute(path: '/add-listing-service', builder: (_, __) => const AddListingServiceScreen()),
        GoRoute(
          path: '/edit-listing-service/:esId',
          builder: (_, state) => EditListingServiceScreen(esId: state.pathParameters['esId']!),
        ),
        GoRoute(
          path: '/manage',
          pageBuilder: (_, __) => _noTransitionPage(const ManageScreen()),
        ),
        GoRoute(path: '/manage-listing-services', builder: (_, __) => const ManageListingServicesScreen()),
        GoRoute(path: '/view-my-services', builder: (_, __) => const ViewMyServicesScreen()),
        GoRoute(
          path: '/booking-calendar',
          pageBuilder: (_, __) => _noTransitionPage(const BookingCalendarScreen()),
        ),
        GoRoute(path: '/mark-busy', builder: (_, __) => const MarkBusyScreen()),
        GoRoute(path: '/membership', builder: (_, __) => const MembershipScreen()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
        GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
        GoRoute(path: '/leads', builder: (_, __) => const LeadsScreen()),
        GoRoute(path: '/contact', builder: (_, __) => const ContactScreen()),
        GoRoute(path: '/change-mobile', builder: (_, __) => const ChangeMobileScreen()),
        GoRoute(path: '/privacy-policy', builder: (_, __) => const PrivacyPolicyScreen()),
        GoRoute(path: '/terms-and-conditions', builder: (_, __) => const TermsConditionsScreen()),
      ],
    );
  }

  static CustomTransitionPage<void> _noTransitionPage(Widget child) {
    return CustomTransitionPage<void>(
      child: child,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      transitionsBuilder: (_, __, ___, child) => child,
    );
  }
}
