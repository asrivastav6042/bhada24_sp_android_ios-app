import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bhada24_sp/core/config/firebase_config.dart';
import 'package:bhada24_sp/core/di/service_locator.dart';
import 'package:bhada24_sp/core/theme/app_theme.dart';
import 'package:bhada24_sp/app.dart';

// Providers
import 'package:bhada24_sp/presentation/providers/auth_provider.dart';
import 'package:bhada24_sp/presentation/providers/dashboard_provider.dart';
import 'package:bhada24_sp/presentation/providers/event_service_provider.dart';
import 'package:bhada24_sp/presentation/providers/category_provider.dart';
import 'package:bhada24_sp/presentation/providers/notification_provider.dart';
import 'package:bhada24_sp/presentation/providers/lead_provider.dart';
import 'package:bhada24_sp/presentation/providers/membership_provider.dart';
import 'package:bhada24_sp/presentation/providers/locale_provider.dart';
import 'package:bhada24_sp/presentation/providers/booking_provider.dart';
import 'package:bhada24_sp/presentation/providers/service_provider_state.dart';
import 'package:bhada24_sp/core/localization/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await FirebaseConfig.initialize();

  // Setup dependency injection
  await setupServiceLocator();

  // Load saved user
  final authProvider = getIt<AuthProvider>();
  await authProvider.loadUser();

  // Load locale
  final localeProvider = getIt<LocaleProvider>();
  await localeProvider.loadSavedLocale();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => getIt<DashboardProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<EventServiceProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<CategoryProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<NotificationProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<LeadProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<MembershipProvider>()),
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider(create: (_) => getIt<BookingProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<ServiceProviderState>()),
      ],
      child: const Bhada24SpApp(),
    ),
  );
}

class Bhada24SpApp extends StatelessWidget {
  const Bhada24SpApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp.router(
      title: 'Bhada24 SP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: localeProvider.locale,
      builder: (context, child) {
        if (child != null) return child;
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: AppRouter.router(context),
    );
  }
}
