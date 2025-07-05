class NewsArticle {
  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final String? url;
  final String? date;
  final String? time;
  final String? author;
  final String? readMoreUrl;
  final String? category;
  final bool? isTrending;

  NewsArticle({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    this.url,
    this.date,
    this.time,
    this.author,
    this.readMoreUrl,
    this.category,
    this.isTrending = false,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['id'] ?? '',
      title: json['title'] ?? 'No title',
      content: json['content'] ?? 'No content',
      imageUrl: json['imageUrl'],
      url: json['url'],
      date: json['date'],
      time: json['time'],
      author: json['author'],
      readMoreUrl: json['readMoreUrl'],
      category: json['category'],
      isTrending: json['is_trending'] ?? false,
    );
  }
}

class NewsResponse {
  final bool success;
  final String? category;
  final List<NewsArticle> data;
  final String? error;
  final int totalArticles;
  final String? timestamp;

  NewsResponse({
    required this.success,
    this.category,
    required this.data,
    this.error,
    required this.totalArticles,
    this.timestamp,
  });

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    return NewsResponse(
      success: json['success'] ?? false,
      category: json['category'],
      data: (json['data'] as List?)
          ?.map((article) => NewsArticle.fromJson(article))
          .toList() ?? [],
      error: json['error'],
      totalArticles: json['totalArticles'] ?? 0,
      timestamp: json['timestamp'],
    );
  }
}
