import 'package:flutter/material.dart';
import '../models/business_model.dart';
import '../services/business_api.dart';
import '../services/user_api.dart'; // We'll need metadata for categories/cities if available

class BusinessFilter {
  String? city;
  String? category;

  BusinessFilter({this.city, this.category});

  bool get isEmpty => city == null && category == null;
}

class BusinessProvider with ChangeNotifier {
  List<BusinessListing> _businesses = [];
  bool _isLoading = false;
  String? _error;
  
  // Filters
  BusinessFilter _filter = BusinessFilter();
  String _searchQuery = '';
  
  // Metadata for dropdowns
  List<String> _availableCities = [];
  List<String> _availableCategories = [
    'AGRICULTURE', 'AUTOMOTIVE', 'BANKING', 'CONSULTING', 'EDUCATION',
    'ELECTRONICS', 'ENTERTAINMENT', 'FINANCE', 'FOOD_AND_BEVERAGE', 
    'HEALTHCARE', 'HOSPITALITY', 'IT', 'LEGAL', 'LOGISTICS', 
    'MANUFACTURING', 'MEDIA', 'REAL_ESTATE', 'RETAIL', 'TELECOMMUNICATIONS',
    'TEXTILES', 'TOURISM', 'TRANSPORTATION', 'WHOLESALE', 'OTHER'
  ]; // Enums from backend

  List<BusinessListing> get businesses => _businesses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  BusinessFilter get filter => _filter;
  String get searchQuery => _searchQuery;
  List<String> get availableCities => _availableCities;
  List<String> get availableCategories => _availableCategories;

  List<BusinessListing> get filteredBusinesses {
    if (_searchQuery.isEmpty) return _businesses;
    final query = _searchQuery.toLowerCase();
    return _businesses.where((b) {
      final matchesName = b.businessName.toLowerCase().contains(query);
      final matchesCity = b.city.toLowerCase().contains(query);
      final matchesCategory = b.category.toLowerCase().contains(query);
      return matchesName || matchesCity || matchesCategory;
    }).toList();
  }

  Future<void> fetchBusinesses({String? defaultCity}) async {
    _isLoading = true;
    _error = null;
    
    // Set default city if filter isn't set
    if (_filter.city == null && defaultCity != null) {
      _filter.city = defaultCity;
    }
    
    notifyListeners();

    try {
      // 1. Fetch directory metadata just to get cities for the filter sheet
      // We can reuse the user API metadata for cities
      try {
        final metadata = await UserApi().getDirectoryMetadata();
        _availableCities = metadata['cities'] ?? [];
      } catch (_) {
        // Fallback or ignore if metadata fails
      }

      // 2. Fetch business listings based on current city filter
      _businesses = await BusinessApi().getApprovedDirectory(city: _filter.city);
      
      // 3. Apply local filtering for category (since backend GET only filters by city currently)
      if (_filter.category != null && _filter.category!.isNotEmpty) {
        _businesses = _businesses.where((b) => b.category == _filter.category).toList();
      }

    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateFilter({String? city, String? category}) {
    _filter.city = city;
    _filter.category = category;
    fetchBusinesses();
  }

  void clearFilter() {
    _filter = BusinessFilter();
    fetchBusinesses();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
