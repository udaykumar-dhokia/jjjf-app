import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../models/matrimony_model.dart';
import '../../../providers/matrimony_provider.dart';
import 'create_profile_screen.dart';

class MyMatrimonyProfileScreen extends StatelessWidget {
  const MyMatrimonyProfileScreen({super.key});

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
          backgroundColor: AppTheme.backgroundLight,
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
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  color: Colors.grey.shade200,
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
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppTheme.backgroundLight,
                  ),
                  child: _buildFullDetailsView(profile),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFullDetailsView(MatrimonialProfile fullProfile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          fullProfile.age != null
              ? '${fullProfile.firstName ?? 'Unknown'}, ${fullProfile.age} yrs'
              : (fullProfile.firstName ?? 'Unknown'),
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Gotra: ${fullProfile.gotra ?? fullProfile.subCaste}',
          style: const TextStyle(fontSize: 18, color: AppTheme.textLight),
        ),
        const SizedBox(height: 24),
        _buildInfoCard(
          title: 'Personal Details',
          children: [
            _buildDetailRow(
              HugeIcons.strokeRoundedArrowUp01,
              'Height',
              fullProfile.height ?? 'N/A',
            ),
            _buildDetailRow(
              HugeIcons.strokeRoundedTapeMeasure,
              'Weight',
              '${fullProfile.weight ?? 'N/A'} kg',
            ),
            _buildDetailRow(
              HugeIcons.strokeRoundedBookOpen01,
              'Education',
              fullProfile.educationDetails,
            ),
            _buildDetailRow(
              HugeIcons.strokeRoundedMoney04,
              'Income',
              fullProfile.monthlyIncome ?? 'N/A',
            ),
            if (fullProfile.biodataPdfUrl != null &&
                fullProfile.biodataPdfUrl!.isNotEmpty)
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
        const SizedBox(height: 16),
        _buildInfoCard(
          title: 'About Me',
          children: [
            Text(
              fullProfile.aboutMe ?? 'No details provided.',
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textDark,
                height: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          title: 'Partner Expectations',
          children: [
            Text(
              fullProfile.expectations ?? 'No details provided.',
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textDark,
                height: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
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
