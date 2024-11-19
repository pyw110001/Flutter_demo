import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';

class PhotoDetailPage extends StatefulWidget {
  final Map<String, dynamic> photo;
  
  const PhotoDetailPage({
    super.key,
    required this.photo,
  });

  @override
  State<PhotoDetailPage> createState() => _PhotoDetailPageState();
}

class _PhotoDetailPageState extends State<PhotoDetailPage> {
  void _sharePhoto() {
    Share.share(
      '分享一张来自 Unsplash 的图片\n'
      '作者: ${widget.photo['author']}\n'
      '${widget.photo['full_url']}',
    );
  }

  String get _highResUrl {
    // 使用full分辨率的URL，并添加尺寸参数
    final url = widget.photo['full_url'] ?? widget.photo['url'];
    print('加载高清图片: $url');
    return '$url&w=2560&q=80';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.photo['author'] ?? '未知作者',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _sharePhoto,
          ),
        ],
      ),
      body: Stack(
        children: [
          PhotoView(
            imageProvider: CachedNetworkImageProvider(_highResUrl),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
            backgroundDecoration: const BoxDecoration(
              color: Colors.black,
            ),
            loadingBuilder: (context, event) {
              // 显示加载进度
              if (event == null) {
                return const Center(child: CircularProgressIndicator());
              }
              final progress = event.cumulativeBytesLoaded / 
                  (event.expectedTotalBytes ?? 1);
              print('图片加载进度: ${(progress * 100).toStringAsFixed(1)}%');
              
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(value: progress),
                    const SizedBox(height: 16),
                    Text(
                      '${(progress * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              print('图片加载错误: $error');
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error, color: Colors.white, size: 48),
                    SizedBox(height: 16),
                    Text(
                      '图片加载失败',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            },
          ),
          // 显示描述信息
          if (widget.photo['description']?.isNotEmpty ?? false)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.photo['description'],
                  style: const TextStyle(color: Colors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }
} 