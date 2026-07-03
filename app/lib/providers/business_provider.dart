import 'package:flutter/material.dart';
import '../models/business_model.dart';
import '../services/business_api.dart';
import '../services/user_api.dart'; // We'll need metadata for categories/cities if available

class BusinessFilter {
  List<String> cities;
  String? category;
  List<String> ownerGaons;
  List<String> ownerNativeDistricts;
  List<String> ownerNativeStates;
  List<String> ownerGotras;

  BusinessFilter({
    this.cities = const [],
    this.category,
    this.ownerGaons = const [],
    this.ownerNativeDistricts = const [],
    this.ownerNativeStates = const [],
    this.ownerGotras = const [],
  });

  bool get isEmpty =>
      cities.isEmpty &&
      category == null &&
      ownerGaons.isEmpty &&
      ownerNativeDistricts.isEmpty &&
      ownerNativeStates.isEmpty &&
      ownerGotras.isEmpty;
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
  List<String> _availableGotras = [];
  List<String> _availableGaons = [];
  List<String> _availableNativeDistricts = [];
  List<String> _availableNativeStates = [];
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
  List<String> get availableGotras => _availableGotras;
  List<String> get availableGaons => _availableGaons;
  List<String> get availableNativeDistricts => _availableNativeDistricts;
  List<String> get availableNativeStates => _availableNativeStates;

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
    if (_filter.cities.isEmpty && defaultCity != null) {
      _filter.cities = [defaultCity];
    }
    
    notifyListeners();

    try {
      // 1. Fetch directory metadata just to get cities for the filter sheet
      // We can reuse the user API metadata for cities
      try {
        final metadata = await UserApi().getDirectoryMetadata();
        if (metadata['cities'] != null && metadata['cities']!.isNotEmpty) {
          _availableCities = metadata['cities']!;
        }
        if (metadata['gaons'] != null && metadata['gaons']!.isNotEmpty) {
          _availableGaons = metadata['gaons']!;
        }
        if (metadata['nativeDistricts'] != null && metadata['nativeDistricts']!.isNotEmpty) {
          _availableNativeDistricts = metadata['nativeDistricts']!;
        }
        if (metadata['nativeStates'] != null && metadata['nativeStates']!.isNotEmpty) {
          _availableNativeStates = metadata['nativeStates']!;
        }
        if (metadata['gotras'] != null && metadata['gotras']!.isNotEmpty) {
          _availableGotras = metadata['gotras']!;
        }
      } catch (_) {
        // Fallback or ignore if metadata fails
      }

      // 2. Fetch business listings based on current city and owner filters
      _businesses = await BusinessApi().getApprovedDirectory(
        cities: _filter.cities,
        gaons: _filter.ownerGaons,
        nativeDistricts: _filter.ownerNativeDistricts,
        nativeStates: _filter.ownerNativeStates,
        gotras: _filter.ownerGotras,
      );
      
      // Extract available owner details from the fetched list only if metadata failed
      if (_availableGaons.isEmpty) {
        _availableGaons = _businesses.map((b) => b.owner?.gaon ?? '').where((s) => s.isNotEmpty).toSet().toList();
      }
      if (_availableGotras.isEmpty) {
        _availableGotras = _businesses.map((b) => b.owner?.gotra ?? '').where((s) => s.isNotEmpty).toSet().toList();
      }
      if (_availableNativeDistricts.isEmpty) {
        _availableNativeDistricts = _businesses.map((b) => b.owner?.nativeDistrict ?? '').where((s) => s.isNotEmpty).toSet().toList();
      }
      if (_availableNativeStates.isEmpty) {
        _availableNativeStates = _businesses.map((b) => b.owner?.nativeState ?? '').where((s) => s.isNotEmpty).toSet().toList();
      }

      // 3. Apply local filtering for category (since backend GET doesn't filter by category currently)
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

  void updateFilter({
    List<String>? cities, 
    String? category,
    List<String>? ownerGaons,
    List<String>? ownerNativeDistricts,
    List<String>? ownerNativeStates,
    List<String>? ownerGotras,
  }) {
    if (cities != null) _filter.cities = cities;
    if (category != null) _filter.category = category;
    if (ownerGaons != null) _filter.ownerGaons = ownerGaons;
    if (ownerNativeDistricts != null) _filter.ownerNativeDistricts = ownerNativeDistricts;
    if (ownerNativeStates != null) _filter.ownerNativeStates = ownerNativeStates;
    if (ownerGotras != null) _filter.ownerGotras = ownerGotras;
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
