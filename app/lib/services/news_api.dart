import '../models/news_model.dart';
import 'core/api_client.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class NewsApi {
  final ApiClient _client = ApiClient();

  Future<Map<String, dynamic>> getNews({
    int limit = 10,
    int offset = 0,
    String search = '',
  }) async {
    final response = await _client.dio.get(
      '/news',
      queryParameters: {
        'limit': limit,
        'offset': offset,
        if (search.isNotEmpty) 'search': search,
      },
    );

    final List<dynamic> data = response.data['data'] ?? [];
    final meta = response.data['meta'] ?? {};

    return {
      'news': data.map((json) => NewsModel.fromJson(json)).toList(),
      'total': meta['total'] ?? 0,
    };
  }

  Future<Map<String, dynamic>> getNewsByUser(
    String userId, {
    int limit = 10,
    int offset = 0,
    String search = '',
  }) async {
    final response = await _client.dio.get(
      '/news/user/$userId',
      queryParameters: {
        'limit': limit,
        'offset': offset,
        if (search.isNotEmpty) 'search': search,
      },
    );

    final List<dynamic> data = response.data['data'] ?? [];
    final meta = response.data['meta'] ?? {};

    return {
      'news': data.map((json) => NewsModel.fromJson(json)).toList(),
      'total': meta['total'] ?? 0,
    };
  }

  Future<NewsModel> getNewsById(String id) async {
    final response = await _client.dio.get('/news/$id');
    return NewsModel.fromJson(response.data);
  }

  Future<NewsModel> createNews(
    String title,
    String description,
    String userId,
    String userName,
    List<File> images,
  ) async {
    FormData formData = FormData.fromMap({
      'title': title,
      'description': description,
      'userId': userId,
      'userName': userName,
    });

    for (var i = 0; i < images.length; i++) {
      formData.files.add(
        MapEntry('images', await MultipartFile.fromFile(images[i].path)),
      );
    }

    final response = await _client.dio.post('/news', data: formData);
    return NewsModel.fromJson(response.data);
  }

  Future<NewsModel> updateNews(
    String id,
    String title,
    String description,
    List<File> newImages,
  ) async {
    FormData formData = FormData.fromMap({
      'title': title,
      'description': description,
    });

    for (var i = 0; i < newImages.length; i++) {
      formData.files.add(
        MapEntry('images', await MultipartFile.fromFile(newImages[i].path)),
      );
    }

    final response = await _client.dio.put('/news/$id', data: formData);
    return NewsModel.fromJson(response.data);
  }

  Future<void> deleteNews(String id) async {
    await _client.dio.delete('/news/$id');
  }
}
