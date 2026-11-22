import 'package:dio/dio.dart';
import 'auth_interceptor.dart';
import '../../data/services/token_storage.dart';

Dio createMovieLogClient() => Dio(
  BaseOptions(
    baseUrl: 'https://workbook.devnoco.com',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ),
);

Dio createAuthenticatedMovieLogClient(TokenStorage storage) => Dio(
  BaseOptions(
    baseUrl: 'https://workbook.devnoco.com',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ),
)..interceptors.add(AuthInterceptor(storage));
