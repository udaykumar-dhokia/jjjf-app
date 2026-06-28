import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:app/models/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../core/widgets/sliver_app_bar_delegate.dart';
import '../widgets/user_activity_tab.dart';
import '../widgets/user_business_tab.dart';
import 'update_profile_screen.dart';
import '../../auth/screens/login_screen.dart';
import '../../family/screens/family_tree_screen.dart';
import '../../../core/widgets/skeleton_loading_wrapper.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onMenuTap;

  const ProfileScreen({super.key, this.onMenuTap});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  bool _isUploadingProfilePic = false;

  TabController? _tabController;
  int _previousTabIndex = 0;
  bool _hasBusiness = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchMyProfile();
    });
  }

  void _updateTabController(bool hasBusiness) {
    if (_tabController == null || _hasBusiness != hasBusiness) {
      _hasBusiness = hasBusiness;
      _tabController?.dispose();
      _tabController = TabController(length: hasBusiness ? 4 : 3, vsync: this);
      _tabController!.addListener(() {
        final familyIndex = _hasBusiness ? 3 : 2;
        if (_tabController!.index == familyIndex) {
          _tabController!.index = _previousTabIndex;
          Navigator.of(
            context,
            rootNavigator: true,
          ).push(MaterialPageRoute(builder: (_) => const FamilyTreeScreen()));
        } else {
          _previousTabIndex = _tabController!.index;
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _showImagePickerOptions(BuildContext context, UserProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const HugeIcon(
                  icon: HugeIcons.strokeRoundedCamera01,
                  color: AppTheme.primaryPurple,
                ),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera, provider);
                },
              ),
              ListTile(
                leading: const HugeIcon(
                  icon: HugeIcons.strokeRoundedImage01,
                  color: AppTheme.primaryPurple,
                ),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery, provider);
                },
              ),
              if (provider.userProfile?.photoUrl != null)
                ListTile(
                  leading: const HugeIcon(
                    icon: HugeIcons.strokeRoundedDelete01,
                    color: Colors.red,
                  ),
                  title: const Text(
                    'Remove photo',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _removeImage(provider);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source, UserProvider provider) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (image != null) {
        setState(() => _isUploadingProfilePic = true);
        final success = await provider.uploadProfileImage(File(image.path));
        setState(() => _isUploadingProfilePic = false);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully'),
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                provider.error ?? 'Failed to update profile picture',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Error selecting image')));
      }
    }
  }

  Future<void> _removeImage(UserProvider provider) async {
    setState(() => _isUploadingProfilePic = true);
    final success = await provider.removeProfileImage();
    setState(() => _isUploadingProfilePic = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture removed successfully')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to remove profile picture'),
        ),
      );
    }
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

  void _showSettingsBottomSheet(
    BuildContext context,
    UserModel user,
    UserProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Settings',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.black12, height: 1),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text(
                  'Show Phone Number in Directory',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Allow other members to see your phone number.',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
                activeColor: AppTheme.primaryPurple,
                value: user.isPhoneNumberVisible,
                onChanged: (bool value) {
                  provider.updatePhoneVisibility(value);
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final authProvider = context.read<AuthProvider>();
    final user = userProvider.userProfile;
    final hasBusiness =
        user?.occupationType.toUpperCase().contains('BUSINESS') ?? false;

    if (user != null) {
      _updateTabController(hasBusiness);
    }

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CustomAppBar(
          title: 'My Profile',
          leading: widget.onMenuTap != null
              ? IconButton(
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedMenu01,
                    color: AppTheme.primaryPurple,
                    size: 24,
                  ),
                  onPressed: widget.onMenuTap,
                )
              : null,
          actions: user != null
              ? [
                  IconButton(
                    icon: const HugeIcon(
                      icon: HugeIcons.strokeRoundedSettings01,
                      color: AppTheme.primaryPurple,
                      size: 20,
                    ),
                    onPressed: () {
                      _showSettingsBottomSheet(context, user, userProvider);
                    },
                  ),
                  IconButton(
                    icon: const HugeIcon(
                      icon: HugeIcons.strokeRoundedEdit02,
                      color: AppTheme.primaryPurple,
                      size: 20,
                    ),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              UpdateProfileScreen(currentUser: user),
                        ),
                      );
                    },
                  ),
                ]
              : null,
        ),
        body: SkeletonLoadingWrapper(
          isLoading: userProvider.isLoading,
          child: userProvider.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        userProvider.error!,
                        style: const TextStyle(color: AppTheme.textLight),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => userProvider.fetchMyProfile(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : user == null
              ? const Center(child: Text('No profile data found.'))
              : RefreshIndicator(
                  onRefresh: () => userProvider.fetchMyProfile(),
                  child: NestedScrollView(
                    physics: const BouncingScrollPhysics(),
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return [
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              const SizedBox(height: 24),
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: user.status == 'PENDING_APPROVAL'
                                      ? Border.all(
                                          color: Colors.orange,
                                          width: 2,
                                        )
                                      : null,
                                ),
                                child: GestureDetector(
                                  onTap: () => _showImagePickerOptions(
                                    context,
                                    userProvider,
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 50,
                                        backgroundColor: Colors.white,
                                        backgroundImage: user.photoUrl != null
                                            ? NetworkImage(user.photoUrl!)
                                                  as ImageProvider
                                            : NetworkImage(
                                                'https://api.dicebear.com/10.x/glass/png?seed=${user.firstName}',
                                              ),
                                      ),
                                      if (_isUploadingProfilePic)
                                        Container(
                                          width: 100,
                                          height: 100,
                                          decoration: const BoxDecoration(
                                            color: Colors.black45,
                                            shape: BoxShape.circle,
                                          ),
                                          child:
                                              const CupertinoActivityIndicator(
                                                color: Colors.white,
                                              ),
                                        ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryPurple,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                          child: const HugeIcon(
                                            icon:
                                                HugeIcons.strokeRoundedCamera01,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '${user.firstName} ${user.fatherName} ${user.gotra}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 14),
                            ],
                          ),
                        ),
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: SliverAppBarDelegate(
                            TabBar(
                              controller: _tabController!,
                              indicatorColor: AppTheme.primaryPurple,
                              labelColor: AppTheme.primaryPurple,
                              unselectedLabelColor: Colors.black54,
                              indicatorWeight: 3,
                              tabs: [
                                const Tab(text: 'Profile'),
                                const Tab(text: 'Activity'),
                                if (hasBusiness) const Tab(text: 'Business'),
                                const Tab(text: 'Family'),
                              ],
                            ),
                            backgroundColor: Colors.white.withOpacity(0.95),
                          ),
                        ),
                      ];
                    },
                    body: TabBarView(
                      controller: _tabController!,
                      children: [
                        // Profile Tab
                        SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 100),
                          child: Column(
                            children: [
                              const SizedBox(height: 16),
                              _buildSectionCard('Personal Information', [
                                _buildInfoRow(
                                  HugeIcons.strokeRoundedUser,
                                  'Gender',
                                  user.gender,
                                ),
                                _buildInfoRow(
                                  HugeIcons.strokeRoundedCalendar01,
                                  'Date of Birth',
                                  '${user.dateOfBirth.day}/${user.dateOfBirth.month}/${user.dateOfBirth.year}',
                                ),
                                if (user.bloodGroup != null &&
                                    user.bloodGroup!.isNotEmpty)
                                  _buildInfoRow(
                                    HugeIcons.strokeRoundedBlood,
                                    'Blood Group',
                                    user.bloodGroup!,
                                  ),
                                _buildInfoRow(
                                  HugeIcons.strokeRoundedFavourite,
                                  'Marital Status',
                                  user.maritalStatus,
                                ),
                                _buildInfoRow(
                                  HugeIcons.strokeRoundedBookOpen01,
                                  'Gotra',
                                  user.gotra,
                                ),
                                if (user.motherName != null &&
                                    user.motherName!.isNotEmpty)
                                  _buildInfoRow(
                                    HugeIcons.strokeRoundedUserLove01,
                                    'Mother Name',
                                    user.motherName!,
                                  ),
                                if (user.spouseName != null &&
                                    user.spouseName!.isNotEmpty)
                                  _buildInfoRow(
                                    HugeIcons.strokeRoundedHeartAdd,
                                    'Spouse Name',
                                    user.spouseName!,
                                  ),
                                if (user.husbandNameWithSurname != null &&
                                    user.husbandNameWithSurname!.isNotEmpty)
                                  _buildInfoRow(
                                    HugeIcons.strokeRoundedHeartAdd,
                                    'Husband Name',
                                    user.husbandNameWithSurname!,
                                  ),
                                if (user.sasuralGotra != null &&
                                    user.sasuralGotra!.isNotEmpty)
                                  _buildInfoRow(
                                    HugeIcons.strokeRoundedBookOpen02,
                                    'Sasural Gotra',
                                    user.sasuralGotra!,
                                  ),
                              ]),

                              _buildSectionCard('Contact Details', [
                                _buildInfoRow(
                                  HugeIcons.strokeRoundedCall02,
                                  'Phone Number',
                                  user.phoneNumber,
                                ),
                                if (user.whatsappNumber != null &&
                                    user.whatsappNumber!.isNotEmpty)
                                  _buildInfoRow(
                                    HugeIcons.strokeRoundedMessage02,
                                    'WhatsApp',
                                    user.whatsappNumber!,
                                  ),
                                _buildInfoRow(
                                  HugeIcons.strokeRoundedMail01,
                                  'Email',
                                  user.email,
                                ),
                                if (user.currentAddress != null &&
                                    user.currentAddress!.isNotEmpty)
                                  _buildInfoRow(
                                    HugeIcons.strokeRoundedLocation01,
                                    'Current Address',
                                    user.currentAddress!,
                                  ),
                                _buildInfoRow(
                                  HugeIcons.strokeRoundedCity01,
                                  'Current City/State',
                                  '${user.currentCity}, ${user.currentState}',
                                ),
                                if (user.pinCode != null &&
                                    user.pinCode!.isNotEmpty)
                                  _buildInfoRow(
                                    HugeIcons.strokeRoundedLocation03,
                                    'Pincode',
                                    user.pinCode!,
                                  ),
                                _buildInfoRow(
                                  HugeIcons.strokeRoundedMapPin,
                                  'Native Village',
                                  user.gaon,
                                ),
                                _buildInfoRow(
                                  HugeIcons.strokeRoundedMapPin,
                                  'Native Location',
                                  '${user.nativeDistrict}, ${user.nativeState}',
                                ),
                              ]),

                              _buildSectionCard('Occupation & Education', [
                                if (user.education != null &&
                                    user.education!.isNotEmpty)
                                  _buildInfoRow(
                                    HugeIcons.strokeRoundedMortarboard01,
                                    'Education',
                                    user.education!,
                                  ),
                                _buildInfoRow(
                                  HugeIcons.strokeRoundedBriefcase02,
                                  'Occupation Type',
                                  user.occupationType,
                                ),
                                if (user.occupationDetails?.companyName !=
                                        null &&
                                    user
                                        .occupationDetails!
                                        .companyName!
                                        .isNotEmpty)
                                  _buildInfoRow(
                                    HugeIcons.strokeRoundedBuilding03,
                                    'Company',
                                    user.occupationDetails!.companyName!,
                                  ),
                                if (user.occupationDetails?.designation !=
                                        null &&
                                    user
                                        .occupationDetails!
                                        .designation!
                                        .isNotEmpty)
                                  _buildInfoRow(
                                    HugeIcons.strokeRoundedUser,
                                    'Designation',
                                    user.occupationDetails!.designation!,
                                  ),
                                if (user.occupationDetails?.businessName !=
                                        null &&
                                    user
                                        .occupationDetails!
                                        .businessName!
                                        .isNotEmpty)
                                  _buildInfoRow(
                                    HugeIcons.strokeRoundedStore01,
                                    'Business Name',
                                    user.occupationDetails!.businessName!,
                                  ),
                                if (user.occupationDetails?.category != null &&
                                    user
                                        .occupationDetails!
                                        .category!
                                        .isNotEmpty)
                                  _buildInfoRow(
                                    HugeIcons.strokeRoundedTag01,
                                    'Business Category',
                                    user.occupationDetails!.category!,
                                  ),
                                if (user.occupationDetails?.industry != null &&
                                    user
                                        .occupationDetails!
                                        .industry!
                                        .isNotEmpty)
                                  _buildInfoRow(
                                    HugeIcons.strokeRoundedFactory,
                                    'Industry',
                                    user.occupationDetails!.industry!,
                                  ),
                                if (user.occupationDetails?.address != null &&
                                    user.occupationDetails!.address!.isNotEmpty)
                                  _buildInfoRow(
                                    HugeIcons.strokeRoundedLocation04,
                                    'Work Address',
                                    '${user.occupationDetails!.address!}${user.occupationDetails?.city != null ? ', ${user.occupationDetails!.city}' : ''}',
                                  ),
                              ]),

                              _buildSectionCard('Family Information', [
                                _buildInfoRow(
                                  HugeIcons.strokeRoundedHome01,
                                  'Role in Family',
                                  user.relationshipToHead,
                                ),
                                _buildInfoRow(
                                  HugeIcons.strokeRoundedUserGroup,
                                  'Head of Family',
                                  user.isHeadOfFamily ? 'Yes' : 'No',
                                ),
                                _buildInfoRow(
                                  HugeIcons.strokeRoundedFingerPrint,
                                  'Family ID',
                                  user.familyId,
                                ),
                              ]),

                              const SizedBox(height: 32),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      await authProvider.logout();
                                      if (context.mounted) {
                                        Navigator.of(
                                          context,
                                          rootNavigator: true,
                                        ).pushAndRemoveUntil(
                                          MaterialPageRoute(
                                            builder: (_) => const LoginScreen(),
                                          ),
                                          (route) => false,
                                        );
                                      }
                                    },
                                    icon: const HugeIcon(
                                      icon: HugeIcons.strokeRoundedLogout01,
                                      color: AppTheme.textLight,
                                    ),
                                    label: const Text(
                                      'Logout',
                                      style: TextStyle(
                                        color: AppTheme.textLight,
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      side: const BorderSide(
                                        color: AppTheme.textLight,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                        UserActivityTab(userId: user.id),
                        if (hasBusiness) UserBusinessTab(userId: user.id),
                        const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
