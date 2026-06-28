import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../models/business_model.dart';
import '../../../core/widgets/custom_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../directory/screens/contact_detail_screen.dart';

class BusinessDetailScreen extends StatelessWidget {
  final BusinessListing business;

  const BusinessDetailScreen({super.key, required this.business});

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
          title: 'Business Details',
          leading: IconButton(
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              color: AppTheme.primaryPurple,
              size: 24,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Container(
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: business.logoUrl != null
                          ? NetworkImage(business.logoUrl!) as ImageProvider
                          : const NetworkImage(
                              'https://api.dicebear.com/10.x/glass/png?seed=business',
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      business.businessName.trim(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
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
                          business.category,
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

                  // Description
                  if (business.description != null &&
                      business.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        business.description!,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Information Sections
                  _buildSectionCard('Contact Information', [
                    _buildInfoRow(
                      HugeIcons.strokeRoundedCall02,
                      'Phone Number',
                      business.contactNumber,
                    ),
                    if (business.website != null)
                      _buildInfoRow(
                        HugeIcons.strokeRoundedGlobal,
                        'Website',
                        business.website!,
                      ),
                  ]),

                  _buildSectionCard('Location', [
                    if (business.address.isNotEmpty)
                      _buildInfoRow(
                        HugeIcons.strokeRoundedLocation01,
                        'Address',
                        business.address,
                      ),
                    if (business.city.isNotEmpty || business.state.isNotEmpty)
                      _buildInfoRow(
                        HugeIcons.strokeRoundedCity01,
                        'City/State',
                        '${business.city}${business.state.isNotEmpty ? ', ${business.state}' : ''}',
                      ),
                  ]),

                  if (business.owner != null) ...[
                    const SizedBox(height: 16),
                    _buildSectionCard('Business Owner', [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: AppTheme.primaryPurple.withOpacity(
                            0.1,
                          ),
                          backgroundImage: business.owner!.photoUrl != null
                              ? NetworkImage(business.owner!.photoUrl!)
                                    as ImageProvider
                              : NetworkImage(
                                  'https://api.dicebear.com/10.x/glass/png?seed=${business.owner!.firstName}',
                                ),
                        ),
                        title: Text(
                          '${business.owner!.firstName} ${business.owner!.fatherName} ${business.owner!.gotra}'
                              .trim(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          business.owner!.currentCity,
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                            fontSize: 13,
                          ),
                        ),
                        trailing: const HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowRight01,
                          color: Colors.black54,
                          size: 20,
                        ),
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ContactDetailScreen(contact: business.owner!),
                            ),
                          );
                        },
                      ),
                    ]),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar:
            (business.contactNumber.isNotEmpty || business.website != null)
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
                      if (business.contactNumber.isNotEmpty)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final Uri url = Uri.parse(
                                'tel:${business.contactNumber}',
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
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                          ),
                        ),
                      if (business.contactNumber.isNotEmpty &&
                          business.website != null)
                        const SizedBox(width: 16),
                      if (business.website != null &&
                          business.website!.isNotEmpty)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              String urlStr = business.website!;
                              if (!urlStr.startsWith('http://') &&
                                  !urlStr.startsWith('https://')) {
                                urlStr = 'https://$urlStr';
                              }
                              final Uri url = Uri.parse(urlStr);
                              if (await canLaunchUrl(url)) {
                                await launchUrl(
                                  url,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            },
                            icon: const HugeIcon(
                              icon: HugeIcons.strokeRoundedGlobal,
                              color: Colors.white,
                              size: 20,
                            ),
                            label: const Text(
                              'Website',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
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
