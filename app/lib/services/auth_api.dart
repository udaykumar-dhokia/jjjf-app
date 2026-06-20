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

    if (accessToken != null) {
      await _client.storage.write(key: 'accessToken', value: accessToken);
    }
    if (refreshToken != null) {
      await _client.storage.write(key: 'refreshToken', value: refreshToken);
    }

    return response.data;
  }

  Future<void> logout() async {
    final refreshToken = await _client.storage.read(key: 'refreshToken');
    if (refreshToken != null) {
      try {
        await _client.dio.post(
          '/auth/logout',
          data: {'refreshToken': refreshToken},
        );
      } catch (e) {
        // Ignore errors if token is already invalidated
      }
    }
    await _client.storage.delete(key: 'accessToken');
    await _client.storage.delete(key: 'refreshToken');
  }
}
