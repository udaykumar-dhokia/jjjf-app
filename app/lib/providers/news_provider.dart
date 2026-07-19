import 'package:flutter/material.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import '../services/news_api.dart';
import '../models/news_model.dart';

class NewsProvider extends ChangeNotifier {
  final NewsApi _newsApi = NewsApi();

  List<NewsModel> _updatesList = [];
  List<NewsModel> _shokSandeshList = [];
  bool _isLoadingUpdates = false;
  bool _isLoadingShokSandesh = false;
  bool _isLoadingMoreUpdates = false;
  bool _isLoadingMoreShokSandesh = false;
  String? _error;

  int _currentUpdatesPage = 0;
  int _currentShokSandeshPage = 0;
  final int _limit = 10;
  bool _hasMoreUpdates = true;
  bool _hasMoreShokSandesh = true;
  String _searchQuery = '';

  List<NewsModel> get updatesList => _updatesList;
  List<NewsModel> get shokSandeshList => _shokSandeshList;
  bool get isLoadingUpdates => _isLoadingUpdates;
  bool get isLoadingShokSandesh => _isLoadingShokSandesh;
  bool get isLoading => _isLoadingUpdates || _isLoadingShokSandesh;
  bool get isLoadingMoreUpdates => _isLoadingMoreUpdates;
  bool get isLoadingMoreShokSandesh => _isLoadingMoreShokSandesh;
  String? get error => _error;
  bool get hasMoreUpdates => _hasMoreUpdates;
  bool get hasMoreShokSandesh => _hasMoreShokSandesh;
  String get searchQuery => _searchQuery;

  NewsProvider() {
    fetchUpdates(refresh: true);
    fetchShokSandesh(refresh: true);
  }

  Future<void> fetchUpdates({bool refresh = false}) async {
    if (refresh) {
      _currentUpdatesPage = 0;
      _hasMoreUpdates = true;
      _updatesList.clear();
      _isLoadingUpdates = true;
      _error = null;
      notifyListeners();
    } else {
      if (!_hasMoreUpdates || _isLoadingUpdates || _isLoadingMoreUpdates) return;
      _isLoadingMoreUpdates = true;
      notifyListeners();
    }

    try {
      final result = await _newsApi.getNews(
        limit: _limit,
        offset: _currentUpdatesPage * _limit,
        search: _searchQuery,
        isShokSandesh: false,
      );

      final List<NewsModel> fetchedNews = result['news'];
      final int total = result['total'];

      if (refresh) {
        _updatesList = fetchedNews;
      } else {
        _updatesList.addAll(fetchedNews);
      }

      _currentUpdatesPage++;
      _hasMoreUpdates = _updatesList.length < total;
      _error = null;
    } catch (e) {
      _error = "Failed to load updates. Please try again.";
    } finally {
      _isLoadingUpdates = false;
      _isLoadingMoreUpdates = false;
      notifyListeners();
    }
  }

  Future<void> fetchShokSandesh({bool refresh = false}) async {
    if (refresh) {
      _currentShokSandeshPage = 0;
      _hasMoreShokSandesh = true;
      _shokSandeshList.clear();
      _isLoadingShokSandesh = true;
      _error = null;
      notifyListeners();
    } else {
      if (!_hasMoreShokSandesh || _isLoadingShokSandesh || _isLoadingMoreShokSandesh) return;
      _isLoadingMoreShokSandesh = true;
      notifyListeners();
    }

    try {
      final result = await _newsApi.getNews(
        limit: _limit,
        offset: _currentShokSandeshPage * _limit,
        search: _searchQuery,
        isShokSandesh: true,
      );

      final List<NewsModel> fetchedNews = result['news'];
      final int total = result['total'];

      if (refresh) {
        _shokSandeshList = fetchedNews;
      } else {
        _shokSandeshList.addAll(fetchedNews);
      }

      _currentShokSandeshPage++;
      _hasMoreShokSandesh = _shokSandeshList.length < total;
      _error = null;
    } catch (e) {
      _error = "Failed to load Shok Sandesh. Please try again.";
    } finally {
      _isLoadingShokSandesh = false;
      _isLoadingMoreShokSandesh = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    fetchUpdates(refresh: true);
    fetchShokSandesh(refresh: true);
  }

  Future<bool> createNewsPost(
    String title,
    String description,
    String userId,
    String userName,
    List<File> images,
    bool isShokSandesh,
  ) async {
    _isLoadingUpdates = true;
    _isLoadingShokSandesh = true;
    _error = null;
    notifyListeners();

    try {
      await _newsApi.createNews(title, description, userId, userName, images, isShokSandesh);
      if (isShokSandesh) {
        await fetchShokSandesh(refresh: true);
      } else {
        await fetchUpdates(refresh: true);
      }
      return true;
    } on DioException catch (e) {
      _error =
          e.response?.data['message']?.toString() ??
          e.message ??
          "Failed to create news post.";
      _isLoadingUpdates = false;
      _isLoadingShokSandesh = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoadingUpdates = false;
      _isLoadingShokSandesh = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteNewsPost(String id) async {
    try {
      await _newsApi.deleteNews(id);
      _updatesList.removeWhere((news) => news.id == id);
      _shokSandeshList.removeWhere((news) => news.id == id);
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
    _isLoadingUpdates = true;
    _isLoadingShokSandesh = true;
    _error = null;
    notifyListeners();

    try {
      final updatedNews = await _newsApi.updateNews(
        id,
        title,
        description,
        newImages,
      );
      final indexUpdates = _updatesList.indexWhere((news) => news.id == id);
      if (indexUpdates != -1) {
        _updatesList[indexUpdates] = updatedNews;
      }
      final indexShok = _shokSandeshList.indexWhere((news) => news.id == id);
      if (indexShok != -1) {
        _shokSandeshList[indexShok] = updatedNews;
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
      _isLoadingUpdates = false;
      _isLoadingShokSandesh = false;
      notifyListeners();
    }
  }
}
