import 'dart:io';
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

  Future<void> fetchMyProfile() async {
    _setLoading(true);
    try {
      _userProfile = await _userApi.getMyProfile();
      _error = null;
    } catch (e) {
      _error = "Failed to load your profile.";
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> completeProfile(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      await _userApi.completeProfile(data);
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

  Future<void> updatePhoneVisibility(bool isVisible) async {
    if (_userProfile == null) return;
    
    // Optimistic UI update
    final oldValue = _userProfile!.isPhoneNumberVisible;
    _userProfile = _userProfile!.copyWith(isPhoneNumberVisible: isVisible);
    notifyListeners();

    try {
      await _userApi.updateMyProfile({'isPhoneNumberVisible': isVisible});
    } catch (e) {
      // Revert if failed
      _userProfile = _userProfile!.copyWith(isPhoneNumberVisible: oldValue);
      _error = "Failed to update visibility setting.";
      notifyListeners();
    }
  }

  Future<bool> uploadProfileImage(File imageFile) async {
    _setLoading(true);
    try {
      final updatedUser = await _userApi.uploadProfileImage(imageFile);
      _userProfile = updatedUser;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = "Failed to upload profile image.";
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> removeProfileImage() async {
    _setLoading(true);
    try {
      final updatedUser = await _userApi.removeProfileImage();
      _userProfile = updatedUser;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = "Failed to remove profile image.";
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
