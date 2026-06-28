import 'dart:io';
import 'package:flutter/material.dart';
import '../models/business_model.dart';
import '../services/business_api.dart';

class UpdateBusinessProvider with ChangeNotifier {
  final BusinessApi _api = BusinessApi();

  bool _isLoading = false;
  String? _error;

  String? businessId;
  String? businessName;
  String? category;
  String? description;
  String? logoUrl;
  String? contactNumber;
  String? website;
  String? address;
  String? city;
  String? state;

  bool get isLoading => _isLoading;
  String? get error => _error;

  void initFromBusiness(BusinessListing business) {
    businessId = business.id;
    businessName = business.businessName;
    category = business.category;
    description = business.description;
    logoUrl = business.logoUrl;
    contactNumber = business.contactNumber;
    website = business.website;
    address = business.address;
    city = business.city;
    state = business.state;
  }

  void updateField(String key, String? value) {
    switch (key) {
      case 'businessName':
        businessName = value;
        break;
      case 'category':
        category = value;
        break;
      case 'description':
        description = value;
        break;
      case 'contactNumber':
        contactNumber = value;
        break;
      case 'website':
        website = value;
        break;
      case 'address':
        address = value;
        break;
      case 'city':
        city = value;
        break;
      case 'state':
        state = value;
        break;
    }
    notifyListeners();
  }

  Future<bool> uploadLogo(File imageFile) async {
    if (businessId == null) return false;
    _setLoading(true);
    try {
      final updatedBusiness = await _api.uploadBusinessLogo(businessId!, imageFile);
      logoUrl = updatedBusiness.logoUrl;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = "Failed to upload business logo.";
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> submitUpdate() async {
    if (businessId == null) return false;
    
    _setLoading(true);
    try {
      final data = {
        'businessName': businessName,
        'category': category,
        'description': description,
        'contactNumber': contactNumber,
        'website': website,
        'address': address,
        'city': city,
        'state': state,
      };

      await _api.updateBusiness(businessId!, data);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = "Failed to update business details.";
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
