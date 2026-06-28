import 'user_model.dart';

class BusinessListing {
  final String id;
  final String ownerId;
  final String businessName;
  final String category;
  final String? description;
  final String? logoUrl;
  final String? website;
  final String contactNumber;
  final String address;
  final String city;
  final String state;
  final String status;
  final UserModel? owner;

  BusinessListing({
    required this.id,
    required this.ownerId,
    required this.businessName,
    required this.category,
    this.description,
    this.logoUrl,
    this.website,
    required this.contactNumber,
    required this.address,
    required this.city,
    required this.state,
    required this.status,
    this.owner,
  });

  factory BusinessListing.fromJson(Map<String, dynamic> json) {
    return BusinessListing(
      id: json['id'],
      ownerId: json['ownerId'],
      businessName: json['businessName'] ?? 'Unknown Business',
      category: json['category'] ?? 'OTHER',
      description: json['description'],
      logoUrl: json['logoUrl'],
      website: json['website'],
      contactNumber: json['contactNumber'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      status: json['status'] ?? 'PENDING',
      owner: json['owner'] != null ? UserModel.fromJson(json['owner']) : null,
    );
  }
}
