import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../models/matrimony_model.dart';
import '../../../providers/matrimony_provider.dart';

class MatrimonyProfileDetailScreen extends StatefulWidget {
  final String targetId;
  final MatrimonialProfile? partialProfile;

  const MatrimonyProfileDetailScreen({
    super.key,
    required this.targetId,
    this.partialProfile,
  });

  @override
  State<MatrimonyProfileDetailScreen> createState() =>
      _MatrimonyProfileDetailScreenState();
}

class _MatrimonyProfileDetailScreenState
    extends State<MatrimonyProfileDetailScreen> {
  bool _hasRequestedAccess = false;

  late Future<MatrimonialProfile?> _fullProfileFuture;

  @override
  void initState() {
    super.initState();
    _fullProfileFuture = context.read<MatrimonyProvider>().fetchFullProfile(
      widget.targetId,
    );
  }

  void _requestAccess() async {
    final provider = context.read<MatrimonyProvider>();
    final success = await provider.requestAccess(widget.targetId);
    if (success) {
      setState(() {
        _hasRequestedAccess = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Access request sent!')));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to send request'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MatrimonyProvider>(
      builder: (context, provider, child) {
        // If loading and we don't have partial data, show loader
        if (provider.isLoading && widget.partialProfile == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final bool accessDenied =
            provider.errorMessage != null &&
            provider.errorMessage!.contains('access');

        final String name = widget.partialProfile?.firstName ?? 'Unknown';
        final String? imageUrl =
            widget.partialProfile?.photoGallery.isNotEmpty == true
            ? widget.partialProfile!.photoGallery.first
            : null;

        return FutureBuilder<MatrimonialProfile?>(
          future: _fullProfileFuture,
          builder: (context, snapshot) {
            final fullProfile = snapshot.data;
            return Scaffold(
              backgroundColor: AppTheme.backgroundLight,
              appBar: CustomAppBar(
                title: name,
                backgroundColor: Colors.white,
                elevation: 0,
              ),
              bottomNavigationBar:
                  (fullProfile?.phoneNumber != null && fullProfile!.phoneNumber!.isNotEmpty)
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
                                    'tel:${fullProfile.phoneNumber}',
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
                                  final phone = fullProfile.whatsappNumber ?? fullProfile.phoneNumber!;
                                  final String waPhone = phone.replaceAll(RegExp(r'\D'), '');
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
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Image Container
                    Container(
                      height: 300,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (imageUrl != null)
                            Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                            )
                          else
                            const Center(
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedUser,
                                size: 100,
                                color: Colors.grey,
                              ),
                            ),
                          if (accessDenied && imageUrl != null)
                            BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                              child: Container(color: Colors.white.withOpacity(0.2)),
                            ),
                        ],
                      ),
                    ),

                    // Details Section
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: AppTheme.backgroundLight,
                      ),
                      child: accessDenied
                          ? _buildAccessDeniedView(name)
                          : (snapshot.connectionState == ConnectionState.waiting)
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(32.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : (snapshot.hasError ||
                                      !snapshot.hasData ||
                                      snapshot.data == null)
                                  ? _buildAccessDeniedView(name)
                                  : _buildFullDetailsView(snapshot.data!),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAccessDeniedView(String name) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const HugeIcon(
          icon: HugeIcons.strokeRoundedLockPassword,
          size: 80,
          color: Colors.grey,
        ),
        const SizedBox(height: 16),
        Text(
          'Private Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'You need to request access to view the full details and photos of $name.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _hasRequestedAccess ? null : _requestAccess,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryPurple,
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            _hasRequestedAccess ? 'Request Sent' : 'Request Access',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFullDetailsView(MatrimonialProfile fullProfile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header Info
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

        // Personal Details Card
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
            if (fullProfile.biodataPdfUrl != null && fullProfile.biodataPdfUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: InkWell(
                  onTap: () {
                    // Could use url_launcher here if installed, else just show it
                  },
                  child: Row(
                    children: [
                      const HugeIcon(icon: HugeIcons.strokeRoundedLink01, color: AppTheme.primaryPurple, size: 24),
                      const SizedBox(width: 16),
                      const Expanded(
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
              ),
          ],
        ),
        const SizedBox(height: 16),

        // About Me Card
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

        // Expectations Card
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
      ],
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> children}) {
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
