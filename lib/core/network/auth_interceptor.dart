import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Interceptor that automatically attaches Firebase ID token
/// to every API request and handles 401 token refresh.
class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final token = await user.getIdToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      }
    } catch (e) {
      // Continue without token if error
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Force refresh the token
          final newToken = await user.getIdToken(true);
          if (newToken != null && newToken.isNotEmpty) {
            // Retry the request with new token
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newToken';
            final response = await Dio().fetch(options);
            return handler.resolve(response);
          }
        }
      } catch (_) {
        // If refresh fails, propagate original error
      }
    }
    handler.next(err);
  }
}
