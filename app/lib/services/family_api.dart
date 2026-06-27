import '../models/user_model.dart';
import 'core/api_client.dart';

class FamilyApi {
  final ApiClient _client = ApiClient();

  Future<Map<String, dynamic>> getMyFamily() async {
    final response = await _client.dio.get('/family/me');
    return response.data;
  }

  Future<Map<String, dynamic>> getFamilyById(String familyId) async {
    final response = await _client.dio.get('/family/$familyId');
    return response.data;
  }

  Future<Map<String, dynamic>> createFamily() async {
    final response = await _client.dio.post('/family/create');
    return response.data;
  }

  Future<UserModel> addFamilyMember(Map<String, dynamic> data) async {
    final response = await _client.dio.post('/family/members', data: data);
    return UserModel.fromJson(response.data);
  }

  Future<UserModel> updateFamilyMember(
    String memberId,
    Map<String, dynamic> data,
  ) async {
    final response = await _client.dio.put(
      '/family/members/$memberId',
      data: data,
    );
    return UserModel.fromJson(response.data);
  }

  Future<void> removeFamilyMember(String memberId) async {
    await _client.dio.delete('/family/members/$memberId');
  }
}
