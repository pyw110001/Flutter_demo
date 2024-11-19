import 'package:dio/dio.dart';

class UnsplashService {
  final String _baseUrl = 'https://api.unsplash.com';
  final String _accessKey = '8uBy81EYaCLmsCmE0n6VND0ElNI-pliY9d1L-ZnbKIw'; // 请替换成你的 Unsplash API key
  final Dio _dio = Dio();

  /// 获取随机图片
  /// 
  /// [width] - 图片宽度，默认1920
  /// [height] - 图片高度，默认1080
  /// 返回值为包含图片URL的Map对象
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
      throw Exception('获取图片失败: $e');
    }
  }
} 