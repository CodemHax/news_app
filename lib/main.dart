import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screen/detail_news.dart';
import 'Ferc/get_news.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

void requestNotificationPermission() async {
  try {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  } catch (e) {
    print('Error requesting notification permission: $e');
  }
}

Future<bool> isConnected() async {
  return Connectivity().checkConnectivity().then((result) {
    return result != ConnectivityResult.none;
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  requestNotificationPermission();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Map<String, dynamic>> articles = [];
  List<String> verticalItems = ['Loading news...'];

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {

    bool isConnectedToInternet = await isConnected();

    if (!isConnectedToInternet) {
      showToastMessage('No internet connection. Please check your connection.');
      setState(() {
        verticalItems = ['No internet connection'];
      });
      return;
    }
    try {
      final news = await fetchTrendingNews();
      setState(() {
        articles = news;
        verticalItems = news.map<String>((article) =>
        article['title'] as String? ?? 'No title').toList();
        if (verticalItems.isEmpty) {
          verticalItems = ['No news available'];
        }
      });
    } catch (e, stack) {
      print('Error loading news: $e\nStacktrace: $stack');
      setState(() {
        verticalItems = ['Error loading news'];
      });
    }
  }

  void showToastMessage(String message) {
    Future.delayed(Duration(milliseconds: 0), () {
      Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
          fontSize: 16.0
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('News App'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _loadNews,
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _loadNews,
          child: articles.isEmpty
            ? Center(
                child: Text(
                  verticalItems.first,
                  style: TextStyle(fontSize: 16),
                ),
              )
            : ListView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                itemCount: articles.length,
                padding: EdgeInsets.all(10),
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      onTap: () {
                        var info = articles[index];
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailNews(
                              title: info['title'] ?? 'No title',
                              content: info['content'] ?? 'No content available',
                              imageUrl: info['imageUrl'],
                              date: info['date'] ?? 'Unknown date',
                              time: info['time'] ?? 'Unknown time',
                              source: info['readMoreUrl'] ?? 'Unknown source',
                              author: info['author'] ?? 'Unknown author',
                            ),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (articles[index]["imageUrl"] != null && articles[index]["imageUrl"].toString().isNotEmpty)
                            Image.network(
                              articles[index]["imageUrl"] ?? '',
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 100,
                                color: Colors.grey.shade200,
                                child: Icon(Icons.image_not_supported, color: Colors.grey),
                              ),
                            ),
                          Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  articles[index]['title'] ?? 'No title',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  _getPreviewContent(articles[index]['content']),
                                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 6),
                                Text(
                                  '${articles[index]['date'] ?? 'Unknown date'}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        ),
      ),
    );
  }

  String _getPreviewContent(dynamic content) {
    if (content == null) return 'No content available';
    return content.toString().length > 100
      ? '${content.toString().substring(0, 100)}...'
      : content.toString();
  }
}
