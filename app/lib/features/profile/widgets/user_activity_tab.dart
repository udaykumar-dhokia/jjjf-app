import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../models/news_model.dart';
import '../../../services/news_api.dart';
import '../../news/widgets/news_card.dart';

class UserActivityTab extends StatefulWidget {
  final String userId;

  const UserActivityTab({super.key, required this.userId});

  @override
  State<UserActivityTab> createState() => _UserActivityTabState();
}

class _UserActivityTabState extends State<UserActivityTab> {
  final NewsApi _newsApi = NewsApi();
  List<NewsModel> _newsList = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchActivity();
  }

  Future<void> _fetchActivity() async {
    try {
      final result = await _newsApi.getNewsByUser(widget.userId);
      if (mounted) {
        setState(() {
          _newsList = result['news'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Failed to load activity";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _fetchActivity();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (_newsList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'No recent activity.',
            style: TextStyle(color: Colors.black54, fontSize: 16),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      physics: const BouncingScrollPhysics(),
      itemCount: _newsList.length,
      itemBuilder: (context, index) {
        return NewsCard(news: _newsList[index]);
      },
    );
  }
}
