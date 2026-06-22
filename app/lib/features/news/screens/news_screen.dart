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

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsProvider>().fetchNews();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<NewsProvider>().fetchNews();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NewsProvider>();

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppBar(title: 'Community News'),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(
              context,
              rootNavigator: true,
            ).push(MaterialPageRoute(builder: (_) => const CreateNewsScreen()));
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
            Padding(
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
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => provider.fetchNews(refresh: true),
                color: AppTheme.primaryPurple,
                child: provider.isLoading && provider.newsList.isEmpty
                    ? const Center(
                        child: CupertinoActivityIndicator(
                          color: AppTheme.primaryPurple,
                        ),
                      )
                    : provider.error != null && provider.newsList.isEmpty
                    ? Center(
                        child: Text(
                          provider.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    : provider.newsList.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 200),
                          Center(
                            child: Text(
                              'No news posts found.',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.only(bottom: 100),
                        itemCount:
                            provider.newsList.length +
                            (provider.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == provider.newsList.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: CupertinoActivityIndicator(
                                  color: AppTheme.primaryPurple,
                                ),
                              ),
                            );
                          }
                          final news = provider.newsList[index];
                          return NewsCard(news: news);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
