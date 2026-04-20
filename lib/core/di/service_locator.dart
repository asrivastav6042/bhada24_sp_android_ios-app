import 'package:get_it/get_it.dart';
import 'package:bhada24_sp/core/network/api_client.dart';

// Domain interfaces
import 'package:bhada24_sp/domain/repositories/i_auth_repository.dart';
import 'package:bhada24_sp/domain/repositories/i_service_provider_repository.dart';
import 'package:bhada24_sp/domain/repositories/i_event_service_repository.dart';
import 'package:bhada24_sp/domain/repositories/i_category_repository.dart';
import 'package:bhada24_sp/domain/repositories/i_notification_repository.dart';
import 'package:bhada24_sp/domain/repositories/i_lead_repository.dart';
import 'package:bhada24_sp/domain/repositories/i_membership_repository.dart';
import 'package:bhada24_sp/domain/repositories/i_availability_repository.dart';
import 'package:bhada24_sp/domain/repositories/i_booking_repository.dart';

// Data implementations
import 'package:bhada24_sp/data/repositories/auth_repository_impl.dart';
import 'package:bhada24_sp/data/repositories/service_provider_repository_impl.dart';
import 'package:bhada24_sp/data/repositories/event_service_repository_impl.dart';
import 'package:bhada24_sp/data/repositories/category_repository_impl.dart';
import 'package:bhada24_sp/data/repositories/notification_repository_impl.dart';
import 'package:bhada24_sp/data/repositories/lead_repository_impl.dart';
import 'package:bhada24_sp/data/repositories/membership_repository_impl.dart';
import 'package:bhada24_sp/data/repositories/availability_repository_impl.dart';
import 'package:bhada24_sp/data/repositories/booking_repository_impl.dart';

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

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Core
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());

  // Repositories (Dependency Inversion: depend on abstractions)
  getIt.registerLazySingleton<IAuthRepository>(
      () => AuthRepositoryImpl(getIt<ApiClient>()));
  getIt.registerLazySingleton<IServiceProviderRepository>(
      () => ServiceProviderRepositoryImpl(getIt<ApiClient>()));
  getIt.registerLazySingleton<IEventServiceRepository>(
      () => EventServiceRepositoryImpl(getIt<ApiClient>()));
  getIt.registerLazySingleton<ICategoryRepository>(
      () => CategoryRepositoryImpl(getIt<ApiClient>()));
  getIt.registerLazySingleton<INotificationRepository>(
      () => NotificationRepositoryImpl(getIt<ApiClient>()));
  getIt.registerLazySingleton<ILeadRepository>(
      () => LeadRepositoryImpl(getIt<ApiClient>()));
  getIt.registerLazySingleton<IMembershipRepository>(
      () => MembershipRepositoryImpl(getIt<ApiClient>()));
  getIt.registerLazySingleton<IAvailabilityRepository>(
      () => AvailabilityRepositoryImpl(getIt<ApiClient>()));
  getIt.registerLazySingleton<IBookingRepository>(
      () => BookingRepositoryImpl(getIt<ApiClient>()));

  // Providers
  getIt.registerFactory<AuthProvider>(
      () => AuthProvider(getIt<IAuthRepository>()));
  getIt.registerFactory<DashboardProvider>(() => DashboardProvider(
        getIt<IServiceProviderRepository>(),
        getIt<IMembershipRepository>(),
      ));
  getIt.registerFactory<EventServiceProvider>(
      () => EventServiceProvider(getIt<IEventServiceRepository>()));
  getIt.registerFactory<CategoryProvider>(
      () => CategoryProvider(getIt<ICategoryRepository>()));
  getIt.registerFactory<NotificationProvider>(
      () => NotificationProvider(getIt<INotificationRepository>()));
  getIt.registerFactory<LeadProvider>(
      () => LeadProvider(getIt<ILeadRepository>()));
  getIt.registerFactory<MembershipProvider>(
      () => MembershipProvider(getIt<IMembershipRepository>()));
  getIt.registerFactory<LocaleProvider>(() => LocaleProvider());
  getIt.registerFactory<BookingProvider>(
      () => BookingProvider(getIt<IBookingRepository>()));
  getIt.registerFactory<ServiceProviderState>(
      () => ServiceProviderState(getIt<IServiceProviderRepository>()));
}
