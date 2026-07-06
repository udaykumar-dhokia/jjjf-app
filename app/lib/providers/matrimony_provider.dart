import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/matrimony_model.dart';
import '../models/matrimony_access_request_model.dart';
import '../services/matrimony_api.dart';

class MatrimonyFilter {
  final Set<String> gotras;
  final Set<String> education;
  final Set<String> heights;
  final Set<String> cities;
  final int? minAge;
  final int? maxAge;
  final String? gender;

  MatrimonyFilter({
    this.gotras = const {},
    this.education = const {},
    this.heights = const {},
    this.cities = const {},
    this.minAge,
    this.maxAge,
    this.gender,
  });

  bool get isEmpty =>
      gotras.isEmpty &&
      education.isEmpty &&
      heights.isEmpty &&
      cities.isEmpty &&
      minAge == null &&
      maxAge == null &&
      gender == null;

  MatrimonyFilter copyWith({
    Set<String>? gotras,
    Set<String>? education,
    Set<String>? heights,
    Set<String>? cities,
    int? minAge,
    int? maxAge,
    String? gender,
    bool clearMinAge = false,
    bool clearMaxAge = false,
    bool clearGender = false,
  }) {
    return MatrimonyFilter(
      gotras: gotras ?? this.gotras,
      education: education ?? this.education,
      heights: heights ?? this.heights,
      cities: cities ?? this.cities,
      minAge: clearMinAge ? null : (minAge ?? this.minAge),
      maxAge: clearMaxAge ? null : (maxAge ?? this.maxAge),
      gender: clearGender ? null : (gender ?? this.gender),
    );
  }
}

class MatrimonyProvider with ChangeNotifier {
  final MatrimonyApi _api = MatrimonyApi();

  MatrimonialProfile? _myProfile;
  List<MatrimonialProfile> _browseList = [];
  List<MatrimonialAccessRequest> _sentRequests = [];
  List<MatrimonialAccessRequest> _receivedRequests = [];
  
  bool _isLoading = false;
  String? _errorMessage;

  Timer? _debounceTimer;

  Map<String, List<String>> _metadata = {
    'gotras': [],
    'cities': [],
    'education': [],
    'heights': [],
  };

  String _searchQuery = '';
  MatrimonyFilter _activeFilter = MatrimonyFilter();

  MatrimonialProfile? get myProfile => _myProfile;
  List<MatrimonialProfile> get browseList => _browseList;
  List<MatrimonialAccessRequest> get sentRequests => _sentRequests;
  List<MatrimonialAccessRequest> get receivedRequests => _receivedRequests;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get searchQuery => _searchQuery;
  MatrimonyFilter get activeFilter => _activeFilter;

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();

    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      fetchBrowseList();
    });
  }

  void setFilter(MatrimonyFilter filter) {
    _activeFilter = filter;
    notifyListeners();
    fetchBrowseList();
  }

  void clearFilter() {
    _activeFilter = MatrimonyFilter();
    notifyListeners();
    fetchBrowseList();
  }

  List<MatrimonialProfile> get filteredBrowseList => _browseList;

  List<String> get availableGotras => _metadata['gotras'] ?? [];
  List<String> get availableEducation => _metadata['education'] ?? [];
  List<String> get availableHeights => _metadata['heights'] ?? [];
  List<String> get availableCities => _metadata['cities'] ?? [];

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> fetchMyProfile() async {
    _setLoading(true);
    _setError(null);
    try {
      _myProfile = await _api.getMyProfile();
    } catch (e) {
      // It might be a 404 if the user hasn't created a profile yet.
      _myProfile = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createProfile(Map<String, dynamic> data) async {
    _setLoading(true);
    _setError(null);
    try {
      _myProfile = await _api.createProfile(data);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _setLoading(true);
    _setError(null);
    try {
      _myProfile = await _api.updateMyProfile(data);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> fetchMetadata() async {
    try {
      _metadata = await _api.getMatrimonyMetadata();
      notifyListeners();
    } catch (e) {
      // It's okay if metadata fails, filters just won't show dynamic options
    }
  }

  Future<void> fetchBrowseList() async {
    _setLoading(true);
    _setError(null);
    try {
      if ((_metadata['gotras']?.isEmpty ?? true)) {
        fetchMetadata();
      }

      final Map<String, dynamic> queryParams = {};
      if (_searchQuery.isNotEmpty) queryParams['search'] = _searchQuery;
      if (!_activeFilter.isEmpty) {
        if (_activeFilter.gotras.isNotEmpty) queryParams['gotras'] = _activeFilter.gotras.toList();
        if (_activeFilter.education.isNotEmpty) queryParams['education'] = _activeFilter.education.toList();
        if (_activeFilter.heights.isNotEmpty) queryParams['heights'] = _activeFilter.heights.toList();
        if (_activeFilter.cities.isNotEmpty) queryParams['cities'] = _activeFilter.cities.toList();
        if (_activeFilter.minAge != null) queryParams['minAge'] = _activeFilter.minAge;
        if (_activeFilter.maxAge != null) queryParams['maxAge'] = _activeFilter.maxAge;
        if (_activeFilter.gender != null) queryParams['gender'] = _activeFilter.gender;
      }

      _browseList = await _api.browseProfiles(queryParams);
    } catch (e) {
      _setError('Failed to load profiles. Make sure your profile is approved.');
    } finally {
      _setLoading(false);
    }
  }

  Future<MatrimonialProfile?> fetchFullProfile(String targetId) async {
    _setLoading(true);
    _setError(null);
    try {
      final profile = await _api.viewFullProfile(targetId);
      _setLoading(false);
      return profile;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return null;
    }
  }

  Future<bool> requestAccess(String targetId) async {
    _setLoading(true);
    _setError(null);
    try {
      final newRequest = await _api.requestAccess(targetId);
      _sentRequests.add(newRequest);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> fetchRequests() async {
    _setLoading(true);
    _setError(null);
    try {
      final sent = await _api.getSentRequests();
      final received = await _api.getReceivedRequests();
      _sentRequests = sent;
      _receivedRequests = received;
    } catch (e) {
      _setError('Failed to fetch requests');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateRequestStatus(String requestId, String status) async {
    _setLoading(true);
    _setError(null);
    try {
      final updatedReq = await _api.updateAccessRequestStatus(requestId, status);
      
      // Update in local list
      final index = _receivedRequests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        _receivedRequests[index] = updatedReq;
      }
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<String?> uploadImage(File imageFile) async {
    _setLoading(true);
    _setError(null);
    try {
      String url = await _api.uploadMatrimonyImage(imageFile);
      _setLoading(false);
      return url;
    } catch (e) {
      if (e is DioException) {
        final errorMsg = e.response?.data?['message'] ?? e.message;
        _setError('Upload failed: $errorMsg');
      } else {
        _setError('Upload failed: $e');
      }
      _setLoading(false);
      return null;
    }
  }
}
