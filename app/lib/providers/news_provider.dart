import 'package:flutter/material.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import '../services/news_api.dart';
import '../models/news_model.dart';

class NewsProvider extends ChangeNotifier {
  final NewsApi _newsApi = NewsApi();

  List<NewsModel> _newsList = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  int _currentPage = 0;
  final int _limit = 10;
  bool _hasMore = true;
  String _searchQuery = '';

  List<NewsModel> get newsList => _newsList;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasMore => _hasMore;
  String get searchQuery => _searchQuery;

  NewsProvider() {
    fetchNews(refresh: true);
  }

  Future<void> fetchNews({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _hasMore = true;
      _newsList.clear();
      _isLoading = true;
      _error = null;
      notifyListeners();
    } else {
      if (!_hasMore || _isLoading || _isLoadingMore) return;
      _isLoadingMore = true;
      notifyListeners();
    }

    try {
      final result = await _newsApi.getNews(
        limit: _limit,
        offset: _currentPage * _limit,
        search: _searchQuery,
      );

      final List<NewsModel> fetchedNews = result['news'];
      final int total = result['total'];

      if (refresh) {
        _newsList = fetchedNews;
      } else {
        _newsList.addAll(fetchedNews);
      }

      _currentPage++;
      _hasMore = _newsList.length < total;
      _error = null;
    } catch (e) {
      _error = "Failed to load news. Please try again.";
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    fetchNews(refresh: true);
  }

  Future<bool> createNewsPost(
    String title,
    String description,
    String userId,
    String userName,
    List<File> images,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _newsApi.createNews(title, description, userId, userName, images);
      await fetchNews(refresh: true);
      return true;
    } on DioException catch (e) {
      _error =
          e.response?.data['message']?.toString() ??
          e.message ??
          "Failed to create news post.";
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteNewsPost(String id) async {
    try {
      await _newsApi.deleteNews(id);
      _newsList.removeWhere((news) => news.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = "Failed to delete news post.";
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateNewsPost(
    String id,
    String title,
    String description,
    List<File> newImages,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedNews = await _newsApi.updateNews(
        id,
        title,
        description,
        newImages,
      );
      final index = _newsList.indexWhere((news) => news.id == id);
      if (index != -1) {
        _newsList[index] = updatedNews;
      }
      return true;
    } on DioException catch (e) {
      _error =
          e.response?.data['message']?.toString() ??
          e.message ??
          "Failed to update news post.";
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
