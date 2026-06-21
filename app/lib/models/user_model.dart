class OccupationDetails {
  final String? businessName;
  final String? category;
  final String? address;
  final String? contact;
  final String? companyName;
  final String? designation;
  final String? industry;
  final String? city;
  final String? description;

  OccupationDetails({
    this.businessName,
    this.category,
    this.address,
    this.contact,
    this.companyName,
    this.designation,
    this.industry,
    this.city,
    this.description,
  });

  factory OccupationDetails.fromJson(Map<String, dynamic> json) {
    return OccupationDetails(
      businessName: json['businessName'],
      category: json['category'],
      address: json['address'],
      contact: json['contact'],
      companyName: json['companyName'],
      designation: json['designation'],
      industry: json['industry'],
      city: json['city'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'businessName': businessName,
      'category': category,
      'address': address,
      'contact': contact,
      'companyName': companyName,
      'designation': designation,
      'industry': industry,
      'city': city,
      'description': description,
    };
  }
}

class UserModel {
  final String id;
  final String? memberId;
  final String firstName;
  final String fatherName;
  final String? motherName;
  final String gotra;
  final String? spouseName;
  final String? husbandNameWithSurname;
  final String? sasuralGotra;
  final String gender;
  final String maritalStatus;
  final DateTime dateOfBirth;
  final String? bloodGroup;
  final String? photoUrl;
  final String email;
  final bool isEmailVerified;
  final String? education;
  final String occupationType;
  final OccupationDetails? occupationDetails;
  final String gaon;
  final String nativeDistrict;
  final String nativeState;
  final String? currentAddress;
  final String currentCity;
  final String currentState;
  final String? pinCode;
  final String phoneNumber;
  final String? whatsappNumber;
  final bool isPhoneNumberVisible;
  final bool isProfileComplete;
  final String familyId;
  final bool isHeadOfFamily;
  final String relationshipToHead;
  final String role;
  final String status;
  final List<String> assignedStates;

  UserModel({
    required this.id,
    this.memberId,
    required this.firstName,
    required this.fatherName,
    this.motherName,
    required this.gotra,
    this.spouseName,
    this.husbandNameWithSurname,
    this.sasuralGotra,
    required this.gender,
    required this.maritalStatus,
    required this.dateOfBirth,
    this.bloodGroup,
    this.photoUrl,
    required this.email,
    required this.isEmailVerified,
    this.education,
    required this.occupationType,
    this.occupationDetails,
    required this.gaon,
    required this.nativeDistrict,
    required this.nativeState,
    this.currentAddress,
    required this.currentCity,
    required this.currentState,
    this.pinCode,
    required this.phoneNumber,
    this.whatsappNumber,
    required this.isPhoneNumberVisible,
    required this.isProfileComplete,
    required this.familyId,
    required this.isHeadOfFamily,
    required this.relationshipToHead,
    required this.role,
    required this.status,
    required this.assignedStates,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      memberId: json['memberId'],
      firstName: json['firstName'] ?? '',
      fatherName: json['fatherName'] ?? '',
      motherName: json['motherName'],
      gotra: json['gotra'] ?? '',
      spouseName: json['spouseName'],
      husbandNameWithSurname: json['husbandNameWithSurname'],
      sasuralGotra: json['sasuralGotra'],
      gender: json['gender'] ?? 'OTHER',
      maritalStatus: json['maritalStatus'] ?? 'SINGLE',
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth']) : DateTime.now(),
      bloodGroup: json['bloodGroup'],
      photoUrl: json['photoUrl'],
      email: json['email'] ?? '',
      isEmailVerified: json['isEmailVerified'] ?? false,
      education: json['education'],
      occupationType: json['occupationType'] ?? 'OTHER',
      occupationDetails: json['occupationDetails'] != null ? OccupationDetails.fromJson(json['occupationDetails']) : null,
      gaon: json['gaon'] ?? '',
      nativeDistrict: json['nativeDistrict'] ?? '',
      nativeState: json['nativeState'] ?? '',
      currentAddress: json['currentAddress'],
      currentCity: json['currentCity'] ?? '',
      currentState: json['currentState'] ?? '',
      pinCode: json['pinCode'],
      phoneNumber: json['phoneNumber'] ?? '',
      whatsappNumber: json['whatsappNumber'],
      isPhoneNumberVisible: json['isPhoneNumberVisible'] ?? false,
      isProfileComplete: json['isProfileComplete'] ?? false,
      familyId: json['familyId'] ?? '',
      isHeadOfFamily: json['isHeadOfFamily'] ?? false,
      relationshipToHead: json['relationshipToHead'] ?? 'SELF',
      role: json['role'] ?? 'MEMBER',
      status: json['status'] ?? 'PENDING_APPROVAL',
      assignedStates: json['assignedStates'] != null ? List<String>.from(json['assignedStates']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'firstName': firstName,
      'fatherName': fatherName,
      'motherName': motherName,
      'gotra': gotra,
      'spouseName': spouseName,
      'husbandNameWithSurname': husbandNameWithSurname,
      'sasuralGotra': sasuralGotra,
      'gender': gender,
      'maritalStatus': maritalStatus,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'bloodGroup': bloodGroup,
      'photoUrl': photoUrl,
      'email': email,
      'isEmailVerified': isEmailVerified,
      'education': education,
      'occupationType': occupationType,
      'occupationDetails': occupationDetails?.toJson(),
      'gaon': gaon,
      'nativeDistrict': nativeDistrict,
      'nativeState': nativeState,
      'currentAddress': currentAddress,
      'currentCity': currentCity,
      'currentState': currentState,
      'pinCode': pinCode,
      'phoneNumber': phoneNumber,
      'whatsappNumber': whatsappNumber,
      'isPhoneNumberVisible': isPhoneNumberVisible,
      'isProfileComplete': isProfileComplete,
      'familyId': familyId,
      'isHeadOfFamily': isHeadOfFamily,
      'relationshipToHead': relationshipToHead,
      'role': role,
      'status': status,
      'assignedStates': assignedStates,
    };
  }

  UserModel copyWith({
    String? id,
    String? memberId,
    String? firstName,
    String? fatherName,
    String? motherName,
    String? gotra,
    String? spouseName,
    String? husbandNameWithSurname,
    String? sasuralGotra,
    String? gender,
    String? maritalStatus,
    DateTime? dateOfBirth,
    String? bloodGroup,
    String? photoUrl,
    String? email,
    bool? isEmailVerified,
    String? education,
    String? occupationType,
    OccupationDetails? occupationDetails,
    String? gaon,
    String? nativeDistrict,
    String? nativeState,
    String? currentAddress,
    String? currentCity,
    String? currentState,
    String? pinCode,
    String? phoneNumber,
    String? whatsappNumber,
    bool? isPhoneNumberVisible,
    bool? isProfileComplete,
    String? familyId,
    bool? isHeadOfFamily,
    String? relationshipToHead,
    String? role,
    String? status,
    List<String>? assignedStates,
  }) {
    return UserModel(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      firstName: firstName ?? this.firstName,
      fatherName: fatherName ?? this.fatherName,
      motherName: motherName ?? this.motherName,
      gotra: gotra ?? this.gotra,
      spouseName: spouseName ?? this.spouseName,
      husbandNameWithSurname: husbandNameWithSurname ?? this.husbandNameWithSurname,
      sasuralGotra: sasuralGotra ?? this.sasuralGotra,
      gender: gender ?? this.gender,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      photoUrl: photoUrl ?? this.photoUrl,
      email: email ?? this.email,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      education: education ?? this.education,
      occupationType: occupationType ?? this.occupationType,
      occupationDetails: occupationDetails ?? this.occupationDetails,
      gaon: gaon ?? this.gaon,
      nativeDistrict: nativeDistrict ?? this.nativeDistrict,
      nativeState: nativeState ?? this.nativeState,
      currentAddress: currentAddress ?? this.currentAddress,
      currentCity: currentCity ?? this.currentCity,
      currentState: currentState ?? this.currentState,
      pinCode: pinCode ?? this.pinCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      isPhoneNumberVisible: isPhoneNumberVisible ?? this.isPhoneNumberVisible,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      familyId: familyId ?? this.familyId,
      isHeadOfFamily: isHeadOfFamily ?? this.isHeadOfFamily,
      relationshipToHead: relationshipToHead ?? this.relationshipToHead,
      role: role ?? this.role,
      status: status ?? this.status,
      assignedStates: assignedStates ?? this.assignedStates,
    );
  }
}
