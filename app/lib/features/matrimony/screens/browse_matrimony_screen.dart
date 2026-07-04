import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../providers/matrimony_provider.dart';
import '../widgets/matrimony_filter_sheet.dart';
import 'matrimony_profile_detail_screen.dart';

class BrowseMatrimonyScreen extends StatefulWidget {
  const BrowseMatrimonyScreen({super.key});

  @override
  State<BrowseMatrimonyScreen> createState() => _BrowseMatrimonyScreenState();
}

class _BrowseMatrimonyScreenState extends State<BrowseMatrimonyScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchExpanded = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MatrimonyProvider>();
      if (provider.browseList.isEmpty) {
        provider.fetchBrowseList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Discover Profiles',
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
                  context.read<MatrimonyProvider>().setSearchQuery('');
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
                  color: context.watch<MatrimonyProvider>().activeFilter.isEmpty
                      ? Colors.black87
                      : AppTheme.primaryPurple,
                  size: 24,
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 20,
                      ),
                      child: const MatrimonyFilterSheet(),
                    ),
                  );
                },
              ),
              if (!context.watch<MatrimonyProvider>().activeFilter.isEmpty)
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
                      onChanged: (val) =>
                          context.read<MatrimonyProvider>().setSearchQuery(val),
                      hintText: 'Search by Name, Gotra, or Location...',
                      prefixIcon: const HugeIcon(
                        icon: HugeIcons.strokeRoundedSearch01,
                        color: AppTheme.primaryPurple,
                        size: 20,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: Consumer<MatrimonyProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.browseList.isEmpty) {
                  return const Center(child: CupertinoActivityIndicator());
                }

                if (provider.errorMessage != null &&
                    provider.browseList.isEmpty) {
                  return Center(child: Text(provider.errorMessage!));
                }

                if (provider.browseList.isEmpty) {
                  return const Center(
                    child: Text(
                      'No profiles found at the moment.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final displayList = provider.filteredBrowseList;

                if (displayList.isEmpty) {
                  return const Center(
                    child: Text(
                      'No profiles match your search/filters.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchBrowseList(),
                  color: AppTheme.primaryPurple,
                  backgroundColor: Colors.white,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: displayList.length,
                    itemBuilder: (context, index) {
                      final profile = displayList[index];
                      final String? imageUrl = profile.photoGallery.isNotEmpty
                          ? profile.photoGallery.first
                          : null;
                      final String name = profile.firstName ?? 'Unknown';
                      final String ageText = profile.age != null
                          ? '${profile.age} yrs'
                          : '';
                      final String gotra = profile.gotra ?? profile.subCaste;

                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MatrimonyProfileDetailScreen(
                                targetId: profile.userId,
                                partialProfile: profile,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.65,
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Stack(
                              children: [
                                // 1. Background Image
                                Positioned.fill(
                                  child: imageUrl != null
                                      ? Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          color: Colors.grey.shade200,
                                          child: const Center(
                                            child: HugeIcon(
                                              icon: HugeIcons.strokeRoundedUser,
                                              size: 80,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                ),
                                // 2. Gradient Overlay & Details
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black54,
                                          Colors.black87,
                                        ],
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ageText.isNotEmpty
                                              ? '$name, $ageText'
                                              : name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 26,
                                            fontWeight: FontWeight.bold,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black45,
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [
                                            _buildChip(
                                              HugeIcons.strokeRoundedUserGroup,
                                              gotra,
                                            ),
                                            if (profile.height != null &&
                                                profile.height!.isNotEmpty)
                                              _buildChip(
                                                HugeIcons
                                                    .strokeRoundedTapeMeasure,
                                                profile.height!,
                                              ),
                                            if (profile
                                                .educationDetails
                                                .isNotEmpty)
                                              _buildChip(
                                                HugeIcons
                                                    .strokeRoundedBookOpen01,
                                                profile.educationDetails,
                                              ),
                                            if (profile.monthlyIncome != null &&
                                                profile
                                                    .monthlyIncome!
                                                    .isNotEmpty)
                                              _buildChip(
                                                HugeIcons.strokeRoundedMoney04,
                                                profile.monthlyIncome!,
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        // View Full Profile button
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: 0.15,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: Colors.white.withValues(
                                                alpha: 0.3,
                                              ),
                                            ),
                                          ),
                                          child: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'View Full Profile',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              HugeIcon(
                                                icon: HugeIcons
                                                    .strokeRoundedArrowRight01,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(dynamic icon, String label) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 160),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(icon: icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
