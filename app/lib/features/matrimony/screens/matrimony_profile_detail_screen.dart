import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../models/matrimony_model.dart';
import '../../../providers/matrimony_provider.dart';
import '../../../core/widgets/sliver_app_bar_delegate.dart';

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
    extends State<MatrimonyProfileDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _hasRequestedAccess = false;
  late Future<MatrimonialProfile?> _fullProfileFuture;
  @override
  void dispose() {
    super.dispose();
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
            
        final bool isRequestAlreadySent = provider.sentRequests
            .any((req) => req.targetId == widget.targetId);
        final bool showAsRequested = _hasRequestedAccess || isRequestAlreadySent;

        final String name = widget.partialProfile?.firstName ?? 'Unknown';
        final String? imageUrl =
            widget.partialProfile?.photoGallery.isNotEmpty == true
            ? widget.partialProfile!.photoGallery.first
            : null;

        return FutureBuilder<MatrimonialProfile?>(
          future: _fullProfileFuture,
          builder: (context, snapshot) {
            final fullProfile = snapshot.data;
            final isWaiting =
                snapshot.connectionState == ConnectionState.waiting;
            final isError =
                snapshot.hasError || !snapshot.hasData || fullProfile == null;
            final shouldShowAccessDenied =
                accessDenied || (!isWaiting && isError);

            return Scaffold(
              backgroundColor: Colors.white,
              appBar: CustomAppBar(
                title: name,
                backgroundColor: Colors.white,
                elevation: 0,
              ),
              bottomNavigationBar:
                  (fullProfile?.phoneNumber != null &&
                      fullProfile!.phoneNumber!.isNotEmpty)
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
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryPurple,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
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
                                  final phone =
                                      fullProfile.whatsappNumber ??
                                      fullProfile.phoneNumber!;
                                  final String waPhone = phone.replaceAll(
                                    RegExp(r'\D'),
                                    '',
                                  );
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
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF25D366),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
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
              body: shouldShowAccessDenied || isWaiting
                  ? SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            height: 300,
                            width: double.infinity,
                            color: Colors.grey.shade200,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (imageUrl != null)
                                  Image.network(imageUrl, fit: BoxFit.cover)
                                else
                                  const Center(
                                    child: HugeIcon(
                                      icon: HugeIcons.strokeRoundedUser,
                                      size: 100,
                                      color: Colors.grey,
                                    ),
                                  ),
                                if (shouldShowAccessDenied && imageUrl != null)
                                  BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 15,
                                      sigmaY: 15,
                                    ),
                                    child: Container(
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(24),
                            child: isWaiting
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(32.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : _buildAccessDeniedView(name, showAsRequested),
                          ),
                        ],
                      ),
                    )
                  : (fullProfile?.biodataPdfUrl != null && fullProfile!.biodataPdfUrl!.isNotEmpty)
                      ? SfPdfViewer.network(
                          fullProfile.biodataPdfUrl!,
                          canShowScrollHead: false,
                          canShowScrollStatus: false,
                        )
                      : const Center(child: Text("No Biodata PDF uploaded.")),
            );
          },
        );
      },
    );
  }

  Widget _buildAccessDeniedView(String name, bool showAsRequested) {
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
          onPressed: showAsRequested ? null : _requestAccess,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryPurple,
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            showAsRequested ? 'Request Sent' : 'Request Access',
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

}
