import 'dart:io';
import 'package:dio/dio.dart';
import '../models/business_model.dart';
import 'core/api_client.dart';

class BusinessApi {
  final ApiClient _client = ApiClient();

  /// Fetches all approved business listings
  /// Optionally filters by cities, and owner details
  Future<List<BusinessListing>> getApprovedDirectory({
    List<String> cities = const [],
    List<String> gaons = const [],
    List<String> nativeDistricts = const [],
    List<String> nativeStates = const [],
    List<String> gotras = const [],
  }) async {
    String url = '/business/directory/approved?';
    
    final params = <String>[];
    if (cities.isNotEmpty) {
      params.add('cities=${Uri.encodeComponent(cities.join(','))}');
    }
    if (gaons.isNotEmpty) {
      params.add('gaons=${Uri.encodeComponent(gaons.join(','))}');
    }
    if (nativeDistricts.isNotEmpty) {
      params.add('nativeDistricts=${Uri.encodeComponent(nativeDistricts.join(','))}');
    }
    if (nativeStates.isNotEmpty) {
      params.add('nativeStates=${Uri.encodeComponent(nativeStates.join(','))}');
    }
    if (gotras.isNotEmpty) {
      params.add('gotras=${Uri.encodeComponent(gotras.join(','))}');
    }

    if (params.isNotEmpty) {
      url += params.join('&');
    } else {
      url = '/business/directory/approved';
    }

    final response = await _client.dio.get(url);
    final List<dynamic> data = response.data;
    return data.map((json) => BusinessListing.fromJson(json)).toList();
  }

  Future<BusinessListing?> getBusinessByUserId(String userId) async {
    try {
      final response = await _client.dio.get('/business/user/$userId');
      if (response.data == null || response.data.toString().isEmpty) {
        return null; // The backend returns an empty response (or null) if not found (because of findFirst returning null)
      }
      return BusinessListing.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateBusiness(String businessId, Map<String, dynamic> updateData) async {
    await _client.dio.put('/business/$businessId', data: updateData);
  }

  Future<BusinessListing> uploadBusinessLogo(String businessId, File imageFile) async {
    String fileName = imageFile.path.split('/').last;
    FormData formData = FormData.fromMap({
      "logo": await MultipartFile.fromFile(imageFile.path, filename: fileName),
    });

    final response = await _client.dio.patch(
      '/business/$businessId/logo',
      data: formData,
    );
    return BusinessListing.fromJson(response.data);
  }
}
