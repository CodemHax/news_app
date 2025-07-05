import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import 'widgets/news_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  bool showSearchBar = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              pinned: true,
              floating: true,
              snap: true,
              title: showSearchBar
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search for news...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    onSubmitted: (query) {
                      if (query.trim().isNotEmpty) {
                        newsProvider.searchNews(query);
                      }
                    },
                  )
                : Text(
                    'News App',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              actions: [
                IconButton(
                  icon: Icon(showSearchBar ? Icons.close : Icons.search),
                  onPressed: () {
                    setState(() {
                      showSearchBar = !showSearchBar;
                      if (!showSearchBar) {
                        _searchController.clear();
                        if (newsProvider.isSearching) {
                          newsProvider.cancelSearch();
                        }
                      }
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    _refreshIndicatorKey.currentState?.show();
                  },
                ),
              ],
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(108),
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      tabs: [
                        Tab(text: 'Headlines'),
                        Tab(text: 'Categories'),
                      ],
                      indicatorWeight: 3,
                      labelStyle: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (newsProvider.categories.isNotEmpty && !newsProvider.isSearching)
                      Container(
                        height: 50,
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          itemCount: newsProvider.categories.length,
                          itemBuilder: (context, index) {
                            final category = newsProvider.categories[index];
                            final isSelected = category == newsProvider.selectedCategory;

                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(
                                  _capitalizeFirstLetter(category),
                                  style: TextStyle(
                                    color: isSelected
                                      ? Colors.white
                                      : isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    newsProvider.setSelectedCategory(category);
                                  }
                                },
                                backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                                selectedColor: Colors.blue,
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildNewsListView(newsProvider),
            _buildCategoriesGridView(newsProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsListView(NewsProvider newsProvider) {
    if (newsProvider.isLoading) {
      return ListView.builder(
        itemCount: 5,
        padding: EdgeInsets.only(top: 8),
        itemBuilder: (context, index) => NewsCardSkeleton(),
      );
    }

    if (newsProvider.error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 50, color: Colors.red[400]),
            SizedBox(height: 16),
            Text(
              newsProvider.error,
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => newsProvider.loadNews(newsProvider.selectedCategory),
              child: Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (newsProvider.articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.article_outlined, size: 50, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              newsProvider.isSearching
                  ? 'No results found for "${newsProvider.searchQuery}"'
                  : 'No news available',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: () => newsProvider.loadNews(newsProvider.selectedCategory),
      child: ListView.builder(
        itemCount: newsProvider.articles.length,
        padding: EdgeInsets.only(top: 8, bottom: 24),
        itemBuilder: (context, index) {
          final article = newsProvider.articles[index];
          return ModernNewsCard(article: article, index: index);
        },
      ),
    );
  }

  Widget _buildCategoriesGridView(NewsProvider newsProvider) {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: newsProvider.categories.length,
      itemBuilder: (context, index) {
        final category = newsProvider.categories[index];
        final Color cardColor = _getCategoryColor(category);

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
            color: cardColor,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                newsProvider.setSelectedCategory(category);
                _tabController.animateTo(0);
              },
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Icon(
                      _getCategoryIcon(category),
                      size: 100,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          _getCategoryIcon(category),
                          color: Colors.white,
                          size: 28,
                        ),
                        Spacer(),
                        Text(
                          _capitalizeFirstLetter(category),
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
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
