import 'dart:io';
import 'package:dio/dio.dart';
import '../models/matrimony_model.dart';
import '../models/matrimony_access_request_model.dart';
import 'core/api_client.dart';

class MatrimonyApi {
  final ApiClient _client = ApiClient();

  Future<MatrimonialProfile> createProfile(Map<String, dynamic> data) async {
    final response = await _client.dio.post('/matrimony', data: data);
    return MatrimonialProfile.fromJson(response.data);
  }

  Future<MatrimonialProfile> getMyProfile() async {
    final response = await _client.dio.get('/matrimony/me');
    return MatrimonialProfile.fromJson(response.data);
  }

  Future<MatrimonialProfile> updateMyProfile(Map<String, dynamic> data) async {
    final response = await _client.dio.put('/matrimony/me', data: data);
    return MatrimonialProfile.fromJson(response.data);
  }

  Future<void> deleteMyProfile() async {
    await _client.dio.delete('/matrimony/me');
  }

  Future<List<MatrimonialProfile>> browseProfiles(Map<String, dynamic> queryParams) async {
    final response = await _client.dio.get('/matrimony/browse', queryParameters: queryParams);
    final List<dynamic> data = response.data;
    return data.map((json) => MatrimonialProfile.fromJson(json)).toList();
  }

  Future<Map<String, List<String>>> getMatrimonyMetadata() async {
    final response = await _client.dio.get('/matrimony/metadata');
    return {
      'gotras': List<String>.from(response.data['gotras'] ?? []),
      'cities': List<String>.from(response.data['cities'] ?? []),
      'education': List<String>.from(response.data['education'] ?? []),
      'heights': List<String>.from(response.data['heights'] ?? []),
    };
  }

  Future<MatrimonialProfile> viewFullProfile(String targetId) async {
    final response = await _client.dio.get('/matrimony/profiles/$targetId');
    return MatrimonialProfile.fromJson(response.data);
  }

  Future<MatrimonialAccessRequest> requestAccess(String targetId) async {
    final response = await _client.dio.post(
      '/matrimony/access-request',
      data: {'targetId': targetId},
    );
    return MatrimonialAccessRequest.fromJson(response.data, isSent: true);
  }

  Future<List<MatrimonialAccessRequest>> getSentRequests() async {
    final response = await _client.dio.get('/matrimony/access-request/sent');
    final List<dynamic> data = response.data;
    return data.map((json) => MatrimonialAccessRequest.fromJson(json, isSent: true)).toList();
  }

  Future<List<MatrimonialAccessRequest>> getReceivedRequests() async {
    final response = await _client.dio.get('/matrimony/access-request/received');
    final List<dynamic> data = response.data;
    return data.map((json) => MatrimonialAccessRequest.fromJson(json, isSent: false)).toList();
  }

  Future<MatrimonialAccessRequest> updateAccessRequestStatus(String requestId, String status) async {
    final response = await _client.dio.put(
      '/matrimony/access-request/$requestId',
      data: {'status': status},
    );
    // When updating, we don't necessarily get the nested user object back depending on backend.
    // For safety we parse it as received (since we only update received ones usually).
    return MatrimonialAccessRequest.fromJson(response.data, isSent: false);
  }

  Future<String> uploadMatrimonyImage(File imageFile) async {
    String fileName = imageFile.uri.pathSegments.last;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(imageFile.path, filename: fileName),
    });

    final response = await _client.dio.post(
      '/upload/image',
      data: formData,
    );
    return response.data['url'];
  }
}
