import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../models/user_model.dart';
import '../../../core/widgets/custom_app_bar.dart';

class ContactDetailScreen extends StatelessWidget {
  final UserModel contact;

  const ContactDetailScreen({super.key, required this.contact});

  Widget _buildInfoRow(dynamic icon, String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HugeIcon(
            icon: icon,
            size: 20,
            color: AppTheme.primaryPurple.withOpacity(0.7),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    final validChildren = children.where((w) => w is! SizedBox).toList();
    if (validChildren.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryPurple,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Colors.black12),
          const SizedBox(height: 12),
          ...validChildren,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CustomAppBar(
          title: 'Contact Details',
          leading: IconButton(
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              color: AppTheme.primaryPurple,
              size: 24,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // --- Avatar Header ---
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage(
                    'https://api.dicebear.com/10.x/glass/png?seed=${contact.firstName}',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${contact.firstName} ${contact.fatherName} ${contact.gotra}'
                    .trim(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Member ID: ${contact.memberId ?? 'Pending'}',
                      style: const TextStyle(
                        color: AppTheme.primaryPurple,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- Personal Information ---
              _buildSectionCard('Personal Information', [
                _buildInfoRow(
                  HugeIcons.strokeRoundedUser,
                  'Gender',
                  contact.gender,
                ),
                if (contact.bloodGroup != null &&
                    contact.bloodGroup!.isNotEmpty)
                  _buildInfoRow(
                    HugeIcons.strokeRoundedBlood,
                    'Blood Group',
                    contact.bloodGroup!,
                  ),
                _buildInfoRow(
                  HugeIcons.strokeRoundedBookOpen01,
                  'Gotra',
                  contact.gotra,
                ),
              ]),

              // --- Contact Details ---
              _buildSectionCard('Contact Details', [
                if (contact.isPhoneNumberVisible)
                  _buildInfoRow(
                    HugeIcons.strokeRoundedCall02,
                    'Phone Number',
                    contact.phoneNumber,
                  ),
                _buildInfoRow(
                  HugeIcons.strokeRoundedCity01,
                  'Current City',
                  contact.currentCity,
                ),
                _buildInfoRow(
                  HugeIcons.strokeRoundedMapPin,
                  'Native Village',
                  contact.gaon,
                ),
                if (contact.nativeDistrict.isNotEmpty)
                  _buildInfoRow(
                    HugeIcons.strokeRoundedMapPin,
                    'Native District',
                    contact.nativeDistrict,
                  ),
              ]),

              // --- Occupation & Education ---
              _buildSectionCard('Occupation', [
                _buildInfoRow(
                  HugeIcons.strokeRoundedBriefcase02,
                  'Occupation Type',
                  contact.occupationType,
                ),
                if (contact.occupationDetails?.companyName != null &&
                    contact.occupationDetails!.companyName!.isNotEmpty)
                  _buildInfoRow(
                    HugeIcons.strokeRoundedBuilding03,
                    'Company',
                    contact.occupationDetails!.companyName!,
                  ),
                if (contact.occupationDetails?.designation != null &&
                    contact.occupationDetails!.designation!.isNotEmpty)
                  _buildInfoRow(
                    HugeIcons.strokeRoundedUser,
                    'Designation',
                    contact.occupationDetails!.designation!,
                  ),
                if (contact.occupationDetails?.businessName != null &&
                    contact.occupationDetails!.businessName!.isNotEmpty)
                  _buildInfoRow(
                    HugeIcons.strokeRoundedStore01,
                    'Business Name',
                    contact.occupationDetails!.businessName!,
                  ),
                if (contact.occupationDetails?.category != null &&
                    contact.occupationDetails!.category!.isNotEmpty)
                  _buildInfoRow(
                    HugeIcons.strokeRoundedTag01,
                    'Category',
                    contact.occupationDetails!.category!,
                  ),
                if (contact.occupationDetails?.industry != null &&
                    contact.occupationDetails!.industry!.isNotEmpty)
                  _buildInfoRow(
                    HugeIcons.strokeRoundedFactory,
                    'Industry',
                    contact.occupationDetails!.industry!,
                  ),
              ]),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
