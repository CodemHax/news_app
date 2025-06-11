import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../../models/news_model.dart';
import '../detail_news.dart';

class ModernNewsCard extends StatelessWidget {
  final NewsArticle article;
  final int index;

  const ModernNewsCard({
    required this.article,
    required this.index,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        FadeEffect(
          duration: Duration(milliseconds: 300),
          delay: Duration(milliseconds: 50 * index),
        ),
        SlideEffect(
          duration: Duration(milliseconds: 300),
          delay: Duration(milliseconds: 50 * index),
          begin: Offset(0, 0.1),
          end: Offset.zero,
        ),
      ],
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        shadowColor: Colors.black26,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailNews(
                  title: article.title,
                  content: article.content,
                  imageUrl: article.imageUrl,
                  date: article.date,
                  time: article.time,
                  author: article.author,
                  source: article.readMoreUrl,
                  url: article.url,
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (article.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: article.imageUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            color: Colors.white,
                            height: 200,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 200,
                          color: Colors.grey.shade200,
                          child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                        ),
                      ),
                      if (article.category != null)
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(article.category!),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getCategoryIcon(article.category!),
                                  size: 12,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  _capitalizeFirstLetter(article.category!),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (article.isTrending == true)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.trending_up, size: 14, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  'TRENDING',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Text(
                      article.content,
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        height: 1.4,
                        color: Colors.grey[700],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          _formatDate(article.date),
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        SizedBox(width: 12),
                        if (article.time != null) ...[
                          Icon(Icons.access_time, size: 14, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            article.time!,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                        Spacer(),
                        if (article.author != null) ...[
                          Icon(Icons.person, size: 14, color: Colors.grey),
                          SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              article.author!,
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Unknown date';

    try {
      final DateTime? date = _parseDate(dateStr);
      if (date != null) {
        return DateFormat('MMM d, yyyy').format(date);
      }
    } catch (e) {
    }

    return dateStr;
  }

  DateTime? _parseDate(String dateStr) {
    try {
      final RegExp dateRegex = RegExp(r'(\d+)\s+(\w+),\s+(\d{4})');
      final match = dateRegex.firstMatch(dateStr);
      if (match != null) {
        final day = int.parse(match.group(1)!);
        final month = _getMonthNumber(match.group(2)!);
        final year = int.parse(match.group(3)!);
        return DateTime(year, month, day);
      }
    } catch (e) {
    }

    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  int _getMonthNumber(String month) {
    const months = {
      'january': 1, 'february': 2, 'march': 3, 'april': 4,
      'may': 5, 'june': 6, 'july': 7, 'august': 8,
      'september': 9, 'october': 10, 'november': 11, 'december': 12
    };
    return months[month.toLowerCase()] ?? 1;
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'trending': return Icons.trending_up;
      case 'business': return Icons.business_center;
      case 'sports': return Icons.sports_soccer;
      case 'world': return Icons.public;
      case 'politics': return Icons.account_balance;
      case 'technology': return Icons.devices;
      case 'entertainment': return Icons.movie_creation;
      case 'science': return Icons.science_outlined;
      default: return Icons.article_outlined;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'trending': return Colors.red;
      case 'business': return Colors.amber[800]!;
      case 'sports': return Colors.green[700]!;
      case 'world': return Colors.purple[700]!;
      case 'politics': return Colors.indigo[600]!;
      case 'technology': return Colors.cyan[700]!;
      case 'entertainment': return Colors.pink[600]!;
      case 'science': return Colors.lightBlue[700]!;
      default: return Colors.grey[700]!;
    }
  }
}

class NewsCardSkeleton extends StatelessWidget {
  const NewsCardSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 20,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 20,
                    width: double.infinity * 0.7,
                    color: Colors.white,
                  ),
                  SizedBox(height: 12),
                  Container(
                    height: 14,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                  SizedBox(height: 6),
                  Container(
                    height: 14,
                    width: double.infinity * 0.9,
                    color: Colors.white,
                  ),
                  SizedBox(height: 6),
                  Container(
                    height: 14,
                    width: double.infinity * 0.8,
                    color: Colors.white,
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 12,
                        width: 80,
                        color: Colors.white,
                      ),
                      Container(
                        height: 12,
                        width: 80,
                        color: Colors.white,
                      ),
                    ],
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
