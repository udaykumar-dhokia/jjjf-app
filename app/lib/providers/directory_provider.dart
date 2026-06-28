import 'package:flutter/material.dart';
import '../services/user_api.dart';
import '../models/user_model.dart';

class DirectoryFilter {
  final Set<String> genders;
  final Set<String> maritalStatuses;
  final Set<String> bloodGroups;
  final Set<String> occupationTypes;
  final Set<String> gotras;
  final Set<String> states;
  final Set<String> cities;

  DirectoryFilter({
    this.genders = const {},
    this.maritalStatuses = const {},
    this.bloodGroups = const {},
    this.occupationTypes = const {},
    this.gotras = const {},
    this.states = const {},
    this.cities = const {},
  });

  bool get isEmpty =>
      genders.isEmpty &&
      maritalStatuses.isEmpty &&
      bloodGroups.isEmpty &&
      occupationTypes.isEmpty &&
      gotras.isEmpty &&
      states.isEmpty &&
      cities.isEmpty;
}

class DirectoryProvider extends ChangeNotifier {
  final UserApi _userApi = UserApi();

  List<UserModel> _allContacts = [];
  List<UserModel> _filteredContacts = [];

  Map<String, List<String>> _metadata = {
    'gotras': [],
    'cities': [],
    'states': [],
  };

  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  DirectoryFilter _activeFilter = DirectoryFilter();

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<UserModel> get allContacts => _allContacts;
  List<UserModel> get filteredContacts => _filteredContacts;
  String get searchQuery => _searchQuery;
  DirectoryFilter get activeFilter => _activeFilter;

  List<String> get availableGotras => _metadata['gotras'] ?? [];
  List<String> get availableCities => _metadata['cities'] ?? [];
  List<String> get availableStates => _metadata['states'] ?? [];

  DirectoryProvider() {
    fetchDirectory();
    fetchMetadata();
  }

  Future<void> fetchDirectory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allContacts = await _userApi.getDirectory();
      _applyFilter();
    } catch (e) {
      _error = "Failed to load directory. Please try again.";
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMetadata() async {
    try {
      _metadata = await _userApi.getDirectoryMetadata();
      notifyListeners();
    } catch (e) {
      // It's okay if metadata fails, filters just won't show dynamic options
    }
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    _applyFilter();
  }

  void setFilter(DirectoryFilter filter) {
    _activeFilter = filter;
    _applyFilter();
  }

  void clearFilter() {
    _activeFilter = DirectoryFilter();
    _applyFilter();
  }

  void _applyFilter() {
    _filteredContacts = _allContacts.where((user) {
      // 1. Check Search Query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final fullName = '${user.firstName} ${user.fatherName} ${user.gotra}'
            .toLowerCase();
        final city = user.currentCity.toLowerCase();
        if (!fullName.contains(query) && !city.contains(query)) {
          return false;
        }
      }

      // 2. Check Active Filters
      if (!_activeFilter.isEmpty) {
        if (_activeFilter.genders.isNotEmpty &&
            !_activeFilter.genders.contains(user.gender)) {
          return false;
        }
        if (_activeFilter.maritalStatuses.isNotEmpty &&
            !_activeFilter.maritalStatuses.contains(user.maritalStatus)) {
          return false;
        }
        if (_activeFilter.bloodGroups.isNotEmpty &&
            (user.bloodGroup == null ||
                !_activeFilter.bloodGroups.contains(user.bloodGroup))) {
          return false;
        }
        if (_activeFilter.occupationTypes.isNotEmpty &&
            !_activeFilter.occupationTypes.contains(user.occupationType)) {
          return false;
        }
        if (_activeFilter.gotras.isNotEmpty &&
            !_activeFilter.gotras.contains(user.gotra)) {
          return false;
        }
        if (_activeFilter.states.isNotEmpty &&
            !_activeFilter.states.contains(user.currentState)) {
          return false;
        }
        if (_activeFilter.cities.isNotEmpty &&
            !_activeFilter.cities.contains(user.currentCity)) {
          return false;
        }
      }

      return true;
    }).toList();

    _isLoading = false;
    notifyListeners();
  }
}
