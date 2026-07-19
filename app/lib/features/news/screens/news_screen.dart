import 'package:app/models/news_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../providers/news_provider.dart';
import '../widgets/news_card.dart';
import 'create_news_screen.dart';
import '../../../core/widgets/skeleton_loading_wrapper.dart';

class NewsScreen extends StatefulWidget {
  final VoidCallback? onMenuTap;

  const NewsScreen({super.key, this.onMenuTap});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final ScrollController _updatesScrollController = ScrollController();
  final ScrollController _shokSandeshScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    _updatesScrollController.addListener(_onUpdatesScroll);
    _shokSandeshScrollController.addListener(_onShokSandeshScroll);
  }

  @override
  void dispose() {
    _updatesScrollController.dispose();
    _shokSandeshScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onUpdatesScroll() {
    if (_updatesScrollController.position.pixels >=
        _updatesScrollController.position.maxScrollExtent - 200) {
      context.read<NewsProvider>().fetchUpdates();
    }
  }

  void _onShokSandeshScroll() {
    if (_shokSandeshScrollController.position.pixels >=
        _shokSandeshScrollController.position.maxScrollExtent - 200) {
      context.read<NewsProvider>().fetchShokSandesh();
    }
  }

  Widget _buildNewsList(
    NewsProvider provider,
    List<NewsModel> list,
    bool isLoading,
    bool hasMore,
    ScrollController controller,
    Future<void> Function() onRefresh,
    String emptyMessage,
  ) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppTheme.primaryPurple,
      child: SkeletonLoadingWrapper(
        isLoading: isLoading && list.isEmpty,
        child: provider.error != null && list.isEmpty
            ? Center(
                child: Text(
                  provider.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              )
            : (list.isEmpty && !isLoading)
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 200),
                  Center(
                    child: Text(
                      emptyMessage,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                controller: controller,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 100, top: 8),
                itemCount: isLoading && list.isEmpty
                    ? 3
                    : list.length + (hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (isLoading && list.isEmpty) {
                    return NewsCard(news: NewsModel.dummy());
                  }
                  if (index == list.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryPurple,
                          ),
                        ),
                      ),
                    );
                  }
                  return NewsCard(news: list[index]);
                },
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NewsProvider>();

    return DefaultTabController(
      length: 2,
      child: GradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: CustomAppBar(
            title: 'Community Updates',
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
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedSearch01,
                  color: Colors.black87,
                  size: 24,
                ),
                onPressed: () {
                  setState(() {
                    _isSearchExpanded = !_isSearchExpanded;
                    if (!_isSearchExpanded) {
                      _searchController.clear();
                      context.read<NewsProvider>().setSearchQuery('');
                    }
                  });
                },
              ),
            ],
            bottom: const TabBar(
              indicatorColor: AppTheme.primaryPurple,
              labelColor: AppTheme.primaryPurple,
              unselectedLabelColor: Colors.black54,
              tabs: [
                Tab(text: 'Updates'),
                Tab(text: 'Shok Sandesh'),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(builder: (_) => const CreateNewsScreen()),
              );
            },
            backgroundColor: AppTheme.primaryPurple,
            shape: CircleBorder(),
            child: const HugeIcon(
              icon: HugeIcons.strokeRoundedEdit02,
              color: Colors.white,
              size: 24,
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
                          onChanged: provider.setSearchQuery,
                          hintText: 'Search news...',
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
                child: TabBarView(
                  children: [
                    _buildNewsList(
                      provider,
                      provider.updatesList,
                      provider.isLoadingUpdates,
                      provider.hasMoreUpdates,
                      _updatesScrollController,
                      () => provider.fetchUpdates(refresh: true),
                      'No news updates found.',
                    ),
                    _buildNewsList(
                      provider,
                      provider.shokSandeshList,
                      provider.isLoadingShokSandesh,
                      provider.hasMoreShokSandesh,
                      _shokSandeshScrollController,
                      () => provider.fetchShokSandesh(refresh: true),
                      'No Shok Sandesh posts found.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
