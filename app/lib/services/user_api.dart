import 'dart:io';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import 'core/api_client.dart';

class UserApi {
  final ApiClient _client = ApiClient();

  Future<void> completeProfile(
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
    
    // Once successfully completed, set flag to true so next boot goes straight to Home
    await _client.storage.write(key: 'isProfileComplete', value: 'true');
  }

  Future<UserModel> getUserProfile(String userId) async {
    final response = await _client.dio.get('/user/$userId');
    return UserModel.fromJson(response.data);
  }

  Future<UserModel> getMyProfile() async {
    final response = await _client.dio.get('/user/profile/me');
    return UserModel.fromJson(response.data);
  }

  Future<void> updateMyProfile(Map<String, dynamic> updateData) async {
    await _client.dio.put('/user/profile/me', data: updateData);
  }

  Future<UserModel> uploadProfileImage(File imageFile) async {
    String fileName = imageFile.path.split('/').last;
    FormData formData = FormData.fromMap({
      "image": await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
      ),
    });

    final response = await _client.dio.patch(
      '/user/profile/image',
      data: formData,
    );
    return UserModel.fromJson(response.data);
  }

  Future<UserModel> removeProfileImage() async {
    final response = await _client.dio.delete('/user/profile/image');
    return UserModel.fromJson(response.data);
  }

  Future<List<UserModel>> getDirectory() async {
    final response = await _client.dio.get('/user/directory/approved');
    final List<dynamic> data = response.data;
    return data.map((json) => UserModel.fromJson(json)).toList();
  }

  Future<Map<String, List<String>>> getDirectoryMetadata() async {
    final response = await _client.dio.get('/user/directory/metadata');
    final Map<String, dynamic> data = response.data;
    return {
      'gotras': List<String>.from(data['gotras'] ?? []),
      'cities': List<String>.from(data['cities'] ?? []),
      'states': List<String>.from(data['states'] ?? []),
    };
  }
}
