import 'package:dio/dio.dart';

class UnsplashService {
  final String _baseUrl = 'https://api.unsplash.com';
  final String _accessKey = '8uBy81EYaCLmsCmE0n6VND0ElNI-pliY9d1L-ZnbKIw';
  final Dio _dio = Dio();

  /// 获取随机图片
  /// [width] - 图片宽度
  /// [height] - 图片高度
  /// 返回包含图片信息的Map
  Future<Map<String, dynamic>> getRandomPhoto({
    int width = 1920,
    int height = 1080,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/photos/random',
        queryParameters: {
          'client_id': _accessKey,
          'w': width,
          'h': height,
        },
      );
      
      return {
        'url': response.data['urls']['regular'],
        'author': response.data['user']['name'],
        'description': response.data['description'] ?? '无描述',
      };
    } catch (e) {
      print('获取随机图片失败: $e');
      throw Exception('获取图片失败: $e');
    }
  }

  /// 获取图片列表
  /// [page] - 页码
  /// [perPage] - 每页数量
  /// [topic] - 分类主题ID，可选
  /// 返回图片列表数组
  Future<List<Map<String, dynamic>>> getPhotos({
    required int page,
    int perPage = 30,
    String? topic,
  }) async {
    try {
      final String endpoint = topic != null 
          ? '$_baseUrl/topics/$topic/photos'
          : '$_baseUrl/photos';

      final response = await _dio.get(
        endpoint,
        queryParameters: {
          'client_id': _accessKey,
          'page': page,
          'per_page': perPage,
          'w': 200,
          'h': 200,
        },
      );

      return (response.data as List).map((photo) => {
        'id': photo['id'],
        'url': photo['urls']['small'],
        'author': photo['user']['name'],
        'description': photo['description'] ?? '无描述',
      }).toList();
    } catch (e) {
      print('获取图片列表失败: $e');
      throw Exception('获取图片列表失败: $e');
    }
  }

  /// 获取主题分类列表
  /// 返回分类列表数组
  Future<List<Map<String, dynamic>>> getTopics() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/topics',
        queryParameters: {
          'client_id': _accessKey,
          'per_page': 30,
        },
      );

      return (response.data as List).map((topic) => {
        'id': topic['id'],
        'title': topic['title'],
        'description': topic['description'],
      }).toList();
    } catch (e) {
      print('获取主题分类失败: $e');
      throw Exception('获取主题分类失败: $e');
    }
  }
} 