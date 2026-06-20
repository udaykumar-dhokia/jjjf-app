import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_api.dart';

class UserProvider extends ChangeNotifier {
  final UserApi _userApi = UserApi();
  
  UserModel? _userProfile;
  bool _isLoading = false;
  String? _error;

  UserModel? get userProfile => _userProfile;
  bool get isProfileLoaded => _userProfile != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProfile(String userId) async {
    _setLoading(true);
    try {
      _userProfile = await _userApi.getUserProfile(userId);
      _error = null;
    } catch (e) {
      _error = "Failed to load profile.";
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> completeProfile(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      _userProfile = await _userApi.completeProfile(data);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = "Failed to update profile.";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearUserProfile() {
    _userProfile = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
