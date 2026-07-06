import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../providers/news_provider.dart';
import '../../../models/news_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../news/screens/read_news_screen.dart';
import '../../../core/widgets/skeleton_loading_wrapper.dart';

class HomeLatestNews extends StatelessWidget {
  final Function(int) onNavigateTab;

  const HomeLatestNews({super.key, required this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    return Consumer<NewsProvider>(
      builder: (context, newsProvider, child) {
        if (newsProvider.isLoading && newsProvider.newsList.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SkeletonLoadingWrapper(
              isLoading: true,
              child: SizedBox(
                height: 150,
                child: _SmallNewsCard(
                  news: NewsModel(
                    id: '',
                    title: 'Loading News Title',
                    description: 'Loading description...',
                    images: [],
                    userId: '',
                    userName: 'Author',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                ),
              ),
            ),
          );
        }

        if (newsProvider.newsList.isEmpty) {
          return const SizedBox.shrink();
        }

        final latestNews = newsProvider.newsList.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Latest Updates',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: () => onNavigateTab(1),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'More',
                      style: TextStyle(
                        color: AppTheme.primaryPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: PageView.builder(
                physics: BouncingScrollPhysics(),
                controller: PageController(viewportFraction: 0.9),
                itemCount: latestNews.length,
                padEnds: false,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                    child: _SmallNewsCard(news: latestNews[index]),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SmallNewsCard extends StatelessWidget {
  final NewsModel news;

  const _SmallNewsCard({required this.news});

  @override
  Widget build(BuildContext context) {
    String? imageUrl;
    if (news.images.isNotEmpty) {
      imageUrl = news.images.first;
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
          rootNavigator: true,
        ).push(MaterialPageRoute(builder: (_) => ReadNewsScreen(news: news)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: Image.network(
                  imageUrl,
                  width: 100,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 100,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      news.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      news.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                      maxLines: imageUrl != null ? 2 : 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 12,
                          color: AppTheme.primaryPurple,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTimeAgo(news.createdAt),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.primaryPurple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
