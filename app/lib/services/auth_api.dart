import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/api_client.dart';

class AuthApi {
  final ApiClient _client = ApiClient();

  Future<void> sendOtp(String email) async {
    await _client.dio.post('/auth/send-otp', data: {'email': email});
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    final response = await _client.dio.post(
      '/auth/verify-otp',
      data: {'email': email, 'otp': otp},
    );

    final accessToken = response.data['accessToken'];
    final refreshToken = response.data['refreshToken'];
    final isProfileComplete = response.data['isProfileComplete'];

    if (accessToken != null) {
      await _client.storage.write(key: 'accessToken', value: accessToken);
    }
    if (refreshToken != null) {
      await _client.storage.write(key: 'refreshToken', value: refreshToken);
    }
    if (isProfileComplete != null) {
      await _client.storage.write(key: 'isProfileComplete', value: isProfileComplete.toString());
    }

    return response.data;
  }

  Future<Map<String, dynamic>> loginWithPassword(String email, String password) async {
    final response = await _client.dio.post(
      '/auth/login/password',
      data: {'email': email, 'password': password},
    );

    final accessToken = response.data['accessToken'];
    final refreshToken = response.data['refreshToken'];
    final isProfileComplete = response.data['isProfileComplete'];

    if (accessToken != null) {
      await _client.storage.write(key: 'accessToken', value: accessToken);
    }
    if (refreshToken != null) {
      await _client.storage.write(key: 'refreshToken', value: refreshToken);
    }
    if (isProfileComplete != null) {
      await _client.storage.write(key: 'isProfileComplete', value: isProfileComplete.toString());
    }

    return response.data;
  }

  Future<void> logout() async {
    final refreshToken = await _client.storage.read(key: 'refreshToken');
    if (refreshToken != null) {
      try {
        final dioLogout = Dio(BaseOptions(
          baseUrl: dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:3333/api',
        ));
        await dioLogout.post(
          '/auth/logout',
          data: {'refreshToken': refreshToken},
          options: Options(headers: {'Authorization': 'Bearer $refreshToken'}),
        );
      } catch (e) {
        // Ignore errors if token is already invalidated
      }
    }
    await _client.storage.delete(key: 'accessToken');
    await _client.storage.delete(key: 'refreshToken');
    await _client.storage.delete(key: 'isProfileComplete');
  }
}
