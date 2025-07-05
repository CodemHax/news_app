import 'package:flutter/material.dart';
import '../fetch//get_news.dart' as fetch;
import '../models/news_model.dart';

class NewsProvider extends ChangeNotifier {
  List<NewsArticle> _articles = [];
  List<String> _categories = ['trending'];
  String _selectedCategory = 'trending';
  Map<String, List<NewsArticle>> _categoryArticles = {};
  Map<String, dynamic> _apiStats = {};

  bool _isLoading = true;
  String _error = '';
  bool _isSearching = false;
  String _searchQuery = '';

  List<NewsArticle> get articles => _articles;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  Map<String, List<NewsArticle>> get categoryArticles => _categoryArticles;
  Map<String, dynamic> get apiStats => _apiStats;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;

  NewsProvider() {
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await loadCategories();
    await loadNews(_selectedCategory);
  }

  void _clearError() {
    _error = '';
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _handleError(String errorMessage) {
    _error = errorMessage;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadCategories() async {
    try {
      final categoriesResponse = await fetch.fetchCategories();
      List<String> fetchedCategories = categoriesResponse;
      
      fetchedCategories.removeWhere((cat) => cat.toLowerCase() == 'all');


      if (!fetchedCategories.contains('trending')) {
        _categories = ['trending', ...fetchedCategories];
      } else {
        _categories = fetchedCategories;
        _categories.remove('trending');
        _categories.insert(0, 'trending');
      }

      notifyListeners();
    } catch (e) {
      _categories = [
        'trending', 'business', 'sports', 'technology',
        'entertainment', 'science', 'politics', 'world'
      ];
      notifyListeners();
    }
  }

  Future<void> loadNews(String category) async {
    if (_isLoading && category == _selectedCategory && _articles.isNotEmpty) {
      return;
    }

    _clearError();
    _setLoading(true);
    _isSearching = false;
    _searchQuery = '';
    _selectedCategory = category;

    try {
      List<Map<String, dynamic>> newsData;
      if (category == 'trending') {
        newsData = await fetch.fetchTrendingNews();
      } else {
        newsData = await fetch.fetchNewsByCategory(category);
      }
      if (newsData.isEmpty) {
        _handleError('No articles found for $category');
        return;
      }
      _articles = newsData.map((article) => NewsArticle.fromJson(article)).toList();
      _categoryArticles[category] = List.from(_articles);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _handleError('Error: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  Future<void> searchNews(String query) async {
    if (query.trim().isEmpty) {
      return loadNews(_selectedCategory);
    }

    _clearError();
    _setLoading(true);
    _isSearching = true;
    _searchQuery = query;

    try {
      final searchResults = await fetch.searchNews(query);
      _articles = searchResults.map((article) => NewsArticle.fromJson(article)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _handleError('Search error: ${e.toString().replaceAll('Exception: ', '')}');
      _articles = [];
      notifyListeners();
    }
  }

  void cancelSearch() {
    if (_isSearching) {
      _isSearching = false;
      _searchQuery = '';

      if (_categoryArticles.containsKey(_selectedCategory)) {
        _articles = _categoryArticles[_selectedCategory]!;
      } else {
        loadNews(_selectedCategory);
      }

      notifyListeners();
    }
  }

  Future<void> refreshNews() async {
    if (_isSearching) {
      await searchNews(_searchQuery);
    } else {
      await loadNews(_selectedCategory);
    }
  }

  void setSelectedCategory(String category) {
    if (category != _selectedCategory) {
      loadNews(category);
    }
  }

  Future<void> getApiStats() async {
    try {
      final stats = await fetch.getApiStatus();
      _apiStats = stats;
      notifyListeners();
    } catch (e) {
      _apiStats = {'error': 'Could not fetch API stats'};
      notifyListeners();
    }
  }
}