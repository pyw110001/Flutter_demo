import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/unsplash_service.dart';
import 'photo_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final UnsplashService _unsplashService = UnsplashService();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _photos = [];
  final List<Map<String, dynamic>> _topics = [];
  
  String? _selectedTopic;
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadTopics();
    _loadPhotos();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 500) {
      _loadPhotos();
    }
  }

  Future<void> _loadTopics() async {
    try {
      final topics = await _unsplashService.getTopics();
      setState(() {
        _topics.clear();
        _topics.addAll(topics);
      });
    } catch (e) {
      print('加载主题失败: $e');
    }
  }

  Future<void> _loadPhotos() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);
    try {
      final photos = await _unsplashService.getPhotos(
        page: _currentPage,
        topic: _selectedTopic,
      );
      
      setState(() {
        _photos.addAll(photos);
        _currentPage++;
        _hasMore = photos.isNotEmpty;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('加载图片失败: $e');
    }
  }

  void _onTopicSelected(String? topicId) {
    setState(() {
      _selectedTopic = topicId;
      _photos.clear();
      _currentPage = 1;
      _hasMore = true;
    });
    _loadPhotos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('壁纸工具', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          // 分类按钮组
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: const Text('全部'),
                    selected: _selectedTopic == null,
                    onSelected: (_) => _onTopicSelected(null),
                  ),
                ),
                ..._topics.map((topic) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(topic['title']),
                    selected: _selectedTopic == topic['id'],
                    onSelected: (_) => _onTopicSelected(topic['id']),
                  ),
                )),
              ],
            ),
          ),
          
          // 图片网格
          Expanded(
            child: GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: MediaQuery.of(context).size.width / 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: _photos.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _photos.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final photo = _photos[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhotoDetailPage(photo: photo),
                      ),
                    );
                  },
                  child: CachedNetworkImage(
                    imageUrl: photo['url'],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 