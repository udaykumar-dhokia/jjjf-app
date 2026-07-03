import '../models/job_model.dart';
import 'core/api_client.dart';

class JobApi {
  final ApiClient _client = ApiClient();

  /// Fetches job postings and requests with optional filters
  Future<List<JobModel>> getJobs({
    String? type,
    Set<String>? cities,
    Set<String>? industries,
    String? search,
  }) async {
    final queryParams = <String, String>{};
    if (type != null && type.isNotEmpty) queryParams['type'] = type;
    if (cities != null && cities.isNotEmpty) queryParams['city'] = cities.join(',');
    if (industries != null && industries.isNotEmpty) queryParams['industry'] = industries.join(',');
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final uri = Uri(path: '/jobs', queryParameters: queryParams);
    
    final response = await _client.dio.get(uri.toString());
    final List<dynamic> data = response.data;
    return data.map((json) => JobModel.fromJson(json)).toList();
  }

  /// Fetches metadata for filter dropdowns (cities and industries)
  Future<Map<String, List<String>>> getMetadata() async {
    final response = await _client.dio.get('/jobs/metadata');
    return {
      'cities': List<String>.from(response.data['cities'] ?? []),
      'industries': List<String>.from(response.data['industries'] ?? []),
    };
  }

  /// Creates a new job posting or request
  Future<JobModel> createJob(Map<String, dynamic> jobData) async {
    final response = await _client.dio.post('/jobs', data: jobData);
    return JobModel.fromJson(response.data);
  }

  /// Updates an existing job
  Future<JobModel> updateJob(String id, Map<String, dynamic> updateData) async {
    final response = await _client.dio.put('/jobs/$id', data: updateData);
    return JobModel.fromJson(response.data);
  }

  /// Deletes a job
  Future<void> deleteJob(String id) async {
    await _client.dio.delete('/jobs/$id');
  }
}
