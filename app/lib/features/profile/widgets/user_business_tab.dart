import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/business_model.dart';
import '../../../services/business_api.dart';
import '../../../providers/user_provider.dart';
import '../../businesses/screens/business_detail_screen.dart';
import '../../businesses/screens/update_business_screen.dart';

class UserBusinessTab extends StatefulWidget {
  final String userId;

  const UserBusinessTab({super.key, required this.userId});

  @override
  State<UserBusinessTab> createState() => _UserBusinessTabState();
}

class _UserBusinessTabState extends State<UserBusinessTab> {
  final BusinessApi _businessApi = BusinessApi();
  BusinessListing? _business;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBusiness();
  }

  Future<void> _fetchBusiness() async {
    setState(() => _isLoading = true);
    final business = await _businessApi.getBusinessByUserId(widget.userId);
    if (mounted) {
      setState(() {
        _business = business;
        _isLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryPurple),
      );
    }

    if (_business == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const HugeIcon(
              icon: HugeIcons.strokeRoundedStore01,
              color: Colors.grey,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No business listed',
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    final currentUser = context.read<UserProvider>().userProfile;
    final isOwner = currentUser?.id == widget.userId;

    return Stack(
      children: [
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 100, top: 16),
          child: Column(
            children: [
              // Business Summary Card that routes to full detail
              GestureDetector(
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          BusinessDetailScreen(business: _business!),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: AppTheme.primaryPurple.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(50),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: _business!.logoUrl != null
                            ? Image.network(
                                _business!.logoUrl!,
                                fit: BoxFit.cover,
                              )
                            : const HugeIcon(
                                icon: HugeIcons.strokeRoundedStore01,
                                color: Colors.grey,
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _business!.businessName,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _business!.category,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppTheme.primaryPurple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowRight01,
                        color: Colors.black54,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              _buildSectionCard('Business Information', [
                _buildInfoRow(
                  HugeIcons.strokeRoundedStore01,
                  'Business Name',
                  _business!.businessName,
                ),
                _buildInfoRow(
                  HugeIcons.strokeRoundedTag01,
                  'Category',
                  _business!.category,
                ),
                if (_business!.description != null &&
                    _business!.description!.isNotEmpty)
                  _buildInfoRow(
                    HugeIcons.strokeRoundedBookOpen01,
                    'Description',
                    _business!.description!,
                  ),
                _buildInfoRow(
                  HugeIcons.strokeRoundedCall02,
                  'Contact',
                  _business!.contactNumber,
                ),
                if (_business!.website != null &&
                    _business!.website!.isNotEmpty)
                  _buildInfoRow(
                    HugeIcons.strokeRoundedGlobal,
                    'Website',
                    _business!.website!,
                  ),
                if (_business!.address.isNotEmpty)
                  _buildInfoRow(
                    HugeIcons.strokeRoundedLocation01,
                    'Address',
                    _business!.address,
                  ),
                _buildInfoRow(
                  HugeIcons.strokeRoundedCity01,
                  'City/State',
                  '${_business!.city}${_business!.state.isNotEmpty ? ', ${_business!.state}' : ''}',
                ),
                _buildInfoRow(
                  HugeIcons.strokeRoundedCheckmarkBadge01,
                  'Status',
                  _business!.status,
                ),
              ]),
            ],
          ),
        ),
        if (isOwner)
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton.extended(
              heroTag: 'edit_business_fab',
              onPressed: () async {
                final result = await Navigator.of(context, rootNavigator: true)
                    .push(
                      MaterialPageRoute(
                        builder: (_) =>
                            UpdateBusinessScreen(currentBusiness: _business!),
                      ),
                    );
                if (result == true) {
                  _fetchBusiness();
                }
              },
              backgroundColor: AppTheme.primaryPurple,
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedEdit02,
                color: Colors.white,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(50),
              ),
              label: const Text(
                'Edit Business',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
