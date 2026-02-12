import 'dart:ui';
import 'package:flutter/material.dart';

import '../services/tmdb_api.dart';
import '../database/favorite.dart';

import 'movie_detail.dart';
import 'movieCatergory.dart';
import 'CategoryDetail.dart';

enum SearchType { movie, tv, all }

enum SortMode {
  relevance,
  popularityDesc,
  ratingDesc,
  newest,
  oldest,
  titleAsc,
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();

  final TmdbService _tmdbService = TmdbService(
    'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJlNWUxYTU5ODc0YzMwZDlmMWM2NTJlYjllZDQ4MmMzMyIsIm5iZiI6MTc2NjQzOTY0Mi40NTIsInN1YiI6IjY5NDliYWRhNTNhODI1Nzk1YzE1NTk5OCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.V0Z-rlGFtBKfCUHFx3nNnqxVNoJ-T3YNVDF8URfMj4U',
  );

  // UI scroll
  final ScrollController _scrollController = ScrollController();

  // Fetch once (relevance order) then sort locally
  static const int _tmdbPageSize = 20;
  static const int _maxItems = 30;

  // Prefetched “relevance order” results
  final List<dynamic> _allResults = [];

  // Displayed list (sorted view of _allResults)
  List<dynamic> _movies = [];

  bool _isLoading = false;
  String _currentQuery = '';
  String? _errorMessage;

  // type + sort
  SearchType _type = SearchType.movie;
  SortMode _sort = SortMode.relevance;

  // de-dupe across pages (key = "movie:123" / "tv:456")
  final Set<String> _seenKeys = <String>{};

  // UI helpers
  bool _showBackToTop = false;
  String? _favoriteGenre;

  @override
  void initState() {
    super.initState();
    _loadFavoriteGenre();

    _scrollController.addListener(() {
      final shouldShow = _scrollController.hasClients &&
          _scrollController.offset > 520 &&
          _movies.isNotEmpty;
      if (shouldShow != _showBackToTop) {
        setState(() => _showBackToTop = shouldShow);
      }
    });
  }

  Future<void> _loadFavoriteGenre() async {
    final genre = await FavoriteDao.getMostFrequentGenre();
    if (mounted) {
      setState(() => _favoriteGenre = genre);
    }
  }

  // -----------------------------
  // Helpers
  // -----------------------------
  String _inferMediaType(dynamic item) {
    final mt = (item is Map) ? item['media_type'] : null;
    if (mt == 'movie' || mt == 'tv') return mt;

    switch (_type) {
      case SearchType.tv:
        return 'tv';
      case SearchType.all:
        return 'movie'; // fallback if missing
      case SearchType.movie:
      default:
        return 'movie';
    }
  }

  String _dedupeKey(dynamic item) {
    final id = (item is Map) ? item['id'] : null;
    final mt = _inferMediaType(item);
    return '$mt:$id';
  }

  String _titleOf(dynamic item) {
    return (item['title'] ?? item['name'] ?? 'Untitled').toString();
  }

  String _dateOf(dynamic item) {
    final mt = _inferMediaType(item);
    final d = mt == 'tv' ? item['first_air_date'] : item['release_date'];
    return (d ?? '').toString(); // ISO yyyy-mm-dd or ""
  }

  int _yearOf(dynamic item) {
    final d = _dateOf(item);
    if (d.length >= 4) {
      final y = int.tryParse(d.substring(0, 4));
      return y ?? 0;
    }
    return 0;
  }

  double _popularityOf(dynamic item) {
    final v = item['popularity'];
    if (v is num) return v.toDouble();
    return 0.0;
  }

  double _ratingOf(dynamic item) {
    final v = item['vote_average'];
    if (v is num) return v.toDouble();
    return 0.0;
  }

  Future<List<dynamic>> _fetchByType(String query, int page) async {
    switch (_type) {
      case SearchType.movie:
        return _tmdbService.searchMovies(query, page: page);
      case SearchType.tv:
        return _tmdbService.searchTv(query, page: page);
      case SearchType.all:
        return _tmdbService.searchMulti(query, page: page);
    }
  }

  List<dynamic> _sortedAll() {
    // Always return a copy, so we never mutate _allResults order.
    if (_sort == SortMode.relevance) {
      return List<dynamic>.from(_allResults);
    }

    final list = List<dynamic>.from(_allResults);

    list.sort((a, b) {
      switch (_sort) {
        case SortMode.popularityDesc:
          return _popularityOf(b).compareTo(_popularityOf(a));
        case SortMode.ratingDesc:
          return _ratingOf(b).compareTo(_ratingOf(a));
        case SortMode.newest:
          return _dateOf(b).compareTo(_dateOf(a)); // ISO sorts correctly
        case SortMode.oldest:
          return _dateOf(a).compareTo(_dateOf(b));
        case SortMode.titleAsc:
          return _titleOf(a).toLowerCase().compareTo(_titleOf(b).toLowerCase());
        case SortMode.relevance:
        default:
          return 0;
      }
    });

    return list;
  }

  void _rebuildDisplayed() {
    _movies = _sortedAll();
  }

  // -----------------------------
  // Search (fetch up to 30)
  // -----------------------------
  Future<void> _search({bool reset = true}) async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    FocusScope.of(context).unfocus();

    if (reset) {
      setState(() {
        _currentQuery = query;

        _allResults.clear();
        _movies = [];
        _seenKeys.clear();

        _errorMessage = null;
        _isLoading = true;
        _showBackToTop = false;
      });

      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    }

    try {
      int page = 1;
      bool stop = false;

      while (!stop && _allResults.length < _maxItems) {
        final result = await _fetchByType(_currentQuery, page);

        if (result.isEmpty) break;

        // In "All", remove people results
        final cleaned = result.where((item) {
          final mt = (item is Map) ? item['media_type'] : null;
          if (_type == SearchType.all && mt == 'person') return false;
          return true;
        }).toList();

        // filter items without poster
        final withPoster = cleaned.where((item) {
          return item['poster_path'] != null &&
              item['poster_path'].toString().isNotEmpty;
        }).toList();

        // de-dupe and append (keeps TMDb relevance order)
        for (final item in withPoster) {
          final key = _dedupeKey(item);
          if (_seenKeys.contains(key)) continue;
          _seenKeys.add(key);

          _allResults.add(item);
          if (_allResults.length >= _maxItems) break;
        }

        // if returned less than a full page, assume no more
        if (result.length < _tmdbPageSize) {
          stop = true;
        } else {
          page += 1;
        }
      }

      if (!mounted) return;

      if (_allResults.isEmpty) {
        setState(() {
          _isLoading = false;
          _movies = [];
          _errorMessage = 'No results for "$_currentQuery"';
        });
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = null;
        _rebuildDisplayed(); // applies current _sort
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _movies = [];
        _errorMessage = "Search failed. Please check your connection.";
      });
    }
  }

  // when user changes type/sort
  void _onTypeChanged(SearchType? t) {
    if (t == null) return;
    setState(() => _type = t);

    if (_controller.text.trim().isNotEmpty) {
      _search(reset: true);
    }
  }

  void _onSortChanged(SortMode? s) {
    if (s == null) return;
    setState(() {
      _sort = s;
      if (_allResults.isNotEmpty) {
        _rebuildDisplayed();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // -----------------------------
  // UI
  // -----------------------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final bool showingResults =
        !_isLoading && _errorMessage == null && _movies.isNotEmpty;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      resizeToAvoidBottomInset: false,
      floatingActionButton: _showBackToTop
          ? FloatingActionButton(
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOutCubic,
                );
              },
              child: const Icon(Icons.arrow_upward_rounded),
            )
          : null,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withOpacity(isDark ? 0.15 : 0.08),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // title
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Search",
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      ),
                      Text(
                        "Find your next story",
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                // search bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _search(reset: true),
                      style: TextStyle(color: colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: _type == SearchType.tv
                            ? "Enter TV show name..."
                            : "Enter title...",
                        hintStyle:
                            TextStyle(color: colorScheme.onSurfaceVariant),
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: Colors.deepPurpleAccent),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.send_rounded,
                              color: colorScheme.onSurfaceVariant),
                          onPressed: () => _search(reset: true),
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ),

                // type + sort bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Row(
                    children: [
                      Expanded(child: _buildTypeDropdown(colorScheme, isDark)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildSortDropdown(colorScheme, isDark)),
                    ],
                  ),
                ),

                // default view when no search has been made
                if (!_isLoading && _movies.isEmpty && _errorMessage == null)
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_favoriteGenre != null) ...[
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Row(
                                children: [
                                  Text(
                                    "Guess Your Favourite Category: ",
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      String searchKey = _favoriteGenre!;
                                      if (searchKey == "Sci-Fi" ||
                                          searchKey == "Science Fiction") {
                                        searchKey = "Fiction";
                                      }
                                      final categoryMovies = MovieCategoryData
                                          .categories[searchKey];
                                      if (categoryMovies != null &&
                                          categoryMovies.isNotEmpty) {
                                        final randomMovie =
                                            (List.from(categoryMovies)
                                                  ..shuffle())
                                                .first;
                                        _controller.text =
                                            randomMovie['title']!;
                                      }
                                      _search(reset: true);
                                    },
                                    child: Text(
                                      _favoriteGenre!,
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                          const SizedBox(height: 40),
                          Text(
                            "Browse Categories",
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 15),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount:
                                MediaQuery.of(context).size.width > 600 ? 3 : 2,
                            childAspectRatio: 2.5,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            children: [
                              _buildCategoryCard(
                                  "Action", Colors.orangeAccent, isDark),
                              _buildCategoryCard(
                                  "Fiction", Colors.blueAccent, isDark),
                              _buildCategoryCard(
                                  "Horror", Colors.redAccent, isDark),
                              _buildCategoryCard(
                                  "Comedy", Colors.greenAccent, isDark),
                              _buildCategoryCard(
                                  "Drama", Colors.yellowAccent, isDark),
                              _buildCategoryCard(
                                  "Romance", Colors.purpleAccent, isDark),
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),

                // loading indicator for fetch
                if (_isLoading)
                  Expanded(
                    child: Center(
                      child:
                          CircularProgressIndicator(color: colorScheme.primary),
                    ),
                  ),

                // error message
                if (_errorMessage != null)
                  Expanded(
                    child: Center(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                  ),

                // results
                if (showingResults)
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _movies.length,
                      itemBuilder: (context, index) {
                        return _buildMovieCard(_movies[index], colorScheme);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeDropdown(ColorScheme cs, bool isDark) {
    return _pillDropdown<SearchType>(
      cs: cs,
      isDark: isDark,
      value: _type,
      icon: Icons.category_outlined,
      items: const [
        DropdownMenuItem(value: SearchType.movie, child: Text("Movie")),
        DropdownMenuItem(value: SearchType.tv, child: Text("TV")),
        DropdownMenuItem(value: SearchType.all, child: Text("All")),
      ],
      onChanged: _onTypeChanged,
    );
  }

  Widget _buildSortDropdown(ColorScheme cs, bool isDark) {
    return _pillDropdown<SortMode>(
      cs: cs,
      isDark: isDark,
      value: _sort,
      icon: Icons.sort_rounded,
      items: const [
        DropdownMenuItem(value: SortMode.relevance, child: Text("Relevance")),
        DropdownMenuItem(
            value: SortMode.popularityDesc, child: Text("Popularity")),
        DropdownMenuItem(value: SortMode.ratingDesc, child: Text("Rating")),
        DropdownMenuItem(value: SortMode.newest, child: Text("Newest")),
        DropdownMenuItem(value: SortMode.oldest, child: Text("Oldest")),
        DropdownMenuItem(value: SortMode.titleAsc, child: Text("Title A-Z")),
      ],
      onChanged: _onSortChanged,
    );
  }

  Widget _pillDropdown<T>({
    required ColorScheme cs,
    required bool isDark,
    required T value,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: cs.onSurfaceVariant, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                isExpanded: true,
                value: value,
                dropdownColor: cs.surface,
                iconEnabledColor: cs.onSurfaceVariant,
                items: items,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // movie/tv card widget
  Widget _buildMovieCard(dynamic movie, ColorScheme colorScheme) {
    final mediaType = _inferMediaType(movie); // 'movie' or 'tv'
    final String title = _titleOf(movie);
    final int yearInt = _yearOf(movie);
    final String year = yearInt == 0 ? "N/A" : yearInt.toString();
    final String? posterPath = movie["poster_path"];

    final rating = _ratingOf(movie); // TMDb vote_average (0..10)
    final popularity = _popularityOf(movie);

    return GestureDetector(
      onTap: () async {
        final int tmdbId = (movie["id"] is int) ? movie["id"] as int : -1;

        String? imdbId;
        if (tmdbId > 0) {
          if (mediaType == 'tv') {
            imdbId = await _tmdbService.getImdbIdByTvTmdbId(tmdbId);
          } else {
            imdbId = await _tmdbService.getImdbIdByTmdbId(tmdbId);
          }
        }

        final formattedMovie = {
          "Title": title,
          "Year": year,
          "Poster": posterPath != null
              ? "https://image.tmdb.org/t/p/w500$posterPath"
              : null,
          "Plot": movie["overview"] ?? "No summary available.",
          "imdbID": imdbId ?? "",
          "imdbRating": rating == 0 ? null : rating.toString(),
        };

        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MovieDetailPage(movie: formattedMovie),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 126,
        decoration: BoxDecoration(
          color: colorScheme.onSurfaceVariant.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(12)),
              child: posterPath != null
                  ? Image.network(
                      "https://image.tmdb.org/t/p/w185$posterPath",
                      width: 85,
                      height: 126,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 85,
                      height: 126,
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(Icons.movie,
                          color: colorScheme.onSurfaceVariant),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: colorScheme.primary.withOpacity(0.12),
                            border: Border.all(
                                color: colorScheme.primary.withOpacity(0.25)),
                          ),
                          child: Text(
                            mediaType.toUpperCase(),
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          year,
                          style: TextStyle(
                            color:
                                colorScheme.onSurfaceVariant.withOpacity(0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Fixed overflow
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),
                    Text(
                      "★ ${rating.toStringAsFixed(1)}   •   Pop ${popularity.toStringAsFixed(0)}",
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.75),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, Color color, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryDetailPage(category: title),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.4), color.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
