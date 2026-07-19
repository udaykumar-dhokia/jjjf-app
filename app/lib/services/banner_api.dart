import '../models/banner_model.dart';
import 'core/api_client.dart';

class BannerApi {
  final ApiClient _client = ApiClient();

  Future<List<BannerModel>> getActiveBanners() async {
    final response = await _client.dio.get('/banner');
    
    if (response.data == null || response.data == '') {
      return [];
    }
    
    final List<dynamic> data = response.data;
    return data.map((json) => BannerModel.fromJson(json)).toList();
  }
}
