import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../models/user_model.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/sliver_app_bar_delegate.dart';
import '../../profile/widgets/user_activity_tab.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../family/screens/family_tree_screen.dart';

class ContactDetailScreen extends StatefulWidget {
  final UserModel contact;

  const ContactDetailScreen({super.key, required this.contact});

  @override
  State<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _previousTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 2) {
        _tabController.index = _previousTabIndex;
        if (widget.contact.familyId != null && widget.contact.familyId!.isNotEmpty) {
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (_) => FamilyTreeScreen(familyId: widget.contact.familyId),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('This contact has no family linked.')),
          );
        }
      } else {
        _previousTabIndex = _tabController.index;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
        body: NestedScrollView(
          physics: const BouncingScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: widget.contact.photoUrl != null
                            ? NetworkImage(widget.contact.photoUrl!)
                                as ImageProvider
                            : NetworkImage(
                                'https://api.dicebear.com/10.x/glass/png?seed=${widget.contact.firstName}',
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${widget.contact.firstName} ${widget.contact.fatherName} ${widget.contact.gotra}'
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
                            'Member ID: ${widget.contact.memberId ?? 'Pending'}',
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
                    controller: _tabController,
                    indicatorColor: AppTheme.primaryPurple,
                    labelColor: AppTheme.primaryPurple,
                    unselectedLabelColor: Colors.black54,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'Profile'),
                      Tab(text: 'Activity'),
                      Tab(text: 'Family'),
                    ],
                  ),
                  backgroundColor: Colors.white.withOpacity(0.90),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
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
                        widget.contact.gender,
                      ),
                      _buildInfoRow(
                        HugeIcons.strokeRoundedCalendar01,
                        'Date of Birth',
                        '${widget.contact.dateOfBirth.day}/${widget.contact.dateOfBirth.month}/${widget.contact.dateOfBirth.year}',
                      ),
                      if (widget.contact.bloodGroup != null &&
                          widget.contact.bloodGroup!.isNotEmpty)
                        _buildInfoRow(
                          HugeIcons.strokeRoundedBlood,
                          'Blood Group',
                          widget.contact.bloodGroup!,
                        ),
                      _buildInfoRow(
                        HugeIcons.strokeRoundedFavourite,
                        'Marital Status',
                        widget.contact.maritalStatus,
                      ),
                      _buildInfoRow(
                        HugeIcons.strokeRoundedBookOpen01,
                        'Gotra',
                        widget.contact.gotra,
                      ),
                      if (widget.contact.motherName != null &&
                          widget.contact.motherName!.isNotEmpty)
                        _buildInfoRow(
                          HugeIcons.strokeRoundedUserLove01,
                          'Mother Name',
                          widget.contact.motherName!,
                        ),
                      if (widget.contact.spouseName != null &&
                          widget.contact.spouseName!.isNotEmpty)
                        _buildInfoRow(
                          HugeIcons.strokeRoundedHeartAdd,
                          'Spouse Name',
                          widget.contact.spouseName!,
                        ),
                      if (widget.contact.husbandNameWithSurname != null &&
                          widget.contact.husbandNameWithSurname!.isNotEmpty)
                        _buildInfoRow(
                          HugeIcons.strokeRoundedHeartAdd,
                          'Husband Name',
                          widget.contact.husbandNameWithSurname!,
                        ),
                      if (widget.contact.sasuralGotra != null &&
                          widget.contact.sasuralGotra!.isNotEmpty)
                        _buildInfoRow(
                          HugeIcons.strokeRoundedBookOpen02,
                          'Sasural Gotra',
                          widget.contact.sasuralGotra!,
                        ),
                    ]),

                    _buildSectionCard('Contact Details', [
                      if (widget.contact.isPhoneNumberVisible)
                        _buildInfoRow(
                          HugeIcons.strokeRoundedCall02,
                          'Phone Number',
                          widget.contact.phoneNumber,
                        ),
                      if (widget.contact.whatsappNumber != null &&
                          widget.contact.whatsappNumber!.isNotEmpty)
                        _buildInfoRow(
                          HugeIcons.strokeRoundedMessage02,
                          'WhatsApp',
                          widget.contact.whatsappNumber!,
                        ),
                      _buildInfoRow(
                        HugeIcons.strokeRoundedMail01,
                        'Email',
                        widget.contact.email,
                      ),
                      if (widget.contact.currentAddress != null &&
                          widget.contact.currentAddress!.isNotEmpty)
                        _buildInfoRow(
                          HugeIcons.strokeRoundedLocation01,
                          'Current Address',
                          widget.contact.currentAddress!,
                        ),
                      _buildInfoRow(
                        HugeIcons.strokeRoundedCity01,
                        'Current City/State',
                        '${widget.contact.currentCity}, ${widget.contact.currentState}',
                      ),
                      if (widget.contact.pinCode != null &&
                          widget.contact.pinCode!.isNotEmpty)
                        _buildInfoRow(
                          HugeIcons.strokeRoundedLocation03,
                          'Pincode',
                          widget.contact.pinCode!,
                        ),
                      _buildInfoRow(
                        HugeIcons.strokeRoundedMapPin,
                        'Native Village',
                        widget.contact.gaon,
                      ),
                      _buildInfoRow(
                        HugeIcons.strokeRoundedMapPin,
                        'Native Location',
                        '${widget.contact.nativeDistrict}, ${widget.contact.nativeState}',
                      ),
                    ]),

                    _buildSectionCard('Occupation & Education', [
                      if (widget.contact.education != null &&
                          widget.contact.education!.isNotEmpty)
                        _buildInfoRow(
                          HugeIcons.strokeRoundedMortarboard01,
                          'Education',
                          widget.contact.education!,
                        ),
                      _buildInfoRow(
                        HugeIcons.strokeRoundedBriefcase02,
                        'Occupation Type',
                        widget.contact.occupationType,
                      ),
                      if (widget.contact.occupationDetails?.companyName != null &&
                          widget.contact.occupationDetails!.companyName!.isNotEmpty)
                        _buildInfoRow(
                          HugeIcons.strokeRoundedBuilding03,
                          'Company',
                          widget.contact.occupationDetails!.companyName!,
                        ),
                      if (widget.contact.occupationDetails?.designation != null &&
                          widget.contact.occupationDetails!.designation!.isNotEmpty)
                        _buildInfoRow(
                          HugeIcons.strokeRoundedUser,
                          'Designation',
                          widget.contact.occupationDetails!.designation!,
                        ),
                      if (widget.contact.occupationDetails?.businessName != null &&
                          widget.contact.occupationDetails!.businessName!.isNotEmpty)
                        _buildInfoRow(
                          HugeIcons.strokeRoundedStore01,
                          'Business Name',
                          widget.contact.occupationDetails!.businessName!,
                        ),
                      if (widget.contact.occupationDetails?.category != null &&
                          widget.contact.occupationDetails!.category!.isNotEmpty)
                        _buildInfoRow(
                          HugeIcons.strokeRoundedTag01,
                          'Category',
                          widget.contact.occupationDetails!.category!,
                        ),
                      if (widget.contact.occupationDetails?.industry != null &&
                          widget.contact.occupationDetails!.industry!.isNotEmpty)
                        _buildInfoRow(
                          HugeIcons.strokeRoundedFactory,
                          'Industry',
                          widget.contact.occupationDetails!.industry!,
                        ),
                      if (widget.contact.occupationDetails?.address != null &&
                          widget.contact.occupationDetails!.address!.isNotEmpty)
                        _buildInfoRow(
                          HugeIcons.strokeRoundedLocation04,
                          'Work Address',
                          '${widget.contact.occupationDetails!.address!}${widget.contact.occupationDetails?.city != null ? ', ${widget.contact.occupationDetails!.city}' : ''}',
                        ),
                    ]),

                    // --- Family Information ---
                    _buildSectionCard('Family Information', [
                      _buildInfoRow(
                        HugeIcons.strokeRoundedHome01,
                        'Role in Family',
                        widget.contact.relationshipToHead,
                      ),
                      _buildInfoRow(
                        HugeIcons.strokeRoundedUserGroup,
                        'Head of Family',
                        widget.contact.isHeadOfFamily ? 'Yes' : 'No',
                      ),
                    ]),
                  ],
                ),
              ),
              // Activity Tab
              UserActivityTab(userId: widget.contact.id),
              // Family Tab Placeholder
              const SizedBox.shrink(),
            ],
          ),
        ),
        bottomNavigationBar:
            (widget.contact.isPhoneNumberVisible && widget.contact.phoneNumber.isNotEmpty)
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
                              'tel:${widget.contact.phoneNumber}',
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
                            final String waPhone = widget.contact.phoneNumber
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
