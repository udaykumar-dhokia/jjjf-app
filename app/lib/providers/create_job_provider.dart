import 'package:flutter/material.dart';
import '../services/job_api.dart';

class CreateJobProvider with ChangeNotifier {
  final JobApi _api = JobApi();

  bool _isLoading = false;
  String? _error;

  // Form Fields
  String _type = 'VACANCY_AVAILABLE';
  String _roleTitle = '';
  String _industry = '';
  String _city = '';
  String? _salaryRange;
  String _description = '';

  String _contactName = '';
  String? _contactPhone;
  String? _whatsappNumber;
  String? _contactEmail;
  List<String> _links = [];

  // Getters & Setters
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get type => _type;
  set type(String val) => _type = val;

  String get roleTitle => _roleTitle;
  set roleTitle(String val) => _roleTitle = val;

  String get industry => _industry;
  set industry(String val) => _industry = val;

  String get city => _city;
  set city(String val) => _city = val;

  String? get salaryRange => _salaryRange;
  set salaryRange(String? val) => _salaryRange = val;

  String get description => _description;
  set description(String val) => _description = val;

  String get contactName => _contactName;
  set contactName(String val) => _contactName = val;

  String? get contactPhone => _contactPhone;
  set contactPhone(String? val) => _contactPhone = val;

  String? get whatsappNumber => _whatsappNumber;
  set whatsappNumber(String? val) => _whatsappNumber = val;

  String? get contactEmail => _contactEmail;
  set contactEmail(String? val) => _contactEmail = val;

  List<String> get links => _links;

  void addLink(String link) {
    _links.add(link);
    notifyListeners();
  }

  void removeLink(int index) {
    _links.removeAt(index);
    notifyListeners();
  }

  // Method to batch update fields without multiple notifies
  void updateField(VoidCallback updateAction) {
    updateAction();
    notifyListeners();
  }

  void resetForm() {
    _type = 'VACANCY_AVAILABLE';
    _roleTitle = '';
    _industry = '';
    _city = '';
    _salaryRange = null;
    _contactName = '';
    _contactPhone = null;
    _whatsappNumber = null;
    _contactEmail = null;
    _links = [];
    _description = '';
    _error = null;
    notifyListeners();
  }

  Future<bool> submitJob() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final payload = <String, dynamic>{
        'type': _type,
        'roleTitle': _roleTitle,
        'industry': _industry,
        'city': _city,
        'description': _description,
        'contactName': _contactName,
      };

      if (_salaryRange != null && _salaryRange!.isNotEmpty) {
        payload['salaryRange'] = _salaryRange!;
      }
      if (_contactPhone != null && _contactPhone!.isNotEmpty) {
        payload['contactPhone'] = _contactPhone!;
      }
      if (_whatsappNumber != null && _whatsappNumber!.isNotEmpty) {
        payload['whatsappNumber'] = _whatsappNumber!;
      }
      if (_contactEmail != null && _contactEmail!.isNotEmpty) {
        payload['contactEmail'] = _contactEmail!;
      }
      if (_links.isNotEmpty) {
        payload['links'] = _links;
      }

      await _api.createJob(payload);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
