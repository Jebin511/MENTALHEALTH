// ignore: depend_on_referenced_packages
import 'package:feelings/chatlist.dart';
import 'package:feelings/message.dart';
import 'package:feelings/surveys.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';


// NEW: Import the chat list page


// A simple data class for our articles
class Article {
  final String title;
  final String description;
  final String imageUrl;

  Article({
    required this.title,
    required this.description,
    required this.imageUrl,
  });
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  YoutubePlayerController? _ytController;
  List<Article> _articles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Fetch content first, then check if the survey is needed
    _fetchContent().then((_) {
      if (!_isLoading) {
        _showSurveyIfNeeded();
      }
    });
  }

  /// Fetches video and articles from the 'content' table.
  Future<void> _fetchContent() async {
    try {
      final response = await Supabase.instance.client.from('content').select();
      
      String? videoId;
      final List<Article> fetchedArticles = [];

      for (var item in response) {
        if (item['content_type'] == 'youtube_video') {
          videoId = item['data_value'];
        } else if (item['content_type'] == 'article') {
          fetchedArticles.add(
            Article(
              title: item['title'] ?? 'No Title',
              description: item['description'] ?? 'No Description',
              imageUrl: item['image_url'] ?? '',
            ),
          );
        }
      }

      if (mounted && videoId != null) {
        setState(() {
          _articles = fetchedArticles;
          _ytController = YoutubePlayerController(
            initialVideoId: videoId!,
            flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
          );
          _isLoading = false;
        });
      } else {
        // Handle case where videoId might be null
        if (mounted) {
          setState(() {
            _articles = fetchedArticles; // Still show articles
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if(mounted){
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching content: ${e.toString()}'))
        );
      }
    }
  }

  /// --- NEW: Checks if a survey exists and shows the dialog if not ---
  Future<void> _showSurveyIfNeeded() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final response = await Supabase.instance.client
          .from('gad7_surveys') // Check the correct table
          .select('id')
          .eq('user_id', userId)
          .limit(1);

      // If the response is empty, it means the user has never submitted the GAD-7 survey
      if (response.isEmpty && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false, // User must interact
          builder: (context) => const SurveyDialog(),
        );
      }
    } catch (e) {
      print('Error checking for survey: $e');
    }
  }

  @override
  void deactivate() {
    _ytController?.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _ytController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PEACE"),
        backgroundColor: const Color(0xFFA786DF),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.message_outlined),
            tooltip: 'Messages',
            onPressed: () {
              // --- THIS IS THE FIX ---
              // Navigate to the list of chats, NOT a single message page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatListPage()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        // ... Your Drawer code can be placed here ...
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_ytController != null)
                  Container(
                    color: Colors.black,
                    child: YoutubePlayer(
                      controller: _ytController!,
                      showVideoProgressIndicator: true,
                      progressIndicatorColor: const Color(0xFFA786DF),
                    ),
                  ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Wellness Articles',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _articles.isEmpty
                      ? const Center(child: Text('No articles found.'))
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _articles.length,
                          itemBuilder: (context, index) {
                            final article = _articles[index];
                            return ArticleCard(
                              title: article.title,
                              description: article.description,
                              imageUrl: article.imageUrl,
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

// Custom widget for an article card
class ArticleCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;

  const ArticleCard({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      height: 120,
                      color: Colors.grey[300],
                      child: const Center(child: Text('Image Failed to Load')),
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}