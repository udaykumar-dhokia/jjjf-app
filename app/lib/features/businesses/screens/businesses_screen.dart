import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/skeleton_loading_wrapper.dart';
import '../../../providers/business_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../models/business_model.dart';
import '../widgets/business_filter_sheet.dart';
import 'business_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class BusinessesScreen extends StatefulWidget {
  final VoidCallback? onMenuTap;

  const BusinessesScreen({super.key, this.onMenuTap});

  @override
  State<BusinessesScreen> createState() => _BusinessesScreenState();
}

class _BusinessesScreenState extends State<BusinessesScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userCity = context.read<UserProvider>().userProfile?.currentCity;
      context.read<BusinessProvider>().fetchBusinesses(defaultCity: userCity);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20),
        child: const BusinessFilterSheet(),
      ),
    );
  }

  Widget _buildSkeleton() {
    final dummyBusiness = BusinessListing(
      id: 'dummy',
      ownerId: 'dummy',
      businessName: 'Dummy Business Name Here',
      category: 'TECHNOLOGY',
      description:
          'This is a dummy description to fill up space for the skeleton.',
      logoUrl: null,
      website: 'www.dummywebsite.com',
      contactNumber: '1234567890',
      address: '',
      city: '',
      state: '',
      status: 'APPROVED',
    );

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _BusinessCard(business: dummyBusiness);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BusinessProvider>();

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CustomAppBar(
          title: 'Businesses',
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
          actions: [
            IconButton(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedSearch01,
                color: _isSearchExpanded
                    ? AppTheme.primaryPurple
                    : Colors.black87,
                size: 24,
              ),
              onPressed: () {
                setState(() {
                  _isSearchExpanded = !_isSearchExpanded;
                  if (!_isSearchExpanded) {
                    _searchController.clear();
                    context.read<BusinessProvider>().setSearchQuery('');
                  }
                });
              },
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedFilterHorizontal,
                    color: provider.filter.isEmpty
                        ? Colors.black87
                        : AppTheme.primaryPurple,
                    size: 24,
                  ),
                  onPressed: _showFilterSheet,
                ),
                if (!provider.filter.isEmpty)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: _isSearchExpanded
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: CustomTextField(
                        controller: _searchController,
                        onChanged: provider.setSearchQuery,
                        hintText: 'Search by Business Name, City...',
                        prefixIcon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedSearch01,
                          color: AppTheme.primaryPurple,
                          size: 20,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: SkeletonLoadingWrapper(
                isLoading: provider.isLoading,
                fallbackSkeleton: _buildSkeleton(),
                child: () {
                  if (provider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Oops, something went wrong!',
                            style: GoogleFonts.poppins(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => provider.fetchBusinesses(),
                            child: Text('Retry', style: GoogleFonts.inter()),
                          ),
                        ],
                      ),
                    );
                  }

                  final businesses = provider.filteredBusinesses;

                  if (businesses.isEmpty) {
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
                            'No businesses found.',
                            style: GoogleFonts.poppins(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppTheme.primaryPurple,
                    onRefresh: () => provider.fetchBusinesses(),
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      itemCount: businesses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _BusinessCard(business: businesses[index]);
                      },
                    ),
                  );
                }(),
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: _buildFloatingCitySelector(provider),
      ),
    );
  }

  Widget _buildFloatingCitySelector(BusinessProvider provider) {
    if (provider.isLoading && provider.businesses.isEmpty)
      return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textDark.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: provider.filter.cities.length == 1 ? provider.filter.cities.first : null,
          hint: Text(
            provider.filter.cities.length > 1 ? 'Multiple Cities' : 'All Cities',
            style: GoogleFonts.inter(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          icon: const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedArrowDown01,
              color: Colors.black,
              size: 20,
            ),
          ),
          dropdownColor: AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(25),
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('All Cities')),
            ...provider.availableCities.map(
              (city) => DropdownMenuItem(value: city, child: Text(city)),
            ),
          ],
          onChanged: (city) {
            provider.updateFilter(
              cities: city == null ? [] : [city],
              category: provider.filter.category,
            );
          },
        ),
      ),
    );
  }
}

class _BusinessCard extends StatelessWidget {
  final BusinessListing business;

  const _BusinessCard({required this.business});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (_) => BusinessDetailScreen(business: business),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo on the left
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(50),
              ),
              clipBehavior: Clip.hardEdge,
              child: business.logoUrl != null
                  ? CachedNetworkImage(
                      imageUrl: business.logoUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryPurple,
                        ),
                      ),
                      errorWidget: (context, url, error) => const HugeIcon(
                        icon: HugeIcons.strokeRoundedStore01,
                        color: Colors.grey,
                      ),
                    )
                  : const HugeIcon(
                      icon: HugeIcons.strokeRoundedStore01,
                      color: Colors.grey,
                      size: 32,
                    ),
            ),
            const SizedBox(width: 16),
            // Business details on the right
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Business Name
                  Text(
                    business.businessName,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Category Tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      business.category,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryPurple,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // About / Description
                  if (business.description != null &&
                      business.description!.isNotEmpty)
                    Text(
                      business.description!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 12),
                  // Contact / Website
                  Row(
                    children: [
                      const HugeIcon(
                        icon: HugeIcons.strokeRoundedCall,
                        color: Colors.grey,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        business.contactNumber,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                      if (business.website != null &&
                          business.website!.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        const HugeIcon(
                          icon: HugeIcons.strokeRoundedGlobal,
                          color: Colors.grey,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            business.website!,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.blueAccent,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
