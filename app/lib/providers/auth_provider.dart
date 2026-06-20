import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_api.dart';

class AuthProvider extends ChangeNotifier {
  final AuthApi _authApi = AuthApi();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider() {
    _checkExistingToken();
  }

  Future<void> _checkExistingToken() async {
    final token = await _storage.read(key: 'accessToken');
    if (token != null) {
      _isAuthenticated = true;
      notifyListeners();
    }
  }

  Future<void> sendOtp(String email) async {
    _setLoading(true);
    try {
      await _authApi.sendOtp(email);
      _error = null;
    } catch (e) {
      _error = "Failed to send OTP. Please try again.";
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    _setLoading(true);
    try {
      await _authApi.verifyOtp(email, otp);
      _isAuthenticated = true;
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
