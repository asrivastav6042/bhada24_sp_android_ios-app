import 'package:dio/dio.dart';
import 'auth_interceptor.dart';

/// Singleton Dio HTTP client with auth interceptor.
class ApiClient {
  static ApiClient? _instance;
  late final Dio dio;

  ApiClient._() {
    dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
      ),
    );
    dio.interceptors.addAll([
      AuthInterceptor(),
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (o) => print('📡 API: $o'),
      ),
    ]);
  }

  factory ApiClient() {
    _instance ??= ApiClient._();
    return _instance!;
  }

  // GET
  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      dio.get(url, queryParameters: queryParameters, options: options);

  // POST
  Future<Response> post(
    String url, {
    dynamic data,
    Options? options,
  }) =>
      dio.post(url, data: data, options: options);

  // PUT
  Future<Response> put(
    String url, {
    dynamic data,
    Options? options,
  }) =>
      dio.put(url, data: data, options: options);

  // PATCH
  Future<Response> patch(
    String url, {
    dynamic data,
    Options? options,
  }) =>
      dio.patch(url, data: data, options: options);

  // DELETE
  Future<Response> delete(
    String url, {
    dynamic data,
    Options? options,
  }) =>
      dio.delete(url, data: data, options: options);
}
