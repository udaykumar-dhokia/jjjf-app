import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../providers/matrimony_provider.dart';
import '../../../core/widgets/sliver_app_bar_delegate.dart';
import 'create_profile_screen.dart';

class MyMatrimonyProfileScreen extends StatefulWidget {
  const MyMatrimonyProfileScreen({super.key});

  @override
  State<MyMatrimonyProfileScreen> createState() =>
      _MyMatrimonyProfileScreenState();
}

class _MyMatrimonyProfileScreenState extends State<MyMatrimonyProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MatrimonyProvider>(
      builder: (context, provider, child) {
        final profile = provider.myProfile;
        if (profile == null) {
          return const Scaffold(
            body: Center(child: Text('Profile not found.')),
          );
        }

        final String? imageUrl = profile.photoGallery.isNotEmpty == true
            ? profile.photoGallery.first
            : null;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppBar(
            title: 'My Profile',
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedArrowLeft01,
                color: AppTheme.primaryPurple,
                size: 24,
              ),
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            ),
            actions: [
              IconButton(
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedPencilEdit02,
                  color: AppTheme.primaryPurple,
                  size: 24,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const CreateMatrimonyProfileScreen(isEditing: true),
                    ),
                  );
                },
              ),
            ],
          ),
          body: NestedScrollView(
            physics: const BouncingScrollPhysics(),
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: 300,
                        width: double.infinity,
                        color: Colors.white,
                        child: imageUrl != null
                            ? Image.network(imageUrl, fit: BoxFit.cover)
                            : const Center(
                                child: HugeIcon(
                                  icon: HugeIcons.strokeRoundedUser,
                                  size: 100,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              profile.age != null
                                  ? '${profile.firstName ?? 'Unknown'} ${profile.gotra ?? profile.subCaste}, ${profile.age} yrs'
                                  : (profile.firstName ?? 'Unknown'),
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                        Tab(text: 'Personal'),
                        Tab(text: 'About'),
                        Tab(text: 'Expectations'),
                      ],
                    ),
                    backgroundColor: Colors.white.withOpacity(0.95),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Personal Details
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _buildInfoCard(
                    title: 'Personal Details',
                    children: [
                      _buildDetailRow(
                        HugeIcons.strokeRoundedArrowUp01,
                        'Height',
                        profile.height ?? 'N/A',
                      ),
                      _buildDetailRow(
                        HugeIcons.strokeRoundedTapeMeasure,
                        'Weight',
                        '${profile.weight ?? 'N/A'} kg',
                      ),
                      _buildDetailRow(
                        HugeIcons.strokeRoundedBookOpen01,
                        'Education',
                        profile.educationDetails,
                      ),
                      _buildDetailRow(
                        HugeIcons.strokeRoundedMoney04,
                        'Monthly Income',
                        profile.monthlyIncome ?? 'N/A',
                      ),
                      if (profile.biodataPdfUrl != null &&
                          profile.biodataPdfUrl!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              const HugeIcon(
                                icon: HugeIcons.strokeRoundedLink01,
                                color: AppTheme.primaryPurple,
                                size: 24,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'View Biodata Document',
                                  style: TextStyle(
                                    color: AppTheme.primaryPurple,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                // Tab 2: About
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _buildInfoCard(
                    title: 'About Me',
                    children: [
                      Text(
                        profile.aboutMe ?? 'No details provided.',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppTheme.textDark,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                // Tab 3: Expectations
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _buildInfoCard(
                    title: 'Partner Expectations',
                    children: [
                      Text(
                        profile.expectations ?? 'No details provided.',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppTheme.textDark,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryPurple,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(dynamic icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          HugeIcon(icon: icon, color: AppTheme.primaryPurple, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
