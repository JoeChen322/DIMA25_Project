import 'package:flutter/material.dart';
import '../services/tmdb_api.dart';
import 'movie_detail.dart';

class ClassicsPage extends StatefulWidget {
  const ClassicsPage({super.key});

  @override
  State<ClassicsPage> createState() => _ClassicsPageState();
}

class _ClassicsPageState extends State<ClassicsPage> {
  final TmdbService _tmdbService = TmdbService(
    'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJlNWUxYTU5ODc0YzMwZDlmMWM2NTJlYjllZDQ4MmMzMyIsIm5iZiI6MTc2NjQzOTY0Mi40NTIsInN1YiI6IjY5NDliYWRhNTNhODI1Nzk1YzE1NTk5OCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.V0Z-rlGFtBKfCUHFx3nNnqxVNoJ-T3YNVDF8URfMj4U',
  );

  final ScrollController _scrollController = ScrollController();

  List<dynamic> _topMovies = [];
  bool _isLoading = true; // first page
  bool _isPaging = false; // load more
  bool _hasMore = true;

  int _page = 1;

  bool _showBackToTop = false;

  static const int _maxItems = 100; // keep “Top 100” behavior

  @override
  void initState() {
    super.initState();
    _fetchInitial();

    _scrollController.addListener(() {
      final shouldShow = _scrollController.hasClients &&
          _scrollController.offset > 520 &&
          _topMovies.isNotEmpty;
      if (shouldShow != _showBackToTop) {
        setState(() => _showBackToTop = shouldShow);
      }
    });
  }

  Future<void> _fetchInitial() async {
    setState(() {
      _isLoading = true;
      _isPaging = false;
      _hasMore = true;
      _page = 1;
      _topMovies = [];
      _showBackToTop = false;
    });

    try {
      final movies = await _tmdbService.getTopRatedMovies(page: 1);

      if (!mounted) return;

      final list = List<dynamic>.from(movies);
      final capped =
          list.length > _maxItems ? list.take(_maxItems).toList() : list;

      setState(() {
        _topMovies = capped;
        _isLoading = false;
        _hasMore = capped.isNotEmpty && capped.length < _maxItems;
      });
    } catch (e) {
      debugPrint("fail: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || _isPaging || !_hasMore) return;

    setState(() => _isPaging = true);

    try {
      final nextPage = _page + 1;
      final movies = await _tmdbService.getTopRatedMovies(page: nextPage);

      if (!mounted) return;

      if (movies.isEmpty) {
        setState(() {
          _isPaging = false;
          _hasMore = false;
        });
        return;
      }

      final merged = List<dynamic>.from(_topMovies)..addAll(movies);

      // cap to Top 50
      final capped =
          merged.length > _maxItems ? merged.take(_maxItems).toList() : merged;

      setState(() {
        _page = nextPage;
        _topMovies = capped;
        _isPaging = false;
        _hasMore = capped.length < _maxItems;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPaging = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load more.")),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
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
      appBar: AppBar(
        title: Text(
          "IMDb Top 100",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.15)
                    : Colors.black.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: colorScheme.onSurface,
                size: 18,
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.deepPurpleAccent),
            )
          : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _topMovies.length + 1,
              itemBuilder: (context, index) {
                if (index < _topMovies.length) {
                  final movie = _topMovies[index];
                  return _buildMovieItem(
                    movie,
                    index + 1,
                    colorScheme,
                    isDark,
                  );
                }
                return _buildFooter(colorScheme);
              },
            ),
    );
  }

  Widget _buildFooter(ColorScheme colorScheme) {
    if (_isPaging) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              "Loading more...",
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    if (_hasMore) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 24),
        child: Center(
          child: ElevatedButton.icon(
            onPressed: _loadMore,
            icon: const Icon(Icons.add),
            label: const Text("Load more"),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 28),
      child: Center(
        child: Text(
          "No more results",
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }

  Widget _buildMovieItem(
    dynamic movie,
    int rank,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        final formattedMovie = {
          "Title": movie["title"] ?? "Unknown Title",
          "Year": (movie["release_date"] != null &&
                  movie["release_date"].toString().length >= 4)
              ? movie["release_date"].split('-')[0]
              : "N/A",
          "Poster": movie['poster_path'] != null
              ? "https://image.tmdb.org/t/p/w500${movie['poster_path']}"
              : "https://via.placeholder.com/500x750?text=No+Poster",
          "Plot": movie["overview"] ?? "No plot description available.",
          "imdbRating": movie["vote_average"]?.toString() ?? "N/A",
          "imdbID": movie["id"].toString(),
          "Type": "movie",
        };

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MovieDetailPage(movie: formattedMovie),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(
                "#$rank",
                style: const TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                movie['poster_path'] != null
                    ? "https://image.tmdb.org/t/p/w92${movie['poster_path']}"
                    : "https://via.placeholder.com/92x138?text=No+Image",
                width: 60,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 60,
                  height: 90,
                  color: colorScheme.surfaceContainerHighest,
                  child: Icon(Icons.movie, color: colorScheme.onSurfaceVariant),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie["title"] ?? "Unknown",
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    (movie["release_date"] != null &&
                            movie["release_date"].toString().length >= 4)
                        ? movie["release_date"].split('-')[0]
                        : "N/A",
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: colorScheme.onSurfaceVariant.withOpacity(0.3),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
