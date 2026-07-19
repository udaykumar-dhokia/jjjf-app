import 'package:flutter/material.dart';
import '../models/banner_model.dart';
import '../services/banner_api.dart';

class BannerProvider with ChangeNotifier {
  final BannerApi _bannerApi = BannerApi();

  List<BannerModel> _banners = [];
  bool _isLoading = false;
  String? _error;

  List<BannerModel> get banners => _banners;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchBanners() async {
    if (_banners.isNotEmpty) return; // Basic caching

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _banners = await _bannerApi.getActiveBanners();
    } catch (e) {
      _error = 'Failed to load banners.';
      print('Error fetching banners: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void refreshBanners() {
    _banners = [];
    fetchBanners();
  }
}
