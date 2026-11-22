import 'package:dio/dio.dart';

import '../../data/services/token_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage);
  final TokenStorage _storage;
  static const protectedPrefixes = ['/v7/', '/v8/'];
  static bool isProtectedPath(String path) =>
      protectedPrefixes.any(path.startsWith);
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await _storage.read();
      if (isProtectedPath(options.path) && token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    } catch (error) {
      handler.reject(DioException(requestOptions: options, error: error));
    }
  }
}
