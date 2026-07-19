import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  ApiClient._internal()
    : _dio = Dio(
        BaseOptions(
          baseUrl: dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:3333/api',
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      ),
      _storage = const FlutterSecureStorage() {
    _initializeInterceptors();
  }

  Dio get dio => _dio;
  FlutterSecureStorage get storage => _storage;

  void _initializeInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'accessToken');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          // Handle 401 Unauthorized globally
          if (e.response?.statusCode == 401) {
            final refreshToken = await _storage.read(key: 'refreshToken');
            if (refreshToken != null) {
              try {
                final dioRefresh = Dio(
                  BaseOptions(
                    baseUrl:
                        dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:3333/api',
                  ),
                );

                final refreshResponse = await dioRefresh.post(
                  '/auth/refresh',
                  data: {'refreshToken': refreshToken},
                );

                final newAccessToken = refreshResponse.data['accessToken'];
                final newRefreshToken = refreshResponse.data['refreshToken'];

                if (newAccessToken != null) {
                  await _storage.write(
                    key: 'accessToken',
                    value: newAccessToken,
                  );
                }
                if (newRefreshToken != null) {
                  await _storage.write(
                    key: 'refreshToken',
                    value: newRefreshToken,
                  );
                }

                final options = e.requestOptions;
                options.headers['Authorization'] = 'Bearer $newAccessToken';

                if (options.data is FormData) {
                  options.data = (options.data as FormData).clone();
                }

                final retryResponse = await _dio.fetch(options);
                return handler.resolve(retryResponse);
              } catch (refreshError) {
                await _storage.delete(key: 'accessToken');
                await _storage.delete(key: 'refreshToken');
                return handler.next(e);
              }
            }
          }
          return handler.next(e);
        },
      ),
    );
  }
}
