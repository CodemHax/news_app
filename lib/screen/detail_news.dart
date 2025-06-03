import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailNews extends StatelessWidget {
  final String title;
  final String content;
  final String? imageUrl;
  final String? date;
  final String? time;
  final String? author;
  final String? source;

  const DetailNews({
    super.key,
    required this.title,
    required this.content,
    this.imageUrl,
    this.date,
    this.time,
    this.author,
    this.source,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              Image.network(
                imageUrl!,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey.shade200,
                  child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '${author ?? 'Unknown author'} • ${date ?? 'Unknown date'}${time != null ? ', $time' : ''}',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(height: 20),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 16.0,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 24),
                  if (source != null && source!.isNotEmpty)
                    GestureDetector(
                      onTap: () async {
                        try {
                          final uri = Uri.parse(source!);

                          bool launched = await launchUrl(
                            uri,
                            mode: LaunchMode.inAppWebView,
                            webViewConfiguration: const WebViewConfiguration(
                              enableJavaScript: true,
                              enableDomStorage: true,
                            ),
                          );

                          if (!launched) {
                            launched = await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );

                            if (!launched) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Could not open link: $source')),
                                );
                              }
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error opening link: ${e.toString()}')),
                            );
                          }
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Icon(Icons.link, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Read full article',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
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

