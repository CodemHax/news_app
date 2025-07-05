import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;

const String apiBaseUrl = 'https://newsapi.archax.site';

Future<List<Map<String, dynamic>>> fetchTrendingNews({int maxLimit = 100}) async {
  final url = Uri.parse('$apiBaseUrl/trending?max_limit=$maxLimit');

  try {
    final response = await http.get(
      url,
      headers: {
        'User-Agent': 'NewsApp/1.0',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final articles = List<Map<String, dynamic>>.from(data['data']);
          return articles;
        } else {
          throw Exception('Failed to load news: ${data['error'] ?? data['message'] ?? 'Unknown error'}');
        }
      } catch (parseError) {
        throw Exception('Failed to parse response: $parseError');
      }
    } else {
      throw Exception('Failed to load news: HTTP ${response.statusCode}');
    }
  } catch (e) {
    if (e is SocketException) {
      throw Exception('Network error: Please check your internet connection');
    } else if (e is TimeoutException) {
      throw Exception('Connection timeout: Server took too long to respond');
    } else {
      throw Exception('Unexpected error: $e');
    }
  }
}

Future<List<Map<String, dynamic>>> fetchNewsByCategory(String category, {int maxLimit = 40}) async {
  final url = Uri.parse('$apiBaseUrl/news/$category?max_limit=$maxLimit');

  try {
    final response = await http.get(
      url,
      headers: {
        'User-Agent': 'NewsApp/1.0',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('Failed to load news: ${data['error'] ?? 'Unknown error'}');
      }
    } else {
      throw Exception('Failed to load news: HTTP ${response.statusCode}');
    }
  } catch (e) {
    if (e is SocketException) {
      throw Exception('Network error: Please check your internet connection');
    } else if (e is TimeoutException) {
      throw Exception('Connection timeout: Server took too long to respond');
    } else {
      throw Exception('Unexpected error: $e');
    }
  }
}

Future<List<Map<String, dynamic>>> fetchHealthNews({int maxLimit = 40}) async {
  try {
    final alternatives = ['medical', 'healthcare', 'wellness'];
    for (final alternative in alternatives) {
      try {
        final url = Uri.parse('$apiBaseUrl/news/$alternative?max_limit=$maxLimit');
        final response = await http.get(
          url,
          headers: {
            'User-Agent': 'NewsApp/1.0',
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          if (data['success'] == true && data['data'] != null) {
            return List<Map<String, dynamic>>.from(data['data']);
          }
        }
      } catch (e) {
        continue;
      }
    }
    return fetchNewsByCategory('general', maxLimit: maxLimit);
  } catch (e) {
    throw Exception('Failed to load health news: $e');
  }
}

Future<List<Map<String, dynamic>>> fetchAllCategoriesNews({int maxLimit = 40}) async {
  try {
    final categories = await fetchCategories();

    categories.removeWhere((cat) => cat == 'trending' || cat == 'all');

    final selectedCategories = categories.take(5).join(',');

    final categoryData = await fetchMultipleCategoriesNews(selectedCategories, maxLimit: maxLimit ~/ 5);

    List<Map<String, dynamic>> allArticles = [];
    categoryData.forEach((category, articles) {
      allArticles.addAll(articles);
    });

    allArticles.shuffle();

    return allArticles;
  } catch (e) {
    throw Exception('Failed to load all categories: $e');
  }
}

Future<Map<String, List<Map<String, dynamic>>>> fetchMultipleCategoriesNews(
    String categories, {int maxLimit = 40}) async {
  final url = Uri.parse('$apiBaseUrl/news/multiple?categories=$categories&max_limit=$maxLimit');

  try {
    final response = await http.get(
      url,
      headers: {
        'User-Agent': 'NewsApp/1.0',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        final Map<String, dynamic> categoriesData = data['data'];
        final Map<String, List<Map<String, dynamic>>> result = {};

        categoriesData.forEach((category, articles) {
          result[category] = List<Map<String, dynamic>>.from(articles);
        });

        return result;
      } else {
        throw Exception('Failed to load multiple categories: ${data['error'] ?? 'Unknown error'}');
      }
    } else {
      throw Exception('Failed to load multiple categories: HTTP ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Unexpected error: $e');
  }
}

Future<List<String>> fetchCategories() async {
  final url = Uri.parse('$apiBaseUrl/categories');

  try {
    final response = await http.get(
      url,
      headers: {
        'User-Agent': 'NewsApp/1.0',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        final categories = List<String>.from(data['data'].map((cat) => cat['category_name']));
        return categories;
      } else {
        throw Exception('Failed to load categories: ${data['error'] ?? 'Unknown error'}');
      }
    } else {
      throw Exception('Failed to load categories: HTTP ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Unexpected error loading categories: $e');
  }
}

Future<List<Map<String, dynamic>>> searchNews(String query, {int maxLimit = 40}) async {
  if (query.trim().isEmpty) {
    throw Exception('Search query cannot be empty');
  }

  final url = Uri.parse('$apiBaseUrl/search?q=${Uri.encodeComponent(query)}&max_limit=$maxLimit');

  try {
    final response = await http.get(
      url,
      headers: {
        'User-Agent': 'NewsApp/1.0',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('Search failed: ${data['error'] ?? 'No results found'}');
      }
    } else {
      throw Exception('Search failed: HTTP ${response.statusCode}');
    }
  } catch (e) {
    if (e is SocketException) {
      throw Exception('Network error: Please check your internet connection');
    } else if (e is TimeoutException) {
      throw Exception('Connection timeout: Server took too long to respond');
    } else {
      throw Exception('Search error: $e');
    }
  }
}

Future<Map<String, dynamic>> getApiStatus() async {
  final url = Uri.parse('$apiBaseUrl/status');

  try {
    final response = await http.get(
      url,
      headers: {
        'User-Agent': 'NewsApp/1.0',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Failed to get API status: HTTP ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('API status error: $e');
  }
}
