import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../services/job_api.dart';

class JobFilter {
  Set<String> cities = {};
  Set<String> industries = {};
  Set<String> jobRoles = {};
  String? search;

  JobFilter({Set<String>? cities, Set<String>? industries, Set<String>? jobRoles, this.search}) {
    if (cities != null) this.cities = cities;
    if (industries != null) this.industries = industries;
    if (jobRoles != null) this.jobRoles = jobRoles;
  }

  bool get isEmpty => cities.isEmpty && industries.isEmpty && jobRoles.isEmpty && search == null;
}

class JobProvider with ChangeNotifier {
  final JobApi _api = JobApi();

  List<JobModel> _vacancies = [];
  List<JobModel> _jobRequests = [];
  
  bool _isLoading = false;
  String? _error;

  // Active filters
  JobFilter _filter = JobFilter();
  
  // Dynamic Metadata
  List<String> _availableCities = [];
  List<String> _availableIndustries = [];
  List<String> _availableJobRoles = [];

  List<JobModel> get vacancies => _vacancies;
  List<JobModel> get jobRequests => _jobRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;
  JobFilter get activeFilter => _filter;
  List<String> get availableCities => _availableCities;
  List<String> get availableIndustries => _availableIndustries;
  List<String> get availableJobRoles => _availableJobRoles;

  Future<void> loadMetadata() async {
    try {
      final metadata = await _api.getMetadata();
      _availableCities = metadata['cities'] ?? [];
      _availableIndustries = metadata['industries'] ?? [];
      _availableJobRoles = metadata['jobRoles'] ?? [];
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load job metadata: $e');
    }
  }

  Future<void> fetchJobs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load metadata if empty
      if (_availableCities.isEmpty || _availableIndustries.isEmpty) {
        await loadMetadata();
      }

      // We fetch all types here and then split them, or fetch twice.
      // Fetching all at once is more efficient for the backend.
      final allJobs = await _api.getJobs(
        cities: _filter.cities,
        industries: _filter.industries,
        jobRoles: _filter.jobRoles,
        search: _filter.search,
      );

      _vacancies = allJobs.where((j) => j.type == 'VACANCY_AVAILABLE').toList();
      _jobRequests = allJobs.where((j) => j.type == 'JOB_REQUIRED').toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(JobFilter filter) {
    _filter = filter;
    fetchJobs();
  }

  void clearFilter() {
    _filter = JobFilter();
    fetchJobs();
  }

  void setSearchQuery(String query) {
    _filter.search = query.isEmpty ? null : query;
    fetchJobs();
  }

  Future<void> createJob(Map<String, dynamic> data) async {
    try {
      await _api.createJob(data);
      // Refresh jobs list to show the newly created one
      await fetchJobs();
    } catch (e) {
      rethrow;
    }
  }
}
