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

  runApp(const _BootstrapApp());
}

class _BootstrapApp extends StatefulWidget {
  const _BootstrapApp();

  @override
  State<_BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<_BootstrapApp> {
  bool _ready = false;
  Object? _error;
  AuthProvider? _authProvider;
  LocaleProvider? _localeProvider;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Initialize Firebase
      await FirebaseConfig.initialize();

      // Setup dependency injection
      await setupServiceLocator();

      // Load saved user
      _authProvider = getIt<AuthProvider>();
      await _authProvider!.loadUser();

      // Load locale
      _localeProvider = getIt<LocaleProvider>();
      await _localeProvider!.loadSavedLocale();

      if (!mounted) return;
      setState(() => _ready = true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'App failed to start.\n$_error',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

    if (!_ready || _authProvider == null || _localeProvider == null) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider!),
        ChangeNotifierProvider(create: (_) => getIt<DashboardProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<EventServiceProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<CategoryProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<NotificationProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<LeadProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<MembershipProvider>()),
        ChangeNotifierProvider.value(value: _localeProvider!),
        ChangeNotifierProvider(create: (_) => getIt<BookingProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<ServiceProviderState>()),
      ],
      child: const Bhada24SpApp(),
    );
  }
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
