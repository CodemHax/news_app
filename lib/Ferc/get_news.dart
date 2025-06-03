import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>> fetchTrendingNews() async {
  final url = Uri.parse('https://newsapi.archax.site/trending?max_limit=100');

  try {
    final response = await http.get(
      url,
      headers: {
        'User-Agent': 'NewsApp/1.0',
        'Accept': 'application/json',
      },
    ).timeout(Duration(seconds: 15));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('Failed to load news: ${data['error'] ?? data['message'] ?? 'Unknown error'}');
      }
    } else {
      throw Exception('Failed to load news: HTTP ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Unexpected error: $e');
  }
}

