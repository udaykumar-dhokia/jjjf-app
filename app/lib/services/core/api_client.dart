import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  // Singleton pattern so we don't recreate Dio instances across the app
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  ApiClient._internal()
      : _dio = Dio(BaseOptions(
          baseUrl: dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:3333/api',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        )),
        _storage = const FlutterSecureStorage() {
    _initializeInterceptors();
  }

  Dio get dio => _dio;
  FlutterSecureStorage get storage => _storage;

  void _initializeInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Automatically inject the JWT token into every request
          final token = await _storage.read(key: 'accessToken');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Handle 401 Unauthorized globally (e.g., refresh token logic goes here)
          return handler.next(e);
        },
      ),
    );
  }
}
