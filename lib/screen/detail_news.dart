import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';

class DetailNews extends StatelessWidget {
  final String title;
  final String content;
  final String? imageUrl;
  final String? date;
  final String? time;
  final String? author;
  final String? source;
  final String? url;

  const DetailNews({
    super.key,
    required this.title,
    required this.content,
    this.imageUrl,
    this.date,
    this.time,
    this.author,
    this.source,
    this.url,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: imageUrl != null ? 250.0 : 0.0,
              pinned: true,
              stretch: true,
              flexibleSpace: imageUrl != null
                ? FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(color: Colors.white),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey.shade200,
                            child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                              stops: [0.6, 1.0],
                            ),
                          ),
                        ),
                      ],
                    ),
                    stretchModes: [
                      StretchMode.zoomBackground,
                      StretchMode.blurBackground,
                    ],
                  )
                : null,
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.roboto(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),

                    SizedBox(height: 16),

                    Row(
                      children: [
                        if (author != null && author!.isNotEmpty)
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.person, size: 16, color: Colors.blue),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    author!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        SizedBox(width: 12),

                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(
                              date ?? 'Unknown date',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),

                    Divider(height: 32),

                    Text(
                      content,
                      style: GoogleFonts.roboto(
                        fontSize: 16.0,
                        height: 1.6,
                        letterSpacing: 0.1,
                      ),
                    ),

                    SizedBox(height: 24),

                    if (source != null && source!.isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? Colors.grey[700]! : Colors.blue.shade100,
                          ),
                        ),
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Source',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
                              ),
                            ),
                            SizedBox(height: 8),
                            InkWell(
                              onTap: () => _launchURL(context, source!),
                              child: Text(
                                source!,
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (source != null && source!.isNotEmpty)
            FloatingActionButton.small(
              heroTag: 'source',
              onPressed: () => _launchURL(context, source!),
              child: Icon(Icons.language),
              backgroundColor: isDark ? Colors.blueGrey[700] : Colors.blue,
            ),
          SizedBox(height: 8),

          FloatingActionButton(
            heroTag: 'share',
            onPressed: () => _shareArticle(),
            child: Icon(Icons.share),
            backgroundColor: isDark ? Colors.blueGrey[600] : Colors.blue.shade700,
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);

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
              SnackBar(content: Text('Could not open link: $url')),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid URL: $url')),
        );
      }
    }
  }

  void _shareArticle() {
    String shareText = '$title\n\n$content';

    if (url != null && url!.isNotEmpty) {
      shareText += '\n\nShort link: $url';
    }

    if (source != null && source!.isNotEmpty) {
      shareText += '\n\nSource: $source';
    }

    Share.share(shareText);
  }
}
