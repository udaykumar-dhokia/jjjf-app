import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_api.dart';

class AuthProvider extends ChangeNotifier {
  final AuthApi _authApi = AuthApi();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isAuthenticated = false;
  bool _isLoading = false;
  bool _isNewUser = false;
  bool _isProfileComplete = false;
  String? _error;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get isNewUser => _isNewUser;
  bool get isProfileComplete => _isProfileComplete;
  String? get error => _error;

  AuthProvider() {
    _checkExistingToken();
  }

  Future<void> _checkExistingToken() async {
    final token = await _storage.read(key: 'accessToken');
    final profileStatus = await _storage.read(key: 'isProfileComplete');
    if (token != null) {
      _isAuthenticated = true;
      _isProfileComplete = profileStatus == 'true';
      notifyListeners();
    }
  }

  Future<void> sendOtp(String email) async {
    _setLoading(true);
    try {
      await _authApi.sendOtp(email);
      _error = null;
    } catch (e) {
      print("Send OTP Error: $e");
      _error = "Failed to send OTP. Please try again.";
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    _setLoading(true);
    try {
      final response = await _authApi.verifyOtp(email, otp);
      _isAuthenticated = true;
      _isNewUser = response['isNewUser'] == true;
      _isProfileComplete = response['isProfileComplete'] == true;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = "Invalid OTP.";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authApi.logout();
    _isAuthenticated = false;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
