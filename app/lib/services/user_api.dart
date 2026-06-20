import '../models/user_model.dart';
import 'core/api_client.dart';

class UserApi {
  final ApiClient _client = ApiClient();

  Future<UserModel> completeProfile(
    Map<String, dynamic> completeProfileData,
  ) async {
    final response = await _client.dio.put(
      '/user/profile',
      data: completeProfileData,
    );

    final accessToken = response.data['accessToken'];
    final refreshToken = response.data['refreshToken'];

    if (accessToken != null) {
      await _client.storage.write(key: 'accessToken', value: accessToken);
    }
    if (refreshToken != null) {
      await _client.storage.write(key: 'refreshToken', value: refreshToken);
    }

    return UserModel.fromJson(response.data['user']);
  }

  Future<UserModel> getUserProfile(String userId) async {
    final response = await _client.dio.get('/user/$userId');
    return UserModel.fromJson(response.data);
  }
}
