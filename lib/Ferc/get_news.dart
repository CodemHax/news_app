import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>> fetchTrendingNews() async {
  final url = Uri.parse('https://newsapi.archax.site/trending?max_limit=100');
  final response = await http.get(url);

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
}

