import 'package:app/models/user_model.dart';
import 'package:flutter/material.dart';
import '../services/user_api.dart';

class CompleteProfileProvider extends ChangeNotifier {
  final UserApi _userApi = UserApi();

  // Step 1: Personal Details
  String firstName = '';
  String fatherName = '';
  String motherName = '';
  String gotra = '';
  String? gender; // 'MALE', 'FEMALE', 'OTHER'
  DateTime? dateOfBirth;
  String? bloodGroup;
  String? maritalStatus; // 'SINGLE', 'MARRIED', 'DIVORCED', 'WIDOWED'

  // Married Fields
  String spouseName = '';
  String husbandNameWithSurname = '';
  String sasuralGotra = '';

  // Step 2: Contact & Address
  String phoneNumber = '';
  String whatsappNumber = '';
  String gaon = '';
  String nativeDistrict = '';
  String nativeState = '';
  String currentCity = '';
  String currentState = '';
  String currentAddress = '';
  String pinCode = '';

  // Step 3: Occupation Details
  String? occupationType; // 'BUSINESS_OWNER', 'JOB_PROFESSIONAL', 'OTHER'

  // Business Fields
  String businessName = '';
  String businessCategory = '';
  String businessAddress = '';
  String businessContact = '';

  // Job Fields
  String companyName = '';
  String designation = '';
  String industry = '';
  String jobCity = '';

  // Other Fields
  String occupationDescription = '';

  // Password Fields
  String password = '';
  String confirmPassword = '';

  // Loading State
  bool isLoading = false;
  String? error;

  bool isUpdateMode = false;

  void initFromUser(UserModel user) {
    isUpdateMode = true;

    firstName = user.firstName;
    fatherName = user.fatherName;
    motherName = user.motherName ?? '';
    gotra = user.gotra;
    gender = user.gender;
    dateOfBirth = user.dateOfBirth;
    bloodGroup = user.bloodGroup;
    maritalStatus = user.maritalStatus;

    if (user.maritalStatus == 'MARRIED') {
      spouseName = user.spouseName ?? '';
      if (user.gender == 'FEMALE') {
        husbandNameWithSurname = user.husbandNameWithSurname ?? '';
        sasuralGotra = user.sasuralGotra ?? '';
      }
    }

    phoneNumber = user.phoneNumber;
    whatsappNumber = user.whatsappNumber ?? '';
    gaon = user.gaon;
    nativeDistrict = user.nativeDistrict;
    nativeState = user.nativeState;
    currentCity = user.currentCity;
    currentState = user.currentState;
    currentAddress = user.currentAddress ?? '';
    pinCode = user.pinCode ?? '';

    occupationType = user.occupationType;
    if (occupationType == 'BUSINESS_OWNER' && user.occupationDetails != null) {
      businessName = user.occupationDetails!.businessName ?? '';
      businessCategory = user.occupationDetails!.category ?? '';
      businessAddress = user.occupationDetails!.address ?? '';
      businessContact = user.occupationDetails!.contact ?? '';
    } else if (occupationType == 'JOB_PROFESSIONAL' &&
        user.occupationDetails != null) {
      companyName = user.occupationDetails!.companyName ?? '';
      designation = user.occupationDetails!.designation ?? '';
      industry = user.occupationDetails!.industry ?? '';
      jobCity = user.occupationDetails!.city ?? '';
    } else if (occupationType == 'OTHER' && user.occupationDetails != null) {
      occupationDescription = user.occupationDetails!.description ?? '';
    }
  }

  void updateField(VoidCallback update) {
    update();
    notifyListeners();
  }

  Future<bool> submitProfile() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      Map<String, dynamic>? occupationDetails;

      if (occupationType == 'BUSINESS_OWNER') {
        occupationDetails = {
          'businessName': businessName,
          'category': businessCategory,
          'address': businessAddress,
          'contact': businessContact,
        };
      } else if (occupationType == 'JOB_PROFESSIONAL') {
        occupationDetails = {
          'companyName': companyName,
          'designation': designation,
          'industry': industry,
          'city': jobCity,
        };
      } else if (occupationType == 'OTHER') {
        occupationDetails = {'description': occupationDescription};
      }

      final Map<String, dynamic> payload = {
        'firstName': firstName,
        'fatherName': fatherName,
        if (motherName.isNotEmpty) 'motherName': motherName,
        'gotra': gotra,
        if (maritalStatus == 'MARRIED' && spouseName.isNotEmpty)
          'spouseName': spouseName,
        if (maritalStatus == 'MARRIED' &&
            gender == 'FEMALE' &&
            husbandNameWithSurname.isNotEmpty)
          'husbandNameWithSurname': husbandNameWithSurname,
        if (maritalStatus == 'MARRIED' &&
            gender == 'FEMALE' &&
            sasuralGotra.isNotEmpty)
          'sasuralGotra': sasuralGotra,
        'gender': gender,
        'maritalStatus': maritalStatus,
        'dateOfBirth': dateOfBirth!.toIso8601String(),
        if (bloodGroup != null && bloodGroup!.isNotEmpty)
          'bloodGroup': bloodGroup,
        'occupationType': occupationType,
        if (occupationDetails != null) 'occupationDetails': occupationDetails,
        'gaon': gaon,
        'nativeDistrict': nativeDistrict,
        'nativeState': nativeState,
        if (currentAddress.isNotEmpty) 'currentAddress': currentAddress,
        'currentCity': currentCity,
        'currentState': currentState,
        if (pinCode.isNotEmpty) 'pinCode': pinCode,
        'phoneNumber': phoneNumber,
        if (whatsappNumber.isNotEmpty) 'whatsappNumber': whatsappNumber,
        'isPhoneNumberVisible': gender == 'MALE',
        'relationshipToHead': 'SELF',
        if (!isUpdateMode) 'password': password,
      };

      if (isUpdateMode) {
        await _userApi.updateMyProfile(payload);
      } else {
        await _userApi.completeProfile(payload);
      }

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('--- SUBMIT PROFILE ERROR ---');
      print(e);
      // Attempt to cast to dynamic to check for response data if it's a DioException
      try {
        final dynamic dioError = e;
        print('Response Data: ${dioError.response?.data}');
      } catch (_) {}

      error = "Failed to submit profile. Please check your connection.";
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
