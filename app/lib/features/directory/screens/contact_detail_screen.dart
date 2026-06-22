import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../models/user_model.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/sliver_app_bar_delegate.dart';
import '../../profile/widgets/user_activity_tab.dart';
import 'package:url_launcher/url_launcher.dart';

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
        body: DefaultTabController(
          length: 2,
          child: NestedScrollView(
            physics: const BouncingScrollPhysics(),
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(shape: BoxShape.circle),
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
                    ],
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: SliverAppBarDelegate(
                    TabBar(
                      indicatorColor: AppTheme.primaryPurple,
                      labelColor: AppTheme.primaryPurple,
                      unselectedLabelColor: Colors.black54,
                      indicatorWeight: 3,
                      tabs: const [
                        Tab(text: 'Profile'),
                        Tab(text: 'Activity'),
                      ],
                    ),
                    backgroundColor: Colors.white.withOpacity(0.90),
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: [
                // Profile Tab
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    children: [
                      _buildSectionCard('Personal Information', [
                        _buildInfoRow(
                          HugeIcons.strokeRoundedUser,
                          'Gender',
                          contact.gender,
                        ),
                        _buildInfoRow(
                          HugeIcons.strokeRoundedCalendar01,
                          'Date of Birth',
                          '${contact.dateOfBirth.day}/${contact.dateOfBirth.month}/${contact.dateOfBirth.year}',
                        ),
                        if (contact.bloodGroup != null &&
                            contact.bloodGroup!.isNotEmpty)
                          _buildInfoRow(
                            HugeIcons.strokeRoundedBlood,
                            'Blood Group',
                            contact.bloodGroup!,
                          ),
                        _buildInfoRow(
                          HugeIcons.strokeRoundedFavourite,
                          'Marital Status',
                          contact.maritalStatus,
                        ),
                        _buildInfoRow(
                          HugeIcons.strokeRoundedBookOpen01,
                          'Gotra',
                          contact.gotra,
                        ),
                        if (contact.motherName != null &&
                            contact.motherName!.isNotEmpty)
                          _buildInfoRow(
                            HugeIcons.strokeRoundedUserLove01,
                            'Mother Name',
                            contact.motherName!,
                          ),
                        if (contact.spouseName != null &&
                            contact.spouseName!.isNotEmpty)
                          _buildInfoRow(
                            HugeIcons.strokeRoundedHeartAdd,
                            'Spouse Name',
                            contact.spouseName!,
                          ),
                        if (contact.husbandNameWithSurname != null &&
                            contact.husbandNameWithSurname!.isNotEmpty)
                          _buildInfoRow(
                            HugeIcons.strokeRoundedHeartAdd,
                            'Husband Name',
                            contact.husbandNameWithSurname!,
                          ),
                        if (contact.sasuralGotra != null &&
                            contact.sasuralGotra!.isNotEmpty)
                          _buildInfoRow(
                            HugeIcons.strokeRoundedBookOpen02,
                            'Sasural Gotra',
                            contact.sasuralGotra!,
                          ),
                      ]),

                      _buildSectionCard('Contact Details', [
                        if (contact.isPhoneNumberVisible)
                          _buildInfoRow(
                            HugeIcons.strokeRoundedCall02,
                            'Phone Number',
                            contact.phoneNumber,
                          ),
                        if (contact.whatsappNumber != null &&
                            contact.whatsappNumber!.isNotEmpty)
                          _buildInfoRow(
                            HugeIcons.strokeRoundedMessage02,
                            'WhatsApp',
                            contact.whatsappNumber!,
                          ),
                        _buildInfoRow(
                          HugeIcons.strokeRoundedMail01,
                          'Email',
                          contact.email,
                        ),
                        if (contact.currentAddress != null &&
                            contact.currentAddress!.isNotEmpty)
                          _buildInfoRow(
                            HugeIcons.strokeRoundedLocation01,
                            'Current Address',
                            contact.currentAddress!,
                          ),
                        _buildInfoRow(
                          HugeIcons.strokeRoundedCity01,
                          'Current City/State',
                          '${contact.currentCity}, ${contact.currentState}',
                        ),
                        if (contact.pinCode != null &&
                            contact.pinCode!.isNotEmpty)
                          _buildInfoRow(
                            HugeIcons.strokeRoundedLocation03,
                            'Pincode',
                            contact.pinCode!,
                          ),
                        _buildInfoRow(
                          HugeIcons.strokeRoundedMapPin,
                          'Native Village',
                          contact.gaon,
                        ),
                        _buildInfoRow(
                          HugeIcons.strokeRoundedMapPin,
                          'Native Location',
                          '${contact.nativeDistrict}, ${contact.nativeState}',
                        ),
                      ]),

                      _buildSectionCard('Occupation & Education', [
                        if (contact.education != null &&
                            contact.education!.isNotEmpty)
                          _buildInfoRow(
                            HugeIcons.strokeRoundedMortarboard01,
                            'Education',
                            contact.education!,
                          ),
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
                        if (contact.occupationDetails?.address != null &&
                            contact.occupationDetails!.address!.isNotEmpty)
                          _buildInfoRow(
                            HugeIcons.strokeRoundedLocation04,
                            'Work Address',
                            '${contact.occupationDetails!.address!}${contact.occupationDetails?.city != null ? ', ${contact.occupationDetails!.city}' : ''}',
                          ),
                      ]),

                      // --- Family Information ---
                      _buildSectionCard('Family Information', [
                        _buildInfoRow(
                          HugeIcons.strokeRoundedHome01,
                          'Role in Family',
                          contact.relationshipToHead,
                        ),
                        _buildInfoRow(
                          HugeIcons.strokeRoundedUserGroup,
                          'Head of Family',
                          contact.isHeadOfFamily ? 'Yes' : 'No',
                        ),
                      ]),
                    ],
                  ),
                ),
                // Activity Tab
                UserActivityTab(userId: contact.id),
              ],
            ),
          ),
        ),
        bottomNavigationBar:
            (contact.isPhoneNumberVisible && contact.phoneNumber.isNotEmpty)
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final Uri url = Uri.parse(
                              'tel:${contact.phoneNumber}',
                            );
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            }
                          },
                          icon: const HugeIcon(
                            icon: HugeIcons.strokeRoundedCall02,
                            color: Colors.white,
                            size: 20,
                          ),
                          label: const Text(
                            'Call',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryPurple,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final String waPhone = contact.phoneNumber
                                .replaceAll(RegExp(r'\D'), '');
                            final String finalPhone = waPhone.length == 10
                                ? '91$waPhone'
                                : waPhone;
                            final Uri url = Uri.parse(
                              'https://wa.me/$finalPhone',
                            );
                            if (await canLaunchUrl(url)) {
                              await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          },
                          icon: const HugeIcon(
                            icon: HugeIcons.strokeRoundedWhatsapp,
                            color: Colors.white,
                            size: 20,
                          ),
                          label: const Text(
                            'WhatsApp',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
