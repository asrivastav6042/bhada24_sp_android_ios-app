// App-wide constants and configuration

class AppConfig {
  AppConfig._();

  static const String appName = 'Bhada24 SP';
  static const String appVersion = '1.0.0';
  static const String logoUrl =
      'https://res.cloudinary.com/djapc6r8k/image/upload/v1767765389/s3hzcv0bjptuadgzqven.png';
  static const String countryCode = '+91';
  static const int phoneLength = 10;
  static const int otpLength = 6;
  static const Duration tokenRefreshInterval = Duration(minutes: 55);
  static const Duration categoryCacheDuration = Duration(minutes: 5);
  static const Duration toastDuration = Duration(seconds: 5);
  static const int maxImageSizeMb = 5;
}
