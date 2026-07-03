import 'user_model.dart';

class JobModel {
  final String id;
  final String type; // 'VACANCY_AVAILABLE' or 'JOB_REQUIRED'
  final String roleTitle;
  final String industry;
  final String city;
  final String? salaryRange;
  final String description;
  final String status;

  final String contactName;
  final String? contactPhone;
  final String? whatsappNumber;
  final String? contactEmail;
  final List<String> links;
  final UserModel? postedBy;
  final DateTime? createdAt;

  JobModel({
    required this.id,
    required this.type,
    required this.roleTitle,
    required this.industry,
    required this.city,
    this.salaryRange,
    required this.description,
    required this.status,
    required this.contactName,
    this.contactPhone,
    this.whatsappNumber,
    this.contactEmail,
    required this.links,
    this.postedBy,
    this.createdAt,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'],
      type: json['type'] ?? 'VACANCY_AVAILABLE',
      roleTitle: json['roleTitle'] ?? '',
      industry: json['industry'] ?? '',
      city: json['city'] ?? '',
      salaryRange: json['salaryRange'],
      description: json['description'] ?? '',
      status: json['status'] ?? 'PENDING',
      contactName: json['contactName'] ?? '',
      contactPhone: json['contactPhone'],
      whatsappNumber: json['whatsappNumber'],
      contactEmail: json['contactEmail'],
      links:
          (json['links'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
      postedBy: json['postedBy'] != null
          ? UserModel.fromJson(json['postedBy'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'roleTitle': roleTitle,
      'industry': industry,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'whatsappNumber': whatsappNumber,
      'contactEmail': contactEmail,
      'city': city,
      'salaryRange': salaryRange,
      'description': description,
      'status': status,
      'links': links,
    };
  }
}
