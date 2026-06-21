import 'package:flutter/material.dart';
import '../services/user_api.dart';
import '../models/user_model.dart';

class DirectoryProvider extends ChangeNotifier {
  final UserApi _userApi = UserApi();

  List<UserModel> _allContacts = [];
  List<UserModel> _filteredContacts = [];
  
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<UserModel> get filteredContacts => _filteredContacts;
  String get searchQuery => _searchQuery;

  DirectoryProvider() {
    fetchDirectory();
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

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilter();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredContacts = List.from(_allContacts);
    } else {
      final query = _searchQuery.toLowerCase();
      _filteredContacts = _allContacts.where((user) {
        final fullName = '${user.firstName} ${user.fatherName} ${user.gotra}'.toLowerCase();
        final city = user.currentCity.toLowerCase();
        return fullName.contains(query) || city.contains(query);
      }).toList();
    }
    
    _isLoading = false;
    notifyListeners();
  }
}
