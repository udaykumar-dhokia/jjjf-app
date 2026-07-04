class MatrimonialProfile {
  final String id;
  final String userId;
  final String? height;
  final num? weight;
  final String subCaste;
  final String educationDetails;
  final String? monthlyIncome;
  final String? aboutMe;
  final String? expectations;
  final List<String> photoGallery;
  final String? biodataPdfUrl;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Flattened user fields for convenience (returned from backend)
  final String? firstName;
  final String? gotra;
  final DateTime? dateOfBirth;
  final int? age;
  final String? phoneNumber;
  final String? whatsappNumber;
  final String? currentCity;

  MatrimonialProfile({
    required this.id,
    required this.userId,
    this.height,
    this.weight,
    required this.subCaste,
    required this.educationDetails,
    this.monthlyIncome,
    this.aboutMe,
    this.expectations,
    required this.photoGallery,
    this.biodataPdfUrl,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.firstName,
    this.gotra,
    this.dateOfBirth,
    this.age,
    this.phoneNumber,
    this.whatsappNumber,
    this.currentCity,
  });

  factory MatrimonialProfile.fromJson(Map<String, dynamic> json) {
    DateTime? dateOfBirthObj = json['dateOfBirth'] != null 
          ? DateTime.tryParse(json['dateOfBirth']) 
          : (json['user'] != null && json['user']['dateOfBirth'] != null 
              ? DateTime.tryParse(json['user']['dateOfBirth']) 
              : null);

    return MatrimonialProfile(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      height: json['height'],
      weight: json['weight'],
      subCaste: json['subCaste'] ?? '',
      educationDetails: json['educationDetails'] ?? '',
      monthlyIncome: json['monthlyIncome'],
      aboutMe: json['aboutMe'],
      expectations: json['expectations'],
      photoGallery: json['photoGallery'] != null 
          ? List<String>.from(json['photoGallery']) 
          : [],
      biodataPdfUrl: json['biodataPdfUrl'],
      status: json['status'] ?? 'PENDING',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
      firstName: json['firstName'] ?? (json['user'] != null ? json['user']['firstName'] : null),
      gotra: json['gotra'] ?? (json['user'] != null ? json['user']['gotra'] : null),
      phoneNumber: json['phoneNumber'] ?? (json['user'] != null ? json['user']['phoneNumber'] : null),
      whatsappNumber: json['whatsappNumber'] ?? (json['user'] != null ? json['user']['whatsappNumber'] : null),
      currentCity: json['currentCity'] ?? (json['user'] != null ? json['user']['currentCity'] : null),
      dateOfBirth: dateOfBirthObj,
      age: json['age'] ?? (dateOfBirthObj != null ? _calculateAge(dateOfBirthObj) : null),
    );
  }

  static int _calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'height': height,
      'weight': weight,
      'subCaste': subCaste,
      'educationDetails': educationDetails,
      'monthlyIncome': monthlyIncome,
      'aboutMe': aboutMe,
      'expectations': expectations,
      'photoGallery': photoGallery,
      'biodataPdfUrl': biodataPdfUrl,
      'status': status,
    };
  }
}
