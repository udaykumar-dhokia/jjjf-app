import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/family_api.dart';

class FamilyProvider with ChangeNotifier {
  final FamilyApi _familyApi = FamilyApi();

  Map<String, dynamic>? _myFamily;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get myFamily => _myFamily;
  List<UserModel> get members {
    if (_myFamily == null || _myFamily!['members'] == null) return [];
    final List<dynamic> mems = _myFamily!['members'];
    return mems.map((e) => UserModel.fromJson(e)).toList();
  }

  UserModel? get headOfFamily {
    if (_myFamily == null || _myFamily!['headOfFamily'] == null) return null;
    return UserModel.fromJson(_myFamily!['headOfFamily']);
  }

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMyFamily() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _myFamily = await _familyApi.getMyFamily();
    } catch (e) {
      if (e.toString().contains('404') ||
          e.toString().contains('null') ||
          e.toString().contains('Null') ||
          e.toString().contains('String') ||
          e.toString().contains('Family not found')) {
        _myFamily = null;
        _error = null; // Just an empty state, not an error
      } else {
        _error = 'Failed to load family data. Please try again.';
        print('Fetch family error: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Map<String, dynamic>? _viewingFamily;
  Map<String, dynamic>? get viewingFamily => _viewingFamily;

  List<UserModel> get viewingMembers {
    if (_viewingFamily == null || _viewingFamily!['members'] == null) return [];
    final List<dynamic> mems = _viewingFamily!['members'];
    return mems.map((e) => UserModel.fromJson(e)).toList();
  }

  UserModel? get viewingHeadOfFamily {
    if (_viewingFamily == null || _viewingFamily!['headOfFamily'] == null) return null;
    return UserModel.fromJson(_viewingFamily!['headOfFamily']);
  }

  Future<void> fetchFamilyById(String familyId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _viewingFamily = await _familyApi.getFamilyById(familyId);
    } catch (e) {
      if (e.toString().contains('404') ||
          e.toString().contains('null') ||
          e.toString().contains('Null') ||
          e.toString().contains('String') ||
          e.toString().contains('Family not found')) {
        _viewingFamily = null;
        _error = null;
      } else {
        _error = 'Failed to load family data. Please try again.';
        print('Fetch family by id error: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createFamily() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _familyApi.createFamily();
      await fetchMyFamily();
      return true;
    } catch (e) {
      _error = 'Failed to create family. Please try again.';
      print('Create family error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addFamilyMember(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _familyApi.addFamilyMember(data);
      await fetchMyFamily();
      return true;
    } catch (e) {
      if (e.toString().contains('409') || e.toString().contains('Conflict')) {
        _error = 'Phone number or email is already in use.';
      } else {
        _error = 'Failed to add family member. Please try again.';
      }
      print('Add family member error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateFamilyMember(
    String memberId,
    Map<String, dynamic> data,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _familyApi.updateFamilyMember(memberId, data);
      await fetchMyFamily();
      return true;
    } catch (e) {
      if (e.toString().contains('409') || e.toString().contains('Conflict')) {
        _error = 'Phone number or email is already in use.';
      } else {
        _error = 'Failed to update family member. Please try again.';
      }
      print('Update family member error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeFamilyMember(String memberId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _familyApi.removeFamilyMember(memberId);
      await fetchMyFamily();
      return true;
    } catch (e) {
      _error = 'Failed to remove family member. Please try again.';
      print('Remove family member error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
