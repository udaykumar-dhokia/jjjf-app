import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../providers/job_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_text_field.dart';
import 'package:hugeicons/hugeicons.dart';
import '../widgets/job_card.dart';
import '../widgets/jobs_filter_sheet.dart';
import 'create_job_screen.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({Key? key}) : super(key: key);

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Fetch data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobProvider>().fetchJobs();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await context.read<JobProvider>().fetchJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JobProvider>(
      builder: (context, provider, child) {
        return GradientBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: CustomAppBar(
              title: 'Jobs Board',
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
                        if (_searchController.text.isNotEmpty) {
                          _searchController.clear();
                          final provider = context.read<JobProvider>();
                          provider.setFilter(
                            JobFilter(
                              cities: provider.activeFilter.cities,
                              industries: provider.activeFilter.industries,
                              search: null,
                            ),
                          );
                        }
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
                        color:
                            provider.activeFilter.cities.isEmpty &&
                                provider.activeFilter.industries.isEmpty
                            ? Colors.black87
                            : AppTheme.primaryPurple,
                        size: 24,
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.white,
                          builder: (context) => Padding(
                            padding: EdgeInsets.only(
                              top: MediaQuery.of(context).padding.top + 20,
                            ),
                            child: const JobsFilterSheet(),
                          ),
                        );
                      },
                    ),
                    if (provider.activeFilter.cities.isNotEmpty ||
                        provider.activeFilter.industries.isNotEmpty)
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
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.primaryPurple,
                indicatorWeight: 3,
                labelColor: AppTheme.primaryPurple,
                unselectedLabelColor: Colors.black54,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                tabs: const [
                  Tab(text: 'Vacancies'),
                  Tab(text: 'Job Requests'),
                ],
              ),
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
                            onChanged: (val) {
                              final p = context.read<JobProvider>();
                              p.setFilter(
                                JobFilter(
                                  cities: p.activeFilter.cities,
                                  industries: p.activeFilter.industries,
                                  search: val,
                                ),
                              );
                            },
                            hintText: 'Search by role or description...',
                            prefixIcon: const HugeIcon(
                              icon: HugeIcons.strokeRoundedSearch01,
                              color: AppTheme.primaryPurple,
                              size: 20,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                // Quick Industry Filters
                if (provider.availableIndustries.isNotEmpty)
                  SizedBox(
                    height: 80,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            label: const Text('All'),
                            selected: provider.activeFilter.industries.isEmpty,
                            onSelected: (selected) {
                              if (selected) {
                                final p = context.read<JobProvider>();
                                p.setFilter(
                                  JobFilter(
                                    cities: p.activeFilter.cities,
                                    industries: {},
                                    search: p.activeFilter.search,
                                  ),
                                );
                              }
                            },
                            selectedColor: AppTheme.primaryPurple.withOpacity(
                              0.2,
                            ),
                            labelStyle: TextStyle(
                              color: provider.activeFilter.industries.isEmpty
                                  ? AppTheme.primaryPurple
                                  : Colors.black87,
                              fontWeight:
                                  provider.activeFilter.industries.isEmpty
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            backgroundColor: Colors.white,
                            side: BorderSide(
                              color: provider.activeFilter.industries.isEmpty
                                  ? AppTheme.primaryPurple
                                  : Colors.grey.shade300,
                            ),
                          ),
                        ),
                        ...provider.availableIndustries.map((ind) {
                          final isSelected =
                              provider.activeFilter.industries.length == 1 &&
                              provider.activeFilter.industries.contains(ind);
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              label: Text(ind),
                              selected: isSelected,
                              onSelected: (selected) {
                                final p = context.read<JobProvider>();
                                p.setFilter(
                                  JobFilter(
                                    cities: p.activeFilter.cities,
                                    industries: selected ? {ind} : {},
                                    search: p.activeFilter.search,
                                  ),
                                );
                              },
                              selectedColor: AppTheme.primaryPurple.withOpacity(
                                0.2,
                              ),
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? AppTheme.primaryPurple
                                    : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: isSelected
                                    ? AppTheme.primaryPurple
                                    : Colors.grey.shade300,
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                Expanded(
                  child: TabBarView(
                    physics: BouncingScrollPhysics(),
                    controller: _tabController,
                    children: [
                      _buildJobList(provider.vacancies, provider.isLoading),
                      _buildJobList(provider.jobRequests, provider.isLoading),
                    ],
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: AppTheme.primaryPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CreateJobScreen()),
                );
              },
              child: const Icon(Icons.add, color: AppTheme.backgroundLight),
            ),
          ),
        );
      },
    );
  }

  Widget _buildJobList(List jobs, bool isLoading) {
    if (isLoading) {
      return Skeletonizer(
        containersColor: Colors.white,
        enabled: true,
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: 4,
          itemBuilder: (context, index) {
            return const Card(
              margin: EdgeInsets.only(bottom: 16),
              child: SizedBox(height: 200),
            );
          },
        ),
      );
    }

    if (jobs.isEmpty) {
      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: const [
            SizedBox(height: 100),
            Center(
              child: Text(
                'No jobs found matching your criteria.',
                style: TextStyle(color: AppTheme.textLight),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          return JobCard(job: jobs[index]);
        },
      ),
    );
  }
}
