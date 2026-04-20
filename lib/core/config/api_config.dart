// Core Config - API Endpoints
// Mapped from React: src/components/config/apiConfig.js

class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'https://bhada24-services.onrender.com/api';

  // Service Provider
  static String getSpById(int id) => '$baseUrl/service-provider/$id';
  static const String registerSp = '$baseUrl/service-provider/register';
  static String deleteSp(int id) => '$baseUrl/service-provider/$id';
  static const String updateSp = '$baseUrl/service-provider/update';
  static String getSpByEmail(String email) =>
      '$baseUrl/service-provider/find/email/$email';
  static String getSpByMobile(String mobile) =>
      '$baseUrl/service-provider/find/$mobile';
  static String deactivateSp(int spId) =>
      '$baseUrl/service-provider/deactivate/$spId';
  static String updateSpLanguage(int spId, String language) =>
      '$baseUrl/service-provider/update/language/$spId?language=${Uri.encodeComponent(language)}';
  static String validateMobile(String mobile) =>
      '$baseUrl/service-provider/validate/$mobile';

  // Notification Settings
  static String updateNotificationSettings(
          int spId, bool mobile, bool email) =>
      '$baseUrl/notification/setting/update/$spId?mobile=$mobile&email=$email';

  // Listing Services (Event Services)
  static const String addListingService = '$baseUrl/listing-services/create';
  static String updateListingService(int esId) =>
      '$baseUrl/listing-services/$esId';
  static String getListingServicesBySpId(int spId) =>
      '$baseUrl/listing-services/sp/$spId';
  static String getListingServiceById(int esId) =>
      '$baseUrl/listing-services/$esId';
  static String deleteListingService(int esId) =>
      '$baseUrl/listing-services/$esId';
  static const String updateBookingStatus =
      '$baseUrl/listing-services/bookings/status';

  // Common
  static const String uploadBase64Image = '$baseUrl/common/uploadBase64Image';

  // FCM Notifications
  static const String registerFcmToken =
      '$baseUrl/common/notifications/register-token';
  static const String updateFcmToken =
      '$baseUrl/common/notifications/update/fcm-token';
  static String getUserTokensStatus(int userId) =>
      '$baseUrl/common/notifications/user/$userId/tokens/status';

  // Availability Exceptions
  static String addAvailabilityException(String serviceType, int serviceId) =>
      '$baseUrl/provider/availability-exceptions/$serviceType/$serviceId';
  static String getAvailabilityExceptions(String serviceType, int serviceId) =>
      '$baseUrl/provider/availability-exceptions/$serviceType/$serviceId';
  static String deleteAvailabilityException(int exceptionId) =>
      '$baseUrl/provider/availability-exceptions/delete/$exceptionId';

  // Categories
  static const String getAllCategories = '$baseUrl/categories';
  static String getCategoryById(int categoryId) =>
      '$baseUrl/categories/$categoryId';
  static String getSubcategories(int categoryId) =>
      '$baseUrl/categories/$categoryId/subcategories';

  // Membership
  static String activateFreeMembership(int spId) =>
      '$baseUrl/membership/activate-free/$spId';
  static String getMembershipStatus(int spId) =>
      '$baseUrl/membership/provider/$spId';

  // Ratings
  static String getProviderAverageRating(int spId) =>
      '$baseUrl/provider/ratings/service/$spId/average';

  // Leads
  static String getLeadsBySpId(int spId) =>
      '$baseUrl/interactions/sp/$spId/leads';

  // Firebase Realtime Database
  static String firebaseNotificationsPath(int userId) =>
      'notifications/$userId';
  static const String firebaseDatabaseUrl =
      'https://bhada24-96846-default-rtdb.asia-southeast1.firebasedatabase.app/';
}
